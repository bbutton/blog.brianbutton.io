---
title: Whidbey System.Configuration, the Principle of Least Surprise, and a dash of TDD
author: Brian Button
type: post
date: 2005-06-11T19:59:00+00:00
url: /index.php/2005/06/11/whidbey-system-configuration-the-principle-of-least-surprise-and-a-dash-of-tdd/
sfw_comment_form_password:
  - HclmRAOCsg88
sfw_pwd:
  - 1qJibJye5qHK
categories:
  - 111
  - 112
  - 115

---
What in the world do these three topics have in common??? I would have thought nothing until yesterday. But then I learned better&hellip;

**The Principle of Least Surprise**

Do me a favor, really quickly. Google &ldquo;[Principle of Least Surprise][1]&rdquo;. Back already? Good. It sure seems like there are a lot of folks out there who are pretty hot on using software that does what they expect it to do. And doing something unexpected, like making Ctrl-Q quit your program instead of ending macro recording, makes some folks pretty angry.

I&rsquo;m a pretty firm believer in this principle as well. I believe that well designed software should do the most expected thing at all times, and never, ever surprise me.

**Whidbey System.Configuration**

And then yesterday, I started playing around with System.Configuration in Visual Studio 2005, and found the Principle of Least Surprise had become more of a guideline than a rule (paraphrase of a movie quote &mdash; anyone recognize its original genesis??? Think Bill Murray, Dan Akroyd, Harold Ramis).

I wrote these tests, each of which I think has a reasonable expectation of passing:

<pre>[TestClass]
    public class RawConstructionFixture
    {
        [TestMethod]
        public void CanBeConstructedFromSingleArgumentConstructor()
        {
            SettingsStore settingsStore = new SettingsStore("foo");
            Assert.AreEqual&lt;string>("foo", settingsStore.Name);
        }

        [TestMethod, ExpectedException(typeof(ConfigurationErrorsException))]
        public void CannotRetrieveValueIfItIsInvalid()
        {
            SettingsStore settingsStore = new SettingsStore();
            Assert.IsNull(settingsStore.Name);
        }

        [TestMethod]
        public void CanSetValueInCodeBeforeGettingAndGetValueBackOut()
        {
            SettingsStore settingsStore = new SettingsStore();
            settingsStore.Name = "foo";

            Assert.AreEqual&lt;string>("foo", settingsStore.Name);
        }
    }</pre>

and here is the class under test:

<pre>public class SettingsStore : ConfigurationElement
    {
        public SettingsStore()
        {
        }

        public SettingsStore(string name)
        {
            this["name"] = name;
        }

        [ConfigurationProperty("name")]
        [StringValidator(MinLength = 1)]
        public string Name
        {
            get
            {
                return (string)this["name"];
            }
            set
            {
                this["name"] = value;
            }
        }
    }</pre>

This seems like a pretty simple class. The only things to note about it are that it derives from ConfigurationElement, which is what ties it into the System.Configuration system, and that the Name property has two attributes on it. Of these two attributes, it is the StringValidatorAttribute that we are particularly interested in.

**Expected Principle of Least Surprise Behavior**

Let&rsquo;s look at each of these tests individually and discuss my expectations, and later we&rsquo;ll talk about what actually happened. And at the very end, we&rsquo;ll talk about the effect of this on being able to write code through TDD that uses any configuration information with validations at all.

So, our first test, <font face="Courier New">CanBeConstructedFromSingleArgumentConstructor</font>, seems pretty simple. I expect to be able to construct a class and initialize its members in the constructor. After all, that&rsquo;s how objects work. The field being initialized in the constructor is Name, which is defined in the SettingsStore class as a string, with a validator that enforces the constraint that any value that Name ever holds will be at least one character long. No problem, I think to myself. I&rsquo;m initializing Name to &ldquo;foo&rdquo;, which is certainly more than one character long. This test should really, really pass. If it doesn&rsquo;t, I think I would be Surprised.

In the second test, <font face="Courier New">CannotRetrieveValueIfItIsInvalid</font>, I create the object using the default constructor and try to access its value before it is initialized. There is a bit of an argument here about what the least surprising behavior would be. My partner thinks it should return NULL, and I think that getting its value at this point would violate the constraint, and an exception should be thrown. He eventually acquiesced to me, and I wrote the test as you see. This seems reasonable to me. Yea!

Finally, in the third test, <font face="courier new">CanSetValueInCodeBeforeGettingAndGetValueBackOut,</font>I instantiate the object using the default constructor and properly initialize the value to something reasonable, &ldquo;foo&rdquo;, which satisfies the length constraint. I then try to assert that the value&nbsp;I set actually was set. I fully and completely expect this test to pass, as would anyone else, I believe.

**What _Really_ Happened**

The first and third tests failed.

In each case, the test failed on the line where I attempted to assign a value to the Name property. Here is the first part of the stack trace:

_TestCase &#8221; failed: Test method ConfigurationAttributeSpike.RawConstructionFixture.CanBeConstructedFromSingleArgumentConstructor threw exception:&nbsp; System.Configuration.ConfigurationErrorsException: The value for the property &#8216;name&#8217; is not valid. The error is: The string must be at least 1 characters long..  
&nbsp;at System.Configuration.ConfigurationProperty.Validate(Object value)  
&nbsp;at System.Configuration.ConfigurationProperty.SetDefaultValue(Object value)  
&nbsp;at System.Configuration.ConfigurationProperty.InitDefaultValueFromTypeInfo(ConfigurationPropertyAttribute attribProperty, DefaultValueAttribute attribStdDefault)_

What it looks like is happening is that at construction, ConfigurationElement, our base class, initializes all properties attributed with ConfigurationPropertyAttribute to some default value. We have the ability to provide a default value as another field to ConfigurationPropertyAttribute, which will get used. But if we don&rsquo;t, ConfigurationElement provides its own. It then, if there are any validations for that field,&nbsp;validates this value against any sort of constraint that has been applied to the property under question. If you don&rsquo;t provide a default value, one is chosen for you, and the validation is done against that value.

The interesting problem that comes up is what happens when the default value that is chosen for you is invalid according to your constraints. This is the situation my tests are in. I have no earthly idea what a good default value would be, so I don&rsquo;t set one. But not setting one leads me down the road of having these tests not work. Quite a quandry 🙂

And this is the crux of my issue. If you have any validation at all on your configuration classes, your ability to instantiate them outside the framework seems to be greatly compromised. It seems you need to provide a valid default value for them, even in those cases (most case?) where there is no default that makes sense.

**What This Means for TDD**

When writing code in a TDD style, your tests/examples are much easier to read and understand if everything you need to know is right there in your tests. If you can find a way to put all your data, all your behavior, and all your asserts into a single place, each test begins to stand alone. I believe that this makes it serve its many purposes as a unit test better.

Given that I can&rsquo;t seem to instantiate a ConfigurationElement that has any validations but has no default values in any way other than having its data reside in an actual XML configuration file, I don&rsquo;t think I can fulfill my initial goal of having everything in one place. I&rsquo;m not at all sure how prevelant ConfigurationElements that have validations but no default values are, but it seems like a fairly routine thing to have to me. And in these cases, I&rsquo;m going to have to externalize my configuration, possibly many times to account for all the different test cases I&rsquo;m going to want to create.

**Am I Just Whining?**

Probably. That&rsquo;s what my wife says I do best 🙂

Looking back over what I wrote, I have to wonder if you think I&rsquo;m doing more whining about something that is making my life marginally harder 🙂 Well, maybe I am! But this one thing seems like it would be so easy to fix, and would make my tests that involve configuration so much easier to write and understand. I&rsquo;m a little shy about relying on configuration files for my unit testing, as we incrementally went down that road in Enterprise Library, and it ended up making things very difficult. Tests became very hard to write because you first had to find the right configuration file, and then create or modify it. It became _really_ hard to inject mock objects, because they had to be created by the configuration system, which meant defining them in configuration files, which made them a pain to use and instantiate. Things would have been much easier if the configuration system and the application logic would have been kept separate!

OK, I take back what I said before &mdash; it is _not_ just whining &mdash; it is the Voice of Experience speaking. Having to work with configuration files in your unit tests is a _royal PITA_ and should be avoided at all costs. I really think this surprising behavior of these objects should be fixed.

I&rsquo;m planning on filing a bug on this through MSDN, and if you agree that it&rsquo;s a problem, please vote for that bug. I&rsquo;ll post the link as soon as I have it.

**UPDATE &mdash;&nbsp;**Here is the link to the bug:&nbsp;[FDBK29746][2]. Vote away!!

&mdash; bab

 [1]: http://www.google.com/search?hl=en&q=principle+of+least+surprise&btnG=Google+Search
 [2]: http://lab.msdn.microsoft.com/ProductFeedback/viewfeedback.aspx?feedbackid=2e8b3699-0288-4756-bba6-227bce82b9e1