---
title: TDD Dive 4 — Refactoring away External Loops
author: Brian Button
type: post
date: 2004-11-25T15:57:00+00:00
url: /index.php/2004/11/25/tdd-dive-4-refactoring-away-external-loops/
sfw_comment_form_password:
  - BBB2qde5CrmC
sfw_pwd:
  - npeBw6KNUnIP
categories:
  - Uncategorized

---
_[Note: I&#8217;m using Copy as HTML to transfer code from VS.Net to BlogJet. This tool embeds style sheets into the posted blog entry to provide the nice formatting for the source code. Unfortunately, the version of .Text used by Dot Net Junkies won&#8217;t let me post the embedded style sheets. This means that viewing this article in an aggregator will look different, and worse, than viewing it on the DotNetJunkies site. I recommend viewing it there, as the code will be more easily readable than in an aggregator &#8212; bab]_

This is the 4th part of an evolving series showing a TDD-built Payroll system in all its glory. Here are the previous parts:

  1. [Deep Dive into Test Driven Development][1]
  2. [TDD Dive &#8212; Part Deux][2]
  3. [Diving into TDD &#8212; Take 3][3]

Now, on to our show&#8230;

* * *

[Jay Bazuzi][4] had a very interesting post on the [Refactoring][5] list (membership required to read posts). Anyhow, Jay made three really good points:

  * Methods should be 1 line long
  * You should share loop code by using internal iterators and delegates
  * You should have no private methods

I&#8217;d like to throw my 2 cents in on these ideas:

**1 line methods**

I&#8217;d sure like to get to the point where I could write one line methods. I need to work harder to get to this point, but I&#8217;d like to try. Jay&#8217;s point was that the interesting thing about objects was not what each one knew how to do by itself &#8212; the interesting thing is how they collaborate with their neighbors to get something done. I&#8217;ve heard this referred to in the past as [RavioliCode][6], not to be confused with [SpaghettiCode][7].

A lot of the ability to do this gets down to your choice of language, as some languages (C-based) are more verbose than others (Smalltalk).

**Prefer Internal Iterators and Delegates to External Iteration**

I have to agree with this point. I used to do this all the time in C++, but I&#8217;ve gotten really far away from this habit in Java and C#. There are really two reasons to do this. The first is to avoid exposing your internal collection to outsiders. For example, in our Payroll example, we had the class EmployeeList, which was basically a strongly typed Employee collection. 

<div class="csharpcode">
  <pre><span class="lnum">     1: </span><span class="kwrd">public</span> <span class="kwrd">class</span> EmployeeList</pre>
  
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
  
  <pre><span class="lnum">    15: </span>    <span class="kwrd">public</span> IList Employees</pre>
  
  <pre><span class="lnum">    16: </span>    {</pre>
  
  <pre><span class="lnum">    17: </span>        get { <span class="kwrd">return</span> employees; }</pre>
  
  <pre><span class="lnum">    18: </span>    }</pre>
  
  <pre><span class="lnum">    19: </span>}</pre>
</div>

And in our Payroll class, we had our Pay method that calculated the pay for all employees.

<div class="csharpcode">
  <pre><span class="lnum">     1: </span><span class="kwrd">public</span> <span class="kwrd">class</span> Payroll</pre>
  
  <pre><span class="lnum">     2: </span>{</pre>
  
  <pre><span class="lnum">     3: </span>    <span class="kwrd">private</span> EmployeeList employees;</pre>
  
  <pre><span class="lnum">     4: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     5: </span>    <span class="kwrd">public</span> Payroll(EmployeeList employees)</pre>
  
  <pre><span class="lnum">     6: </span>    {</pre>
  
  <pre><span class="lnum">     7: </span>        <span class="kwrd">this</span>.employees = employees;</pre>
  
  <pre><span class="lnum">     8: </span>    }</pre>
  
  <pre><span class="lnum">     9: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    10: </span>    <span class="kwrd">public</span> IList Pay(<span class="kwrd">string</span> payDate)</pre>
  
  <pre><span class="lnum">    11: </span>    {</pre>
  
  <pre><span class="lnum">    12: </span>        ArrayList payRecords = <span class="kwrd">new</span> ArrayList();</pre>
  
  <pre><span class="lnum">    13: </span>        <span class="kwrd">foreach</span>(Employee employee <span class="kwrd">in</span> employees.Employees)</pre>
  
  <pre><span class="lnum">    14: </span>        {</pre>
  
  <pre><span class="lnum">    15: </span>            employee.Pay(payDate, payRecords);</pre>
  
  <pre><span class="lnum">    16: </span>        }</pre>
  
  <pre><span class="lnum">    17: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    18: </span>        <span class="kwrd">return</span> payRecords;</pre>
  
  <pre><span class="lnum">    19: </span>    }</pre>
  
  <pre><span class="lnum">    20: </span>}</pre>
</div>

The problem is that now our collection is vulnerable to changing by someone outside its encapsulation boundary, its class, EmployeeList. Exposing our naked collection like that makes it possible for someone to do bad things to it and to us.

Another issue with this is that we&#8217;re going to have this external iteration loop (lines 13-16) repeated all over our codebase, as we do different things to the collection of Employees. We can refactor this, however, to reuse the existing loop plumbing and allow our clients to specify the body of that loop. 

What we can do is to create a method in EmployeeList called Apply() that takes a special delegate the we&#8217;ll write. This delegate will accept an Employee as its parameter, and the Apply() method will have the one and only one looping construct over an EmployeeList in our system. And the body of that loop will just call the delegate, passing in each Employee object in turn. Here is what it looks like in code:

<div class="csharpcode">
  <pre><span class="lnum">     1: </span><span class="kwrd">public</span> <span class="kwrd">class</span> EmployeeList</pre>
  
  <pre><span class="lnum">     2: </span>{</pre>
  
  <pre><span class="lnum">     3: </span>    <span class="kwrd">private</span> ArrayList employees = <span class="kwrd">new</span> ArrayList();</pre>
  
  <pre><span class="lnum">     4: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     5: </span>    <span class="kwrd">public</span> <span class="kwrd">delegate</span> <span class="kwrd">void</span> ApplyAction(Employee employee);</pre>
  
  <pre><span class="lnum">     6: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     7: </span>    <span class="kwrd">public</span> <span class="kwrd">void</span> Apply(ApplyAction action)</pre>
  
  <pre><span class="lnum">     8: </span>    {</pre>
  
  <pre><span class="lnum">     9: </span>        <span class="kwrd">foreach</span>(Employee employee <span class="kwrd">in</span> employees)</pre>
  
  <pre><span class="lnum">    10: </span>        {</pre>
  
  <pre><span class="lnum">    11: </span>            action(employee);</pre>
  
  <pre><span class="lnum">    12: </span>        }</pre>
  
  <pre><span class="lnum">    13: </span>    }</pre>
  
  <pre><span class="lnum">    14: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    15: </span>    <span class="kwrd">public</span> <span class="kwrd">void</span> Add(<span class="kwrd">string</span> employeeName, <span class="kwrd">int</span> yearlySalary)</pre>
  
  <pre><span class="lnum">    16: </span>    {</pre>
  
  <pre><span class="lnum">    17: </span>        employees.Add(<span class="kwrd">new</span> Employee(employeeName, yearlySalary));</pre>
  
  <pre><span class="lnum">    18: </span>    }</pre>
  
  <pre><span class="lnum">    19: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    20: </span>    <span class="kwrd">public</span> <span class="kwrd">int</span> Count</pre>
  
  <pre><span class="lnum">    21: </span>    {</pre>
  
  <pre><span class="lnum">    22: </span>        get { <span class="kwrd">return</span> employees.Count; }</pre>
  
  <pre><span class="lnum">    23: </span>    }</pre>
  
  <pre><span class="lnum">    24: </span>}</pre>
</div>

Note the new Apply() method in lines 7-13. This method does as described above &#8212; it takes a delegate and applies it to each Employee object in turn. It is the responsibility of the function to which the call is delegated to maintain what ever kind of state or context that is applicable per call. We were also able to get rid of our Employees property that exposed our collection to the world.

Here is the Payroll class after refactoring it to use this new Apply() method.

<div class="csharpcode">
  <pre><span class="lnum">     1: </span><span class="kwrd">public</span> <span class="kwrd">class</span> Payroll</pre>
  
  <pre><span class="lnum">     2: </span>{</pre>
  
  <pre><span class="lnum">     3: </span>    <span class="kwrd">private</span> EmployeeList employees;</pre>
  
  <pre><span class="lnum">     4: </span>    <span class="kwrd">private</span> ArrayList payRecords;</pre>
  
  <pre><span class="lnum">     5: </span>    <span class="kwrd">private</span> <span class="kwrd">string</span> payDate;</pre>
  
  <pre><span class="lnum">     6: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     7: </span>    <span class="kwrd">public</span> Payroll(EmployeeList employees)</pre>
  
  <pre><span class="lnum">     8: </span>    {</pre>
  
  <pre><span class="lnum">     9: </span>        <span class="kwrd">this</span>.employees = employees;</pre>
  
  <pre><span class="lnum">    10: </span>    }</pre>
  
  <pre><span class="lnum">    11: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    12: </span>    <span class="kwrd">public</span> IList Pay(<span class="kwrd">string</span> payDate)</pre>
  
  <pre><span class="lnum">    13: </span>    {</pre>
  
  <pre><span class="lnum">    14: </span>        <span class="kwrd">this</span>.payDate = payDate;</pre>
  
  <pre><span class="lnum">    15: </span>        payRecords = <span class="kwrd">new</span> ArrayList();</pre>
  
  <pre><span class="lnum">    16: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    17: </span>        employees.Apply(<span class="kwrd">new</span> EmployeeList.ApplyAction(PayEmployee));</pre>
  
  <pre><span class="lnum">    18: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    19: </span>        <span class="kwrd">return</span> payRecords;</pre>
  
  <pre><span class="lnum">    20: </span>    }</pre>
  
  <pre><span class="lnum">    21: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    22: </span>    <span class="kwrd">private</span> <span class="kwrd">void</span> PayEmployee(Employee employee)</pre>
  
  <pre><span class="lnum">    23: </span>    {</pre>
  
  <pre><span class="lnum">    24: </span>        employee.Pay(payDate, payRecords);</pre>
  
  <pre><span class="lnum">    25: </span>    }</pre>
  
  <pre><span class="lnum">    26: </span>}</pre>
</div>

Look at the Pay method in lines 12-20. Now, instead of having the explicit looping logic here, I have a call to the EmployeeList.Apply() method, passing a delegate to my new PayEmployee method. The end result of this is that I get rid of the looping logic at the price of another private method, PayEmployee. Even this cost is gone, however, in Whidbey, where you can have anonymous delegates. Finally, line 17 to me does not communicate its intention very well, so I did an ExtractMethod on it and created a PayAllEmployees private method. This is left as an exercise for the reader 🙂

I&#8217;m still not entirely happy with the Pay method, however, as its first two lines seem a little strange. Since I have to maintain state across calls to the PayEmployee method, I have to promote our argument, payDate, and our Collecting Parameter payRecords into member variables. This allows them to carry the state through the multiple calls to PayEmployee. I&#8217;m going to just acknowledge that I don&#8217;t like it right now, but I figure I&#8217;ll be back to clear that up later. I&#8217;m hoping future changes will inform me of what that stuff needs to turn into.

**No Private Methods**

Another point Jay makes is that private methods are really public methods of another, new class trying to find their way out. I actually teach this same concept, but I don&#8217;t start invoking it until a private methods gets rich enough for someone to want to test them. At that point, I advocate pulling it out into another class.

But perhaps Jay has an interesting point, and I&#8217;d like to try it.&nbsp;But I can&#8217;t see making _all_ private methods into methods on other classes. I admit that I haven&#8217;t tried it as aggressively as Jay describes, so my opinion shouldn&#8217;t carry as much weight as his here, but it seems that there are some methods that are introduced just to help explain other code. I mean those one-liners that make code more easily readable. For example, the PayAllEmployees() method from above is introduced just to help make our code more readable. And the private PayEmployee() method is just an artifact of the language.

On the other hand, maybe there is something interesting going on here. If I moved the PayEmployees() method to another class, called PayrollAction or something like that, then the PayEmployee() method could come along, too. It would still remain private there, however, since it is an artifact of the language, and not strictly something we would want to write. I&#8217;m not sure that this would make things communicate better at this point, and it would give me more classes and methods. That moves me further away from The Simplest Thing That Could Possibly Work, which is always my underlying goal. I think I&#8217;ll keep this one under my hat for now, but I&#8217;m ready to spring to it should the need arise.

But what this piece of advice does to for me is to make me even more vigilant against creeping private methods. I think I&#8217;m going to be more proactive about moving them out into their own classes earlier than I have before.

**Conclusion**

I think I&#8217;m happier with the code now that I&#8217;ve gotten rid of the external iteration. I&#8217;ve encapsulated my collection, yet still maintained the generality I had before by introducing the Apply() method on EmployeeList. And I&#8217;ve made my Payroll class simpler, since it doesn&#8217;t have to understand as much about the internals of the EmployeeList class, which is always a good thing.

In the next episode, I promise we&#8217;ll finish this first story. Thanks for your patience, but I just keep discovering new things about this code I&#8217;ve never noticed before. By the way, this is one of the most powerful arguments for pair programming &#8212; the act of explaining your design to someone as it is taking shape leads to a better design. Just working in the same room together isn&#8217;t the same thing &#8212; you have to be intimately connected, as in Pair Programming.

&#8212; bab

 [1]: http://dotnetjunkies.com/WebLog/oneagilecoder/archive/2004/10/25/29610.aspx
 [2]: http://dotnetjunkies.com/WebLog/oneagilecoder/archive/2004/11/07/31298.aspx
 [3]: http://dotnetjunkies.com/WebLog/oneagilecoder/archive/2004/11/15/32245.aspx
 [4]: http://weblogs.asp.net/jaybaz_ms
 [5]: http://groups.yahoo.com/group/Refactoring/
 [6]: http://c2.com/cgi/wiki?RavioliCode
 [7]: http://c2.com/cgi/wiki?SpaghettiCode