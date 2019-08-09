---
title: The downside of coding alone…
author: Brian Button
type: post
date: 2007-11-17T15:05:00+00:00
url: /index.php/2007/11/17/the-downside-of-coding-alone/
sfw_comment_form_password:
  - 3aqoD7L85y0z
sfw_pwd:
  - gTzwcnGvbiGm
categories:
  - 111

---
I had what was probably an obvious insight the other day while I was working on my project alone. I&#8217;m a team of one, which kind of gets in the way when it comes to pairing. This, unfortunately, has an effect on my final code.


  


**Good pairs are adversarial**


  


When you find yourself pairing with someone really good, it can almost feel adversarial. What I mean by that is that you can get into a rhythm where one person writes a test, intending to lead his partner down the road of writing a particular piece of code. His partner, however, can write something entirely different that still causes the test to pass.


  


This back and forth dance between tester and implementer forms the basis of good micro pairing sessions. In these sessions the tester/driver intends to lead the implementer down a particular path, but the implementer has the option of following another way, forcing the test writer to write another test, trying to drive the implementer down the intended path, and so on.


  


This leads to particularly good code, as the code that is written is usually the least code possible to implement the functionality, and the tests that are written thoroughly cover the functionality that was intended. It&#8217;s really cool to watch this work.


  


**If you&#8217;re a pair of one&#8230;**


  


If you happen to be working by yourself, it is very difficult to simulate this tension between test authoring and application implementation. At least, from my point of view, what happens is that I _do_ write the code I want to test to lead me to, regardless of whether or not there is a simpler way to get the test to pass. I think it is natural to do this, since you&#8217;re trying to play both sides of the partnership.


  


I think code I write without a pair is inferior to code I create with a partner, for this exact reason. We didn&#8217;t fight over the minimal implementation, which leads to still good code, but not the glory that is fully paired/TDD code.


  


There ain&#8217;t nothing better.


  


&#8212; bab