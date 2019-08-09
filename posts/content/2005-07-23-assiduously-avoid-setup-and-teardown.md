---
title: Assiduously avoid Setup and TearDown!!
author: Brian Button
type: post
date: 2005-07-23T10:40:00+00:00
url: /index.php/2005/07/23/assiduously-avoid-setup-and-teardown/
sfw_comment_form_password:
  - bIEVkSGj4OdY
sfw_pwd:
  - NXtEWV4Zz9au
categories:
  - 111

---
Enough people have been ragging on me for not having blogged anything significant for a while that I thought I&rsquo;d make use of my airplane time to say something that might actually matter (as opposed to whining about various .Net features that I don&rsquo;t like :)). So here goes&hellip;

**Setup and Teardown Are _Evil_**

When writing tests in NUnit, JUnit, and probably most of the other xUnits around town, you have the ability to share setup and teardown logic between tests. We were originally taught that any sort of replicated setup and teardown logic should be factored out to these special places, so that it was in our code Once and Only Once.

Well, during my travels through the test first world, I like to think I&rsquo;ve learned a few things. One of the more interesting things that I think I&rsquo;ve learned is that tests need to be understandable with the least amount of effort possible if they are going to serve their purpose of documentation. And I personally think that Setup and TearDown inhibit readability.

**An Example**

Here are some sample tests from some old code I have lying around. This is from a system that implements a very simple point of sale system &mdash; a fancy cash register. Theses are specifically tests around the PointOfSale class, which is the driver for the entire system. Take a look at this one test and see what you can infer from it:

<pre>[Test]
        public void CanShowPriceOfPretzels()
        {
            MockDisplay d = new MockDisplay();
            MockProductList p = new MockProductList();
            POS pos = new POS(d, p);

            pos.DoSale("456");

            Assert.AreEqual("Pretzels", d.GetName());
            Assert.AreEqual("1.99", d.GetPrice());
        }</pre>

From my point of view, the first and most important thing that I can infer from this is something key about the architecture &mdash; the POS class uses a Display instance and a ProductList. This gives me the shape of the system, and helps me understand what the test does.&nbsp; It sure seems like the POS must take in a bar code, look up what product it maps to using the ProductList, and finally display the information onto the Display. Admittedly, this exsample is a bit trivial, but there is a wealth of information to be gained by looking at this test. 

Let&rsquo;s look at another test in the same fixture:

<pre>[Test]
       public void NothingDisplayedAtStartup()
       {
           MockDisplay d = new MockDisplay();
           MockProductList p = new MockProductList();
           POS pos = new POS(d, p);

           Assert.AreEqual("", d.GetName());
           Assert.AreEqual("0.00", d.GetPrice());
       }</pre>

As you&nbsp;can see, the first three lines are absolutely identical.&nbsp;Let&rsquo;s go ahead and refactor these two tests to share their common setup logic and see how that affects the tests:

<pre>[TestFixture]
    public class POSFixture 
    {
        private MockDisplay display;
        private MockProductList productList;
        private POS pos;

        [SetUp]
        public void CreateObjects()
        {
            display = new MockDisplay();
            productList = new MockProductList();
            pos = new POS(display, productList);
        }

        [Test]
        public void NothingDisplayedAtStartup()
        {
            Assert.AreEqual("", display.GetName());
            Assert.AreEqual("0.00", display.GetPrice());
        }

        [Test]
        public void CanShowPriceOfBeer()
        {
            pos.DoSale("123");

            Assert.AreEqual("Beer", display.GetName());
            Assert.AreEqual("2.99", display.GetPrice());
        }

        [Test]
        public void CanShowPriceOfPretzels()
        {
            pos.DoSale("456");

            Assert.AreEqual("Pretzels", display.GetName());
            Assert.AreEqual("1.99", display.GetPrice());
        }
    }</pre>

Here we see the entire test fixture in all its glory. And if we look at each of the tests, it is very easy to see exactly what that test does to the system and its intended effect. But in my mind you completely and totally lose the context of the system. To understand what&nbsp;the test is poking and prodding at, you have to&nbsp;tear your eyes&nbsp;away from the test and go find&nbsp;the setup method. I think this makes each individual test harder to understand.&nbsp;It also would make an automated documentation tool harder to write as well, since it would have to somehow bring along enough context to explain the test.

**What about Once and Only Once?**

I fully understand,appreciate, and follow&nbsp;the Once and Only Once (OAOO) mantra of the agile movement. But this mantra has to be taken in its context &mdash; it is a part of the definition of SimpleDesign. SimpleDesign means to write the system such that these things are true:

  1. Code is appropriate for its audience
  2. Communicates its intent clearly
  3. Each concept is represented once and only once
  4. Expressed in as few classes as possible
  5. Expressed in as few methods as possible

_in that order!_ If you look carefully at that list, communication is #2 on the list, while OAOO is #3. This means the communication trumps a little duplication. Part of becoming more experienced at TDD, Refactoring, and Simple Design is knowing when it is appropriate to leave in a little duplication to enhance communication. And I think this is one of those times.

There is definitely a price to pay for it, however. Since the setup and teardown logic are potentially duplicated among a bunch of similar unit tests, you have to change each of them individually should the logic change. I&rsquo;ve paid that price a bunch of times in the past, but I _still_ believe that the gains in communication outweigh the cost of the replicated changes. YMMV 🙂

**When _should_ Setup and TearDown be used?**

There are still some places that are very appropriate for using Setup and TearDown. In my mind, these are used for resource management. If I had a dime for every time I see someone put some cleanup code after the asserts in a test, I&rsquo;d be rich beyond my wildest dreams 🙂 What they apparently don&rsquo;t understand is that if an assert fires, you exit the test right then and there, and your fancy cleanup logic never happens. Those with an appreciation for this fact have been known to encapsulate their tests with try/finally blocks, just to ensure that their cleanup happens.

It is this logic that I think deserves to be factored out. The cleanup logic is _not_ part of the context for understanding the test, it is part of the plumbing that makes the test run. I fully and completely believe that this kind of logic needs to be factored out of each test and put someplace else. In fact, having it in the test confuses the issues and obscures the actual purpose of the test. By moving it into Setup and TearDown, you leave just that code in the test methods that really do establish the context of the test.

Examples of this kind of logic would include:

  * Resource management for opening and closing files, sockets, or other resources
  * Resetting housekeeping variables defined, managed, and manipulated in the tests themselves
  * Stuff you darn well want to make sure happens before and especially after each test.

I followed this pattern when I was writing tests for the Caching block in the Enterprise Library. One of the features of the Caching block was that it could store data into either a database or isolated storage. This storage is persistent, which meant that I had to make very, very sure that these resources were reset to known states before I could reliably run each test. So what I did was to clear out this persistent state before each test ran in the Setup method. I also made sure to clear out this persistent state after the last test was finished, so that the next fixture that ran could be assured that the state was clear. This last little hint was a hard-learned lesson where tests began to fail based on the order in which they ran, causing me to spend a few hours trying to track down why it was happening. It was at that point that I started making a point of cleaning up at the end as well 🙂

&mdash; bab

&nbsp;

&nbsp;