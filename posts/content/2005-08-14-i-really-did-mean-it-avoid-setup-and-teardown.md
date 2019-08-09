---
title: I really did mean it — avoid Setup and Teardown
author: Brian Button
type: post
date: 2005-08-14T15:51:00+00:00
url: /index.php/2005/08/14/i-really-did-mean-it-avoid-setup-and-teardown/
sfw_comment_form_password:
  - DqquFqHbuFvW
sfw_pwd:
  - hFdud6AwOhxS
categories:
  - 111

---
I&rsquo;m glad my post on [Assiduously Avoiding Setup and Teardown][1] has engendered so much conversation over the past few weeks. I&rsquo;m on vacation in Europe until August 15th, so I&rsquo;ve had spotty internet connectivity. On my few opportunities to check in, however, I&rsquo;ve seen a lot of activity on that post 🙂

Some of the activity concerned me, however. I really did mean what I say, and I can explain why.

**Simple Design**

Here is the crux of the issue. In the agile world, we are obligated to obey the practice of SimpleDesign. Simply put, this means that we have to eschew obfuscation and keep our code clear, simple, and clean. SimpleDesign is &ldquo;defined&rdquo; as an ordered list of characteristics that code should have. Reciting from memory (since I&rsquo;m&nbsp;4200 miles from home!),

  1. Code is appropriate for its audience
  2. Code communicates its intention clearly to its audience
  3. Each concept is expressed in code once and only once
  4. Code is expressed in as few classes as possible
  5. Code is expressed in as few methods as possible

These characteristics are expressed in this order for a reason &mdash; the ones at the top contribute more to creating simple code than those at the bottom. Therefore, to keep our code simple, we should try to apply all of these characteristics to our code, keeping in mind their ordering. So if there are tradeoffs to be made between the above-mentioned list items, we should always make them in favor of those items appearing higher in the list.

The result of all of that is that it is OK, and even appropriate, to trade off a little code duplication if it improves readability. I believe this is the case for avoiding Setup/Teardown. Let me explain a bit more&hellip;

**The Unique Mission of Programmer Tests**

If you&rsquo;ve made it this far, I have to assume that you&rsquo;re an evangelical, card-carrying TDDer. Great! This gives us some common ground from which to work. As you&rsquo;ve developed your classes and systems in this way, have you noticed differences between application code and test code?&nbsp;One big difference that I see all the time is that the application&nbsp;code is written to be easily changeable. The application changes all the&nbsp;time as you&nbsp;add new features, so that code is written to allow you to change it easily. It is malleable.

Test code, however, has a different mission. It is specifically written so that implementation changes&nbsp;should not cause test code changes. Test code, in fact, is written as an explanation&nbsp;of the functionality embodied in application code. It is written such that someone can easily understand what&nbsp;the application code _does_ without needing to delve into the application code itself.&nbsp;To fulfill this mission, the test code needs to be written with special care, so that it _can_ explain without requiring physical leaps around the code base. These jumps cause mental context switches that make it more difficult to create that same mental explanation.

**My Original Example**

In my previous post, I suggested this as a simple test.

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

In this test, you see the three main portions you would expect to see. In the Arrange portion, you see the system being set up. In the Act section, you see me poking at the system, trying to make something happen. And in the Assert part, you see me checking to make sure that the right thing happened. Simple test, declarative code, easy to read and understand, etc.

What makes this test simple to me is that its logic is entirely declarative. There is absolutely nothing in there except for declarations and imperatives. Create this, tell it to that, and check that it happened. Everything is all there, in one place.

**Rewritten with Setup**

So let&rsquo;s rewrite this test using the Setup metaphor, and see if that affects readability:

<pre>[SetUp]
        public void CreateObjects()
        {
            display = new MockDisplay();
            productList = new MockProductList();
            pos = new POS(display, productList);
        }

        [Test]
        public void CanShowPriceOfPretzels()
        {
            pos.DoSale("456");

            Assert.AreEqual("Pretzels", display.GetName());
            Assert.AreEqual("1.99", display.GetPrice());
        }
</pre>

In my mind, I think it is pretty obvious that this is less clear. I can&rsquo;t look at the test method alone and understand what is happening. On the other hand, this code is much more maintainable, since changes to how you create a POS are now all defined in one place. This would seem to point towards a spectrum, with independent understandability at one end, and complete maintainability at the other. The question we have to struggle with is where should our application code lie on this spectrum versus where test code should lie.

**Rewritten with manual Setup method**

Let&rsquo;s look at another option, which is to have a manual setup method that does the same thing that the [SetUp] method would do, but is explicitly called:

<pre>[Test]
        public void CanShowPriceOfPretzels()
        {<br />            CreateObjects();
            pos.DoSale("456");

            Assert.AreEqual("Pretzels", display.GetName());
            Assert.AreEqual("1.99", display.GetPrice());
        }

        private void CreateObjects()
        {
            display = new MockDisplay();
            productList = new MockProductList();
            pos = new POS(display, productList);
        }
</pre>

Again, this code is less clear than the first. It is also, as the immediately preceeding example, more maintainable. It could be argued that this is slightly more readable than the above example using the NUnit [SetUup] mechanism, but I don&rsquo;t believe they differ significantly. Let&rsquo;s place this just slightly more towards the Independent understandability than the previous example.

**Different missions, different audiences**

As I said above, the mission for application code is different from the mission for test code. Application code embodies business value. It changes fairly frequently, as requirements change force code changes. These changes are implemented through a mixture of refactoring and adding new code. Much of the value embodied in this code is tied up in a programmer&rsquo;s ability to change it easily, rapidly, and with low risk. This code needs to live on that same spectrum described above more towards the maintainability end. Understandabilty is still critically important, but maintainability is pretty important as well.

Test code _defines_ the business behavior. As shown above, it is simple, declarative in nature, and written in a standard Arrange/Act/Assert format. While refactorings to happen in this code, it is more rare than in application code. But this code is _read_ frequently, as developers try to understand how the&nbsp;business logic works. Any mental energy spent understanding how the tests work detracts from the amount of energy available to understand the important stuff &mdash; the application. This code needs to live more towards the independent understandability end of the spectrum.

**Counterpoints**

In some of the articles I&rsquo;ve read that have added onto my original posts, people have been discussing ways to create tests that are more maintainable.

One criticism stated that the duplication would make code changes so difficult that someone would either not make the change, or would just stop maintaining their tests, drifting away from TDD back into hacking and slashing. While I understand and appreciate this fear, I have not found the duplication to be as burdensome as intimated by this comment. First of all, if you have this same piece of code duplicated in _that_ many places, maybe there are some design issues that are lurking. I seldom have the 20 or more tests for a single class that some of the commenters described. I have to wonder if the class being tested, in that case, had too many responsibilities and was begging for a refactoring, or if the test was not written close enough to where the functionality was being implemented. Lots of time testing pain is a sign that there is something wrong with the design.

And someone else even suggested that you should ancillary classes to help you with making your tests more maintainable. These included creating factories that were used to create objects for each of your tests. I agree wholeheartedly that doing this will aid in creating more maintainable tests, but I firmly believe that it moves the test code towards the wrong end of that spectrum again. I don&rsquo;t want to distract my reader&rsquo;s eyes from the application logic, so I want to keep my test code brain-dead simple. Factories, polymorphic classes, and other highly necessary OO techniques detract from simplicity and understandability, and have no place in test code. They are fantastic in application code, and I use them all the time. Really, I do 🙂&nbsp;But I_&nbsp; do not_ put them into my test code.

**Conclusion**

I hope I&rsquo;ve at the very least convinced you that I meant what I originally said. I have thought about this extensively, and these are the conclusions I&rsquo;ve drawn from my introspection. Others are certainly free to balance the maintainence/readability forces differently, and I respect their conclusions. I, however, stand by what I said &mdash; Assiduously Avoid Setup and Teardown.

Let the comments fly!!!

&mdash; bab

&nbsp;

 [1]: http://www.agileprogrammer.com/oneagilecoder/archive/2005/07/23/6261.aspx