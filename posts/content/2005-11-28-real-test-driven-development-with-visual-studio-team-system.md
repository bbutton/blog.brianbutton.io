---
title: Real Test Driven Development with Visual Studio Team System
author: Brian Button
type: post
date: 2005-11-28T08:09:00+00:00
url: /index.php/2005/11/28/real-test-driven-development-with-visual-studio-team-system/
sfw_comment_form_password:
  - P7UgOL3oO2bM
sfw_pwd:
  - g5gGDCTWjpOB
categories:
  - 111
  - 112

---
There has been a lot of controversy lately, both in the blogosphere and on the Yahoo TestDrivenDevelopment group, about whether or not it is possible to due _true_ Test Driven Development (TDD) using VSTS. I&rsquo;m here to tell you that it is absolutely, completely, totally possible. But it ain&rsquo;t easy. The point of the rest of this post is to explain why, and to show you another, easier,&nbsp;way.

**My definition of TDD**

I&rsquo;m pretty hard-core about what I consider to be&nbsp;Test Driven Development. I believe that I have to write a test first, before any application code is present. I believe I have to write enough code to make the test compile and fail, and then make the test pass. Then I need to refactor my code. All the while, I need to be able to run my tests easily, jump to failures as they happen, and navigate between code and test easily.

**Starting off &mdash; Creating our base solution and projects**

As in all projects, we need to start by defining our solution and our first project.

<img height="201" alt="NewSolution" src="http://www.agilestl.com/private/blog/NewSolution.GIF" width="282" border="0" />

&nbsp;In VSTS, to begin doing TDD, you need to create a Test Project. Test projects are special kinds of projects, with a special, double-secret probation GUID hidden in them. This GUID identifies them to VSTS as a project that houses tests, which I guess is used to help the built-in test runner, test viewer, and test manager to find the assemblies to reflect over to find the tests. It also serves to taint the definition of this kind of project to prevent it from being opened in Visual Studio Profession. Rumor has it on the web that you can remove this GUID and the Pro-level tool can open the project again, but now the tests won&rsquo;t be found. Pick your poison&hellip; Anyhow, in the Solution Items folder above, you see two other files. the first, localtestrun.testrunconfig defines metainformation needed to tell VSTS how to run your unit tests. There are a bunch of special-purpose attributes that you can set in this file that allow you to do fancy things in our tests that we&rsquo;ll talk about later. The TDDWithVSTS.vsmdi file contains the definitions of any lists of tests that you&rsquo;ve defined with the included TestManager view (which I believe only ships with the VSTS for Testers SKU). I typically completely and totally ignore this file and its contents, because it doesn&rsquo;t help me to define lists of related tests. I tend to run my tests either one at a time, at the class level, at the project level, or at the solution level. The tests lists let you define arbitrary sets of tests to run together, a feature that just doesn&rsquo;t excite me.

**Creating our first test**

Here is the first test I created. I&rsquo;m just doing the simple Stack exercise, as the TDD process isn&rsquo;t the centerpiece of this article. 

<pre>namespace SampleTestProject
{
    /// &lt;summary>
    /// Summary description for StackFixture
    /// &lt;/summary>
    [TestClass]
    public class StackFixture
    {
        public StackFixture()
        {
            //
            // TODO: Add constructor logic here
            //
        }

        #region Additional test attributes
        //
        // You can use the following additional attributes as you write your tests:
        //
        // Use ClassInitialize to run code before running the first test in the class
        // [ClassInitialize()]
        // public static void MyClassInitialize(TestContext testContext) { }
        //
        // Use ClassCleanup to run code after all tests in a class have run
        // [ClassCleanup()]
        // public static void MyClassCleanup() { }
        //
        // Use TestInitialize to run code before running each test 
        // [TestInitialize()]
        // public void MyTestInitialize() { }
        //
        // Use TestCleanup to run code after each test has run
        // [TestCleanup()]
        // public void MyTestCleanup() { }
        //
        #endregion

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

Here we can see the basic outline of a test, along with some extra,optional testing attributes that the Create Unit Tests wizard built for me. I don&rsquo;t need any of the extra attributes, so I&rsquo;m going to remove the region from the above code and actually write my first test. If I didn&rsquo;t want to ever see this stuff, I could certainly find the template that defined this base test and remove all the noise.

<pre>using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace SampleTestProject
{
    [TestClass]
    public class StackFixture
    {
        [TestMethod]
        public void StackIsEmptyAtCreation()
        {
            Stack stack = new Stack();
            Assert.IsTrue(stack.IsEmpty);
        }
    }
}</pre>

Compile and you get the expected warning about no Stack class defined.&nbsp;Now I can go build the skeleton of that class in typical TDD fashion. Note that I have to do this by hand &mdash; there is no fancy QuickFix-type&nbsp;wizard to build this class for me. So to build this, I have to create another project, this time a regular&nbsp;class library project and create a new&nbsp;Stack class there. The project creation is a one-time only kind of cost, so I&rsquo;m not&nbsp;really worried about it, but I&rsquo;d sure like&nbsp;some sort of feature to create the class for me instead of me typing the boilerplate code. This is my first hint that this tool is really meant to help you test already&nbsp;existing&nbsp;code, instead of meant to help you write tests and force you to write other code. In fact, were I to have written my Stack class first, there are all kinds of wizards in place to auto-generate my tests for me, but this is the wrong direction to interest me.

One quick note before going on &mdash; VSTS does not allow you to place tests in source assemblies, and you&rsquo;re discouraged from putting source in test assemblies.&nbsp;This forces a source-code organizational scheme on you where your tests and code are in different assemblies.&nbsp;This has its pros and&nbsp;cons, but I think&nbsp;I like the end layout. We had our tests inside our code assemblies in Enterprise Library 1.0, and&nbsp;we had to have like 6 different compiler targets to&nbsp;build all the different variations&nbsp;we needed. With them in different assemblies, you don&rsquo;t need to play these games, and things are much more simple. But now you&rsquo;re forced to&nbsp;make things public in order to test them (or use InternalsVisibleTo, which is a topic for another posting coming soon).

After building my minimal&nbsp;Stack class,&nbsp;I have to add the project reference to my test project references, so that the compiler can find my class. Once I do that, VSTS has a handy keystroke (Shift-Alt F10) that will automatically generate the using statement for me that I need to compile.

<img height="352" alt="AutoUsingGenerate" src="http://www.agilestl.com/private/blog/AutoUsingGenerate.GIF" width="979" border="0" />

Once I generate the using for the class, I then have to go manually create the stub for the IsEmpty method. Now, if this were a method and not a property, apparently, VSTS would offer to create a stub for me, populated with a single line body that throws an Exception. I&rsquo;m not sure why properties and methods are treated differently, but they clearly are.&nbsp;I&rsquo;d expect at least a dialog that asked me if IsEmpty is a field or a property. Anyhow, I go create the property by hand, recompile, and I&rsquo;m finally ready to run my test.

What I&rsquo;d really like to find is an easy way to say, &ldquo;VSTS, please run this test I&rsquo;m currently editing for me&rdquo;. Unfortunately, there is no easy way to run a single test. About the best you can do, if you are looking for something easy, is to run all tests in a single TestProject at once. If a file that belongs to a test project is the currently active edit window, you can either hit a toolbar button or hit Shift-Ctrl-X to run all tests in that project. I know that in my development cycle, I tend to run smaller sets of tests as part of my rapid TDD rhythm, and expand outwards as I get closer to completion, or enough time passes that I want to run a larger set of tests. Perhaps this is a smell resulting from our suite of 1800 tests taking almost 10 minutes to run through VSTS, or perhaps this is a normal rhythm that most people use. In any case, the only way to find an individual test to run, or to run just those tests in a single test class, is to open the TestView window, which reflects over all your TestProject assemblies in your solution and displays a listbox of all your tests. I&rsquo;ve enclosed the TestView window as it initially is displayed for the latest Enterprise Library.

<img height="542" alt="TestView" src="http://www.agilestl.com/private/blog/TestView.GIF" width="447" border="0" />

Now, as I said, we have 1800 tests, organized into about 20 different TestProjects or so. So if I wanted to run a particular test, the only way I can do it is to find it in this window, right click on it, and run it from there. This is a pain to do when you have lots of tests, and is also rather keyboard-unfriendly. You can group the items by different criteria, like into a single solution node, into project nodes, etc, but you have to do this grouping each time you open the TestView window, as the Group By choice isn&rsquo;t remembered. This is one of the usability issues that is typically overlooked during reviews of this tool by people who are new to it. This view works just great if you have a few tests, but it starts to fall apart as your number of tests goes up. When first opening this window, for example, it takes over 30 seconds on my laptop to scan through all the assemblies and find all 1800 tests. After this, it opens right up, but it makes the act of running your tests the first time rather painful.

Now, lets look at the results of running our tests. The results are displayed in the Test Results window. This window looks very much like the Test View window, but its purpose in life is to show you the outcome of the tests that you have run. As a simple example of this, here are the results from our Stack test run &mdash;

<img height="133" alt="TestResults" src="http://www.agilestl.com/private/blog/TestResults.GIF" width="1068" border="0" />

We see all kinds of stuff in this window, and most of it good. All of the information in this window is important to us in figuring out the status of the tests that we just ran. We see that the single test that we have ran but failed. We see the name of the test, which project it was in, and the error message that was generated by the failure. All good stuff. In a perfect world, what I&rsquo;d really like to happen now is for me to be able to double click on the failed test, and be taken to the point of failure. But what I get when I double-click on that test is the Test Results pane &mdash;

<img height="313" alt="TestResultsPane" src="http://www.agilestl.com/private/blog/TestResultsPane.GIF" width="983" border="0" />

This pane tells me everything I ever wanted to know about this test run. It tells me what test is was, when I ran it, how long it took, why it failed. It tells me exactly where the failure happened. Unfortunately, _it doesn&rsquo;t give me any way to **get** to the failure_. You see, the stack trace is not live at all. I have to examine it, interpret it, find the particular line I want to look at, open the file, navigate to the line, and then I can finally examine my failure. I frankly cannot believe that they left this out, as this is the most basic function of a stack trace in a test tool. The fact that this trace is just dead text just boggles my mind. Sorry, VSTS Team, I know you worked hard on this tool, but&nbsp;come on&hellip;&nbsp;

So let&rsquo;s just suppose I do navigate to the failed line, and from there figure out how to fix the code to make the test pass, and try to rerun my test. As we saw in the Test Results window two figures above, there is a link in there to Rerun Original Tests. Let&rsquo;s just say that I clicked this. In my mind, the logical thing to happen would be for the code to get recompiled as needed, and the tests that failed get run, based on the new code. Well, it turns out not to be the case. What happens is that VSTS saves each individual test run in its own individual folder on your disk, including all results files that are generated by the tool and all the assemblies needed to reproduce those results. If you want to recompile and rerun the one test that failed, unfortunately, you need to navigate back to that test in the Test View window and run it again from there.

However, I now really can rerun my test, watch it pass, and feel happy. I did it! I wrote a test in a Test Driven fashion using VSTS as my IDE of choice. It was painful, but I was able to do it.

**And for the second test and beyond&hellip;**

There isn&rsquo;t much point in showing you how to write more tests in this single class, as the process is the same. As long as you have relatively few tests and a reasonably simple system, this testing system works pretty well. I&rsquo;ve used it for teaching many times, and I can do anything I want to with it. Students sometimes chuckle as I go from window to window to window to make fairly simple things work, but I can do it. Once you get used to the keyboard shortcuts, you can start to move reasonably quickly.

However, once you get to a thousand tests or so, things get a bit dicey. The Test View window is extremely inconvenient to navigate, the Test Results window does a good job of showing you which tests failed, but falls down on helping you navigate to figure out _why_ they failed. And the biggest problem I have with this framework is that the built-in test runner is **_slow_**. I can&rsquo;t give benchmarks, as far as I know, but I do know that it seems like it takes at least twice as long to run our tests through it as it does through NUnit (our tests are written to run in either framework through judicious use of using aliases).

**How I _really_ use VSTS for unit testing**

I think I made my point that I have no real problem with the testing framework itself, other than a few quirks that I haven&rsquo;t gone into. But the test runner/viewer/manager aspect is pretty tough to use. Fortunately for all of us, there is a very simple, free alternative. Jamie Cansdale has written a tool called [TestDriven.Net][1] that will run your unit tests for you in a much more reasonable fashion. Once you load and install TD.Net, you can right click on a test, or a test class, or a test namespace and run that set of tests. You can right click on test files, test projects, solution folders, or the entire solution in Solution Explorer, and you can run those sets of tests.

<img height="322" alt="TDNetPopup" src="http://www.agilestl.com/private/blog/TDNetPopup.GIF" width="667" border="0" />

The results do not show up in a graphical manner, but instead show up in your Output window. But when tests fail, the stack traces that are printed out are live and clickable, and take you to the line of code where the failure happened. You can also explore the stack trace of the failed test, popping up and down the callers and callees to figure out where you went wrong. With the combination of VSTS and TD.Net, you can do anything!

So I&rsquo;d have to say that my TDD process, with TD.Net installed, works like the following. I do this every day, so I&rsquo;m pretty sure that this process works well enough for anyone committed to doing Test Driven Development with VSTS.

  1. Create the appropriate solutions and projects as needed. I am currently just adding functionality to Enterprise Library, so my solutions and projects are already existing for the most part.
  2. Decide on the test to write and write it. If I need a new test fixture, use VSTS to create it for me. If I need a new test, create it where it should be.
  3. Compile and use the built-in VSTS auto-import and method-generation features as much as possible to get the test to compile.
  4. Right click on the test, run it, and watch it fail.
  5. Double click on stack trace where code needs to be fixed and fix code
  6. Right click on test, run it, and watch it pass.
  7. Right click on class, namespace, project, or solution to run larger set of tests.
  8. Repeat forever ![][2]

**Conclusion (finally!)**

All done and told, TD.Net makes the actual testing framework that I&rsquo;m using almost irrelevant. I&rsquo;m just as productive using VSTS as I am using NUnit with this as my test runner. The VSTS team did a decent job creating a nice testing framework (Abstract Test Case issues aside ![][3]), and Jamie filled in the holes with a great runner. Between the two of them, I&rsquo;m able to be productive, happy, and test-infected.

(N.B. &mdash; I have completely ignored the refactoring half of TDD in this article. VSTS does have built-in refactoring tools that work in a pretty expected way for the most part. Assume that I do the refactorings at the appropriate times during this article, and we&rsquo;ll all sleep better.)

&mdash; bab

**Now playing:** Rush &#8211; A Show Of Hands &#8211; The Rhythm Method

 [1]: http://www.testdriven.net/
 [2]: http://www.agilestl.com/private/blog/smile1.gif
 [3]: http://www.agilestl.com/private/blog/smile9.gif