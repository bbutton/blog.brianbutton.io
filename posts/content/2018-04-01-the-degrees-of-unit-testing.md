---
title: The Degrees of Unit Testing
author: Brian Button
type: post
date: 2018-04-01T21:36:21+00:00
url: /index.php/2018/04/01/the-degrees-of-unit-testing/
categories:
  - Agile

---
# Three Degrees of Unit Testing

_I apologize for the length of this. I&#8217;m very passionate about this topic, and there is so much to say. The three styles of testing really are different, and explaining them does take some room!_

Any amount of unit testing, done almost any way, adds value to a code base. Regardless of how and when the tests were written, as long as they are reliable and quick, and prove the code does what we think it does, I&#8217;m in favor of them. But that is not to say there are not degrees of goodness within the scope of unit testing, especially around when the tests are conceived.

My point in this post is to show how the benefits of unit testing increase the closer you get to letting the tests drive both the implementation and design of the code as it is written. For those of you who have never heard of Test Driven Development (TDD) or have never _really_ tried it, I&#8217;m hoping this opens some eyes.

## The Basics &#8211; Tests After Coding

For most people, this is what comes to mind when thinking about writing unit tests &#8211; _I write my code, then I write tests for it_. This activity, by definition, occurs after code has be written and is an extra task. Let&#8217;s look at an example:

<pre class="prettyprint" title="">// Calculator class
public String calculate(String calculation) throws Exception {
  calculation = calculation.trim();
  String[] pieces = calculation.split(&quot; &quot;);

  int first = Integer.parseInt(pieces[0]);
  int second = Integer.parseInt(pieces[2]);
  String operand = pieces[1].trim();

  switch(operand) {
    case &quot;+&quot; : return Integer.toString(first + second);
    case &quot;-&quot; : return Integer.toString(first - second);
    case &quot;*&quot; : return Integer.toString(first * second);
    case &quot;/&quot; : return Integer.toString(first / second);
  }

  throw new Exception(&quot;No calculation found&quot;);
}

// Calculator tests
@Test
public void testCalculations() throws Exception {
  Calculator c = new Calculator();

  assertEquals(&quot;3&quot;, c.calculate(&quot;1 + 2&quot;));
  assertEquals(&quot;1&quot;, c.calculate(&quot;2 - 1&quot;));
  assertEquals(&quot;8&quot;, c.calculate(&quot;2 * 4&quot;));
  assertEquals(&quot;2&quot;, c.calculate(&quot;8 / 4&quot;));

  try {
    c.calculate(null);
  } catch(Exception e) {
  }
}
</pre>

Here we see a simple case of an isolated method, where testing after the code is written is easy. No dependencies, simple inputs and outputs, no problem. As the implementation gets more complicated, though, and dependencies creep in, and code gets longer, testing this code becomes much harder. Here, for example, is a simple Point of Sale system that uses an inventory system to retrieve information a barcode just scanned and a display to show the information retrieved. Here is that code along with a test I wrote. (note I had to fake out some of the complexity to make my point. I&#8217;ve seen each and every behavior mentioned in lots of production code, however!)

> Display and Inventory classes 

<pre class="prettyprint" title="">public class Display {
  public static Display getInstance() { return new Display(); }

  private Display() {}

  public void showError(String errorMessage) { DisplayService.showError(errorMessage); }
  public void displayItem(Item item) { DisplayService.displayItem(item); }
}

public class DisplayConfig {}

public class DisplayService {
  private static Item lastItem;

  public static void showError(String errorMessage) {}
  public static void displayItem(Item item) {
  // do the real stuff for displaying an item and save
  // the item so we can test this method
  lastItem = item;
  }

  public static void configure(DisplayConfig config) {
    // configuration code
  }

  // WARNING - testing only!!!
  public static Item getLastItem() { return lastItem; }
}
</pre>

<pre class="prettyprint" title="">public class Inventory {
  public static Inventory getInstance() { return new Inventory(); }
  private Inventory() {}

  public Item getItem(String barcode) { return InventoryService.getItem(barcode); }
}

public class InventoryConfig {}

public class InventoryService {
  public static Item getItem(String barcode) {
    try {
      Thread.sleep(2530);
    } catch (InterruptedException e) {}

    Item item = new Item();
    item.setName(&quot;foo&quot;);
    item.setPrice(&quot;1.99&quot;);

    return item;
  }

  public static void configure(InventoryConfig config) {
  // configuration stuff
  }
}

</pre>

> Item 

<pre class="prettyprint" title="">public class Item {
  private String name;
  private String price;

  public String getName() { return name; }
  public void setName(String name) { this.name = name;}
  public String getPrice() { return price; }
  public void setPrice(String price) { this.price = price; }
}
</pre>

> PointOfSale 

<pre class="prettyprint" title="">public class POS {
  public void doSale(String barcode) {
    if(barcode == null) {
      Display.getInstance().showError(&quot;Invalid barcode scanned&quot;);
      return;
    }

    Display.getInstance().displayItem(Inventory.getInstance().getItem(barcode));
  }
}
</pre>

> PointOfSaleTest 

<pre class="prettyprint" title="">public class POSTests {
  @Test
  public void myTest() {
    DisplayConfig dConfig = new DisplayConfig();
    // 10 lines ofsetup code hidden
    DisplayService.configure(dConfig);

    InventoryConfig iConfig = new InventoryConfig();
    // 15 lines of setup code hidden
    InventoryService.configure(iConfig);

    POS pos = new POS();
    pos.doSale(&quot;barcode&quot;);

    Item item = DisplayService.getLastItem();
    assertEquals(&quot;foo&quot;, item.getName());
    assertEquals(&quot;1.99&quot;, item.getPrice());
  }
}
</pre>

Now, testing becomes harder because the code was likely not written with testability in mind. The design doesn&#8217;t easily support testing small pieces, and there frequently aren&#8217;t hooks into the written code to allow it to be tested. So, instead of fixing the design to make things more testable, fewer tests are written and hacks are put into place to allow for testing. On top of that, the dependencies in the code require a lot more setup to let us test our little piece, and they also tend to make tests take longer to run and run less reliably.

However, this is the kind of testing most developers do, as it is what we&#8217;ve learned over our careers. It provides partial test coverage, usually of the happy-path cases, which is an improvement over not having tests at all. But since testing is done after the functionality is completed, it is viewed as an &#8220;extra activity&#8221;, which means it is the first thing dropped when time run short.

## Test First Programming

In this style of development, a significant amount of up-front thought and design go into an implementation. Once the design is decided upon, the code is then written by creating a test before code, and repeating that until the implementation is complete.

This is completely identical, in terms of outcomes, to the Test After case, when the problem is very simple. But when the problem gets larger, with dependencies and more complicated coding, you tend to get more code and path coverage due to writing less code to satisfy each test. You also begin to use the tests as feedback into the quality of the design — as tests become harder to write as the code becomes more tightly coupled, which leads to design improvements along the way. The codebase grows as the tests grow, so you get coverage of happy path and error conditions as well. That&#8217;s a bonus for this kind of testing.

To start, this is a UML diagram I might have come up with as thinking about solving the same problem from above. The difference in who I might think about this is that making the design testable becomes a first-class design decision. So, instead of using singletons or static classes, I rely entirely on interfaces and the Dependency Inversion Principal to keep things loosely coupled.

![Test First Design UML][1]

To implement this, we might start with the concrete implementation of the real Display and Inventory classes, according to the contracts defined in their interfaces. Among the design choices we would make would be to avoid Singletons and static classes, because both make testing more difficult. As our first step for the Inventory class, for instance, we&#8217;d make a list of test cases we&#8217;d like to implement:

> Inventory Test List 

  * Will return an item when passed a valid barcode
  * Throws an exception when no item found for a valid barcode
  * Throws an exception when passed a null barcode
  * Throws an exception for an invalid barcode
  * Throws an exception of all information not available to construct an Item

That would be my first pass at a test list, knowing I might find more as I go. One interesting thing that did come up as I was building this is that I realized BarCode is an abstraction that probably needs to be written and have its own tests (validation on construction for the most part). Next step is to write our first test to implement the design we created above:

> InventoryRepositoryTests 

<pre class="prettyprint" title="">@Test
public void AppropriateItemRetrievedWhenGivenCorrectBarcode() {
  InventoryRepository repository = new InventoryRepository(connection);
  Item expectedItem = new Item(&quot;Coke&quot;, &quot;$1.99&quot;);
  repository.addItem(expectedItem);

  Item item = repository.getItem(&quot;validBarcode&quot;);

  assertEquals(expectedItem, item);
}
</pre>

Before we write _any_ application code, we write our test. This serves as an exploration of the interface and as documentation of how our class will work. In this case, I am using the Repository pattern to encapsulate database operations. I add a test object, use my repository to retrieve it, and make sure it is the same object. From just writing this test, I found I missed the addItem() method in my InventoryRepository and found my Item class needs an equality operator. Easy things to add!

After writing this test, we&#8217;d confirm our system won&#8217;t compile yet, since we haven&#8217;t written any application code yet (hence the _TestFirst_ name). We&#8217;d write empty shells of all appropriate classes, adding just enough to make the test compile and fail for the correct reason of not having the appropriate code written yet.

Lastly, I&#8217;d repeat these tests for the rest of the InventoryRepository class and then PhysicalDisplay class, followed by the PointOfSale class, working from the bottom up. At this point, I&#8217;d expect to have three main application classes written, along with the POD class of Item, and tests for the three main classes. Each class would be thoroughly tested, as we designed our system to be testable and implemented each class one test at a time.

The downside with Test First is that you tend to stick to close to the original design as you&#8217;re incrementally writing tests. This means the learning and investigation in the construction process was still very front-loaded.

## Test Driven Development

Now, I know I&#8217;ve been doing a great job of hiding my preference here, but I&#8217;m going to go ahead now and admit to it. I&#8217;m a TDD fan. I&#8217;ve been doing it since 1999 or so, it is the primary way I write any non-trivial code, and there is nothing better that I&#8217;ve found in my 30+ years in the software industry.

The thought process behind TDD is that every move you make while writing code is an experiment, an experiment of how you can satisfy an example through a small amount of code. And after each experiment completes successfully, you spend a few minutes ensuring the code remains simple, readable, and changeable, to support your next experiment. There&#8217;s really not any more to it.

What follows is a portion of a larger example of this, done in steps, because TDD is done in small steps. The complete example is available on [github][2]. In addition to the tests/experiments and code, there are also complete and explicit checkin comments for each step of the way.

The first thing to notice here is we&#8217;re not taking time up front to come up with a design. Part of the Test Driven approach is that you start with your first experiment, write code, and iterate to the minimal design that supports your code. While some believe this is an indication TDD is against design, it&#8217;s more true that TDD is a tool to allow design to evolve constantly rather than being concentrated up front.

To build our system, we&#8217;ll work _outside-in_, meaning we&#8217;ll look at our system as a whole and write our first experiment to implement a sliver of behavior from the entry-point of our application, then dig in and implement the internals one piece at a time.

> Point of Sale Experiment List 

  * Given a barcode, display the corresponding name and price
  * Given a different barcode, display the corresponding name and price
  * Given a null barcode, show the appropriate error
  * Given an invalid barcode, show the appropriate error

Thinking about shape of this problem, we need our PointOfSale class and someplace to display the output. This Display class is important, because it is how we&#8217;re going to tell our experiment is successful. Everything else will come from thinking about the design as we go.

> PointOfSale tests 

<pre class="prettyprint" title="">public class PointOfSaleTests {
  @Test
  public void correctNameAndPriceShownWhenBarcodeScanned() { 
    Display display = new Display();
    PointOfSale pos = new PointOfSale(display);

    pos.doSale(&quot;validBarCode&quot;);

    assertEquals(&quot;Coke&quot;, display.getDisplayedName());
    assertEquals(&quot;$1.99&quot;, display.getDisplayedPrice());
  }
}
</pre>

As we create the shells of our classes and start to implement the code to make this experiment a success, we&#8217;ll discover our Display class has a `showItem(String name, String price)` method our PointOfSale class calls, and also some testing-only methods to get the item details provided through showItem(). This drives out an interface over the Display class that holds just the application method, while the _TestDouble_ we create will have the methods to get the item back for us to confirm. This sounds complicated, but let me show you the code for it.

PointOfSale implementation

<pre class="prettyprint" title="">public class PointOfSale {
  private DisplayIF display;

  public PointOfSale(DisplayIF display) { this.display = display; }
  public void doSale(String validBarCode) { display.showItem(&quot;Coke&quot;, &quot;$1.99&quot;); }
}

public interface DisplayIF {
  void showItem(String name, String price);
}

// This is a TestDouble, a class written only to allow your design to be tested
public class Display implements DisplayIF {
  private String displayedName;
  private String displayedPrice;

// Method called by application code, to be extracted to interface
  public void showItem(String name, String price) {
    displayedName = name;
    displayedPrice = price;
  }

// Testing-only methods
public String getDisplayedName() { return displayedName; }
public String getDisplayedPrice() { return displayedPrice; }
}
</pre>

Again, there is a lot more detail in GitHub, and there is even a _lot_ more detail you can learn from someone who already knows how this technique works.

As you do this, as you create small experiments and implement the minimal code to satisfy them, your system will grow. Do this a hundred times, and you have a small system. Repeat it a thousand, and you have a larger one. And you can keep going, because this scales as large as you like. Since you keep things clean and simple after each experiment finishes, your code is always understandable and easy to change.

It&#8217;s just that simple.

## Conclusion

At the end of the day, code with tests is better than code without tests. Testing after you write the code is likely to cover the happy paths and some of the error cases, but doesn&#8217;t do anything to improve the design. Writing tests before you write code lets you cover more of the error cases, but again generally doesn&#8217;t help you with the design. Going all the way to TDD, however, gets you clean code, nearly total test coverage, and a design and is simple and easy to maintain.

TDD is considered controversial by many. I&#8217;m really not sure why.

 [1]: https://www.agilestl.com/BlogImages/TestFirstUML.png "More testable design"
 [2]: https:/github.com/bbutton/POS