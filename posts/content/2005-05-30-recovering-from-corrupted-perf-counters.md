---
title: Recovering from corrupted perf counters
author: Brian Button
type: post
date: 2005-05-30T14:40:00+00:00
url: /index.php/2005/05/30/recovering-from-corrupted-perf-counters/
sfw_comment_form_password:
  - kymEZevGSRdL
sfw_pwd:
  - QAev8vcfwuEh
categories:
  - 112
  - 115

---
Don&rsquo;t know if any of you have ever had this happen to you or not, but it paniced me a bit when it happened to me. I opened up perfmon, and instead of nice names of counters and categories, I had nothing but numbers in their place. The last thing I wanted to do was to have to rebuild my VPC, so I _really_ wanted a way to fix this.

**Google Is Your Friend**

Google led me [here][1], where another gentleman, ScanIAm, had the same problem. He posted about it on that forum, and eventually found his answer. If you look at message at the end of that thread, he posts his solution:

<!--StartFragment -->&nbsp;1) 

<a href="http://support.microsoft.com/?kbid=300956" target="_blank">KB300956</a>&nbsp;this will clear you out.  
2)&nbsp;To fix .Net performance counters&nbsp;<a href="http://blogs.msdn.com/mikedodd/archive/2004/10/17/243799.aspx" target="_blank">Click Here</a>  
3) To fix Asp.Net performance counters,&nbsp;head to your c:winntMicrosoft.netframeworkv1.1.4322&nbsp;path and type:&nbsp; **lodctr aspnet_perf.ini**

I did just what he said, and everything came back perfectly. I had been seeing a strange exception while trying to run installutil on one of my assemblies, which started this whole slide into perf-counter-hell. But this post brought me back, and I&rsquo;m very happy to say it all works again!

I hope this helps someone else out there someday as much as it helped me.

&mdash; bab

&nbsp;

 [1]: http://channel9.msdn.com/ShowPost.aspx?PostID=61336