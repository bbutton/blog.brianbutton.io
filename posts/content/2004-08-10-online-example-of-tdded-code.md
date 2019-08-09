---
title: Online example of TDD’ed code
author: Brian Button
type: post
date: 2004-08-10T06:14:00+00:00
url: /index.php/2004/08/10/online-example-of-tdded-code/
sfw_comment_form_password:
  - EEt1SK54W0yf
sfw_pwd:
  - CHiw5RtHR5fZ
categories:
  - 111
  - 115

---
Over the years, I&#8217;ve gotten a lot of requests for non-trivial examples of code entirely written using TDD and Simple Design. I can finally give you that example.

This code is for the [Offline Application Block][1], part of Microsoft&#8217;s Smart Client initiative. Basically, it implements a framework that will allow client code to operate in much the same way, whether it is connected to the internet or not. It was written over a period of about 12 weeks, and was done entirely test first.

Due to legal restrictions, Microsoft is unable to release unit tests along with the application block, but the unit tests are available through the [
  
GotDotNet Smart Client workspace][2]. You&#8217;ll have to join the workspace to see them, but if you want examples, it should be worth it.

I&#8217;d also welcome any kinds of questions about the design, the tests, or how the block was written.

&#8212; bab

 [1]: http://www.microsoft.com/downloads/details.aspx?FamilyId=BD864EB5-56B3-43A5-A964-6F23566DF0AB&displaylang=en
 [2]: http://www.gotdotnet.com/Community/Workspaces/Workspace.aspx?id=60dd1bb9-0d1e-45e0-975a-a7f398697344