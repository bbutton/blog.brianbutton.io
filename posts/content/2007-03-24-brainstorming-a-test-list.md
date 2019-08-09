---
title: Brainstorming a test list
author: Brian Button
type: post
date: 2007-03-24T07:32:00+00:00
url: /index.php/2007/03/24/brainstorming-a-test-list/
sfw_comment_form_password:
  - XqFy1Gy5iqzd
sfw_pwd:
  - L5pCfjC45FG3
categories:
  - Uncategorized

---
_Question_ &#8212; When writing code test first, how do you know where to start, how do you know what to do next, and how do you know you&#8217;re finished?

_Answer &#8212;_ By creating a list of tests that help you bound the problem you&#8217;re solving.

Given that previous statement, it sounds like having a good set of tests is a pretty important part of _Test_ Driven Development, eh? Obviously it is, so the question becomes how you create a good list. 

Creating a good test list is a skill that needs to be learned and practiced. It&#8217;s an important thing to do because it is our first act of design as we start to build something. It also helps us create our roadmap through the creation of the method, from start to finish, so that we always have a good idea of where to go next. 

When I approach creating a test list, I specifically ignore the concept of tests and think about _examples_ I want to teach my code to do. I start by thinking of simple examples that exercise the basic, but extremely limited, functionality of my method, and then start to layer on more complexity with subsequent examples. When I&#8217;ve thought of as many examples as I need to flesh out the total behavior, I start thinking about examples of what I&#8217;d like to happen when things start to go wrong. Once I&#8217;ve finished those, I have a pretty good idea of all the things I need to teach my code to do, and I&#8217;m ready to start implementing. Let&#8217;s look at a simple problem as a way of further explaining what I mean:

Let&#8217;s consider a method that reverses the elements in an array of integers and returns them in a new array.&nbsp;The first example I might think of is:

  * An array of a single integer is returned unchanged, in a new array

This example forces me to write enough code to define what my input parameter is, what my return parameter looks like, and establishes that I&#8217;m returning my information in a new array. So far, so good. This simple example has started to flesh out the publicly visible portions of this class.

My next example would expand on this, adding in the ability to reverse a larger array:

  * An array with multiple elements is returned in reverse order in a new array

Since this problem is so simple, those two examples might be enough to flesh out the basic behavior of this method. That leaves me with considering corner cases and exceptional conditions. To define that behavior, I think these last two example should suffice:

  * A null array causes an ArgumentNullException to be thrown
  * An empty array is returned as a new empty array

I think those&nbsp;4 examples should be enough to define the behavior of this problem well enough that I could code it.

**Are we really finished?**

I said back up top that I would say a few more words about &#8220;being done&#8221; later in this entry, and that time has come. The thing about writing a test list is that it very much like any sort of designing on paper &#8212; it is a guess. You don&#8217;t truly know if you&#8217;re done until the code is written and working in its final environment. The only real feedback about whether or not you defined the right set of examples is whether or not your code works correctly. If you find that you have to add additional functionality to finish your method, then you missed a test. If you later find bugs in the code, you&#8217;ve missed a test. When either of these two cases happens, however, fret not. Think of it not as a failure, but as an opportunity to learn 🙂 I&#8217;m never concerned that I think of all the tests/examples at first, because I know I can always modify my test list as I go. What I am concerned about, however, are bugs that I let slip through from missing tests. In that case, I should reflect on what test I could have written to find that bug while the code was being written and write that test and others like it next time.

That&#8217;s all there is to it &#8212; no muss, no fuss, no guilt. If you mess up and miss a test, learn from it, and do better next time.

**Conclusion**

The act of writing a test list is an act of design. It is the first concrete opportunity for the developer to really think about what this particular method is about to do. Having a test list allows you to focus on incrementally developing your method, from a simple example to those that are more complex, until you&#8217;re finished.

**In our next episode&#8230;**

If you&#8217;d like to play along with our game, you can think about creating a test list for a query string builder for a web request. I know there is already one in .Net, but forget about that one for now. Try to figure out a list of tests that you could create that would guide you from the simplest case to the final product, including any and all corner cases you can think of. The problem statement would be:

_Given a URL and an array of name/value pairs, create a syntactically correct query string, suitable for use on the web._

I&#8217;ll share my version with you early next week, from sunny, warm West Palm Beach, Florida 🙂

&#8212; bab