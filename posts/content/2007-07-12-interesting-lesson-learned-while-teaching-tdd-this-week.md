---
title: Interesting lesson learned while teaching TDD this week…
author: Brian Button
type: post
date: 2007-07-12T16:22:00+00:00
url: /index.php/2007/07/12/interesting-lesson-learned-while-teaching-tdd-this-week/
sfw_comment_form_password:
  - OeORQWkwnFd9
sfw_pwd:
  - 3fywMPhMHFoT
categories:
  - 111

---
I&#8217;ve been preaching TDD for years, and one of the lessons that I&#8217;ve taught over and over is that if a test is hard to write, you have probably bitten off more than you can chew. Comment out this test, try a smaller byte, and come back to this test later. 

I need to listen to myself more often 🙂

**Background**

It has always been difficult for me to explain to students how TDD works with multiple objects, refactoring, stubs, and the whole shebang. They get the refactoring part, they get the writing a test and them some code part, but their understanding falls apart when I start talking about testing void methods. This is where test doubles of some sort come in, and I swear, I&#8217;ve seen more blank stares when I explain this than I have any other time in the rest of my 42 years.

So I did something about it this class.

I took my own advice.

**The change**

Instead of having a big jump from TDD on a single class to this whole-hog example, I put in a couple of smaller examples, with exercises,&nbsp;between the two existing endpoints. In the first one, I introduce a test double that allows them to test that the side-effect of calling a method happens correctly. It takes a single interface and a single stub to implement this new concept, and they get it! Then I introduce another stub that provides data into the class under test, which requires another interface and stub class. And they still get it! Now we&#8217;re at the point where we&#8217;d be previously, but I don&#8217;t see any blank stares. Victory!

**The lesson**

_If a test is hard to write, then you&#8217;ve probably bitten off more than you can chew. Comment it out and try a smaller byte._

That advice works for the instructor, too!

&#8212; bab