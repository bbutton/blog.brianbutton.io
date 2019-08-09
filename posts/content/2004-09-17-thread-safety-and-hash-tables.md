---
title: Thread-safety and hash tables
author: Brian Button
type: post
date: 2004-09-17T08:15:00+00:00
url: /index.php/2004/09/17/thread-safety-and-hash-tables/
sfw_comment_form_password:
  - 1GjBxH6lDMIJ
sfw_pwd:
  - oKF3j6qtytj9
categories:
  - 112
  - 115

---
I&#8217;m storing information in a hashtable. The information is keyed off a string, and the key is volatile &#8212; items can be removed, added, replaced, etc., from the hash table. The problem that I&#8217;m studying is how to manipulate this information in a thread-safe way without locking the entire hash table all the time and killing performance.

Solution number 1 was to lock the entire hash table during each operation on the data in the hash table. I had code like this:

lock(hashtable) {  
&nbsp; Item item = (Item)hashtable[key];  
&nbsp; item.SetName(&#8220;foo&#8221;);  
&nbsp; database.Persist(item);  
}

The problem with this is that I couldn&#8217;t take advantage of SQLServer&#8217;s ability to handle several database operations simultaneously. In the presence of lots of threads, my CPU usage in this style never got about 50% or so, indicating that there was lots of contention for the lock that was preventing any parallelism entirely (kind of the point of threads, eh???)

Next attempt was the naive way:

Item item = (Item)hashtable[key];  
lock(item) {  
&nbsp; item.SetName(&#8220;foo&#8221;);  
&nbsp; database.Persist(item);  
}

Obviously not thread safe. Between the first and second line, someone can come in and delete or replace the item in the hash table, so I could be dealing with old data, possibly persisting data to the database that is stale and overwriting the new data. This is bad.

Next attempt was to be a little clever and wrap the data in the cache with an object that was longer-lived than an individual cache item. This way the above attempt was OK to do, because I was always guaranteed that the wrapper was the same and I could lock it to prevent changes to its contents. It looked something like this:

ItemWrapper wrapper = (ItemWrapper)hashtable[key];  
lock(wrapper) {  
&nbsp; Item item = wrapper.Item;  
&nbsp; item.SetName(&#8220;foo&#8221;);  
&nbsp; database.Persist(item);  
}

Our problem here was that I could never get rid of these wrappers. Once in the hashtable, they had to live there forever. If I did start getting rid of them, I&#8217;d get right back into the same place where I was before with the race condition between getting stuff out of the cache and locking it.

What I really wanted was a single method call that I could make on a hashtable that would return me an Item from the hashtable already locked, and locked in a thread-safe way. And I couldn&#8217;t lock the hashtable while I was trying to lock the Item, because that would lead to the same performance problems that I had originally. So what was I to do????

Well, I started looking at Optimistic Locking as a way around this. I embedded a version number inside my Item object and started doing various manipulations to that version number in an attempt to satisfy all my requirements. But this is getting very complicated, and I&#8217;m still not convinced of my thread safety.

So, my question for you, my loyal reader (all 1 of you :))&#8230; Have I missed something? Is there some other, simpler&nbsp;way of approaching this problem that I missed? Any comments and hints appreciated.

&#8212; bab

&nbsp;

**Now playing:** [Dream Theater][1] &#8211; [Hollow Years][2]

 [1]: http://phobos.apple.com/WebObjects/MZSearch.woa/wa/advancedSearchResults?artistTerm=Dream Theater
 [2]: http://phobos.apple.com/WebObjects/MZSearch.woa/wa/advancedSearchResults?songTerm=Hollow Years&artistTerm=Dream Theater