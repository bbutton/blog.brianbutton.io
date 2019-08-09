---
title: Enterprise Library and Object Builder
author: Brian Button
type: post
date: 2006-01-03T14:37:00+00:00
url: /index.php/2006/01/03/enterprise-library-and-object-builder/
sfw_comment_form_password:
  - qgngsA6C1Pko
sfw_pwd:
  - EQNUx0us2ZPR
categories:
  - 115

---
One of the biggest areas of change between this new version of Enterprise Library and the original version, shipped a year ago, is our configuration system. The original configuration system, written (and rewritten 3x) by Scott Densmore, worked tremendously well, but was custom-written just for Enterprise Library. In our newer version, we&rsquo;ve adopted a more reusable framework on which to base our configuration system. This framework, called Object Builder, is a reusable, configurable dependency injection and object creation pipeline written as part of the CAB project by [Peter Provost][1] and [Brad Wilson][2], with lots of goals donated by [Ed Jezierski][3]. As part of our code reuse initiative, we decided it would be a good idea if both CAB and Enterprise Library could ship with a similar underlying infrastructure, just so we have a better common story to tell between the two projects.

**Brief discussion of what Object Builder is**

Object Builder (OB) is, as I mentioned previously, is basically a pipeline that allows you to customize how an object is created. You talk to it by saying something like:

&nbsp;&nbsp;&nbsp; <font face="Courier New">MyFoo foo = ObjectBuilder.BuildUp<MyFoo>(&ldquo;FooInstanceName&rdquo;);</font>

Looks really simple, right? Well, what actually happens during that call can be changed, and tailored, and twisted to be almost anything you want. The creational process through OB can be customized by registering Strategies with your OB instance. These Strategies customize the trip through the pipeline by adding steps to your object&rsquo;s journey. Strategies are added into different _phases_ of creation, including PreCreation, Creation, Initialization, and PostInitialization, based on how you add them to OB, depending on when your particular operation needs to happen. For Enterprise Library&rsquo;s purposes, for instance, we have several steps that take place during PreCreation, a Creation strategy, and a PostCreation strategy that all happen while building objects, and we add the strategies responsible for implementing them to our own OB instance in a class called EnterpriseLibraryFactory.

Each Strategy that is registered with OB can gather information and context at runtime, when it is invoked, by querying any one of several Policy instances that can be associated with a particular Strategy. You can use this to use the same Strategy for several purposes, and inform the Strategy about the details of its purpose using a Policy at runtime.

**Enterprise Library and its factories**

There are two basic kinds of blocks in Enterprise Library, characterized by how you create them. There are those blocks where the caller explicitly instantiates the block and makes calls to it. For example, when you want to make a database call, you talk to the DatabaseFactory and ask for a specific Database instance, as

&nbsp;&nbsp;&nbsp; <font face="courier new">Database db&nbsp;= DatabaseFactory.CreateDatabase(&ldquo;Sales&rdquo;);</font>

Caching, Data Access, Security, and Cryptography each work this way, and we&rsquo;ll call these instance-based blocks for our purposes in this article. Each of these blocks provides a static factory class that can be used to create instances of the block, as shown above. These static factories don&rsquo;t do much work themselves, but only serve as a convenience for our callers. The actual work of orchestrating the creation of our objects happens in the instance factories called from their static brethren.

There are also other blocks that are accessed exclusively through static instances. Logging and Exception Handling both work this way. When you want to log a message, you don&rsquo;t have to create an instance of the Logging block and then call Write. Instead, you talk to a single, global instance of the Logger, as

&nbsp;&nbsp;&nbsp; <font face="courier new">Logger.Write(&ldquo;My message&rdquo;);</font>

We&rsquo;ll call these facade-based blocks in this article, for our convenience. Now, what you may not know is that inside facade-based blocks, there are still objects that are created for each call to the block. These per-call objects are created through instance-based factories as described above, which allows me to explain our creation process one time and have it apply to all blocks (lucky for me!).

And now that I&rsquo;ve made the case for how each of the blocks shares many similar aspects as far as how they create their objects through these instance-based factories, let me just add that these factories don&rsquo;t really do very much. Their only real responsibilities are to act as an adapter layer between the static facades of each of the blocks and the underlying generic interfaces of Object Builder. These instance factories basically just allow us to put a type onto the object that gets created through OB, and that&rsquo;s about where their job ends. The really interesting stuff happens in how Enterprise Library uses Object Builder, and that&rsquo;s what the rest of this article is about.

**How Enterprise Library uses Object Builder**

Enterprise Library has a few interesting requirements for how we build our objects that were interesting to implement. I didn&rsquo;t do most of the heavy lifting on this &mdash; it was done in large part by Fernando Simonazzi of Clarius. Fernando went through several iterations of his implementation until we could find something that both made sense and was performant enough for us to accept.

The two biggest issues we had in adopting OB for our own were that we needed didn&rsquo;t always know the exact type of the object we were trying to create (SqlDatabase versus OracleDatabase, for example),&nbsp;and we needed to drive all of our creation through configuration. Neither of these requirements were directly implemented in OB, so we had to write our own strategies to get them to happen. These strategies allowed us create our objects using code that looked like

&nbsp;&nbsp;&nbsp; <font face="courier new">Database db = DatabaseFactory.CreateDatabase();</font>

In that seemingly simple line of code, lots of things had to happen to give you back to exact type and specific instance of a database that was needed.

In a nutshell, these are the steps we needed.&nbsp;Don&rsquo;t worry if these steps aren&rsquo;t clear now &mdash; I&rsquo;ll be explaining them in detail immediately afterwards.&nbsp;

  1. Determine the name of the instance to construct. Users can either provide the instance name to us, or they can tell us to create the _default_ instance, which requires some work on our part to find the correct instance name to use.
  2. Figure out if the instance being requested is a singleton or not. If it is a singleton and it has already been created, then just return the already created object, otherwise allow the strategy chain to proceed.
  3. Take the instance name we&rsquo;ve discovered and create an instance of that object, driven through configuration.
  4. Attach any needed instrumentation objects to the freshly created object instance.
  5. Hand the object back to the original caller.

And the biggest design goal we had to keep in mind throughout this process is that we had to make it easy for someone else to come in later, read, and understand how the whole instantiation process happens, and be able to hook their own blocks and providers into it as well. Sounds pretty simple, eh?? What follows is our best shot at fulfilling all these goals. Read on, ask questions, and we&rsquo;ll end up with a pretty good explanation of how it all works by the end.

**Build Steps**

_Determining the name of default instances_

As I said before, many of our blocks allow users to define a default instance of a block. This is what lets you ask for an instance of the Caching block, for example, without needing to specify that named instance to create. But for us to instantiate your CacheManager object, we have to figure out what name you assigned as the default. Conveniently for us, this is defined in your configuration file, as

<font face="courier new">&nbsp;<cachingConfiguration defaultCacheManager=&#8221;ReferenceData&#8221;><br />&nbsp;</cachingConfiguration></font>

This is where our first custom strategy comes in. ConfigurationNameMappingStrategy is responsible for&nbsp;translating from the empty instance name and a configuration file to the appropriate default instance name. Now it can&rsquo;t do this on its own, since it doesn&rsquo;t know how each block&rsquo;s configuration section looks, so it needs some help. It gets this help by looking at the class being created for a specific attribute, the ConfigurationNameMapperAttribute, that describes a helper class that can parse the configuration and can figure out the name of the default instance. Here, the ConfigurationNameMapperAttribute is shown on the CacheManager, pointing to the type CacheManagerDataRetriever. 

<pre>[ConfigurationNameMapper(typeof(CacheManagerDataRetriever))]
    public class CacheManager : IDisposable
    {
    }</pre>

DataRetrievers are a category of objects we&rsquo;ve created as helpers whenever we need to read some sort of configuration information. In this case. the CacheManagerDataRetriever implements IConfigurationNameMapper, whose responsibility it is to know how to read a configuration section, parse it, and return the default instance name.

The ConfigurationNameMappingStrategy knows the type of the object it is being asked to create,&nbsp;uses this type to reflect and find the ConfigurationNameMapperAttribute, instantiates an object of this type, reads the default instance name, and uses that to drive the rest of the creation process. And that&rsquo;s all there is to it&nbsp;![][4]&nbsp;

_Looking for singletons_

Most of our classes in Enterprise Library are instantiated as they are needed. But for some objects, for various reasons, we don&rsquo;t create a new instance each time. The Caching block, for example,&nbsp;needs to reuse the same CacheManager instance each time, so that it can keep the in-memory and on-disk representations of the cache consistent between different cache invocations. And other blocks, such as Exception Handling, reuse the same set of objects each time to save the instantiation cost, since it is very expensive to create all the configuration objects this&nbsp;block needs.

The way that this is managed in Enterprise Library is by asking OB to remember instances of certain blocks for us. When we ask OB to create instances of those blocks for us, it first checks to see if it already has an instance lying around with&nbsp;the appropriate name for us. If so, it hands that instance back to us, otherwise, it creates a new instance, caches it, and returns it.

The way OB can tell whether or not to treat an instance of a singleton or not is through ObjectBuilder concepts called Locators and LifetimeContainers. LifetimeContainers, in OB-speak, manage the lifetime of named instances of objects. You can register an object and its name with a LifetimeContainer, and it will keep that object alive until such time as you dispose of the LifetimeContainer. And every&nbsp;LifetimeContainer&nbsp;is associated with a Locator. A Locator acts as a dictionary that maps instance names to objects, but it does it using WeakReferences &mdash; this means that storing something in a Locator will not prevent that object from being GCed. Tot keep an object alive, you need to provide the LifetimeContainer as well, which is what keeps the references in use, preventing the object from being scavenging out of existence.

There is very little custom code that we had to write in Enterprise Library to implement this singleton ability, as Object Builder had it most of it built in. All we needed to do was to have the instance-based factories&nbsp;that wanted this functionality inherit from LocatorNameTypeFactoryBase<T>, a type we wrote for Enterprise Library. This base class created a ReadWriteLocator, for object lookups, and a LifetimeContainer, to provide for the persistence of the objects, and ensured that these infrastructure objects were used whenever we used OB to instantiate our objects. All of this magic is hidden from our callers. 

Here is the CacheManagerFactory, as an example:

<pre>public class CacheManagerFactory : LocatorNameTypeFactoryBase&lt;CacheManager&gt;
    {
        /// &lt;summary>
        /// &lt;para>Initializes a new instance of the &lt;see cref="CacheManagerFactory" /> class 
        /// with the default configuration source.&lt;/para>
        /// &lt;/summary>
        protected CacheManagerFactory()
            : base()
        {
        }
 
        /// &lt;summary>
        /// &lt;para>Initializes a new instance of the &lt;see cref="CacheManagerFactory" /> class 
        /// with the given configuration source.&lt;/para>
        /// &lt;/summary>
             /// 
        public CacheManagerFactory(IConfigurationSource configurationSource)
            : base(configurationSource)
        { }
    }</pre>

As you can see, the base class contains all the singleton-related magic, which we can access just by inheriting from the base class I described. 

_Instantiating the object_

OK, now that the preliminaries are out of the way, we&rsquo;re ready for the really interesting, and slightly complicated, part of this &mdash; actually instantiating the object. This is where we&nbsp;take the configuration data, metadata available through attributes, and other custom code, shake them up, and spit out the object we want. Hold on tight, because there are a few different steps that have to happen here, and each of them has to happen just right for our object to be created.

&nbsp;It all starts with the ConfiguredObjectStrategy, which is one of the strategies we plug into OB as a PreCreation strategy. All this strategy does is to look for the object type being instantiated, retrieve a custom-built factory that knows how to instantiate an object of that type, and make a call to that factory. It figures out the kind of custom factory to use by using the CustomFactoryAttribute placed on the class being instantiated:

<pre>[CustomFactory(typeof(CacheManagerCustomFactory))]
    public class CacheManager : IDisposable
    {
    }
</pre>

_Note: Sharp readers will have noticed that the CacheManager is attributed with two different attributes, each used during different phases of object creation. The ConfigurationNameMapperAttribute is used to figure out the default instance name for a block, and the CustomFactoryAttribute describes how to instantiate block instances._

The ConfiguredObjectStrategy instantiates this factory, and delegates the responsibility of orchestrating the creation of&nbsp;the requested object to it.

Inside of all of these factories, the same set of core things happens. 

  1. Each custom factory knows which configuration class contains the configuration information. This is generally hardcoded in each custom factory, since that factory knows which configuration classes that it needs to create the objects it is responsible for. It also knows how to read the given configuration information to create an instance of its configuration class.
  2. Inspects the configuration class to find the Assembler that is used actually construct the final object. Assemblers have the responsibility of instantiating the final object being created. They are hardcoded classes that know the types of objects they&rsquo;re going to create, know how to call the constructor of that class, and do any extra work needed to initialize that object before returning it.

Again, most of this logic is contained in base classes we&rsquo;ve provided. Here we see the SymmetricCryptoProviderCustomFactory which is responsible for creating your symmetric cryptographic provider. It has almost no code in it, as it inherits its functionality from its bases:

<pre>public class SymmetricCryptoProviderCustomFactory : AssemblerBasedCustomFactory&lt;ISymmetricCryptoProvider, SymmetricProviderData&gt;
    {
        protected override SymmetricProviderData GetConfiguration(string name, IConfigurationSource configurationSource)
        {
            return new CryptographyConfigurationView(configurationSource).GetSymetricCryptoProviderData(name);
        }
    }</pre>

&nbsp;And in its base class, AssemblyerBasedCustomFactory, we add the Create call:

<pre>public abstract class AssemblerBasedCustomFactory&lt;TObject, TConfiguration&gt; : AssemblerBasedObjectFactory&lt;TObject, TConfiguration&gt;, ICustomFactory
        where TObject : class
        where TConfiguration : class
    {
        public TObject Create(IBuilderContext context, string name, IConfigurationSource configurationSource, ConfigurationReflectionCache reflectionCache)
        {
            TConfiguration objectConfiguration = GetConfiguration(name, configurationSource);
            TObject createdObject = Create(context, objectConfiguration, configurationSource, reflectionCache);

            return createdObject;
        }

        protected abstract TConfiguration GetConfiguration(string name, IConfigurationSource configurationSource);
    }</pre>

And its base class adds the algorithm to actually cause the instantiations to happen:

<pre>public abstract class AssemblerBasedObjectFactory&lt;TObject, TConfiguration&gt;
        where TObject : class
        where TConfiguration : class
    {
        public virtual TObject Create(IBuilderContext context, TConfiguration objectConfiguration, IConfigurationSource configurationSource, ConfigurationReflectionCache reflectionCache)
        {
            IAssembler&lt;TObject, TConfiguration&gt; assembler = GetAssembler(objectConfiguration);
            TObject createdObject = assembler.Assemble(context, objectConfiguration, configurationSource, reflectionCache);

            return createdObject;
        }

        private IAssembler&lt;TObject, TConfiguration&gt; GetAssembler(TConfiguration objectConfiguration)
        {
            Type type = objectConfiguration.GetType();
            AssemblerAttribute assemblerAttribute = GetAssemblerAttribute(type);

            return (IAssembler&lt;TObject, TConfiguration&gt;)Activator.CreateInstance(assemblerAttribute.AssemblerType);
        }

        private AssemblerAttribute GetAssemblerAttribute(Type type)
        {
            AssemblerAttribute assemblerAttribute 
                = Attribute.GetCustomAttribute(type, typeof(AssemblerAttribute)) as AssemblerAttribute;
            return assemblerAttribute;
        }
    }</pre>

&nbsp;And finally, the last link in the chain, an Assembler implementation:

<pre>public class SymmetricAlgorithmProviderAssembler : IAssembler&lt;ISymmetricCryptoProvider, SymmetricProviderData&gt;
    {
        public ISymmetricCryptoProvider Assemble(IBuilderContext context, SymmetricProviderData objectConfiguration, IConfigurationSource configurationSource, ConfigurationReflectionCache reflectionCache)
        {
            SymmetricAlgorithmProviderData castedObjectConfiguration
                = (SymmetricAlgorithmProviderData)objectConfiguration;

            ISymmetricCryptoProvider createdObject
                = new SymmetricAlgorithmProvider(
                        castedObjectConfiguration.AlgorithmType,
                        castedObjectConfiguration.ProtectedKeyFilename,
                        castedObjectConfiguration.ProtectedKeyProtectionScope);

            return createdObject;
        }
    }
</pre>

_Attaching Instrumentation_

The final step in this process is to attach any needed instrumentation to the objects just created. This is a completly separate process from object instantiation and deserves an entire post of its own, which is what I&rsquo;m going to do. My next post will be about how instrumentation in Enterprise Library works, how it is instantiated, and attached to the objects it is observing. It is completely different from the original implementation, with the intent to allow it to be turned on and off through configuration, and to allow instrumentation handling code to be kept separate from instrumentation reporting code. More on these topics later.

**Things I&rsquo;ve (intentionally) left out**

In the process of explaining this stuff, I&rsquo;ve simplified some concepts along the way. I intend to go back and offer other blog entires on these topics. They are subjects that build on this basic understanding we&rsquo;ve gained from this post, so I wanted to let people read and digest this first before adding new information on top of it.

The first topic I omitted from this post is actually a performance optimization we had to add late in our development cycle. As you can tell, this factory code we created is heavily attribute based, and reading attributes at runtime is really, _really_ slow. We had our entire system created and working, profiled it, and found out that we were several times slower than our 1.0 and 1.1 releases, which is obviously not acceptable. Fernando implemented a system where we cache the objects we instantiate via attribute reflection, so we only have to pay this price one time. This brought our performance up to where we needed it almost completely. But this attribute caching is purely an implementation detail of how the internals work and doesn&rsquo;t affect the overall design much at all (as it should be!).

The other topic I omitted for now is the whole idea of polymorphic configuration and object creation. In lots of places, we know the base type of the object we want to create, but we don&rsquo;t know the actual concrete type. For example, we may know that we need an ISymmetricCryptoProvider, but we don&rsquo;t know if we need a SymmetricCryptoProvider or a DPAPISymmetricCryptoProvider. We can find this out through configuration, but I haven&rsquo;t discussed how that works yet. That, again, is a topic for another post.

**Summary**

This, in its high-level entirety, is the object creation process inside Enterprise Library. We went down this road because we wanted to use Object Builder as the driver for our factories. It is one part experiment and one part an attempt to reuse code and policies inside p&p. I think it worked out rather well, as it gave us a reusable pipeline into which we can inject strategies that govern how our creation process works. We can modify when and where objects are created and bound together without having to go change explicit code for the most part, which is an interesting win for us.

The basics of the whole process start with the block instance factory. These classes call into EnterpriseLibraryFactory, which starts us on our trip through ObjectBuilder. This trip allows us to translate an empty name into a default name, implement a singleton pattern completely external to the object being made into a singleton, and create an object entirely based on configuration. Inside each object being instantiated, there is an attribute that describes the custom mfactory that knows how to build that object. This factory uses the configuration class for the object being built to find the assembler that can create the actual object, instantiates the configuration object and assembler, and tells the assembler to create the final object, and _voila_, we&rsquo;re finished!

**Request for comments**

This is my first attempt at explaining this topic. Its a bit complicated and there is a chance that my explanation may add to some level of confusion. If I&rsquo;ve explained something badly, or you have a question about what I really meant, please ask me. I intend to edit and update this blog posting as I learn more about my feedback, until it actually does explain what I want it to. So, keeps those cards and letters coming!

&mdash; bab

&nbsp;

**Now playing:** AC/DC &#8211; Dirty Deeds Done Dirt Cheap &#8211; Big Balls

**Now playing:** AC/DC &#8211; Dirty Deeds Done Dirt Cheap &#8211; Big Balls

 [1]: http://peterprovost.org/
 [2]: http://www.agileprogrammer.com/dotnetguy
 [3]: http://blogs.msdn.com/edjez
 [4]: http://www.agilestl.com/private/blog/smile1.gif