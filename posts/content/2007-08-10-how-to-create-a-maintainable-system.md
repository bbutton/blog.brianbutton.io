---
title: How to create a maintainable system
author: Brian Button
type: post
date: 2007-08-10T08:51:00+00:00
url: /index.php/2007/08/10/how-to-create-a-maintainable-system/
sfw_comment_form_password:
  - lTk1YLv5QW6E
sfw_pwd:
  - 1uveFFlD1RuS
categories:
  - 111

---
[Ayende][1] had an interesting post on his blog today about [the only metric that really counts][2], which is maintainability. He made a joke about measuring this property of a system by measuring the intensity of groans that emanate from the team when asked to changed something, which made me laugh.

It did bring up a more significant question in my mind, one that I&#8217;ve thought about before, and something that I&#8217;ve been telling my TDD classes lately. The question always comes up in class about why we just don&#8217;t design our systems right in the first place, for some value of right. There are several parts to my answer, but one of them is always that we build our systems simply and change them as we need to so that we can practice changing our systems for our big moment. That big moment happens when the customer comes in and tells us that he really, really, really needs this new feature, and he needs it by next Thursday.

If we had never practiced changing our system, and had never considered changing our system, then this might be a pretty scary thing. But if you build your system such that you practice changing it in new and interesting ways from the first day, when that change request comes in, you yawn and make the change.

In short, you get a maintainable system by practicing maintenance from the first day.

&#8212; bab

 [1]: http://ayende.com/
 [2]: http://feeds.feedburner.com/~r/AyendeRahien/~3/142698733/The-only-metric-that-counts-Maintainability.aspx