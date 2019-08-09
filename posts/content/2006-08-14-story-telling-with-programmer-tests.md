---
title: Story Telling with Programmer Tests
author: Brian Button
type: post
date: 2006-08-14T21:38:00+00:00
url: /index.php/2006/08/14/story-telling-with-programmer-tests/
sfw_comment_form_password:
  - Wo9KpaS0Pots
sfw_pwd:
  - c8xO7DQuFAV0
categories:
  - 111

---
(First test post with Windows Live Writer Beta&#8230;)

Here are the tests for a class I wrote a while ago. This class is used internally by the Caching Application Block inside the Enterprise Library. It has a bunch of housekeeping data inside of it, but the only really interesting behavior in it revolves around determining when an item in the cache is expired. The user is allowed to provide zero or more objects who can determine, in a manner of their own choosing, whether or not the item in question has aged too long and should be flushed from the cache.

What I hope to show, and what I&#8217;d love feedback on, is whether or not these tests tell you the story of this class. This&nbsp;test class is named CacheItemExpirationsFixture, which I hope gives you, as the programmer and reader,&nbsp;a clue that&nbsp;I&#8217;m going to be talking about CacheItem&#8217;s and how they are expired. And&nbsp;I truly hope that the names of the tests tell a progressive story about how this class was designed, what my intention was&nbsp;when I wrote&nbsp;each of the test methods, and would&nbsp;give someone else enough of a clue to be able to figure out which test to look at to learn something of interest about the class under test.&nbsp;

<pre>namespace Microsoft.Practices.EnterpriseLibrary.Caching.Tests
{
    [TestClass]
    public class CacheItemExpirationsFixture
    {
    [TestMethod]
        public void CanExpireCacheItemFromSingleExpirationObject()</pre>

<pre>[TestMethod]
        public void ItemShouldNotBeExpiredIfNoExpirationObjectIsExpired()

    [TestMethod]
        public void ItemNotExpiredIfAllExpirationsAreFalse()

    [TestMethod]
        public void ItemIsExpiredIfAllExpirationsAreTrue()

    [TestMethod]
        public void ItemIsExpiredIfAnyExpirationsAreTrue()

    [TestMethod]
        public void ItemIsNotExpiredIfNoExpirationsAreGiven()

    [TestMethod]
        public void ItemIsNotExpiredIfEmptyExpirationArrayIsGiven()

    [TestMethod]
        public void SingleExpirationIsNotifiedWhenCacheItemUpdated()

    [TestMethod]
        public void AllExpirationsNotifiedWhenCacheItemUpdated()

    [TestMethod]
        public void CtorForLoadingInitializesExpirationsToMatchLastAccessedTime()
    }
}</pre>

Now here is the body of one of the tests. It is short, declarative, and illustrative of the intent I had in mind as I wrote this test. All the tests in this class are similar to this, differing mostly in the details of what was being tested.

&nbsp;

<pre>[TestMethod]
        public void ItemIsExpiredIfAnyExpirationsAreTrue()
        {
            CacheItem cacheItem = new CacheItem("key", "value", CacheItemPriority.Normal, null, new NeverExpired(), new AlwaysExpired());
            Assert.IsTrue(cacheItem.HasExpired(),
                          "Any expirations in collection are expired, cache object is expired");
        }
</pre>

Now, its entirely possible that some of the details of the context might not be familiar to you, but hopefully the basic idea is. I create my object, call one of its methods, and ensure that the right thing has happened. The test is short, complete in and of itself, and hopefully pretty descriptive of the what I was trying to demonstrate.

The reason I&#8217;m writing this is that I&#8217;ve been seeing a lot of tests lately that do none of the things that I&#8217;ve just written about. They have a generically written test fixture name, the names of each individual test method are short, like _public void incrementCount()_, and the implementation of the test is long, twisted, complicated, and totally unrevealing of the intent of the person writing the test.

I&#8217;m hoping that this post can serve as a jumping off point for me to start blogging about what it takes to keep tests telling simple stories, and for having the tests drive a simple, yet complete, design into the application code. I intend this to be a continuing series on this topic, as I feel quite strongly about it. In my mind, the ability to create simple tests, have those tests tell a compelling story, and have the test methods themselves be an expression of my design intent, rather than an example of a messy implementation, is the key to really _getting_ TDD.

More (much more) later.

&#8212; bab