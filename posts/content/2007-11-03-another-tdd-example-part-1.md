---
title: Another TDD example – Part 1
author: Brian Button
type: post
date: 2007-11-03T06:25:00+00:00
url: /index.php/2007/11/03/another-tdd-example-part-1/
sfw_comment_form_password:
  - eHHzTRUZDYj8
sfw_pwd:
  - 5ufQEYw15znu
categories:
  - Uncategorized

---
Title: Solution to Class Exercise

As described in class:

I have books &#8212; too many books. They are all over the floor, I trip over them. I can&#8217;t keep track of all the different books I have. I really need a book list manager. Please build one for me.

Here is the list of stories I give the students, and I ask for them in somewhat random order.

    I should be able to see a list of my books, sorted alphabetically by title
    I should be able to see all books in a specific genre
    I should be able to read in a list of books from a text file
    I need to know the current price of a book
    I want to sort books according to price
    I want to be able to add a new book to my list
    I want to be able to save my list of books to a text file
    I want to be able to mark books as having been read
    I want to be able to find which books have been read
    I want to sort books by genre and title
    
    BookID  |Title                          |Genre          |HasBeenRead
    1       |Clifford Goes To College       |Childrens      |Y
    2       |Have Space Suit, Will Travel   |ScienceFiction |N
    3       |Goedel, Escher, and Bach       |Science        |N
    4       |Elegant Universe               |Science        |Y
    5       |Life in 1000 AD                |History        |N
    6       |1001 Ways to Cook a Cat        |Cooking        |N
    

**Story 1 &#8212; Give me a list of books sorted by title**

Most basic functionality in system. I just need to get a list of my books. I&#8217;ll invent some way to get a list of books into my system later, but for now, assume I have a list, and show them to me in some way sorted alphabetically.

I start by writing a test, being the good TDD programmer. Here is my first test:

    [TestFixture]
    public class BookListManagerFixture
    {
        [Test]
        public void EmptyBookListReturnsNothing()
        {
            BookListManager manager = new BookListManager();
    
            List<Book> sortedBookList = manager.GetSortedBookList();
    
            Assert.IsEmpty(sortedBookList);
        }
    }
    

This is the simplest test I can write to get the ball rolling. I&#8217;m starting to get the feel for the API, seeing how to create a BookListManager, how to talk to it, and its basic empty behavior. It&#8217;s pretty apparent to me that I&#8217;m going to be managing a list of 0 or more books. When I am presented with a problem that requires me to handle many items, I generally try to handle three cases, in this order:

  * 0 &#8211; Let&#8217;s me get the problem set up, and get feel of the API
  * 1 &#8211; Gets the business logic in the problem correct
  * many &#8211; Makes me write the looping logic for already working business logic.

And now the simple code to get the previous test to compile. I created an empty Book class. I guess I don&#8217;t strictly need a Book class yet, but this application is all about managing lists of books. I&#8217;m willing to go out on a limb to guess about a book class, but I don&#8217;t know what is in yet.

    public class Book
    {
    }
    

Here is the first shot at a BookListManager. Basic, simple, doesn&#8217;t do anything yet. It exists just to fail my test.

    public class BookListManager
    {
        public List<Book> GetSortedBookList()
        {
            return null;   
        }
    }
    

This leads me to implement the simplest code I can to get this test to pass:

    public class BookListManager
    {
        public List<Book> GetSortedBookList()
        {
            return new List<Book>();   
        }
    }
    

Now my GetSortedBookList class returns an empty list, which allows my test to pass, trivially. An important thing to note, however, is that I&#8217;m making a statement about how my code acts when the collection it is asked to sort is empty. This behavior has to work now, it has to work tomorrow, and it has to work forever. If I were to skip writing this test, I&#8217;d always have that nagging doubt about how my system acted in this situation.

> Rule &#8212; Always write tests for trivial boundary condition cases. They have to work, so they need tests. The tests are easy to write, so write &#8216;em! 

Now the test for a single item in the list. Again, this test should be trivial, but we have to document and prove the behavior for this case, which requires a test to be written.

    [Test]
    public void SingleBookInListIsReturnedAsSortedList()
    {
        BookListManager manager = new BookListManager();
        manager.Add(new Book());
    
        List<Book> sortedBookList = manager.GetSortedBookList();
    
        Assert.IsNotEmpty(sortedBookList);
    }
    

So, this is a logical second test. I needed to add a book into my list somehow, and I found one of the many ways to do this. There are several ways to get the book into the system, some of them better than others. The easiest way of doing it is to just add an Add method to the BookListManager. This way, you can add new books to the list in the Arrange section of your test, putting the test data and test behavior in the same place, which is always a good thing.

The assert in this test just checks to make sure that there is something in our list of books, which is OK, but is not what I would consider to be a strong assertion. What we really mean is that there is a book, and, in fact, it is the _same_ book as we put in. Since we&#8217;re sorting based on title, perhaps this is a good time to give a book a Title property, to allow us to assert a bit more about this solution.

        [Test]
        public void SingleBookInListIsReturnedAsSortedList()
        {
            BookListManager manager = new BookListManager();
            manager.Add(new Book("My Title"));
    
            List<Book> sortedBookList = manager.GetSortedBookList();
    
            Assert.AreEqual(1, sortedBookList.Count);
            Assert.AreEqual("My Title", sortedBookList[0].Title);
        }
    }
    

This test is essentially the same, but it has a stronger assertion &#8212; the output list has a single element in it, and that element has the same title as the book that we put in. That&#8217;s about the strongest assertion that we can make at this point. Note that I didn&#8217;t use Assert.AreSame to ensure that the Book object put into the list and the Book object returned from the list are the _same_ object, as that would imply an implementation decision. Eventually, I&#8217;m going to want to implement Book.Equals, so I don&#8217;t have to manually compare books by inspecting their properties.

Implementing this functionality is trivial:

    public class Book
    {
        private readonly string title;
    
        public Book(string title)
        {
            this.title = title;
        }
    
        public string Title
        {
            get { return title; }
        }
    }
    
    public class BookListManager
    {
        private readonly List<Book> bookList = new List<Book>();
    
        public List<Book> GetSortedBookList()
        {
            return bookList;  
        }
    
        public void Add(Book book)
        {
            bookList.Add(book);
        }
    }
    

OK, now its time for the _many_ test. Here is my first shot at this test. **Note that this is wrong, wrong, wrong**.

    [Test]
    public void MultipleBooksAreReturnedInSortedByTitleOrder()
    {
        BookListManager manager = new BookListManager();
        manager.Add(new Book("AAA"));
        manager.Add(new Book("BBB"));
    
        List<Book> sortedBookList = manager.GetSortedBookList();
    
        Assert.AreEqual(2, sortedBookList.Count);
        Assert.AreEqual("AAA", sortedBookList[0].Title);
        Assert.AreEqual("BBB", sortedBookList[1].Title);
    }
    

This looks like a pretty reasonable test to write, and it is, save for one important detail. It won&#8217;t ever fail. Many a rookie (and experienced!) TDD&#8217;er has left out the step of watching a test fail before implementing it. In this case, this test would have passed the first time it was run. When that happens, you should immediately react by thinking, &#8220;Huh? WTF?&#8221; Tests that pass the first time should be viewed with lots and lots and lots of skepticism. In this case, we added to books to the BookListManager in pre-sorted order, so no sorting was necessary to make the test pass. Since writing the sorting behavior is an important part of the method we&#8217;re writing, and the test isn&#8217;t forcing us to write any sorting behavior at all, I&#8217;d say this was a bad test. 2 lessons to take from this:

> **Always** watch your tests fail before implementing the logic
> 
> Care must be taken when crafting test data to have it force you down the path you need to take 

Let&#8217;s try that test one more time, with better test data, and watch it fail:

        [Test]
        public void MultipleBooksAreReturnedInSortedByTitleOrder()
        {
            BookListManager manager = new BookListManager();
            manager.Add(new Book("BBB"));
            manager.Add(new Book("AAA"));
    
            List<Book> sortedBookList = manager.GetSortedBookList();
    
            Assert.AreEqual(2, sortedBookList.Count);
            Assert.AreEqual("AAA", sortedBookList[0].Title);
            Assert.AreEqual("BBB", sortedBookList[1].Title);
        }
    }
    

There was a little bit of work necessary to get this test to pass. My first attempt was to add a bit of code to the BookListManager.Sort method:

    public List<Book> GetSortedBookList()
    {
        bookList.Sort();
        return bookList;
    }
    

First of all, I hate this code. I hate for about 92 different reasons. The first is that I hate having to separate the two lines of implementation, but List<T>.Sort() returns void. Second, and equally hateful, is that it sorts the list in place. What I would really like is `List<T> List<T>.Sort()`, a method that Sorts the underlying list and returns me a sorted copy of it, leaving the original list untouched. I have a feeling they made this choice because it gives me the option of copying the list first by myself or just sorting the list in place. If they did what I was suggesting, then there would be no way to sort a list in place, which may be a desired behavior in some cases. Hey, developing software is all about making choices, right? I do have a solution to the problem involves using Extension Methods from C# 3.5 that I&#8217;ll post another day.

The other thing I didn&#8217;t like about this code is that it didn&#8217;t work 🙁 My problem is that the Sort() method requires that the objects being sorted be comparable in some way. The easiest way is to make my Book class implement IComparable<Book>, or I could create a BookComparator that implements IComparator<Book> and move this functionality outside of Book itself. I chose the former, as it seems simpler for right now. This required me to write some code in the Book class, which is a danger sign.

> A fixture for one class should not force you to add code into a different class. Write a separate fixture. The first fixture describes the need, the second fixture drives the implementation. 

Since I need to add functionality into the Book class, I really need a BookFixture. I&#8217;m going to comment out my original test, create the functionality I need in the BookFixture, and then return to my original test. This jumping from test to test is actually very common. Here is my BookFixture and Book code to implement IComparable<Book>:

    [TestFixture]
    public class BookFixture
    {
        [Test]
        public void BookWithTitleBeforeSecondBookReturnsNegativeCompareToValue()
        {
            Book before = new Book("A");
            Book after = new Book("B");
    
            Assert.Less(before.CompareTo(after), 0);
        }
    
        [Test]
        public void BookWithTitleAfterSecondBookReturnsPositiveCompareToValue()
        {
            Book after = new Book("B");
            Book before = new Book("A");
    
            Assert.Greater(after.CompareTo(before), 0);
        }
    
        [Test]
        public void BooksWithSameTitleReturnZeroCompareToValue()
        {
            Book same1 = new Book("A");
            Book same2 = new Book("A");
    
            Assert.AreEqual(0, same1.CompareTo(same2));
        }
    }
    
    public class Book : IComparable<Book>
    {
        private readonly string title;
    
        public Book(string title)
        {
            this.title = title;
        }
    
        public string Title
        {
            get { return title; }
        }
    
        public int CompareTo(Book other)
        {
            return title.CompareTo(other.title);
        }
    }
    

That&#8217;s some pretty exhaustive testing! To be very honest, the second and third tests passed the first time I ran them. I kind of expected that, as I had only one line of code to write to invoke the correct CompareTo behavior for the entire class, and I wrote that to get the first test to pass. I still wrote the remaining tests, and I&#8217;d recommend that anyone else write these tests, as a way of clearly documenting the correct behavior. I have to admit that I always forget how CompareTo works with respect to which way the comparison works. I figure that if I have a problem with it, others may also, so I document the daylights out of it 😉

Now when we go babck to our original test, it works now that I&#8217;ve implemented the IComparable<Book> functionality on Book.

Here is the final BookListManagerFixture and BookListManager code to go with the BookFixture and Book classes above:

    [TestFixture]
    public class BookListManagerFixture
    {
        [Test]
        public void EmptyBookListReturnsNothing()
        {
            BookListManager manager = new BookListManager();
    
            List<Book> sortedBookList = manager.GetSortedBookList();
    
            Assert.IsEmpty(sortedBookList);
        }
    
        [Test]
        public void SingleBookInListIsReturnedAsSortedList()
        {
            BookListManager manager = new BookListManager();
            manager.Add(new Book("My Title"));
    
            List<Book> sortedBookList = manager.GetSortedBookList();
    
            Assert.AreEqual(1, sortedBookList.Count);
            Assert.AreEqual("My Title", sortedBookList[0].Title);
        }
    
        [Test]
        public void MultipleBooksAreReturnedInSortedByTitleOrder()
        {
            BookListManager manager = new BookListManager();
            manager.Add(new Book("BBB"));
            manager.Add(new Book("AAA"));
    
            List<Book> sortedBookList = manager.GetSortedBookList();
    
            Assert.AreEqual(2, sortedBookList.Count);
            Assert.AreEqual("AAA", sortedBookList[0].Title);
            Assert.AreEqual("BBB", sortedBookList[1].Title);
        }
    }
    
    public class BookListManager
    {
        private readonly List<Book> bookList = new List<Book>();
    
        public List<Book> GetSortedBookList()
        {
            bookList.Sort();
            return bookList;
        }
    
        public void Add(Book book)
        {
            bookList.Add(book);
        }
    }
    

**Next up**

In the next installment, I&#8217;ll take a book list and filter it by genre. Coming soon to a theater near you 🙂

&#8212; bab