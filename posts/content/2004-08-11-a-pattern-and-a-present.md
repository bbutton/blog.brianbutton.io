---
title: A Pattern and a Present
author: Brian Button
type: post
date: 2004-08-11T05:33:00+00:00
url: /index.php/2004/08/11/a-pattern-and-a-present/
sfw_comment_form_password:
  - 1NorAlT4KHgU
sfw_pwd:
  - 8luXzesGwvNm
categories:
  - 115

---
## What&#8217;s In a Name


  
It&#8217;s 1995, and the GoF book had just been published. For those of you who do not know what the GoF book is, it is the original Design Patterns book, written by Ralph Johnson, Erich Gamma, John Vlissides, and Richard Helm. At that point in time, very few developers had ever heard of patterns as reusable problem solutions. I was fortunate to be hooked in with some very smart people, so I was pushed towards reading this book, and it has served me well to this day.

Cut to 2004, almost 10 years after this book was published, and still, very few programmers have read this book. This book contains such important knowledge that it should be read cover to cover by anyone developing OO software. In addition to the patterns described in this book, there are thousands more patterns available on the web, in books, in magazines, and in the heads of your fellow developers. Each of these patterns represents some practical knowledge that you can use to solve an interesting problem the next time you face it.

For example&#8230;

I was implementing a cache library the other day, very much like the ASP.Net cache, with a few more features to it. The basic operation of this cache is pretty simple, in that it just takes keys and values provided by the user and stores them both into an in-memory table, and into a replaceable backing store. The backing store can be nothing, to provide only in-memory functionality, or it can be SQLServer, Isolated Storage, files, etc. Everything happens in the same thread as the caller, with respect to adding, removing, finding, etc.

But, there are background operations that go on as well. Every so often, a piece of the cache wakes up and wanders through the items in the cache and checks to see if any of them consider themselves to be expired, according to criteria and policies provided by the user. And after each add is done, the cache goes through and makes room for subsequent adds based on a scavenging algorithm. As I said, both of these operations go on in the background, as the user is adding, removing, etc, stuff from the cache in multiple application threads. Given the opportunity, there is every chance that I could have multiple expirations and scavengings happening at the same time, which would be a nightmare to manage. So I was looking for a solution to serlialize these requests without adding a ton of extra complexity to the code, and without changing anything in the client code.

What really needed to happen was that I needed to have the client code call the existing background task scheduler in the same way as always, but the background scheduler needed to be made a little smarter. This was the perfect place to apply the [Active Object][1] pattern. Active Object is a tool you can use to allow a server object, like our background scheduler, to receive requests from callers, in the thread of the caller, and execute that request in the server&#8217;s own thread. The way it does this is through some extra machinery that allows it to [reify][2] the request into a Command object (Command is one of those GoF patterns. I&#8217;ll show an example in a minute.), store it into a special kind of queue called a Producer/Consumer Queue, and have the scheduler pull the request off the queue in the scheduler&#8217;s thread. Now it can execute the requests one at a time, without having to worry about implementing some sort of complicated locking system, etc.

This blog entry has gotten pretty long, so I&#8217;m going to end it here. I&#8217;ll start putting up code samples later, to better explain what I was talking about.

 [1]: http://www.cs.wustl.edu/~schmidt/PDF/Act-Obj.pdf
 [2]: http://dictionary.reference.com/search?q=reify