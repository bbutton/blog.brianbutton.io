---
title: The unsung benefit of TDD
author: Brian Button
type: post
date: 2004-10-22T10:08:00+00:00
url: /index.php/2004/10/22/the-unsung-benefit-of-tdd/
sfw_comment_form_password:
  - QWH5cefa5yfM
sfw_pwd:
  - gpDbRaMQx1El
categories:
  - Uncategorized

---
Through an interesting set of circumstances, I have the opportunity to create a really simple build server here on my project team at MS. We&#8217;re using Windows Services for Unix and writing everything using KSH scripts. Ah, my years of Unix experience coming in handy again 🙂

Anyhow, the issue here is that my script is now 200 lines long, and I&#8217;m trying to put in several different changes to get it finished. But I&#8217;m not writing it test first. And because of this, I&#8217;ve got a dozen different changes running around in my head, and it is slowing me down.

Not only does writing code test first let you explore the interface, document the design, and create this safety net of tests, it also forces you to focus on one thing at a time.

I&#8217;m not doing that, and it hurts.

&#8212; bab

**PS &#8212; Go Cards!!!**