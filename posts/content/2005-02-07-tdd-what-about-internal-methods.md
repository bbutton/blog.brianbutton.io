---
title: TDD — What about internal methods?
author: Brian Button
type: post
date: 2005-02-07T21:53:00+00:00
url: /index.php/2005/02/07/tdd-what-about-internal-methods/
sfw_comment_form_password:
  - olpPmxPl8825
sfw_pwd:
  - 1pADUk05WJ6M
categories:
  - Uncategorized

---
Over the past few months, I&rsquo;ve taken part in a few chats about whether or not internal methods should be tested. One of the basic premises of TDD is that you should use it to explore, design, and implement the public interface of your classes. If you are using it to test methods that are less than public, you are probably testing implementation and not interface, which leads to very fragile tests.

For the longest time I didn&rsquo;t believe that. I truly believed that internal methods were just another &ldquo;public&rdquo;-like interface, to a smaller audience. And I just spent 30 minutes writing this blog entry explaining my reasoning. And as I went through my arguments, I started thinking. And then I erased what I had written.

So, this is my new post:

A few weeks ago I posted an entry called Extreme Refactoring. One of the goals of what I did was to eliminate all private methods, just to see where that took the design. I liked where it went, and it has changed how I think about new code that I write.

Maybe, must maybe,&nbsp;we can do the same kind of thing with internal methods.&nbsp;Private methods are an indication that a class is doing too much. It is possible to move that logic out of the private methods into public methods of other classes. And maybe it is possible that a class that has both public and internal methods is doing too much as well. Maybe that&rsquo;s a hint that that class is doing too much.

At this point I don&rsquo;t know. I really meant this posting to be an explanation of why writing internal methods through TDD made sense, since they weren&rsquo;t really anything other than scoped publics. But now I&rsquo;m starting to wonder. I just don&rsquo;t know. I&rsquo;m going to have to try to write code cognizant of this and see where it takes me. Maybe in well defined and factored classes, you have either private, protected, and public methods. I haven&rsquo;t decided if internal classes are OK or not &mdash; I&rsquo;ll have to try it and find out.

The problem I have seen is that in large applications, there are services that classes offer to each other, inside the bounds of the application, that classes outside the application should not be able to consume. Internal methods go part of the way towards solving this, but even they break down when the application spans multiple assemblies. I want to find a way to address this issue, but still create safe, security-conscious code.

Sorry for the ramble, but this was really an exploration and journey for me to get to this point. I look forward to trying this theory out.

bab

&nbsp;

**Now playing:** Liquid Tension Experiment &#8211; Liquid Tension Experiment 2 &#8211; Liquid Dreams