---
title: This isn’t how I learned TDD… — Updated!
author: Brian Button
type: post
date: 2005-11-18T06:34:00+00:00
url: /index.php/2005/11/18/this-isnt-how-i-learned-tdd-updated/
sfw_comment_form_password:
  - 5iRKFQtSEdrw
sfw_pwd:
  - 4fmLKa2vF5yI
categories:
  - 111
  - 112

---
**_<u>Updated &#8211; 11/23/2005</b>_</u></p> 

The content on this page has been taken down. I want to thank those of you who voted on this topic to send the correct message to Microsoft, and those of you inside of Microsoft who took the complaints seriously and acted on them. </>

&#8211; bab

**_<u>Original Post</b>_</u></p> 

This [link][1] has been making its way through the blogosphere over the past couple of days. Please take a minute and visit that link, and then come back here.

_<Brief musical interlude>_

I learned about this from [Michael Feathers][2], who learned about it from Scott Bellware. Ladies and gentlemen, this piece of advice is slightly less than correct. The problem here is not that the advice is wrong (ok, that&rsquo;s a problem, but we could overlook that since there is so much other good TDD information out there), it is that it is coming from Microsoft. Given that there are billions of MS developers, and they tend to go look to MS for advice about how to develop, this advice carries instant weight and credibility. And yet, it is not correct.

Fortunately, there is a feedback mechanism that you can use should you wish to. At the bottom of that page, there is a place to vote on the quality of information on that page. There is even a place to put comments, gently encouraging the content to be changed.

**Why the advice is wrong**

Now that the rant is over, I&rsquo;d like to discuss what is so wrong with the advice. All you experienced TDDers will have picked up on it immediately after reading the page. The problem is that if you develop your software in the way described in that page, you remove the opportunity to learn from feedback. And after all, the whole point of TDD is to poke at your code, learn from it, and use that learning to poke at it again.

The advice as given is (slightly paraphrased with a few steps omitted):<!--StartFragment -->

  1. Make a list of tests that will verify the requirements. A complete list of tests for a particular feature area describes the requirements of that feature area unambiguously and completely. 
  2. Create work items in Team Foundation System for each test that needs to be written
  3. Write the shells of the classes and interfaces you&rsquo;ll need to implement these tests
  4. Generate test stubs for each class and interface
  5. Carefully examine each test to make sure it tests what you think it should
  6. Run all tests and watch them fail
  7. Go through each test and update it to test what you actually want it to. This is where you implement each test fully
  8. Run all tests and watch them pass
  9. Fix bugs

Contrast this with a different approach to writing your code:

  1. Make a list of tests that will verify the requirements. Don&rsquo;t worry if the list isn&rsquo;t complete &mdash; you can add to it as you go and learn
  2. Write a test from your list that illustrates some behavior of your system that you consider important but can be implemented quickly (5 minutes?)
  3. Try to compile it and watch it fail
  4. Write just enough code to make that single test compile but fail. This may involve creating new classes and interfaces
  5. Run this test and watch it fail
  6. Make the test pass
  7. Run all tests and watch them pass
  8. If any failed, fix the code and rerun tests
  9. Refactor
 10. If feature is implemented and all refactoring is finished, then goto end
 11. Consider if there are new tests to add to your list
 12. Goto step 2

The key difference between these two approaches is that the top piece of advice encourages you to plot your entire course through unknown territory up front. You create your entire test list, commit this to stone through TFS work items, write all your classes and interfaces, generate all your tests, implement everything, and then look to see if things pass. If, in this case, you decide you were wrong about something, or some requirement changes, or other strange set of cosmic events occurs, changing your mind is going to be painful. If you just learn something new that makes you take a different course, you have to go back and change all this infrastructure you&rsquo;ve built up around a guess about how something might work, and it just isn&rsquo;t going to happen. In this style of development, I believe you&rsquo;re going to make your stab at it at first, and then make that stab work.

In the bottom style of development, you&rsquo;re encouraged to work entirely piecemeal. Try something, make it work, learn from it, and try the next thing based on what you&rsquo;ve learned. If you change your mind, the only baggage you are responsible for bringing along with you is that baggage you&rsquo;ve already created. You have nothing invested in your guess about how this thing might work, so learning and changing your mind is easy, quick, and cheap.

These are two different styles of development, and only one of them is TDD.

&mdash; bab

&nbsp;

 [1]: http://msdn2.microsoft.com/en-us/library/ms182521.aspx
 [2]: http://www.artima.com/weblogs/viewpost.jsp?thread=137207