---
title: A Great Refactoring Experience
author: Brian Button
type: post
date: 2004-12-03T10:40:00+00:00
url: /index.php/2004/12/03/a-great-refactoring-experience/
sfw_comment_form_password:
  - 5dZbtkRA0BQ3
sfw_pwd:
  - w3kWib22JyW7
categories:
  - Uncategorized

---
This post is going to be entirely non-technical. Instead, I want to relate a refactoring experience I had yesterday with [Peter Provost][1].

Peter is working on something that he has never worked on before, Event Tracing in Windows (ETW). This is a very low-level, kernel-provided facility to track events in Windows. Accessing these APIs is hard, because you have to P/Invoke to get to all the calls, and it involves messy logic in .Net to make it all work. So, to let him go faster, I&#8217;m pairing with him (I&#8217;ve never seen this before either, but between us, we&#8217;re making good progress).

Well, we had written one test, and we had all the logic in this one single test. We didn&#8217;t know how to do any of this ETW stuff yet, so we were using our tests to explore the API. So, we got this first test to work, and then started to refactor out the non test-specific code into another class that we called a TraceEventGuidCollection. Not to hard to do, so we finished that pretty quickly. Then we started looking at that new class, and both of us realized that it was just too complex. It knew how to handle the specific TraceEvent stuff that we were working with, and it also knew about how to create, destroy, and manage unmanaged arrays of pointers in .Net. It seemed like two classes to us, but we had no idea how to split it in half. So we just did it. We had no idea where we were going, we had no idea what our plan should be &#8212; we were pretty clueless. So we just started doing an [ExtractClass][2] refactoring by the [book][3].

We pulled out our IntPtr [] array into the new class we had just created, and changed the original TraceEventGuidCollection class to use the array in its new home. Then we started moving over all the methods that used the array into the new class, one by one, addressing problems as we found them. The interesting part that we both noticed at this point is that we still had no idea of where we were going, but we knew we liked it. We&#8217;ve only known each other for a couple of months, but we&#8217;ve built up a level of respect and trust between us, so we were able to proceed together without fear. We knew we&#8217;d get somewhere good.

As we proceeded through the class, we discovered that we had two methods that were 89% identical, but there was just enough different to make our lives difficult. This was the outline of each function:

<font face="Courier New">public void DoSomething()<br />{<br />&nbsp;&nbsp;&nbsp; // setup stuff<br />&nbsp;&nbsp;&nbsp; // AllocateArrays<br />&nbsp;&nbsp;&nbsp; // Fill Arrays<br />&nbsp;&nbsp;&nbsp; // if(error occurs) throw win32exception<br />&nbsp;&nbsp;&nbsp; // Cleanup<br />}</font>

<font face="times">The problems that we had were that the way we detected an error was different, and what the method returned was different. In one case, we were in the constructor, so we didn&rsquo;t want to return anything. In the other case, we were using the API to figure out how many slots to allocate into our array, using some API tricks, and that had to return a number.</font>

<font face="Times">So our problem was that the code was <em>really, really</em> close to the same, but just enough different to make refactoring them both to look the same. We spun on this for about a half hour, trying different things to make them look the same, refactor them over to the other class, etc, and ended up backing out each of them. Finally, we decided to solve the smaller problem of just moving the constructor logic over. But in the process of doing this, we had to make the code much uglier than it was in its current home. We held our noses and did it, again confident that we could clean it up later.</font>

<font face="Times">We refactored this first piece of code over, got everything to work, and then went to work on the second method. Once we finally finished this, Peter was still unhappy with how the classes were laid out. Because we had refactored them and paid attention to where the responsibilities should lie, we had this totally subjective feeling that something was wrong. Peter and I looked at it for a bit, and finally realized that the second method was totally unneeded. We got rid of it, changed our constructor a bit to pick up a little of that responsibility, and checked in the code.</font>

This was one medium sized piece of our day, and we were exhausted at this point. But the two classes we had come up with were now factored much better, we had each learned something about how the worked, and we had a great time ![][4]

If people only realized what a great creative process refactoring was, there would be a lot more people doing it!

&ndash; bab

&nbsp;

 [1]: http://www.peterprovost.org/
 [2]: http://www.refactoring.com/catalog/extractClass.html
 [3]: http://www.amazon.com/exec/obidos/ASIN/0201485672/peterprovosto-20
 [4]: file:///C:/Program%20Files/BlogJetBeta/Data/Smiles/smile1.gif