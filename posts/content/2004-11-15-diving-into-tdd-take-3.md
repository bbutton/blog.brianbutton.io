---
title: Diving into TDD — Take 3
author: Brian Button
type: post
date: 2004-11-15T15:06:00+00:00
url: /index.php/2004/11/15/diving-into-tdd-take-3/
sfw_comment_form_password:
  - kL3oGeTMEh5I
sfw_pwd:
  - LNPlr46JJvoO
categories:
  - Uncategorized

---
_[Note: I&#8217;m using Copy as HTML to transfer code from VS.Net to BlogJet. This tool embeds style sheets into the posted blog entry to provide the nice formatting for the source code. Unfortunately, the version of .Text used by Dot Net Junkies won&#8217;t let me post the embedded style sheets. This means that viewing this article in an aggregator will look different, and worse, than viewing it on the DotNetJunkies site. I recommend viewing it there, as the code will be more easily readable than in an aggregator &#8212; bab]_

Well, [we&#8217;ve written two tests][1] so far, and [we&#8217;ve refactored this thing to within an inch of its life][2]. We have a bit more to go before we get the Payroll portion of this first story finished up, after which we have to deal with reading the input batch file and writing the output check list, and also write a main. I&#8217;m much less concerned about those functions, because I know I can handle them. They&#8217;re part of the plumbing that makes the program work, rather than the meat of the program, so I generally leave those kinds of things for last.

As of now, we can pay one person, as long as it is always the first of the month. We should probably expand on both of those things, so that we can pay people or not, based on the day of the month, and we should also try to pay more than one person. Going back to our test list, those are the two remaining tests for this class.

### Paying multiple employees

I&#8217;m going to choose to implement paying multiple people next. As a simplifying assumption, I&#8217;m always going to pass in a valid pay date when calling Payroll.Pay, since I haven&#8217;t implemented the logic to make paydays conditional on date yet. This is a pretty standard trick when implementing a system using TDD &#8212; You know you have some complex conditional behavior to be implemented soon, but you haven&#8217;t implemented it yet. What you can do is to write your tests now to reflect that condition always being true. This lets you make progress now, and also provides a safety net to prove that your code still works for the _true_ case later, when you do implement the conditional.

So, as our first step, we need to write a test that tries to pay multiple people. That test might look like this:

<div class="csharpcode">
  <pre><span class="lnum">     1: </span>[Test]</pre>
  
  <pre><span class="lnum">     2: </span><span class="kwrd">public</span> <span class="kwrd">void</span> PayAllEmployeesOnFirstOfMonth()</pre>
  
  <pre><span class="lnum">     3: </span>{</pre>
  
  <pre><span class="lnum">     4: </span>    EmployeeList employees = <span class="kwrd">new</span> EmployeeList();</pre>
  
  <pre><span class="lnum">     5: </span>    employees.Add(<span class="str">"Bill"</span>, 1200);</pre>
  
  <pre><span class="lnum">     6: </span>    employees.Add(<span class="str">"Tom"</span>, 2400);</pre>
  
  <pre><span class="lnum">     7: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     8: </span>    Payroll payroll = <span class="kwrd">new</span> Payroll(employees);</pre>
  
  <pre><span class="lnum">     9: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    10: </span>    IList payRecords = payroll.PayAll(<span class="str">"05/01/2004"</span>);</pre>
  
  <pre><span class="lnum">    11: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    12: </span>    Assert.AreEqual(2, payRecords.Count);</pre>
  
  <pre><span class="lnum">    13: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    14: </span>    PayRecord billsPay = payRecords[0] <span class="kwrd">as</span> PayRecord;</pre>
  
  <pre><span class="lnum">    15: </span>    Assert.AreEqual(<span class="str">"Bill"</span>, billsPay.Name);</pre>
  
  <pre><span class="lnum">    16: </span>    Assert.AreEqual(100, billsPay.Pay);</pre>
  
  <pre><span class="lnum">    17: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    18: </span>    PayRecord tomsPay = payRecords[1] <span class="kwrd">as</span> PayRecord;</pre>
  
  <pre><span class="lnum">    19: </span>    Assert.AreEqual(<span class="str">"Tom"</span>, tomsPay.Name);</pre>
  
  <pre><span class="lnum">    20: </span>    Assert.AreEqual(200, tomsPay.Pay);</pre>
  
  <pre><span class="lnum">    21: </span>}</pre>
</div>

It is very similar to the previous tests. The only real differences are that we add two employees to the EmployeeList, and we have a new method, seen on Line 10, called Payroll.PayAll. This is a little tool-centric and language-imposed trick I&#8217;m using here. The existing Payroll.Pay method takes a single date and returns a single PayRecord. In an ideal world, I&#8217;d really like to just change that method to return an IList containing PayRecords, but language rules don&#8217;t let us override a method purely on return type. So, to have another Pay-like method that returns an IList of PayRecords, I have to have a differently named method.

I do have other options, rather than creating this newly named method. 

  1. I could write the test to use the IList-returning Payroll.Pay method. This is where I eventually intend to be, after all. My objection to this is that it would require me to change multiple tests all at the same time to get this to compile and work. That&#8217;s nowhere near the smallest step I could make, and I&#8217;d rather find another path.
  2. I could comment out this newest test and refactor the previous tests to use the new version of the Payroll.Pay method. To do this the right way, I&#8217;d use a ChangeMethodSignature refactoring, which would involve these steps:


  1. Create new method with signature I want. 
  2. Make the old method call the new method
  3. Retarget all calls to the old method to call the new one

The problem with this is that to do step 1, we&#8217;d have to override the existing method with a new method differing only in return type, getting us back to right where we are now with the PayAll method, at least temporarily. 

  3. We could proceed as we are now, make PayAll work, then convert all existing tests to call PayAll, one at a time. Once that is finished, no one should be using the existing Pay method, so we can get rid of it, and rename the PayAll method back to Pay, as we wanted. The reason I&#8217;ll choose this path is that my toolset (ReSharper) is really good at things like RenameMethod, so I can do that easily.

So at this point, I&#8217;ll go ahead and make the above test work as written. The first thing I need to do is to expand the EmployeeList class to actually have a list of employees, instead of just one. This is a simple refactoring, involving replacing the scalar Employee object with an ArrayList of employees, and adapting the existing methods to use the first item in the ArrayList as the single employee previously defined in the class. After doing this, I reran all my tests to confirm that all tests other than the one I&#8217;m implementing now still work, and they did. Here is the new code, along with a new method, Employees, that returns the entire list of employees:

<div class="csharpcode">
  <pre><span class="lnum">     1:</span> <span class="kwrd">public</span> <span class="kwrd">class</span> EmployeeList</pre>
  
  <pre><span class="lnum">     2: </span>{</pre>
  
  <pre><span class="lnum">     3: </span>    <span class="kwrd">private</span> ArrayList employees = <span class="kwrd">new</span> ArrayList();</pre>
  
  <pre><span class="lnum">     4: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     5: </span>    <span class="kwrd">public</span> <span class="kwrd">void</span> Add(<span class="kwrd">string</span> employeeName, <span class="kwrd">int</span> yearlySalary)</pre>
  
  <pre><span class="lnum">     6: </span>    {</pre>
  
  <pre><span class="lnum">     7: </span>        employees.Add(<span class="kwrd">new</span> Employee(employeeName, yearlySalary));</pre>
  
  <pre><span class="lnum">     8: </span>    }</pre>
  
  <pre><span class="lnum">     9: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    10: </span>    <span class="kwrd">public</span> <span class="kwrd">int</span> Count</pre>
  
  <pre><span class="lnum">    11: </span>    {</pre>
  
  <pre><span class="lnum">    12: </span>        get { <span class="kwrd">return</span> employees.Count; }</pre>
  
  <pre><span class="lnum">    13: </span>    }</pre>
  
  <pre><span class="lnum">    14: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    15: </span>    <span class="kwrd">public</span> Employee Employee</pre>
  
  <pre><span class="lnum">    16: </span>    {</pre>
  
  <pre><span class="lnum">    17: </span>        get { <span class="kwrd">return</span> employees[0] <span class="kwrd">as</span> Employee; }</pre>
  
  <pre><span class="lnum">    18: </span>    }</pre>
  
  <pre><span class="lnum">    19: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    20: </span>    <span class="kwrd">public</span> IList Employees</pre>
  
  <pre><span class="lnum">    21: </span>    {</pre>
  
  <pre><span class="lnum">    22: </span>        get { <span class="kwrd">return</span> employees; }</pre>
  
  <pre><span class="lnum">    23: </span>    }</pre>
  
  <pre><span class="lnum">    24: </span>}&nbsp;</pre>
</div>

Now the Payroll.PayAll method:

<div class="csharpcode">
  <pre><span class="lnum">     1: </span><span class="kwrd">public</span> IList PayAll(<span class="kwrd">string</span> payDate)</pre>
  
  <pre><span class="lnum">     2: </span>{</pre>
  
  <pre><span class="lnum">     3: </span>    ArrayList payRecords = <span class="kwrd">new</span> ArrayList();</pre>
  
  <pre><span class="lnum">     4: </span>    <span class="kwrd">foreach</span>(Employee employee <span class="kwrd">in</span> employees.Employees)</pre>
  
  <pre><span class="lnum">     5: </span>    {</pre>
  
  <pre><span class="lnum">     6: </span>        payRecords.Add(employee.Pay(payDate));</pre>
  
  <pre><span class="lnum">     7: </span>    }</pre>
  
  <pre><span class="lnum">     8: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     9: </span>    <span class="kwrd">return</span> payRecords;</pre>
  
  <pre><span class="lnum">    10: </span>}</pre>
</div>

All tests work at this point, so its time for some refactoring. Let&#8217;s start by changing the first test to use the new PayAll method:

<div class="csharpcode">
  <pre><span class="lnum">     1: </span>[Test]</pre>
  
  <pre><span class="lnum">     2: </span><span class="kwrd">public</span> <span class="kwrd">void</span> NoOnePaidIfNoEmployees()</pre>
  
  <pre><span class="lnum">     3: </span>{</pre>
  
  <pre><span class="lnum">     4: </span>    EmployeeList employees = <span class="kwrd">new</span> EmployeeList();</pre>
  
  <pre><span class="lnum">     5: </span>    Payroll payroll = <span class="kwrd">new</span> Payroll(employees);</pre>
  
  <pre><span class="lnum">     6: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     7: </span>    IList payrollOutput = payroll.PayAll(<span class="str">"05/01/2004"</span>);</pre>
  
  <pre><span class="lnum">     8: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     9: </span>    Assert.AreEqual(0, payrollOutput.Count);</pre>
  
  <pre><span class="lnum">    10: </span>}</pre>
</div>

And now, the last test to change:

<div class="csharpcode">
  <pre><span class="lnum">     1: </span>[Test]</pre>
  
  <pre><span class="lnum">     2: </span><span class="kwrd">public</span> <span class="kwrd">void</span> PayOneEmployeeOnFirstOfMonth()</pre>
  
  <pre><span class="lnum">     3: </span>{</pre>
  
  <pre><span class="lnum">     4: </span>    EmployeeList employees = <span class="kwrd">new</span> EmployeeList();</pre>
  
  <pre><span class="lnum">     5: </span>    employees.Add(<span class="str">"Bill"</span>, 1200);</pre>
  
  <pre><span class="lnum">     6: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     7: </span>    Payroll payroll = <span class="kwrd">new</span> Payroll(employees);</pre>
  
  <pre><span class="lnum">     8: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     9: </span>    IList payrollOutput = payroll.PayAll(<span class="str">"05/01/2004"</span>);</pre>
  
  <pre><span class="lnum">    10: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    11: </span>    Assert.AreEqual(1, payrollOutput.Count);</pre>
  
  <pre><span class="lnum">    12: </span>            </pre>
  
  <pre><span class="lnum">    13: </span>    PayRecord billsPay = payrollOutput[0] <span class="kwrd">as</span> PayRecord;</pre>
  
  <pre><span class="lnum">    14: </span>    Assert.AreEqual(<span class="str">"Bill"</span>, billsPay.Name);</pre>
  
  <pre><span class="lnum">    15:  </span>   Assert.AreEqual(100, billsPay.Pay);</pre>
  
  <pre><span class="lnum">    16: </span>}</pre>
</div>

And now, the old Pay method is no longer used, so I can go ahead and get rid of it, followed by a RenameMethod on PayAll to Pay, and we&#8217;re right where we wanted to be.

### What if it&#8217;s not the first of the month?

Our original spec said that we shouldn&#8217;t pay an employee if payroll gets run on any day but the first of the month. We&#8217;ve avoided coding that so far, but we kind of need that to complete the Payroll class. So, let&#8217;s write a test. First question is, now that we&#8217;re thinking about day of the month, do we need to write any tests to confirm that we can pay on the first? Well, all the tests that we&#8217;ve written previously have assumed that the date was the first of the month, so each of those test cases should still function. That&#8217;s our proof that we can pay if we need to. Now we need to _not_ pay if we _don&#8217;t_ need to. Here is that test:

<div class="csharpcode">
  <pre><span class="lnum">     1: </span>[Test]</pre>
  
  <pre><span class="lnum">     2: </span><span class="kwrd">public</span> <span class="kwrd">void</span> NoEmployeePaidIfNotFirstOfMonth()</pre>
  
  <pre><span class="lnum">     3: </span>{</pre>
  
  <pre><span class="lnum">     4: </span>    EmployeeList employees = <span class="kwrd">new</span> EmployeeList();</pre>
  
  <pre><span class="lnum">     5: </span>    employees.Add(<span class="str">"Johnny"</span>, 3600);</pre>
  
  <pre><span class="lnum">     6: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     7: </span>    Payroll payroll = <span class="kwrd">new</span> Payroll(employees);</pre>
  
  <pre><span class="lnum">     8: </span>    IList emptyList = payroll.Pay(<span class="str">"05/02/2004"</span>);</pre>
  
  <pre><span class="lnum">     9: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    10: </span>    Assert.AreEqual(0, emptyList.Count);</pre>
  
  <pre><span class="lnum">    11: </span>}</pre>
</div>

Run it, watch it fail, and now implement this functionality. Now the question is where should it go? Here is one implementation of it:

<div class="csharpcode">
  <pre><span class="lnum">     1: </span><span class="kwrd">public</span> IList Pay(<span class="kwrd">string</span> payDate)</pre>
  
  <pre><span class="lnum">     2: </span>{</pre>
  
  <pre><span class="lnum">     3: </span>    ArrayList payRecords = <span class="kwrd">new</span> ArrayList();</pre>
  
  <pre><span class="lnum">     4: </span>    <span class="kwrd">foreach</span>(Employee employee <span class="kwrd">in</span> employees.Employees)</pre>
  
  <pre><span class="lnum">     5: </span>    {</pre>
  
  <pre><span class="lnum">     6:  </span>       <span class="kwrd">if</span>(employee.IsPayday(payDate))</pre>
  
  <pre><span class="lnum">     7: </span>        {</pre>
  
  <pre><span class="lnum">     8: </span>            payRecords.Add(employee.Pay());                  </pre>
  
  <pre><span class="lnum">     9: </span>        }</pre>
  
  <pre><span class="lnum">    10: </span>    }</pre>
  
  <pre><span class="lnum">    11: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    12: </span>    <span class="kwrd">return</span> payRecords;</pre>
  
  <pre><span class="lnum">    13: </span>}</pre>
</div>

This would certainly work, and it is a solution I see a lot, but there is a philosophical issue with it. There is this OO design principle called _[Tell, Don&#8217;t Ask][3]_. What it says is that you shouldn&#8217;t ask an object a question about its state and then do something based on the response. If you think about it, that&#8217;s really exposing something about the internals of the object you&#8217;re talking to. The whole point of objects is that they are supposed to encapsulate data and behavior. If we let them do this, we end up with an interface that is made up of interesting methods, each of which has some meaning and context. If we don&#8217;t follow this rule, we end up with a lot of dumb data classes and a few god classes in our system that hold all the interesting behavior. I say, move the behavior and data to the same place, and get rid of simple accessor/setter methods! 

To implement this change following _Tell, Don&#8217;t Ask_ required a few more changes than the original change. First of all, the Employee.Pay method is changed:

<div class="csharpcode">
  <pre><span class="lnum">     1: </span><span class="kwrd">public</span> PayRecord Pay(<span class="kwrd">string</span> payDate)</pre>
  
  <pre><span class="lnum">     2: </span>{</pre>
  
  <pre><span class="lnum">     3: </span>    <span class="kwrd">if</span>(IsPayday(payDate))</pre>
  
  <pre><span class="lnum">     4: </span>    {</pre>
  
  <pre><span class="lnum">     5: </span>        PayRecord payRecord = <span class="kwrd">new</span> PayRecord(Name, CalculatePay());</pre>
  
  <pre><span class="lnum">     6: </span>        <span class="kwrd">return</span> payRecord;</pre>
  
  <pre><span class="lnum">     7: </span>    }</pre>
  
  <pre><span class="lnum">     8: </span>    <span class="kwrd">else</span> <span class="kwrd">return</span> <span class="kwrd">null</span>;</pre>
  
  <pre><span class="lnum">     9: </span>}</pre>
</div>

And the Payroll.Pay method has to be changed as well. We need to look out for the null PayRecord coming back from the Employee.Pay method, and only add the returned PayRecord to our collection of PayRecords if it is not null. I&#8217;m not so sure this code looks any better than the first attempt we made&nbsp;by exposing the&nbsp;Employee.IsPayday method as public&#8230;&nbsp;

The real solution to this dilemma is to use another pattern, called a _CollectingParameter_, to get rid of the null checking. Basically, if you hold your head just right,&nbsp;calling a method on another object and getting back a value, and doing something different based on whether that value is null or not, is really kind of a _Tell, Don&#8217;t Ask_ violation. The same logic that is being done in the calling method through a check for null could realy&nbsp;be moved into the called method, provided the called method has someplace to put the result.&nbsp;That someplace is the&nbsp;_CollectingParameter_. This is how the refactoring turns out&#8230;

Inside Payroll.Pay, we get back to a very simple interface, with no extra state-based code:

<div class="csharpcode">
  <pre><span class="lnum">     1: </span><span class="kwrd">public</span> IList Pay(<span class="kwrd">string</span> payDate)</pre>
  
  <pre><span class="lnum">     2: </span>{</pre>
  
  <pre><span class="lnum">     3: </span>    ArrayList payRecords = <span class="kwrd">new</span> ArrayList();</pre>
  
  <pre><span class="lnum">     4: </span>    <span class="kwrd">foreach</span>(Employee employee <span class="kwrd">in</span> employees.Employees)</pre>
  
  <pre><span class="lnum">     5: </span>    {</pre>
  
  <pre><span class="lnum">     6: </span>        employee.Pay(payDate, payRecords);</pre>
  
  <pre><span class="lnum">     7: </span>    }</pre>
  
  <pre><span class="lnum">     8: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     9: </span>    <span class="kwrd">return</span> payRecords;</pre>
  
  <pre><span class="lnum">    10: </span>}</pre>
</div>

Note how we create our _CollectingParameter_ payRecords at the top of the Pay method and pass it into the Employee.Pay method each time it is called. This allows the logic about whether or not to add a PayRecord into the Employee class, which is where the behavior that controls Pay logic lives. This is a better distribution of responsibilities. Here is the Employee.Pay code:

<div class="csharpcode">
  <pre><span class="lnum">     1: </span><span class="kwrd">public</span> <span class="kwrd">void</span> Pay(<span class="kwrd">string</span> payDate, IList payRecords)</pre>
  
  <pre><span class="lnum">     2: </span>{</pre>
  
  <pre><span class="lnum">     3: </span>    <span class="kwrd">if</span>(IsPayday(payDate))</pre>
  
  <pre><span class="lnum">     4: </span>    {</pre>
  
  <pre><span class="lnum">     5: </span>        PayRecord payRecord = <span class="kwrd">new</span> PayRecord(Name, CalculatePay());</pre>
  
  <pre><span class="lnum">     6: </span>        payRecords.Add(payRecord);</pre>
  
  <pre><span class="lnum">     7: </span>    }</pre>
  
  <pre><span class="lnum">     8: </span>}</pre>
</div>

And finally, here is all the code, as far as we&#8217;ve implemented so far. We&#8217;re still left with reading and writing to and from our input and output files, but we&#8217;ll cover that next time. There are some interesting design decisions in there that could spark some good conversation (if anyone is actually reading this!)

<div class="csharpcode">
  <pre><span class="lnum">     1: </span><span class="kwrd">using</span> System.Collections;</pre>
  
  <pre><span class="lnum">     2: </span><span class="kwrd">using</span> NUnit.Framework;</pre>
  
  <pre><span class="lnum">     3: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     4: </span><span class="kwrd">namespace</span> PayrollExercise</pre>
  
  <pre><span class="lnum">     5: </span>{</pre>
  
  <pre><span class="lnum">     6: </span>    [TestFixture]</pre>
  
  <pre><span class="lnum">     7: </span>    <span class="kwrd">public</span> <span class="kwrd">class</span> PayrollFixture</pre>
  
  <pre><span class="lnum">     8: </span>    {</pre>
  
  <pre><span class="lnum">     9: </span>        [Test]</pre>
  
  <pre><span class="lnum">    10: </span>        <span class="kwrd">public</span> <span class="kwrd">void</span> NoOnePaidIfNoEmployees()</pre>
  
  <pre><span class="lnum">    11: </span>        {</pre>
  
  <pre><span class="lnum">    12: </span>            EmployeeList employees = <span class="kwrd">new</span> EmployeeList();</pre>
  
  <pre><span class="lnum">    13: </span>            Payroll payroll = <span class="kwrd">new</span> Payroll(employees);</pre>
  
  <pre><span class="lnum">    14: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    15: </span>            IList payrollOutput = payroll.Pay(<span class="str">"05/01/2004"</span>);</pre>
  
  <pre><span class="lnum">    16: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    17: </span>            Assert.AreEqual(0, payrollOutput.Count);</pre>
  
  <pre><span class="lnum">    18: </span>        }</pre>
  
  <pre><span class="lnum">    19: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    20: </span>        [Test]</pre>
  
  <pre><span class="lnum">    21: </span>        <span class="kwrd">public</span> <span class="kwrd">void</span> PayOneEmployeeOnFirstOfMonth()</pre>
  
  <pre><span class="lnum">    22: </span>        {</pre>
  
  <pre><span class="lnum">    23: </span>            EmployeeList employees = <span class="kwrd">new</span> EmployeeList();</pre>
  
  <pre><span class="lnum">    24: </span>            employees.Add(<span class="str">"Bill"</span>, 1200);</pre>
  
  <pre><span class="lnum">    25: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    26: </span>            Payroll payroll = <span class="kwrd">new</span> Payroll(employees);</pre>
  
  <pre><span class="lnum">    27: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    28: </span>            IList payrollOutput = payroll.Pay(<span class="str">"05/01/2004"</span>);</pre>
  
  <pre><span class="lnum">    29: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    30: </span>            Assert.AreEqual(1, payrollOutput.Count);</pre>
  
  <pre><span class="lnum">    31: </span>            </pre>
  
  <pre><span class="lnum">    32: </span>            PayRecord billsPay = payrollOutput[0] <span class="kwrd">as</span> PayRecord;</pre>
  
  <pre><span class="lnum">    33: </span>            Assert.AreEqual(<span class="str">"Bill"</span>, billsPay.Name);</pre>
  
  <pre><span class="lnum">    34: </span>            Assert.AreEqual(100, billsPay.Pay);</pre>
  
  <pre><span class="lnum">    35: </span>        }</pre>
  
  <pre><span class="lnum">    36: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    37: </span>        [Test]</pre>
  
  <pre><span class="lnum">    38: </span>        <span class="kwrd">public</span> <span class="kwrd">void</span> PayAllEmployeesOnFirstOfMonth()</pre>
  
  <pre><span class="lnum">    39: </span>        {</pre>
  
  <pre><span class="lnum">    40: </span>            EmployeeList employees = <span class="kwrd">new</span> EmployeeList();</pre>
  
  <pre><span class="lnum">    41: </span>            employees.Add(<span class="str">"Bill"</span>, 1200);</pre>
  
  <pre><span class="lnum">    42: </span>            employees.Add(<span class="str">"Tom"</span>, 2400);</pre>
  
  <pre><span class="lnum">    43: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    44: </span>            Payroll payroll = <span class="kwrd">new</span> Payroll(employees);</pre>
  
  <pre><span class="lnum">    45: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    46: </span>            IList payRecords = payroll.Pay(<span class="str">"05/01/2004"</span>);</pre>
  
  <pre><span class="lnum">    47: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    48: </span>            Assert.AreEqual(2, payRecords.Count);</pre>
  
  <pre><span class="lnum">    49: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    50: </span>            PayRecord billsPay = payRecords[0] <span class="kwrd">as</span> PayRecord;</pre>
  
  <pre><span class="lnum">    51: </span>            Assert.AreEqual(<span class="str">"Bill"</span>, billsPay.Name);</pre>
  
  <pre><span class="lnum">    52: </span>            Assert.AreEqual(100, billsPay.Pay);</pre>
  
  <pre><span class="lnum">    53: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    54: </span>            PayRecord tomsPay = payRecords[1] <span class="kwrd">as</span> PayRecord;</pre>
  
  <pre><span class="lnum">    55: </span>            Assert.AreEqual(<span class="str">"Tom"</span>, tomsPay.Name);</pre>
  
  <pre><span class="lnum">    56: </span>            Assert.AreEqual(200, tomsPay.Pay);</pre>
  
  <pre><span class="lnum">    57: </span>        }</pre>
  
  <pre><span class="lnum">    58: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    59: </span>        [Test]</pre>
  
  <pre><span class="lnum">    60: </span>        <span class="kwrd">public</span> <span class="kwrd">void</span> NoEmployeePaidIfNotFirstOfMonth()</pre>
  
  <pre><span class="lnum">    61: </span>        {</pre>
  
  <pre><span class="lnum">    62: </span>            EmployeeList employees = <span class="kwrd">new</span> EmployeeList();</pre>
  
  <pre><span class="lnum">    63: </span>            employees.Add(<span class="str">"Johnny"</span>, 3600);</pre>
  
  <pre><span class="lnum">    64: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    65: </span>            Payroll payroll = <span class="kwrd">new</span> Payroll(employees);</pre>
  
  <pre><span class="lnum">    66: </span>            IList emptyList = payroll.Pay(<span class="str">"05/02/2004"</span>);</pre>
  
  <pre><span class="lnum">    67: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    68: </span>            Assert.AreEqual(0, emptyList.Count);</pre>
  
  <pre><span class="lnum">    69: </span>        }</pre>
  
  <pre><span class="lnum">    70: </span>    }</pre>
  
  <pre><span class="lnum">    71: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    72: </span>    <span class="kwrd">public</span> <span class="kwrd">class</span> Payroll</pre>
  
  <pre><span class="lnum">    73: </span>    {</pre>
  
  <pre><span class="lnum">    74: </span>        <span class="kwrd">private</span> EmployeeList employees;</pre>
  
  <pre><span class="lnum">    75: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    76: </span>        <span class="kwrd">public</span> Payroll(EmployeeList employees)</pre>
  
  <pre><span class="lnum">    77: </span>        {</pre>
  
  <pre><span class="lnum">    78: </span>            <span class="kwrd">this</span>.employees = employees;</pre>
  
  <pre><span class="lnum">    79: </span>        }</pre>
  
  <pre><span class="lnum">    80: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    81: </span>        <span class="kwrd">public</span> IList Pay(<span class="kwrd">string</span> payDate)</pre>
  
  <pre><span class="lnum">    82: </span>        {</pre>
  
  <pre><span class="lnum">    83: </span>            ArrayList payRecords = <span class="kwrd">new</span> ArrayList();</pre>
  
  <pre><span class="lnum">    84: </span>            <span class="kwrd">foreach</span>(Employee employee <span class="kwrd">in</span> employees.Employees)</pre>
  
  <pre><span class="lnum">    85: </span>            {</pre>
  
  <pre><span class="lnum">    86: </span>                employee.Pay(payDate, payRecords);</pre>
  
  <pre><span class="lnum">    87: </span>            }</pre>
  
  <pre><span class="lnum">    88: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    89: </span>            <span class="kwrd">return</span> payRecords;</pre>
  
  <pre><span class="lnum">    90: </span>        }</pre>
  
  <pre><span class="lnum">    91: </span>    }</pre>
  
  <pre><span class="lnum">    92: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    93: </span>    <span class="kwrd">public</span> <span class="kwrd">class</span> Employee</pre>
  
  <pre><span class="lnum">    94: </span>    {</pre>
  
  <pre><span class="lnum">    95: </span>        <span class="kwrd">private</span> <span class="kwrd">string</span> name;</pre>
  
  <pre><span class="lnum">    96: </span>        <span class="kwrd">private</span> <span class="kwrd">int</span> salary;</pre>
  
  <pre><span class="lnum">    97: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    98: </span>        <span class="kwrd">public</span> Employee(<span class="kwrd">string</span> name, <span class="kwrd">int</span> yearlySalary)</pre>
  
  <pre><span class="lnum">    99: </span>        {</pre>
  
  <pre><span class="lnum">   100: </span>            <span class="kwrd">this</span>.name = name;</pre>
  
  <pre><span class="lnum">   101: </span>            <span class="kwrd">this</span>.salary = yearlySalary;</pre>
  
  <pre><span class="lnum">   102: </span>        }</pre>
  
  <pre><span class="lnum">   103: </span>&nbsp;</pre>
  
  <pre><span class="lnum">   104: </span>        <span class="kwrd">private</span> <span class="kwrd">string</span> Name</pre>
  
  <pre><span class="lnum">   105: </span>        {</pre>
  
  <pre><span class="lnum">   106: </span>            get { <span class="kwrd">return</span> name; }</pre>
  
  <pre><span class="lnum">   107: </span>        }</pre>
  
  <pre><span class="lnum">   108: </span>&nbsp;</pre>
  
  <pre><span class="lnum">   109: </span>        <span class="kwrd">private</span> <span class="kwrd">int</span> CalculatePay()</pre>
  
  <pre><span class="lnum">   110: </span>        {</pre>
  
  <pre><span class="lnum">   111: </span>            <span class="kwrd">return</span> salary/12;</pre>
  
  <pre><span class="lnum">   112: </span>        }</pre>
  
  <pre><span class="lnum">   113: </span>&nbsp;</pre>
  
  <pre><span class="lnum">   114: </span>        <span class="kwrd">public</span> <span class="kwrd">void</span> Pay(<span class="kwrd">string</span> payDate, IList payRecords)</pre>
  
  <pre><span class="lnum">   115: </span>        {</pre>
  
  <pre><span class="lnum">   116: </span>            <span class="kwrd">if</span>(IsPayday(payDate))</pre>
  
  <pre><span class="lnum">   117: </span>            {</pre>
  
  <pre><span class="lnum">   118: </span>                PayRecord payRecord = <span class="kwrd">new</span> PayRecord(Name, CalculatePay());</pre>
  
  <pre><span class="lnum">   119: </span>                payRecords.Add(payRecord);</pre>
  
  <pre><span class="lnum">   120: </span>            }</pre>
  
  <pre><span class="lnum">   121: </span>        }</pre>
  
  <pre><span class="lnum">   122: </span>&nbsp;</pre>
  
  <pre><span class="lnum">   123: </span>        <span class="kwrd">private</span> <span class="kwrd">bool</span> IsPayday(<span class="kwrd">string</span> payDate)</pre>
  
  <pre><span class="lnum">   124: </span>        {</pre>
  
  <pre><span class="lnum">   125: </span>            <span class="kwrd">string</span> [] dateParts = payDate.Split(<span class="kwrd">new</span> <span class="kwrd">char</span>[] {<span class="str">'/'</span>});</pre>
  
  <pre><span class="lnum">   126: </span>            <span class="kwrd">return</span> dateParts[1] == <span class="str">"01"</span>;</pre>
  
  <pre><span class="lnum">   127: </span>        }</pre>
  
  <pre><span class="lnum">   128: </span>    }</pre>
  
  <pre><span class="lnum">   129: </span>&nbsp;</pre>
  
  <pre><span class="lnum">   130: </span>    <span class="kwrd">public</span> <span class="kwrd">class</span> PayRecord</pre>
  
  <pre><span class="lnum">   131: </span>    {</pre>
  
  <pre><span class="lnum">   132: </span>        <span class="kwrd">private</span> <span class="kwrd">string</span> name;</pre>
  
  <pre><span class="lnum">   133: </span>        <span class="kwrd">private</span> <span class="kwrd">int</span> pay;</pre>
  
  <pre><span class="lnum">   134: </span>&nbsp;</pre>
  
  <pre><span class="lnum">   135: </span>        <span class="kwrd">public</span> PayRecord(<span class="kwrd">string</span> name, <span class="kwrd">int</span> pay)</pre>
  
  <pre><span class="lnum">   136: </span>        {</pre>
  
  <pre><span class="lnum">   137: </span>            <span class="kwrd">this</span>.name = name;</pre>
  
  <pre><span class="lnum">   138: </span>            <span class="kwrd">this</span>.pay = pay;</pre>
  
  <pre><span class="lnum">   139: </span>        }</pre>
  
  <pre><span class="lnum">   140: </span>&nbsp;</pre>
  
  <pre><span class="lnum">   141: </span>        <span class="kwrd">public</span> <span class="kwrd">string</span> Name</pre>
  
  <pre><span class="lnum">   142: </span>        {</pre>
  
  <pre><span class="lnum">   143: </span>            get { <span class="kwrd">return</span> name; }</pre>
  
  <pre><span class="lnum">   144: </span>        }</pre>
  
  <pre><span class="lnum">   145: </span>&nbsp;</pre>
  
  <pre><span class="lnum">   146: </span>        <span class="kwrd">public</span> <span class="kwrd">int</span> Pay</pre>
  
  <pre><span class="lnum">   147: </span>        {</pre>
  
  <pre><span class="lnum">   148: </span>            get { <span class="kwrd">return</span> pay; }</pre>
  
  <pre><span class="lnum">   149: </span>        }</pre>
  
  <pre><span class="lnum">   150: </span>    }</pre>
  
  <pre><span class="lnum">   151: </span>&nbsp;</pre>
  
  <pre><span class="lnum">   152: </span>    <span class="kwrd">public</span> <span class="kwrd">class</span> EmployeeList</pre>
  
  <pre><span class="lnum">   153: </span>    {</pre>
  
  <pre><span class="lnum">   154: </span>        <span class="kwrd">private</span> ArrayList employees = <span class="kwrd">new</span> ArrayList();</pre>
  
  <pre><span class="lnum">   155: </span>&nbsp;</pre>
  
  <pre><span class="lnum">   156: </span>        <span class="kwrd">public</span> <span class="kwrd">void</span> Add(<span class="kwrd">string</span> employeeName, <span class="kwrd">int</span> yearlySalary)</pre>
  
  <pre><span class="lnum">   157: </span>        {</pre>
  
  <pre><span class="lnum">   158: </span>            employees.Add(<span class="kwrd">new</span> Employee(employeeName, yearlySalary));</pre>
  
  <pre><span class="lnum">   159: </span>        }</pre>
  
  <pre><span class="lnum">   160: </span>&nbsp;</pre>
  
  <pre><span class="lnum">   161: </span>        <span class="kwrd">public</span> <span class="kwrd">int</span> Count</pre>
  
  <pre><span class="lnum">   162: </span>        {</pre>
  
  <pre><span class="lnum">   163: </span>            get { <span class="kwrd">return</span> employees.Count; }</pre>
  
  <pre><span class="lnum">   164: </span>        }</pre>
  
  <pre><span class="lnum">   165: </span>&nbsp;</pre>
  
  <pre><span class="lnum">   166: </span>        <span class="kwrd">public</span> Employee Employee</pre>
  
  <pre><span class="lnum">   167: </span>        {</pre>
  
  <pre><span class="lnum">   168: </span>            get { <span class="kwrd">return</span> employees[0] <span class="kwrd">as</span> Employee; }</pre>
  
  <pre><span class="lnum">   169: </span>        }</pre>
  
  <pre><span class="lnum">   170: </span>&nbsp;</pre>
  
  <pre><span class="lnum">   171: </span>        <span class="kwrd">public</span> IList Employees</pre>
  
  <pre><span class="lnum">   172: </span>        {</pre>
  
  <pre><span class="lnum">   173: </span>            get { <span class="kwrd">return</span> employees; }</pre>
  
  <pre><span class="lnum">   174: </span>        }</pre>
  
  <pre><span class="lnum">   175: </span>    }</pre>
  
  <pre><span class="lnum">   176: </span>}</pre>
</div>

 [1]: http://dotnetjunkies.com/WebLog/oneagilecoder/archive/2004/10/25/29610.aspx
 [2]: http://dotnetjunkies.com/WebLog/oneagilecoder/archive/2004/11/07/31298.aspx
 [3]: http://www.pragmaticprogrammer.com/ppllc/papers/1998_05.html