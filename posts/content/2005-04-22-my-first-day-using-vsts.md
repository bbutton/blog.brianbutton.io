---
title: My first day using VSTS
author: Brian Button
type: post
date: 2005-04-22T16:36:00+00:00
url: /index.php/2005/04/22/my-first-day-using-vsts/
sfw_comment_form_password:
  - 1NOOnGwAR50v
sfw_pwd:
  - Dz5ITx9hRyeS
categories:
  - 111
  - 112
  - 115

---
My group at MS is considering changing over to using the new unit testing stuff built into the newest version of Visual Studio, so I decided to give it a try. I&rsquo;ll be keeping a diary of how things go today, and hopefully I&rsquo;ll learn something interesting.

The first thing I&rsquo;ve learned is that I can&rsquo;t wait for the ReSharper EAP ![][1]&nbsp;I need the navigation and refactoring tools I get with that. Boy I miss them in Whidbey&hellip;

So, on to the show!

**How does this thing work?**

I have no idea how it works. I know how NUnit works. I know how JUnit works. I don&rsquo;t know how this works. Google, however, pointed me to here: <http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dnvs05/html/vstsunittesting.asp>. In this link, the author explains how to create, run, and manage tests. Read it before you go on.

**My first test**

I&rsquo;m rewriting the instrumentation stuff that goes along inside Enterprise Library. The first version of it didn&rsquo;t do everything that we wanted, so I volunteered to rewrite it to make it more OO, more easily separable from the calling code, and hopefully able to be driven from configuration. I&rsquo;m not sure how I&rsquo;m going to do any of those things yet, so I plan to play around and learn how to do it today.

So, my first learning is that there are things called test projects, and they have some sort of relationship to your regular projects. There is a wizard to create them, which means I don&rsquo;t have to. We&rsquo;ll see if I like that or not &mdash; I&rsquo;m generally not a wizard fan. And it turns out that you don&rsquo;t need to use the wizard to create these things. You can just do a regular Add Project and choose Testing Project. The nice part about working with a TestingProject is that you get some additional choices on the Add menu &mdash; things like adding new tests of various kinds. In fact, I just did that, and I appear to have broken the IDE.&nbsp;It locked up, and it is currently using 99% of my CPU. Thus is the way of beta software&hellip;

So, restarting&hellip; Doh! It came back just as I was about to kill it&hellip;

So, saying Add New Test brings up a dialog where you can choose the kind of test you want to add. There are generic tests, load tests, manual tests, web tests, and finally, unit tests. There is a choice to just create a test and one that will drive you through a wizard that will create test stubs for you for all existing methods. I&rsquo;m going to use the manual test generation method, because I hate tools the generate tests for me. One annoyance about this dialog box is that I have to put a .cs suffix on my Test Name before OK is enabled.

After choosing OK, I&rsquo;m presented with this test shell:

<pre>using System;
using Microsoft.VisualStudio.QualityTools.UnitTesting.Framework;

namespace InstrumentationTests
{
    /// &lt;summary>
    /// Summary description for InstrumentationExplorationFixture
    /// &lt;/summary>
    [TestClass]
    public class InstrumentationExplorationFixture
    {
        public InstrumentationExplorationFixture()
        {
            //
            // TODO: Add constructor logic here
            //
        }

        /// &lt;summary>
        /// Initialize() is called once during test execution before
        /// test methods in this test class are executed.
        /// &lt;/summary>
        [TestInitialize()]
        public void Initialize()
        {
            //  TODO: Add test initialization code
        }

        /// &lt;summary>
        /// Cleanup() is called once during test execution after
        /// test methods in this class have executed unless the
        /// corresponding Initialize() call threw an exception.
        /// &lt;/summary>
        [TestCleanup()]
        public void Cleanup()
        {
            //  TODO: Add test cleanup code
        }

        [TestMethod]
        public void TestMethod1()
        {
            //
            // TODO: Add test logic here
            //
        }
    }
}
</pre>

Not bad, although I&rsquo;ll probably change the template to get rid of those annoying comments. In this test you see some attributes that are very similar to NUnit&rsquo;s attributes. TestClass appears to map to TestFixture, TestInitialize => SetUp, TestCleanup => TearDown, TestMethod => Test. It also supports ExpectedException, just like NUnit, and it has the equivalents for TestFixtureSetUp and TestFixtureTearDown, and one new one, something that lets you set up just after your assembly loads and right before it unloads. These are called AssemblyInitialize/AssemblyCleanup and ClassInitialize/Cleanup.

At this point, I started writing my first test. And I was thinking so hard about the test, that I forgot I was using the VSTS testing framework (btw, what is the short name for this thing? NUnit versus ???). I just started writing a test, and everything just worked for me. The first change I saw was that the Assert.AreEqual method is not a generic. The old one still exists, but with the new one, you can specify the type of the things to compare, and a certain class of errors is now caught at compile time. Here is my first test:

<pre>[TestMethod]
        public void CreateAndClearCounter()
        {
            EnterpriseLibraryPerformanceCounter counter = new EnterpriseLibraryPerformanceCounter();
            counter.Clear();

            Assert.AreEqual&lt;int>(0, counter.Value);
        }
</pre>

I&rsquo;m following a practice here called Coding by Intention. I have not written a thing yet, but I&rsquo;m writing my code as if I have all of these methods and classes already in place. I&rsquo;ll create them as I go to make this test pass. But coding like this helps you think about the abstractions you need to perform your task. So I obviously need to create an EnterpriseLibraryPerformanceCounter (I doubt this name will last very long. We have nothing else called EnterpriseLibrary*, so why should this be called this).

**On to the second test**

OK, so I&rsquo;ve written and implemented that test, and it was pretty easy. It really felt as simple as using NUnit. The only problem right now is that TestDriven.Net isn&rsquo;t working. I&rsquo;ve talked with Jamie, and he&rsquo;s working on a solution for that. So now its time for that second test. Here it is:

<pre>[TestMethod]
        public void CounterCanBeIncremented()
        {
            EnterpriseLibraryPerformanceCounter counter = new EnterpriseLibraryPerformanceCounter();
            counter.Clear();
            counter.Increment();

            Assert.AreEqual&lt;long>(1, counter.Value);
        }
</pre>

Again, a really simple test. Now I try to run it&hellip;It&rsquo;s only running one test. Damn. I&rsquo;m trying to figure out why it is only running one test, but it shouldn&rsquo;t be this hard.

Well, I got the other test to run. I had to physically move it before the first test, and then it got picked up. Then I moved it back to where it was, and it worked there, too. Very strange, but I&rsquo;ll definitely keep an eye on this behavior.

**Test number 3**

OK, now that I have some basic counting functionality in place, I want to get it so that I can have multiple instances of the same counter. I write a new test, write the code to get it to compile and fail, and it does. In fact, all three tests fail now. And I have no idea how to know where they&rsquo;re failing.

The way that this test stuff works here is that there is a pane called Test Results. Double-clicking on a test gives you a new view that shows the test name, how long it took, etc, as well as any error message and the stack trace. But the stack trace isn&rsquo;t clickable. I&rsquo;m trying to figure out how I can get from my stack trace to the line of code that failed. There are no line numbers in the stack trace either, so I can&rsquo;t get there manually. This is more than a little frustrating. It is not working as I expect or want at this point. Not happy&hellip;

**Summary**

I&rsquo;m wrapping up my work for the day now, and I have some conclusions. Please take these conclusions with a huge grain of salt, since I just started working with this tool. I&rsquo;m uncomfortable with it, it is not natural yet, so it is to be expected that I wasn&rsquo;t as productive as I would be using my old tools.

However&hellip;

I find test authoring to be the same. For the basic kinds of tests I&rsquo;m doing, it is exactly like using NUnit. There are a bunch more attributes that you can use to let you do things that may or may not be wise, but they are available. What I don&rsquo;t like, at all, is how I have to run the tests. This is completely a product of not having TestDriven.Net installed. I can&rsquo;t pick and choose the tests I want to run easily, and I can&rsquo;t run just a single test easily. I know I can click on the check boxes in the Test Results windows to choose which tests to run, but that just seems foreign to me right now. And when the tests run, they seem to take a long time. The reported time is only a fraction of a fraction of a second, but the subjective time the tool spends starting stuff up seems to be pretty long,and it doesn&rsquo;t get shorter for subsequent runs of the same tests. TD.Net has these same issues at times, and it might just be spinning up the AppDomain for the test, etc. It just _feels_ like a long time.

The biggest disappointment to me is how hard it is to figure out how to find the line where a test broke. I&rsquo;m sure I&rsquo;m just missing something simple, as no one would create a test tool where you couldn&rsquo;t jump around in the stack &mdash; I&rsquo;m just missing how to. But if I&rsquo;m missing it, does that mean that it&rsquo;s too hard to find?

Stay tuned for more tales of my travels through this testing framework. There is a lot to learn with it, as it is _much_ more than a TDD framework. My problem is going to be finding and choosing just those parts I need.

&mdash; bab

&nbsp;

 [1]: http://www.agilestl.com/private/blog/smile1.gif