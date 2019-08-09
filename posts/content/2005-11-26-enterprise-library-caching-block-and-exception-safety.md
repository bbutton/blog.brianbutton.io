---
title: Enterprise Library Caching Block and Exception Safety
author: Brian Button
type: post
date: 2005-11-26T15:28:00+00:00
url: /index.php/2005/11/26/enterprise-library-caching-block-and-exception-safety/
sfw_comment_form_password:
  - jr5y1YRmoYUZ
sfw_pwd:
  - QTABJ7RMRUhP
categories:
  - 112
  - 115

---
Someone recently sent me some email after looking through my old Enterprise Library January, 2005 Caching block code, and asked to say a few words about the design of the exception safety of that block. This was one of the flaws in the original implementation of the Caching block that this newer implementation replaced. It had some thread safety issues, and it did not function well in the face of exceptions. Therefore, as one of the major design goals for my new implementation, exception safety became&nbsp;a very big concern.

What I wanted to do was set things up so that if an exception happened, I&rsquo;d recover from it gracefully, restore everything to the same state that it was in before the exception happened, and throw the exception back to the caller. Unfortunately, I couldn&rsquo;t do that, for reasons I&rsquo;ll talk about later. What I ended up doing was recovering from an exception by deleting the user&rsquo;s data stored at that caching key, leaving the system in a predictable state but with some limited data loss.

Before we talk about why I had to make that choice, l want to give you a bit of background on exceptions.

**What are exceptions?**

Exceptions represent a major advancement in handling errors that occur while a program is running. Being an old Unix hacker, I remember making a function call, getting back -1 as the return code and checking the global errno value for the failure reason. Then you&rsquo;d go check in errno.h to see if the error code held by errno represented a sytem-defined error. If so, you could call strerr to get the error text associated with that error. This text was not customizable at all, but just a bunch of standard strings that shipped with your operating system.

There were a few downsides to this design &mdash;

  * You had to explicitly check for error returns from function calls. If you didn&rsquo;t check, the error went unnoticed and unhandled
  * It was not remotely thread safe. Since errno was a global variable, it could be changed by any thread at any time. They eventually improved on this by changing errno from being an int into being a C macro that hid some thread-safe logic. Still, pretty ugly.

Contrast this with today&rsquo;s style of error checking, which involves creating, throwing, and catching exceptions, and you&rsquo;re left with a much more structured approach to handling errors in your system. Now, some piece of code can detect that some problem has happened, and it can raise a big, read, unignorable flag that someone higher up in the call chain has to deal with. You are allowed to customize the information contained in your exception through standard OO means, you can catch different of errors differently, leading to better encapsulation of error handling logic, and you can also centralize all your error handling in one place. And because of how throwing exceptions work, it is necesarily thread safe.

I know all of you already know most of this, but I like showing off my old, crusty Unix roots ![][1]

**What is exception safety?**

So let&rsquo;s think about what happens in your application when an exception is thrown. Basically, processing stops right then and there in that particular thread. Whatever that code was doing, it is interrupted, and the search for a matching catch block begins. The bad part about this is that any sort of resource management that you have carefully crafted is likely to be interrupted as well. So if you had any data structures you manipulating, or if you had any files opened, monitors locked, or whatever, you leave them in whatever state they were in when the exception happened, unless your code takes active measures to prevent this from happening. And the degree to which you go to prevent this dictates how strong an exception guarantee you can provide to your callers.

**Exception safety guarantees**

There are several levels of exception safety, describing the state in which a system is left after an exception is handled.

The first level is offering no guarantee. In this level, which is where, unfortunately most code lives, the state of the system is undefined after an exception is thrown. The code throwing the exception made no attempt to clean up, so any data structures that were in use could be corrupted, resources could have been leaked, and your disk could be reformatting right now&hellip;

In the second kind of exception safety guarantee, called the Basic Exception Safety Guarantee, the system is left in a stable condition, but something in it may have changed. This change is probably due to the application trying to do some cleanup action, based on recovering from the error. This is the kind of safety I promise in the caching block, and I&rsquo;ll explain why shortly.

The third kind of exception safety guarantee is the Strong Exception Safety Guarantee. With this promise, if an exception is thrown during an operation, the state of the system is left unchnaged from its original state. In other words, operations either succeed or fail, totally. This is the best kind of guarantee, but it is the pretty hard to provide.

Finally, the most strict exception safety guarantee is the No Throw Guarantee. This simply promises that exceptions will never leak out of a method. Any exceptions that are thrown internally are handled internally, and no one is the wiser. This is hardest one to provide reliably, mainly because it is not always clear how to react to an exception that is thrown at the at which it was thrown. I personally use this form of guarantee least, since I don&rsquo;t like mixing up the exception detection and reporting with the exception handling code. My feeling is that someone higher in the food chain probably knows more about handling this exception than me, and I should let them.

**Caching and the DataBackingStore**

Here is the basic algorithm I wanted to implement:

<font face="Courier New">public void Add(string key, object newValue)<br />{<br />&nbsp;&nbsp;&nbsp;&nbsp;if(ItemIsAlreadyInCache(key)<br />&nbsp;&nbsp;&nbsp;&nbsp;{<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; inMemoryCache.Remove(key);<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; databaseBackingStore.Remove(key);<br />&nbsp;&nbsp;&nbsp; }</p> 

<p>
  &nbsp;&nbsp;&nbsp; inMemoryCache.Add(key, object);<br />&nbsp;&nbsp;&nbsp; databaseBackingStore.Add(key, object);<br />}</font>
</p>

<p>
  The issue with this code is that it doesn&rsquo;t do anything in the face of exceptions. My caching block stores all its items in two places &mdash; in an in-memory hashtable for quick access and in some form of persistent storage to allow the cache to survive through an app recycle or something (think smart client). The first backing store I implemented used a database, so let&rsquo;s consider that. So let&rsquo;s imagine that we ran the code as written above. If an exception were to have happened after removing the item from the in-memory cache, then I&rsquo;d be stuck with the cache in an inconsistent state &mdash; the in-memory representation would not have an item that was still represented in the backing store. This is bad.
</p>

<p>
  We can get around this problem by reversing the order of those two calls &mdash;
</p>

<p>
  <font face="courier new">public void Add(string key, object newValue)<br />{<br />&nbsp;&nbsp;&nbsp;&nbsp;if(ItemIsAlreadyInCache(key)<br />&nbsp;&nbsp;&nbsp;&nbsp;{<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; databaseBackingStore.Remove(key);<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; inMemoryCache.Remove(key);<br />&nbsp;&nbsp;&nbsp; }</p> 
  
  <p>
    &nbsp;&nbsp;&nbsp; inMemoryCache.Add(key, object);<br />&nbsp;&nbsp;&nbsp; databaseBackingStore.Add(key, object);<br />}</font>
  </p>
  
  <p>
    We can do this, because we can depend on the database used in the backing store to promise us to abide by a strong exception guarantee. After all, data integrity is what databases are very good for. Since we can rely on the database to either completely remove the item or not touch it at all, we can make tha call first, and only remove the object from our in-memory cache if the first remove worked. And if it didn&rsquo;t work, an exception would be thrown, and we&rsquo;d be left right where we started. But what about the two Add calls &mdash; is there an order that we can put them in to make the add operation strongly exception safe as well? As a matter of fact, we need to do a little more restructuring to make that work, since the recovery operation is a bit more complicated.
  </p>
  
  <p>
    Let&rsquo;s assume that we switch around the order to be like this &mdash;
  </p>
  
  <p>
    <font face="courier new">public void Add(string key, object newValue)<br />{<br />&nbsp;&nbsp;&nbsp;&nbsp;if(ItemIsAlreadyInCache(key)<br />&nbsp;&nbsp;&nbsp;&nbsp;{<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; databaseBackingStore.Remove(key);<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; inMemoryCache.Remove(key);<br />&nbsp;&nbsp;&nbsp; }</p> 
    
    <p>
      &nbsp;&nbsp;&nbsp; databaseBackingStore.Add(key, object);<br />&nbsp;&nbsp;&nbsp; inMemoryCache.Add(key, object);<br />}</font>
    </p>
    
    <p>
      If an exception happens during the databaseBackingStore.Add call, we obviously shouldn&rsquo;t add the new element to the in-memory hash table, since that is a recipe for inconsistency. What we should do, in fact, is add the <em>old</em> item back in! If we&rsquo;re going to promise exception safety from this method, we need to arrange things so that the state of the underlying cache is unchanged after the exception. But what happens if the add of the old item to the databaseBackingStore fails? Now we&rsquo;re in really big trouble! Fortunately, what we can do is to defer the remove/add functionality to a single stored procedure with transactional characteristics, which would mean our code could now look like this &mdash;
    </p>
    
    <p>
      <font face="courier new">public void Add(string key, object newValue)<br />{<br />&nbsp;&nbsp;&nbsp; databaseBackingStore.Add(key, object);<br />&nbsp;&nbsp;&nbsp; inMemoryCache.Remove(key);<br />&nbsp;&nbsp;&nbsp; inMemoryCache.Add(key, object);<br />}</font>
    </p>
    
    <p>
      As long as we assume that the Remove and Add calls to the hashtable can never fail, and as long as the key isn&rsquo;t null they can&rsquo;t, we&rsquo;re finished! Yea!!!
    </p>
    
    <p>
      <strong>Enter the second backing store</strong>
    </p>
    
    <p>
      In addition to supporting persistence through a database, I had a requirement to support something called Isolated Storage, or IS for short. IS is a special place on your hard drive that windows arranges to always have writable for you, almost regardless of your current identity and permissions (not quite, but close enough for our purposes). IS acts just like its own little file system, with the ability to create directories and files in those directories. You have a limited subset of operations that you can perform on those files, which are creating directories and files, and removing directories and files. As we will see shortly, this is entirely insufficient for our needs.
    </p>
    
    <p>
      Let&rsquo;s start from this as our base attempt at getting an IsolatedStorageBackingStore to work &mdash;
    </p>
    
    <p>
      <font face="courier new">public void Add(string key, object newValue)<br />{<br />&nbsp;&nbsp;&nbsp;&nbsp;if(ItemIsAlreadyInCache(key)<br />&nbsp;&nbsp;&nbsp;&nbsp;{<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; isoStorageBackingStore.Remove(key);<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; inMemoryCache.Remove(key);<br />&nbsp;&nbsp;&nbsp; }</p> 
      
      <p>
        &nbsp;&nbsp;&nbsp; isoStorageBackingStore.Add(key, object);<br />&nbsp;&nbsp;&nbsp; inMemoryCache.Add(key, object);<br />}</font>
      </p>
      
      <p>
        And let&rsquo;s assume that there is an exception thrown for some reason during the isoStorageBackingStore.Add method call. What kinds of recovery actions can we take? In a perfect world, we&rsquo;d like to do as we did for the database backing store, and reset things to how they were before we started fiddling, but in this case, we can&rsquo;t. We could imagine some code that looked this as our attempt at error handling &mdash;
      </p>
      
      <p>
        <font face="courier new">public void Add(string key, object newValue)<br />{<br />&nbsp;&nbsp;&nbsp;&nbsp;if(ItemIsAlreadyInCache(key)<br />&nbsp;&nbsp;&nbsp;&nbsp;{<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; isoStorageBackingStore.Remove(key);<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; inMemoryCache.Remove(key);<br />&nbsp;&nbsp;&nbsp; }</p> 
        
        <p>
          &nbsp;&nbsp;&nbsp; try<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; isoStorageBackingStore.Add(key, object);<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; inMemoryCache.Add(key, object);<br />&nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; catch(Exception)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; isoStorageBackingStore.Add(key, originalObject);<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; inMemoryCache.Add(key, originalObject)<br />&nbsp;&nbsp;&nbsp; }<br />}</font>
        </p>
        
        <p>
          And this would leave the cache how we found it. But we have no assurances whatsoever that the re-adding of the original object is going to succeed. If it fails, we&rsquo;re left with a cache in an unpredictable state, which clearly violates our Strong Exception Safety guarantee.
        </p>
        
        <p>
          Going back to my Unix roots, I learned long ago that there is only one safe way to deal with replacing files in a file system, and that involves a 3&ndash;step operation:
        </p>
        
        <ol>
          <li>
            Rename the original file to a new name
          </li>
          <li>
            Insert the new file
          </li>
          <li>
            Remove the old file
          </li>
        </ol>
        
        <p>
          And if the insertion of the new file failed, you simply rename the old file back to its original name, and you&rsquo;re back where you started, and everyone is happy. You really need the rename functionality to make this work, as it doesn&rsquo;t use up file system resources, other than the equivalent of a directory slot (inode). Renames are considered to be pretty safe things to do, in that they don&rsquo;t fail, or they fail really quickly. If you don&rsquo;t have permission to rename the file, the rename fails immediately. If you are out of inodes in your file system, the call fails immediately. And so on. If you contrast this with an Add operation, there are lots of reasons they can fail. But if the add does fail, you clean up the resources it used, which should leave enough resources to be able to rename the old file back. And IS lacks this rename capability. Without it, it is impossible to create a backing store that can promise a strong guarantee. Which is exactly why I had to change to offering the Basic Exception Safety guarantee.
        </p>
        
        <p>
          And this is also why the Caching Block promises that it will remove any traces of any object that is being added or removed from the cache when an exception happens. The basic algorithm for adding something to the cache becomes something like this &mdash;
        </p>
        
        <pre>        public void Add(string key, object value, CacheItemPriority scavengingPriority, ICacheItemRefreshAction refreshAction, params ICacheItemExpiration[] expirations)
        {
            ValidateKey(key);
            EnsureCacheInitialized();

            CacheItem cacheItemBeforeLock = LockItemInCache();</pre>
        
        <pre>            try
            {
                CacheItem newCacheItem = new CacheItem(key, value, scavengingPriority, refreshAction, expirations);
                try
                {
                    backingStore.Add(newCacheItem);
                    cacheItemBeforeLock.Replace(value, refreshAction, scavengingPriority, expirations);
                    inMemoryCache[key] = cacheItemBeforeLock;
                }
                catch
                {
                    backingStore.Remove(key);
                    inMemoryCache.Remove(key);
                    throw;
                }
            }
            finally
            {
                Monitor.Exit(cacheItemBeforeLock);
            }
        }
</pre>
        
        <p>
          And the backingStore.Add looks like this, refactored into a class called BaseBackingStore &mdash;
        </p>
        
        <pre>       public virtual void Add(CacheItem newCacheItem)
        {
            try
            {
                RemoveOldItem(newCacheItem.Key.GetHashCode());
                AddNewItem(newCacheItem.Key.GetHashCode(), newCacheItem);
            }
            catch
            {
                Remove(newCacheItem.Key.GetHashCode());
                throw;
            }
        }
</pre>
        
        <p>
          Please try to ignore the ugly implementation details above. There were some implementation issues with IsolatedStorage and path lengths that caused some problems. The essence of the solution, however, is that if anything goes wrong, immediately begin removing whatever we&rsquo;ve touched, so we can at least leave the cache in a predictable state so someone can continue to use it.
        </p>
        
        <p>
          The biggest downside of the&nbsp;inability of IS to do what I needed is that I had to&nbsp;change the DataBackingStore class to work the same way.&nbsp;I&rsquo;d much rather offer the strong guarantee for the DataBackingStore, but then the two backing stores I implemented wouldn&rsquo;t be substitutable for each other, and&nbsp;Barbara Liskov would be very unhappy with me!
        </p>
        
        <p>
          <strong>Conclusion</strong>
        </p>
        
        <p>
          Boy, that was probably my longest&nbsp;blog posting yet! I wanted to share the whole thought process of how I went from really trying to get the best exception guarantee I could out of my code, and why I had to compromise. If I&rsquo;ve left any questions unanswered, or wasn&rsquo;t clear about something, please let me know, and I&rsquo;ll add even more to this tome. Thanks for&nbsp;reading, and I hope it was interesting,
        </p>
        
        <p>
          &mdash; bab
        </p>
        
        <p>
          &nbsp;
        </p>

 [1]: http://www.agilestl.com/private/blog/smile1.gif