---
title: Episode 2 – Filtering by Genre
author: Brian Button
type: post
date: 2007-11-05T14:16:00+00:00
url: /index.php/2007/11/05/episode-2-filtering-by-genre/
sfw_comment_form_password:
  - TP9N0RXAs3fv
sfw_pwd:
  - tunZiR9kGQCk
categories:
  - Uncategorized

---
> Update &#8212; Craig Buchek pointed out something about one of my tests that he didn&#8217;t like. My test entitled PresortedBookListWithSomeBooksInCorrectGenreOnlyReturnsBooksInCorrectGenre made an assumption about data ordering that was stronger than was necessary for the intent of the test. I didn&#8217;t need to show that the elements came out of the filtered list in sorted order for that test &#8212; I only needed to show that the elements were present in the filtered list. I&#8217;ve updated the area around that test with new content explaining the interesting lesson that Craig taught me. Thanks to Craig and all the participants on the XPSTL list. 

OK, time for story number 2 &#8212;

    I want to see just those books that are in a specific genre, sorted by title, so that I can survey which books I have on particular topics.
    

Fortunately for us, this turns out to be trivial in .Net 2.0 (Sorry, Java guys!).

**First case &#8212; test for 0**

As I said in the previous episode, when faced with the challenge of implementing a story that involves multiple results, follow the rule of _0, 1, many_. So here is my test for getting no books back when there are no books in my genre:

    [Test]
    public void NoBooksReturnedWhenFilteringEmptyListOfBooksForGenre()
    {
        BookListManager manager = new BookListManager();
    
        List<Book> filteredBookList = manager.GetBooksInGenre("Genre");
    
        Assert.IsEmpty(filteredBookList);
    }
    

I puzzled a bit about the name of our new member funcction, GetBooksInGenre. Should it be FilterBooksByGenre, GetAllBooksInGenre, or any one of several other candidates? I played with each of them, trying them out for size, thinking about whether or not I liked the way the API felt. The fact that I was thinking about the API now, _before_ I implemented the functionality, is actually pretty important. This is one of the key differences in Test _Driven_ Development versus Test-at-the-same-time Development or Test After Development. In the latter two kinds of development, you write the code, putting a stake in the ground representing a potentially significant amount of work. It is only after the code is written that you start exercising the interface that you&#8217;ve written. In the first way, using Test Driven Development, you play with the interface first, without regard to how the code will be written, and have the opportunity to get things as best as you can now, before that stake gets planted.

So I finally settled on the API I show in the test. Let&#8217;s write enough code to make that test compile but fail:

    public List<Book> GetBooksInGenre(string genre)
    {
        return null;
    }
    

and the final code:

    public List<Book> GetBooksInGenre(string genre)
    {
        return bookList;
    }
    

Again, remember to watch the test fail to make sure that the test _can_ fail, and that your code is making it pass.

**Second case &#8212; test for 1**

Next test is to create a list with one book in it, and that book should have the correct genre being searched for, and filter for that genre:

    [Test]
    public void SingleBookReturnedWhenFilteringListWithOneBookInCorrectGenre()
    {
        BookListManager manager = new BookListManager();
        manager.Add(new Book("Title", "Genre"));
    
        List<Book> filteredBookList = manager.GetBooksInGenre("Genre");
    
        Assert.AreEqual(1, filteredBookList.Count);
        Assert.AreEqual("Title", filteredBookList[0].Title);
        Assert.AreEqual("Genre", filteredBookList[0].Genre);
    }
    

OK, so first of all, this test requires a change to our Book class. Previously, Book only had a single argument to its constructor, just a title. Now it needs a genre, which is going to require a change to the Book class to make this test compile. It also needs a Genre property to allow us to test that we get the right book back.

If we start off by changing the constructor for Book directly, we&#8217;ll break other tests. What we need to do is find a way to make this change in such a way that we keep our code working and can slowly change to the new constructor. Being able to do this is a critical part of learning to write code using TDD. Each and every change we make to our code needs to made in as small sized steps as possible. This lets us stay close to working code, adding functionality quickly, and then simplifying things immediately afterwards.

The path I&#8217;d take is to ignore this new test for a moment. We wrote it, and the act of writing it informed us that we need a different signature for our constructor. So let&#8217;s create that constructor and make sure that everything still works after making that change. Once we finish that, we can go back to this test and implement the functionality it is requiring.

Step one in implementing this refactoring is to create a new constructor that takes the two arguments defined in our newest test. Change the old constructor to call the new constructor, passing in a dummy value for the genre in all cases where the old constructor is being called:

    public class Book : IComparable<Book>
    {
        private readonly string title;
    
        public Book(string title) : this(title, "Unspecified")
        {
        }
    
        public Book(string title, string genre)
        {
            this.title = title;
        }
    
        public string Title
        {
            get { return title; }
        }
    
        public string Genre
        {
            get { return null; }
        }
    
        public int CompareTo(Book other)
        {
            return title.CompareTo(other.title);
        }
    }
    

I also created a property called Genre to let the new test compile. After making this change, all my tests still pass. It is important to note that I didn&#8217;t add anything but the absolute minimum I needed to keep the old tests working.

> Do not add functionality while refactoring. Resist, resist, resist. Do not add it now, but remember to add tests to force you to add it later. 

Now that we have the two constructors, we can realize that we don&#8217;t need to original constructor any more, so we can get rid of it, one call-site at a time. This is important, since we don&#8217;t have to make a big-bang change but can change one thing at a time. That&#8217;s the sign of a well executed refactoring.

Change one site, re-run tests, ensure things still work. Once you&#8217;ve found and changed all call sites, remove the old method, recompile and re-run tests. Done! Now, back to that test&#8230;

As of right now, we have the new constructor in place, as well as the empty Genre property. We run the test, the test fails. Now lets implement the code to get this test working, which only consists of adding the code behind the Genre property to the Book:

    public class Book : IComparable<Book>
    {
        private readonly string title;
        private readonly string genre;
    
        public Book(string title, string genre)
        {
            this.title = title;
            this.genre = genre;
        }
    
        public string Title
        {
            get { return title; }
        }
    
        public string Genre
        {
            get { return genre; }
        }
    
        public int CompareTo(Book other)
        {
            return title.CompareTo(other.title);
        }
    }
    

I guess the case of a filtering a list of a single book wasn&#8217;t that interesting after all. Let&#8217;s write another test that tries to filter another list containing a single book, but let&#8217;s make that book have a genre different than that we&#8217;re searching for. Maybe that will cause us to write some code.

    [Test]
    public void NoBookReturnedWhenFilteringListWithOneBookInDifferentGenre()
    {
        BookListManager manager = new BookListManager();
        manager.Add(new Book("Title", "Good"));
    
        List<Book> filteredBookList = manager.GetBooksInGenre("Bad");
    
        Assert.IsEmpty(filteredBookList);
    }
    

Run this test, it compiles the first time, but it fails. I guess we do get to write some code&#8230;

    public List<Book> GetBooksInGenre(string genre)
    {
        return bookList.FindAll(delegate(Book book)
                                    {
                                        return book.Genre == genre;
                                    });
    }
    

This code uses the .Net 2.0 anonymous delegate syntax that allows you to create a delegate in place and pass it as a function into the method you&#8217;re calling. What happens in the List<T>.FindAll method is that it takes the delegate and applies it to all the elements in the collection, one at a time. In this case, if the Predicate delegate passed in executes and returns true, then the code inside the FindAll method adds the element into a new collection. Once the iteration is finished, the new list is returned to the caller.

The powerful part about doing this is that the new delegate has access to all the state that existed at the point at which it was defined. In other words, even though the delegate we&#8217;re defining is being passed as a parameter to the FindAll method and will be invoked later, in a completely different context, it still has access to the methods, members, parameters, and local variables that were in existence at the place where the delegate was defined, which is in our GetBooksInGenre method. Pretty cool, eh? It is an example of how you can create and use _closures_ in .Net.

**A bit of test refactoring before we carry on**

As Book is growing larger than a single property, we&#8217;re going to find ourselves inspecting its list of properties in our tests over and over. When faced with this, I tend to create an Equals method for the object I&#8217;m manipulating in my tests. This lets me directly compare the objects in a single Assert.AreEquals. Since the Equals method is code, however, I have to write tests for it, and it usually takes several tests. Here is the code for Book.Equals:

    public override bool Equals(object obj)
    {
        Book other = obj as Book;
        if(other == null) return false;
    
        return title == other.title &&
               genre == other.genre;
    }
    

and the completed tests for it, in the BookFixture (obviously):

    [Test]
    public void TwoBooksWithSameGenreAndTitleAreEqual()
    {
        Book first = new Book("Title", "Genre");
        Book second = new Book("Title", "Genre");
    
        Assert.AreEqual(first, second);
    }
    
    [Test]
    public void DifferentTitlesMakeBooksNotEqual()
    {
        Book first = new Book("A", "Genre");
        Book second = new Book("B", "Genre");
    
        Assert.AreNotEqual(first, second);
    }
    
    [Test]
    public void DifferentGenresMakeBooksNotEqual()
    {
        Book first = new Book("Title", "A");
        Book second = new Book("Title", "B");
    
        Assert.AreNotEqual(first, second);
    }
    
    [Test]
    public void NullObjectToCompareToCausesObjectsToBeUnequal()
    {
        Assert.IsFalse(new Book("", "").Equals(null));
    }
    
    [Test]
    public void WrongKindOfObjectPassedToEqualsCausesObjectsToBeUnequal()
    {
        Assert.AreNotEqual(new Book("", ""), "");
    }
    

I personally find an Equals method difficult to implement test first. In my standard working model, I would like to slowly build up the complete set of functionality needed to make something work. I don&#8217;t know how to do this with Equals. The problem is that it is difficult to incrementally add behavior to an Equals method and keep a set of growing tests working for it.

For example, I could have defined a test called BooksWithSameTitleCompareEqual, something like this:

    [Test]
    public void BooksWithSameTitleCompareEqual()
    {
        Book first = new Book("A", "");
        Book second = new Book("A", "");
    
        Assert.AreEqual(first, second);
    }
    

This would lead to a trivial implementation of my Equals method that just compared the titles to see if the objects were equal. Next, I&#8217;d add a test comparing the genre of books, but it would have to be crafted in such a way that the titles would be the same as well. And, in the previous test, I would have to have created the test data in such a way that the test wouldn&#8217;t break as I added code to compare the genre. My second test would have looked like this:

    [Test]
    public void BooksWithSameGenreAndTitleCompareEqual()
    {
        Book first = new Book("A", "G");
        Book second = new Book("A", "G");
    
        Assert.AreEqual(first, second);
    }
    

Note that the test has to have the intent of proving that not just the genres are equal, but that _all_ fields we&#8217;ve written tests for up to this point are equal. So if we had 5 fields in our class, we&#8217;d have to have 5 tests, each growing by one field each time, but still having all other fields &#8220;equal&#8221; in some way, like the empty genres in my first test. This all feels very contrived and pedantic to me. What I usually do is to write a single test with all fields being equal, and write the positive test case for equality in one fell swoop. The exception to this is when calculating equality is more complex than just comparing fields. If there are loop comparisons involved or something, I will write individual tests for that.

Once this is finished, however, I do tend to write negative test cases for each, individual field, to ensure I haven&#8217;t missed something, and tests for passing null and passing the wrong kinds of objects.

That gives me 3 + n tests to write the Equals method for any class, at a minimum, where &#8220;n&#8221; is the number of fields a class has. When you&#8217;re fairly trivial Equals method is only about 5 lines long, and you&#8217;ve spent 15 minutes writing all those tests for it, you have to start thinking whether or not it was worth it. Well, my answer is that it is worth it, if you&#8217;re writing your Equals method by hand.

I prefer to let my tool generate it for me, in which case I don&#8217;t write any tests for it 🙂

**Third case &#8212; multiple books**

OK, so we&#8217;re finally at the point of handling multiple books at a time in our filtering. To get the multi case working, I think I see two separate steps. The first step is to implement filtering across multiple books, while the second step is to make sure that the filtered list is sorted by title. We should break this down into two separate tests.

In the first test, we&#8217;re going to check that we&#8217;re filtering correctly. In this test, we need to prove that we can filter the list for books having the correct genre. We are not concerned with the ordering of the books here, so we&#8217;ll just confirm that the right books are contained in the filtered list (this is the change from Craig). Here it is:

    [Test]
    public void PresortedBookListWithSomeBooksInCorrectGenreOnlyReturnsBooksInCorrectGenre()
    {
        BookListManager manager = new BookListManager();
        Book firstMatchingBook = new Book("A", "G1");
        Book secondMatchingBook = new Book("C", "G1");
        Book nonMatchingBook = new Book("B", "G2");
        manager.Add(firstMatchingBook);
        manager.Add(nonMatchingBook);
        manager.Add(secondMatchingBook);
    
        List<Book> filteredBookList = manager.GetBooksInGenre("G1");
    
        Assert.AreEqual(2, filteredBookList.Count);
        Assert.Contains(firstMatchingBook, filteredBookList);
        Assert.Contains(secondMatchingBook, filteredBookList);
    }
    

The trick I just learned in writing this test is that you have to be conscious of making the assertions in the test match the intent of the test as described in the name. In this case, we are intending to prove that we can filter the list, so our assertions should support this functionality exactly. They should be strong enough to confirm that this behavior is actually happening, but not so strong that they assert behavior that hasn&#8217;t been written yet. In our case, that means assertions about filtering, but none about sorting. This is why I&#8217;m using Assert.Contains in that test.

While this sounds like a tremendously good plan, unfortunately this test passed the first time I ran it. I understand why it happened &#8212; the List<Book>.FindAll(Predicate) method I called finds all elements that satisfy the predicate when called. It was the simplest way to get that particular test working, and I got the looping logic for free.

Now for the test of making sure that the filtered list I get is sorted:

    [Test]
    public void UnsortedBookListWithSomeBooksInCorrectGenreOnlyReturnsBooksInCorrectGenre()
    {
        BookListManager manager = new BookListManager();
        Book firstMatchingBook = new Book("A", "G1");
        Book secondMatchingBook = new Book("C", "G1");
        manager.Add(secondMatchingBook);
        manager.Add(new Book("B", "G2"));
        manager.Add(firstMatchingBook);
    
        List<Book> filteredBookList = manager.GetBooksInGenre("G1");
    
        Assert.AreEqual(2, filteredBookList.Count);
        Assert.AreEqual(firstMatchingBook, filteredBookList[0]);
        Assert.AreEqual(secondMatchingBook, filteredBookList[1]);
    }
    

All I did was the switch up the order I added the books. The output, once the functionality is implemented, should be the same as in the previous tests. I implement the functionality in BookListManager like this:

    public List<Book> GetBooksInGenre(string genre)
    {
        return GetSortedBookList().FindAll(delegate(Book book)
                                    {
                                        return book.Genre == genre;
                                    });
    }
    

All I had to do was the pre-sort the list! I love when I can build on existing functionality. This happens a lot when you build small, fine-grained methods. You end up being able to use them in new and interesting combinations to implement new functionality easily.

**Conclusion**

When I sat down to write this episode, I truly thought it was going to be 2 or 3 tests, a couple hundred words, and a bit of code. When I got into it, though, I found several other tests to write, a need to write and use the Equals method for Book, and a bit of refactoring. I always find it interesting how complexity just shows up and how easily it is handled.

As an observation, you may have noticed that I have 68 lines of source code, almost all of it completely and totally trivial methods, and about 190 lines of test code. That ratio is a little skewed, because I haven&#8217;t had any really good functionality to implement, but I&#8217;m not upset about it at all. I&#8217;m certain that the 68 lines of source work, and I can continue to leverage the 190 lines of test code forever to confirm that the lines continue to work. I consider that to be an investment well worth the effort.

The next episode will add another user story to the mix. I think I&#8217;ll do the last one in the list, retrieving a list of books sorted by genre and title.

Until we meet again!

&#8212; bab