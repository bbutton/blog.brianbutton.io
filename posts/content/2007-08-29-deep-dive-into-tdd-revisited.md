---
title: Deep Dive into TDD Revisited
author: Brian Button
type: post
date: 2007-08-29T15:03:00+00:00
url: /index.php/2007/08/29/deep-dive-into-tdd-revisited/
sfw_comment_form_password:
  - RMVKH3FngK5B
sfw_pwd:
  - lsbAd3TD5KtD
categories:
  - 111

---
Hi, everyone. I haven&#8217;t posted any serious technical content on this blog for a long time now. The reason for this is that I&#8217;m now a pointy haired boss most of the time. I spend my days teaching, mentoring, coaching, and occasionally pairing with someone on another team. I miss coding&#8230; I really do. <sniff>

However, I&#8217;ve been digging into _Interaction Based Testing_ over the past few weeks, and I&#8217;ve found it fascinating. The road I took to get here involved trying to learn more about what [Behavior Driven Development][1] is, and why so many people I know and respect seem to like it, or at least appreciate it. One of the techniques that BDD uses is something called Interaction Based Testing, or IBT for short.

**Interaction Based Testing**

IBT is different from traditional TDD in that it is defining and verifying the interactions between objects as they take place, rather than defining and verifying that some input state is being successfully translated to some output state. This latter kind of testing, called _State Based Testing_, or SBT for short, is what I had always done when I did TDD (for the most part). IBT involves using a Mock Object Framework that allows you to set expectations on objects that your class under test is going to call, and then helps you verify that each of those calls took place. Here is a short example:

    [TestFixture]
    public class IBTExample
    {
        [Test]
        public void SampleITBTest()
        {
            MockRepository mocks = new MockRepository();
    
            IListener listener = mocks.CreateMock<IListener>();
            Repeater repeater = new Repeater(listener);
    
            listener.Hear("");
            LastCall.On(listener).Constraints(Is.NotNull()).Repeat.Once();
    
            mocks.ReplayAll();
    
            repeater.Repeat("");
    
            mocks.VerifyAll();
        }
    }
    

The basic problem that I&#8217;m trying to solve here is that I can write a method, Repeat(), on a class called Repeater such that when I call Repeat(), it repeats what it was passed to its IListener. The way that I set this up is more complicated than I would use in a state-based test, but I avoid cluttering my test with irrelevant implementation details (like explicit data).

What this test is doing is creating the system and setting expectations on the IListener that define how the Repeater class is going to use it at the appropriate time. The MockRepository is the class that represents the mock object framework I&#8217;m using, which in this case is [Rhino Mocks][2]. I new one of these up, and it handles all the mocking and verification activities that this test requires. On the next line, you see me creating a mock object to represent an IListener. I typically would have created a state-based stub for this listener that would simply remember what it was told, for my test to interrogate later. In this case, the framework is creating a testing version of this interface for me, so I don&#8217;t have to build my own stub. Next, I create the class under test and wire it together with the listener. Nothing fancy there.

The next line looks a little strange, and it is. It is actually a result of how this particular mocking framework functions, but it is easily understood. While it may look like I&#8217;m calling my listener&#8217;s Hear method, I&#8217;m actually not. When you create an instance of the mocking framework, it is created in a recording mode. What this means is that every time you invoke a method on a mocked out object while recording, you are actually calling a proxy for that object and defining expectations for how that object will be called in your regular code later. In this case (admittedly, not the simplest case), listener.Hear() is a void method, so I have to split the setting of expectations into two lines. On the first line, I call the proxy, and the framework makes a mental note that I called it. On the next line, I say to the framework, &#8220;Hey, remember that method I just called? Well, in my real code, when I call it, I expect that I am going to pass it some kind of string that will never be null, and I&#8217;ll call that method exactly once. If I do these things, please allow my test to pass. If I don&#8217;t do them, then fail it miserably&#8221;.

After I set up the single expectation I have on the code I&#8217;m going to be calling, I exit record mode and enter replay mode. In this mode. the framework allows me to run my real code and plays back my expectations for me while my real code executes. The framework keeps track of whatever is going on, and when I finally call my application method, Repeater.Repeat() in this case, followed by the mocks.VerifyAll(), it checks to make sure that all expectations were met. If they were, I&#8217;m cool, otherwise my test fails.

I hope that was at least a little clear. It was very confusing to me, but I sat down with a few folks at the agile conference two weeks ago, and they showed me how this worked. I&#8217;m still very new at it, so I&#8217;m likely to do things that programmers experienced with this kind of testing would find silly. If any of you see something I&#8217;m doing that doesn&#8217;t make sense, please tell me!

Here is the code this test is forcing me to write:

    public class Repeater
    {
        private readonly IListener listener;
    
        public Repeater(IListener listener)
        {
            this.listener = listener;
        }
    
        public void Repeat(string whatToRepeat)
        {
            listener.Hear(whatToRepeat);
        }
    }
    
    public interface IListener
    {
        void Hear(string whatToHear);
    }
    

**Advantages to IBT style TDD**

There are several things about this that I really like:

  * It allows me to write tests that completely and totally ignore what the data is that is being passed around. In most state-based tests, the actual data is irrelevant. You are forced to provide some values just so that you can see if your code worked. The values obfuscate what is happening. IBT allows me to avoid putting any data into my tests that isn&#8217;t completely relevant to that test, which allows me to focus better on what the test is saying.
  * It allows me to defer making decisions until much later. You can&#8217;t see it in this example, but I&#8217;m finding that I&#8217;m much better able to defer making choices about things until truly need to make them. You&#8217;ll see examples of this in the blog entries that are to follow (more about this below).
  * I get to much simpler code than state-based testing would lead me to
  * My workflow changes. I used to 
      1. Write a test
      2. Implement it in simple, procedural terms
      3. Refactor the hell out of it

With ITB, I&#8217;m finding that it is really hard to write expectations on procedural code, so my code much more naturally tends to lots of really small, simple objects that collaborate together nicely. I am finding that I do refactoring less frequently, and it is usually when I&#8217;ve changed my mind about something rather than as part of my normal workflow. This is new and interesting to me.

There are some warts that I&#8217;m seeing with it, and I&#8217;ll get to those as well, as I write further in this series. I&#8217;m also very certain that this technique has its time and place. One of the things I want to learn is where that time and place is. Anyhow, here are my plans for this:

**Revisiting my Deep Dive**

I want to redo the example I did a couple years ago when I solved the [Payroll][3] [problem][4] [in a][5] [6-part][6] [blog][7] [series][8]. I want to solve the same problem in a ITB way, and let you see where it leads me. I&#8217;ve done this once already, part of the way, just to learn how this worked, and the solution I came up with was very different than the one I did the first time. I&#8217;m going to do this new series the exact same way as the old series, talking through what I&#8217;m doing and what I&#8217;m thinking the whole time. I&#8217;m personally very curious to see where it goes.

Once we&#8217;re finished, I want to explore some other stories that are going to force me to refactor some of my basic design assumptions, because one of the knocks against ITB is that it makes refactoring harder by defining the interactions inside your tests _and_ your code. We&#8217;ll find out.

**Please ask questions**

I&#8217;m learning this stuff as I go, so I&#8217;m very eager to hear criticisms of what I&#8217;ve done and answer questions about why I&#8217;ve done things. Please feel free to post comments on the blog about this and the following entries. I&#8217;m really looking forward to this, and I hope you readers are, too.

&#8212; bab

 [1]: http://behaviour-driven.org
 [2]: http://www.ayende.com/projects/rhino-mocks.aspx
 [3]: http://www.agileprogrammer.com/oneagilecoder/archive/2004/10/25/2805.aspx
 [4]: http://www.agileprogrammer.com/oneagilecoder/archive/2004/11/07/2799.aspx
 [5]: http://www.agileprogrammer.com/oneagilecoder/archive/2004/11/15/2793.aspx
 [6]: http://www.agileprogrammer.com/oneagilecoder/archive/2004/11/25/2771.aspx
 [7]: http://www.agileprogrammer.com/oneagilecoder/archive/2004/12/02/2767.aspx
 [8]: http://www.agileprogrammer.com/oneagilecoder/archive/2004/12/04/2756.aspx