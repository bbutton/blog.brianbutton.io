---
title: What do you find hard to test?
author: Brian Button
type: post
date: 2005-11-02T14:10:00+00:00
url: /index.php/2005/11/02/what-do-you-find-hard-to-test/
sfw_comment_form_password:
  - APHo0t4NHqKw
sfw_pwd:
  - cp5VbKVbsdWt
categories:
  - 111
  - 112

---
OK, folks. I&rsquo;m asking you &mdash;

<blockquote dir="ltr" style="MARGIN-RIGHT: 0px">
  <p>
    <em>What kinds of problems do you find hard to conquer through TDD?</em>
  </p>
</blockquote>

I&rsquo;m interested in writing a continuing series on my blog about things that are difficult to create TDD. I plan on taking the suggestions that I get, both through email and as comments on this blog post, and begin solving them using C# and .Net. The intent of this series is twofold: the first result I hope to get from this is the obvious one &mdash; a set of lessons about how to TDD hard problems. The second result I hope for is more important &mdash; I want to show that seemingly difficult problems are not as hard as they seem if you change around the problem to suit your needs. In other words, if something is hard to test, maybe you&rsquo;re not thinking about it the right way.

Here is a suggestion to get you started:

  * A filesystem walker &mdash; walk a filesystem starting at a directory and do something or other for each file found. Maybe we&rsquo;re searching for a particular file, or looking for a set of files matching a certain pattern, or whatever. The essence of this is that you need to walk a filesystem tree, and develop this code test first.

I know many of you want to see GUIs and database code developed test first, but I intentionally haven&rsquo;t mentioned them as examples above. I want to hear specifics about what makes them hard for you. Given that knowledge, we&rsquo;ll focus on just those areas and solve those problems.

You can either respond through my blog here, or you can email your suggestions to <TDD-problems@agilestl.com> .

I&rsquo;m looking forward to hearing your suggestions!

&mdash; bab

&nbsp;