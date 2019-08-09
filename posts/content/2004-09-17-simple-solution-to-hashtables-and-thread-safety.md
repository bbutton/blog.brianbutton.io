---
title: Simple Solution To Hashtables and Thread Safety
author: Brian Button
type: post
date: 2004-09-17T11:13:00+00:00
url: /index.php/2004/09/17/simple-solution-to-hashtables-and-thread-safety/
sfw_comment_form_password:
  - GDNa4pt3kFE6
sfw_pwd:
  - lWkSk2dVMwHW
categories:
  - 112
  - 115

---
Shortly after I posted the original entry on this, I figured out a much more simple way than using version numbers, etc.

Item item = null;  
bool lockWasSuccessful = false;

while(true) {  
&nbsp;&nbsp;&nbsp; lock(hashtable) {  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; item = hashtable[key];  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; lockWasSuccessful = Monitor.TryEntry(item);  
&nbsp;&nbsp;&nbsp; }

&nbsp;&nbsp;&nbsp; if(lockWasSuccessful == false) {  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Thread.Sleep(0);  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; continue;  
&nbsp;&nbsp;&nbsp; }

// If we reach here, the item was successfully locked

&nbsp;&nbsp;&nbsp; try {

// Application code goes here

&nbsp;&nbsp;&nbsp; }  
&nbsp;&nbsp;&nbsp; finally {  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Monitor.Exit(item);  
&nbsp;&nbsp;&nbsp; }

&nbsp;&nbsp;&nbsp; break;  
}

So, the secret here is that I use TryEnter to try to lock the object while the hashtable is locked. I then drop the lock on the hashtable and check to see if the TryEnter worked. If it did not, I just repeat the process. If it did, then I&#8217;m free to go do application stuff, remembering to drop the lock when I finish. Tres simple!

Does that solution make sense? It is the simplest one I can think of that satisfies my performance requirements. _Much_ more simple than the version number scheme I was using.

Any comments?

&#8212; bab

&nbsp;

**Now playing:** [Dream Theater][1] &#8211; Six Degrees Of Inner Turbulence (Disc 2) &#8211; [VIII. Losing Time &#8211; Grand Finale][2]

 [1]: http://phobos.apple.com/WebObjects/MZSearch.woa/wa/advancedSearchResults?artistTerm=Dream Theater
 [2]: http://phobos.apple.com/WebObjects/MZSearch.woa/wa/advancedSearchResults?songTerm=VIII. Losing Time - Grand Finale&artistTerm=Dream Theater