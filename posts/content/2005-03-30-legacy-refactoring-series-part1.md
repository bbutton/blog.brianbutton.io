---
title: Legacy Refactoring Series – Part1
author: Brian Button
type: post
date: 2005-03-30T21:14:00+00:00
url: /index.php/2005/03/30/legacy-refactoring-series-part1/
sfw_comment_form_password:
  - Z8wQ0CkbWkvz
sfw_pwd:
  - wcgDEbb6ZEf2
categories:
  - Uncategorized

---
As promised, this is the first installment of a series of articles on refactoring a piece of legacy code that I have been given. The purpose of this particular piece of code is to use reflection to find all the types in an assembly, determine the relationships and associations between these types, and spit the resulting model out in XMI. For those of you who are unfamiliar with XMI, as I was/am, it is a standard interchange format that UML tools are supposed to support that allows models built in one tool to be viewed in another tool.

**Current State of Codebase**

In its current state, the codebase is not as healthy as it could be. There are three classes in this system. The first class is the GUI, which is pretty simple and self contained. There might be some logic in it that could be refactored out into a Controller-type class, but I haven&rsquo;t looked at it closely enough yet to know. In the same file as the GUI is the worker method for the thread where all the work happens. Not sure if I like this or not yet, but I&rsquo;ll visit it at some point. There is a class called Assembly2UML which is the main worker class for this tool. This class is responsible for finding all the types and their relationships, and it has one real method in it, Serialize, and its 200 lines long. We&rsquo;ll revisit this Serialize method shortly, as it is our original target for refactoring. Finally, there is another file called XMIServices, which houses both the interface IUMLFormatter and its derived type XMIFormatter. It is the responsibility of this XMIFormatter to be called occasionally from the Serializer to output the growing XMI model as it forms.

That&rsquo;s the basic architecture. As it is, it would be very difficult to test, so I&rsquo;d like to make few minor modifications to let us get it under some very simple tests.

**Why is it hard to get under test?**

I&rsquo;d like to explain why this particular method is difficult to test, and also make a point about how we can design interfaces to make methods more easily testable. In this case, our problem is that the signature of the Serialize method looks like this:

<pre>public bool Serialize(Assembly assembly,SerializationProgressHandler progressHandler)</pre>

The immediate issue with this is that in order to test this beast, we have to pass it an Assembly. This is a pretty high bar for us to get over to let us call this method &mdash; we have to have a compiled assembly on our disk somewhere that has just the right set of classes in it to let us test what we&rsquo;re trying to look at. 

If we look through the code, however, the method doesn&rsquo;t use any fancy features of an assembly. All it does is ask the Assembly for an array of its Types and for its name. If we, perchance, were to pass in the name of the assembly and an array of types, we could avoid having to climb the hurdle of creating special test-only assemblies to allow us to test this method. That would be very cool, and would make our lives easier. 

This leads me to my first point. When you&rsquo;re creating methods in your system, please think about the requirements you&rsquo;re putting on the callers of your methods, and make those requirements as lax as you can. In this case, we had to have an entire Assembly compiled and on disk before we could call this method, where we really only needed an array of types. If this code would have been written in TDD style,. I doubt this situation would have arisen, but it frequently happens in legacy code. We should try to make our methods as easy as possible for others to call, just to make our maintainers&rsquo; lives easier later.

**Our first step**

As Michael Feathers describes in his book, Working Effectively with Legacy Code (WELC), before we can test a method, we have to be able to _sense_ what it does. What Michael means by that is that we have to have something to look at to know if the method does what it is supposed to. That can be a return code from a method, or a side-effect from it touching some other object during its execution. In this case, the authors of the original code gave us our hook for sensing in the IUMLFormatter class. An instance of this class is passed to us upon creation of an Assembly2UML object, so we&rsquo;re all set with our sensor.

Now the one implementation of IUMLFormatter that they provide is a pretty complicated one, the XMIFormatter, and I really don&rsquo;t want to parse through the entire XMI output for a model to know whether or not our method still worked, so I&rsquo;ll probably define a much simpler IUMLFormatter class to use as a sensor in our tests. It&rsquo;ll just make our asserts easier to write and read.

But the first thing to do to make our tests easier to write is to do a simple, safe refactoring to the Serialize method. What we need to do is to create a second Serialize method that is much friendlier toward unit testing. The original method, which is _waaaay_ to long to show you&nbsp; here&nbsp; uses two bits of information out of the Assembly it is passed &mdash; the assembly name and its list of types. So, my first step in making this easier to test is to extract variables out to hold these two values. This way, I only access them once each, and I can use the variables in place of the property call all over the place. This leaves the top of the Serialize method looking like this:

<pre>public bool Serialize(Assembly assembly,SerializationProgressHandler progressHandler)
        {
            string fullName = assembly.FullName;
            Type [] typesInAssembly = assembly.GetTypes();

            int maxBound = typesInAssembly.Length*3;
            int currentProgress = 0;
            if(progressHandler != null)
                if(progressHandler(this,0,maxBound,currentProgress,String.Empty) == ProgressStatus.Abort)
                    return false;
    
            umlFormater.Initialize(fullName);
    
            //Figure out ranges and call on progress
            //First pass through types and create unique namespaces list:
            StringCollection namespacesList = new StringCollection();
            foreach(Type type in typesInAssembly)
            {
                if(!namespacesList.Contains(type.Namespace))
                    namespacesList.Add(type.Namespace);
            }</pre>

Now that I have these variables in place, and I&rsquo;m using them throughout the rest of the method, I can do an ExtractMethod refactoring on everything after those two variable initializations and put them into the Serialize method I really want to test:

<pre>public bool Serialize(Type[] typesInAssembly, SerializationProgressHandler progressHandler, string fullName)
</pre>

And now the old method, in its entirety, looks like this: 

<pre>public bool Serialize(Assembly assembly,SerializationProgressHandler progressHandler)
        {
            string fullName = assembly.FullName;
            Type [] typesInAssembly = assembly.GetTypes();

            return Serialize(typesInAssembly, progressHandler, fullName);
        }
</pre>

And our new method, the one with the Type[] array, is completely and easily testable. Step one accomplished!

**In the next installment**

The next thing we need to do is to start characterizing what this method does with tests. This is another thing out of WELC &mdash; before you can start refactoring or changing what a method does, you have to get it under tests, and this first set of tests serves to characterize the existing&nbsp;behavior of the method. We&rsquo;re going to wrap progressively bigger tests around this method, until we feel that its pretty tightly controlled by these tests. And then we&rsquo;re going to write one more that exposes a bug that I see, recognize, understand, and already know how to fix. But I can&rsquo;t do it until I can extract it out someplace where I can directly sense it, which means we have some refactoring to do first.

Until next time&hellip;

&mdash; bab