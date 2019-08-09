---
title: Interesting difference using nested test suites in JUnit versus NUnit
author: Brian Button
type: post
date: 2007-09-10T10:58:00+00:00
url: /index.php/2007/09/10/interesting-difference-using-nested-test-suites-in-junit-versus-nunit/
sfw_comment_form_password:
  - RXd3bd1nk6dQ
sfw_pwd:
  - B3F0V9XMgwEk
categories:
  - 111
  - 112

---
My friend, [Jim Newkirk][1], introduced me to a very nice way of partitioning programmer tests for a class as you write them. Most developers write a single test class for a single application class, and just dump all tests for that class in the same place. This is not as correct as it could be (that&#8217;s Consultant-Speak for &#8220;that&#8217;s just plain wrong&#8221;).

The accepted best practice is to group together tests that have the same setup/teardown logic into the same test fixtures, which can lead to having multiple fixtures for a single class. For example, when I build a Stack class, I generally have different fixtures for each of the different states that my Stack class can have, and I put a test into the correct fixture representing its starting state. For example, I might have states corresponding to

  * an empty stack
  * stack with a single element
  * stack with multiple elements
  * stack that is full

and so on. I would create a new fixture for each of these states, and use setup and teardown to push my system into the given state for that fixture. I know that this is a departure from my previous advice about [Assiduously Avoid Setup and Teardown][2], but I think I like where this leads me. I promise to post an example of writing tests like this over the next few days, but that example is not part of what I&#8217;m talking about here.

What I am talking about is an arrangement like this:

    [TestFixture]
    public class StackFixture
    {
        [TestFixture]
        public class EmptyFixture
        {
            [Test]
            public void ATest() {}
        }
    
        [TestFixture]
        public class SingleElementFixture
        {
            [Test]
            public void AnotherTest() {}
        }
    }
    

and so on. The main reason I like this arrangement of using nested fixtures is that it allows for me to separate out tests for different behaviors of my class into different fixtures, which lets me find them more easily and makes it easier to decide where to put new tests, and it lets me run all the tests for a particular class together at the same time. If I were to have several independent test fixtures, I would have no automated way of ensuring that I ran all of them together. The closest I could come would be to use categories, which is rather manual and error prone.

Now, what I just tried to do was to replicate this arrangement in Java, and it was harder to make it work. Using JUnit 3.8.1, I tried this:

    public class StackFixture extends TestCase {
        public static class EmptyFixture extends TestCase {
            public void testATest() {}
        }
    }
    

This gave me two tests run, one failing, so it found the test in the inner class, but found an error about no test being found in the outer fixture, StackFixture, so my tests could never all pass. I tried removing static from the class declaration, and then JUnit didn&#8217;t find the test in the inner fixture, and I still had the failure for no tests found. Clearly, not possible here.

Then I tried JUnit 4, which, like NUnit 2 and beyond, uses attributes to identify tests. In Java, they call them annotations, but they seem to be the same thing. Here is what I wrote:

    public class JUnitFourFixture {
        public  class StackEmptyFixture {
            @Test
            public void EmptyAtCreation() {
                Stack stack = new Stack();
    
                assertTrue(stack.isEmpty());
            }
        }
    }
    

When I ran this, I got an error popup saying that there were no tests found. Not a winner 🙁 But when I added static to the class declaration for the inner class, things did finally work beautifully. Here is the code that worked, with an extra fixture added just to be sure, and the inner classes made static. (BTW, for those of you who don&#8217;t know, there are two kinds of inner classes in Java. Inner classes without the static prefix belong to a particular instance of the enclosing class, so when you instantiate the outer class, you&#8217;re instantiating the inner class as well, and it has access to stuff in the outer object. If you have the static prefix, then the inner class is entirely independent of the outer class, just like inner classes in C#.)

    public class JUnitFourFixture {
        public static class StackEmptyFixture {
            @Test
            public void EmptyAtCreation() {
                Stack stack = new Stack();
    
                assertTrue(stack.isEmpty());
            }
        }
    
        public static class SingleElementFixture {
            @Test
            public void AnotherTest() {
                assertTrue(true);
            }
        }
    }
    

I don&#8217;t know how many of you didn&#8217;t know this, or never had a reason to care about this, but I am teaching a Java TDD course this week. Before I taught this, I wanted to make sure it worked!

&#8212; bab

 [1]: http://blogs.msdn.com/jamesnewkirk/
 [2]: http://www.agileprogrammer.com/oneagilecoder/archive/2005/07/23/6261.aspx