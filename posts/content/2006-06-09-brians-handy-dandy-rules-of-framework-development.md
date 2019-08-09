---
title: Brian’s Handy Dandy Rules of Framework Development
author: Brian Button
type: post
date: 2006-06-09T14:00:00+00:00
url: /index.php/2006/06/09/brians-handy-dandy-rules-of-framework-development/
sfw_comment_form_password:
  - c6TfmH42aHP5
sfw_pwd:
  - UHuGT3NBPgLu
categories:
  - 111
  - 112

---
The whole basis of my talk at TechEd is that there are some non-technical rules around which creating good frameworks should revolve. Since I mined those rules from my earlier poll on this blog, I thought I should share my results with you. I give you

**Brian&rsquo;s Handy Dandy Rules for Framework Development**

  * Clients come before frameworks
  * Ease of use trumps ease of implementation
  * Quality, Quality, Quality
  * Be an enabler
  * It&rsquo;s a people problem

_Clients come before frameworks_

This was easily the most commonly heard bit of advice my poll revealed, and it matches up very nicely with my own experiences. The best frameworks are not created, they are mined out of existing code. The worst frameworks seem to have sprung from the twisted imagination of a rogue architect somewhere&hellip;

_Ease of use trumps ease of implementation_

As the author of a framework, you need to keep your eye on the ball of making others&rsquo; jobs easier. If you ever have to make a tradeoff between changing something to make it easier to implement and changing something to make it easier for your framework clients to use, always choose the latter. Write good documentation, ship your unit tests, and test out your APIs through writing lots of in-house client code. Lots of eyes on the API helps as well

_Quality, Quality, Quality_

Use Test Driven Development on your framework code, and enable framework users to use it on theirs. This means to avoid things like _sealed_ and overzealous use of CAS. &lsquo;Nuff said.

_Be an enabler_

You can&rsquo;t read people&rsquo;s minds, so don&rsquo;t presume to know what their key uses of your framework will be. Allow people to embrace and extend your framework through extension points. Document these extension points, give lots of examples, and create automation to help users with these tasks.

_It&rsquo;s a people problem_

Building a framework is decidedly not a difficult technical problem. We&rsquo;ve built these things before, we&rsquo;ll build them again. It is primarily an issue of balancing people and their conflicting interests. Good architects know this and are adept at balancing these concerns.

**Summary**

In a nutshell, that&rsquo;s my talk. I have&nbsp;a lot more detail, a lot more stories, and a lot more to say. If you want to hear it, come see me Friday morning, from 9&ndash;10:30 at TechEd 🙂

See you there,

bab