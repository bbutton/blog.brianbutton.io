---
title: The Never-ending TDD Story — Part 5
author: Brian Button
type: post
date: 2004-12-02T17:07:00+00:00
url: /index.php/2004/12/02/the-never-ending-tdd-story-part-5/
sfw_comment_form_password:
  - mzrKQ4uaxJG6
sfw_pwd:
  - O7mZKVIxiqVD
categories:
  - Uncategorized

---
_[Note: I&#8217;m using Copy as HTML to transfer code from VS.Net to BlogJet. This tool embeds style sheets into the posted blog entry to provide the nice formatting for the source code. Unfortunately, the version of .Text used by Dot Net Junkies won&#8217;t let me post the embedded style sheets. This means that viewing this article in an aggregator will look different, and worse, than viewing it on the DotNetJunkies site. I recommend viewing it there, as the code will be more easily readable than in an aggregator &#8212; bab]_

As promised, we are finally adding the input and output handling stuff. If you can recall from _way_ back in installment one, I chose to implement this stuff last, because it wasn&#8217;t challenging and it wasn&#8217;t the core of the problem. In other words, I was pretty sure I could make it work when I had to, so I wasn&#8217;t worried about it. Well, since the meat of the story is now finished, I need to do my I/O, and here it is.

**Output**

I&#8217;m going to start working on the output side first, just for the fun of it. I&#8217;m not exactly sure why I&#8217;m doing this, but it may be because the output side already has a fully formed user, the Payroll class, while the input is a little foggier. Should the input reading drive the system, should there be something else out there that drives the whole thing&#8230; I don&#8217;t know yet, so I&#8217;m going to do the output side first.

So, as we discussed in the first installment, there is this company that will print the checks for me, but I have to give them a properly formatted batch file. This was the sample output that we had:

<font face="Times New Roman">Check,100,Frank Furter,$10000,05/01/2004<br />Check,101,Howard Hog,$12000,05/01/2004<br />Check,102,Frank Furter,$10000,06/01/2004<br />Check,103,Howard Hog,$12000,06/01/2004</font>

Out output class just has to mimic this exactly. No problem!

Let&#8217;s start implementing this new class. As before, we need to create a test list before we can start working on the code. This helps me get my thoughts straight about what this class needs to do. Here is my first shot at a test list:

  1. Should print no output if there are no pay records
  2. Should print exactly one line if there is a single pay record
  3. Check numbers always start at 100 after object created
  4. Check numbers keep incrementing throughout lifetime of check writer object
  5. Should print two lines if there are two pay records

Armed with that test list, I&#8217;m going to start writing my CheckWriter class. I choose to write test number 1 first, as it seems to be the most basic, and will force me to write at least a stub for all the classes I&#8217;ll need. Here&#8217;s that test:

<div class="csharpcode">
  <pre><span class="lnum">     1: </span>[TestFixture]</pre>
  
  <pre><span class="lnum">     2: </span><span class="kwrd">public</span> <span class="kwrd">class</span> CheckWriterFixture</pre>
  
  <pre><span class="lnum">     3: </span>{</pre>
  
  <pre><span class="lnum">     4: </span>    [Test]</pre>
  
  <pre><span class="lnum">     5: </span>    <span class="kwrd">public</span> <span class="kwrd">void</span> NoOutputWrittenIfNoPayRecords()</pre>
  
  <pre><span class="lnum">     6: </span>    {</pre>
  
  <pre><span class="lnum">     7: </span>        IList payRecords = <span class="kwrd">new</span> ArrayList();</pre>
  
  <pre><span class="lnum">     8: </span>        StringWriter checkData = <span class="kwrd">new</span> StringWriter();</pre>
  
  <pre><span class="lnum">     9: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    10: </span>        CheckWriter writer = <span class="kwrd">new</span> CheckWriter(checkData);</pre>
  
  <pre><span class="lnum">    11: </span>        writer.Write(payRecords);</pre>
  
  <pre><span class="lnum">    12: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    13: </span>        Assert.AreEqual(<span class="kwrd">string</span>.Empty, checkData.ToString());</pre>
  
  <pre><span class="lnum">    14: </span>    }</pre>
  
  <pre><span class="lnum">    15: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    16: </span>    <span class="kwrd">private</span> <span class="kwrd">class</span> CheckWriter</pre>
  
  <pre><span class="lnum">    17: </span>    {</pre>
  
  <pre><span class="lnum">    18: </span>        <span class="kwrd">public</span> CheckWriter(TextWriter checkData)</pre>
  
  <pre><span class="lnum">    19: </span>        {</pre>
  
  <pre><span class="lnum">    20: </span>        }</pre>
  
  <pre><span class="lnum">    21: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    22: </span>        <span class="kwrd">public</span> <span class="kwrd">void</span> Write(IList payRecords)</pre>
  
  <pre><span class="lnum">    23: </span>        {</pre>
  
  <pre><span class="lnum">    24: </span>        }</pre>
  
  <pre><span class="lnum">    25: </span>    }</pre>
  
  <pre><span class="lnum">    26: </span>}</pre>
</div>

Now the interesting thing here is that I intended to just stop here so I could watch my test fail. But I ran it and it worked&#8230; It turns out that I don&#8217;t need to do anything inside the Write() method to make the test pass. But I consider this test to still be very valuable. First of all, it got me focused on the interface I intended to support without having to worry about the details of how I would implement that interface. Secondly, the CheckWriter class has to respond in a predictable way when the list of PayRecords it gets is empty. Now, no matter how the code mutates over time, I can still confirm that the empty case does the right thing. So I guess I&#8217;m finished with this first test.

The next test tries to write a single entry into the output stream for a single PayRecord. I do this simple case so I can get the line formatting correct. I could have jumped straight to passing in a bunch of PayRecords, but then I&#8217;d have had to worry about details about iteration as well as formatting, and that step is too big. The smaller step I chose to take will make me focus strictly on the formatting of a single line. Here is that test:

<div class="csharpcode">
  <pre><span class="lnum">     1: </span>[Test]</pre>
  
  <pre><span class="lnum">     2: </span><span class="kwrd">public</span> <span class="kwrd">void</span> SinglePayRecordFormattedCorrectlyWhenWritten()</pre>
  
  <pre><span class="lnum">     3: </span>{</pre>
  
  <pre><span class="lnum">     4: </span>    IList payRecords = <span class="kwrd">new</span> ArrayList();</pre>
  
  <pre><span class="lnum">     5: </span>    payRecords.Add(<span class="kwrd">new</span> PayRecord(<span class="str">"Bill"</span>, 1000));</pre>
  
  <pre><span class="lnum">     6: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     7: </span>    StringWriter checkData = <span class="kwrd">new</span> StringWriter();</pre>
  
  <pre><span class="lnum">     8: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     9: </span>    CheckWriter writer = <span class="kwrd">new</span> CheckWriter(checkData);</pre>
  
  <pre><span class="lnum">    10: </span>    writer.Write(payRecords);</pre>
  
  <pre><span class="lnum">    11: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    12: </span>    Assert.AreEqual(<span class="str">"Check,100,Bill,$1000,05/01/2004"</span> + </pre>
  
  <pre>                            System.Environment.NewLine, checkData.ToString());</pre>
  
  <pre><span class="lnum">    13: </span>}</pre>
</div>

Well, isn&#8217;t this interesting&#8230; To format the output properly, I need the date for a PayRecord. I completely missed this! I&#8217;ll have to go back to the PayRecord class and change that class to hold the pay date, and fix up any tests and calling code to handle the date. Before I do this, though, is there any way I could have avoided this error? I suppose I could have started with the CheckWriter as my first class, establishing how the output would be written and what data it would contain. But I&#8217;d have done that in kind of a vacuum, since I wouldn&#8217;t have had the essence of the problem solved het. Would I have come up with the PayRecord class had I started with the CheckWriter first? I don&#8217;t know. I almost certainly wouldn&#8217;t have called it a PayRecord yet, because I woudn&#8217;t have known I needed something like that. To be honest, I&#8217;m pretty sure that there would be no sure-fire way to avoid an error like this. What I do know is that I have my tests to back me up, so this change should be pretty easy to make. So I&#8217;ll make it.

To make this change, I went into PayrollFixture and changed the first test I found that did any assertions against the contents of a PayRecord. I included an assertion to check the pay date. Then I changed PayRecord to take a pay date in its constructor and added a getter property to get the pay date back out. Compiled, found where I had to change the calls to the constructor to PayRecord and ran my tests. The test I just updated passed, so I went back and updated the rest of the tests in PayFixture to check the pay date as well. The key here is that I changed a test to direct me to what to change in my application code. I changed it in the test, then followed that to the place I had to change. Then the compiler was able to tell me what else needed to change. Moral of the story is to listen to your tools &#8212; they&#8217;ll tell you where to go to make these changes.

So, back on track now, I finish implementing the test I was originally writing&#8230;

<div class="csharpcode">
  <pre><span class="lnum">     1: </span><span class="kwrd">public</span> <span class="kwrd">class</span> CheckWriter</pre>
  
  <pre><span class="lnum">     2: </span>{</pre>
  
  <pre><span class="lnum">     3: </span>    <span class="kwrd">private</span> TextWriter checkData;</pre>
  
  <pre><span class="lnum">     4: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     5: </span>    <span class="kwrd">public</span> CheckWriter(TextWriter checkData)</pre>
  
  <pre><span class="lnum">     6: </span>    {</pre>
  
  <pre><span class="lnum">     7: </span>        <span class="kwrd">this</span>.checkData = checkData;</pre>
  
  <pre><span class="lnum">     8: </span>    }</pre>
  
  <pre><span class="lnum">     9: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    10: </span>    <span class="kwrd">public</span> <span class="kwrd">void</span> Write(IList payRecords)</pre>
  
  <pre><span class="lnum">    11: </span>    {</pre>
  
  <pre><span class="lnum">    12: </span>        <span class="kwrd">string</span> name = ((PayRecord)payRecords[0]).Name;</pre>
  
  <pre><span class="lnum">    13: </span>        <span class="kwrd">int</span> pay = ((PayRecord)payRecords[0]).Pay;</pre>
  
  <pre><span class="lnum">    14: </span>        <span class="kwrd">string</span> date = ((PayRecord)payRecords[0]).PayDate;</pre>
  
  <pre><span class="lnum">    15: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    16: </span>        <span class="kwrd">string</span> payData = <span class="str">"Check,100,"</span> + name + <span class="str">",$"</span> + pay + <span class="str">","</span> + date;</pre>
  
  <pre><span class="lnum">    17: </span>        checkData.WriteLine(payData);</pre>
  
  <pre><span class="lnum">    18: </span>    }</pre>
  
  <pre><span class="lnum">    19: </span>}</pre>
</div>

This implementation suffices to make this new test pass. I know there is no iteration in it, I know I&#8217;ll need that eventually, but by not putting it in, I was able to focus in getting the formatting just right. Before I can move on, though, I need to make sure that my first test still passes. So I run it, and sure enough, it fails! So already, the test that was really trivial to write and to implement turns out to be somewhat valuable. To make this first test pass, I have to bail out of my Write method if there are no payRecords in the parameter. Simple change to make, and then all my tests run again. 

For the next test, I&#8217;ll implement test #3. In this test, I need to make sure that whenever I create and use a new CheckWriter, the check number in the output always starts at 100. Here&#8217;s the test:

<div class="csharpcode">
  <pre><span class="lnum">     1: </span>[Test]</pre>
  
  <pre><span class="lnum">     2: </span><span class="kwrd">public</span> <span class="kwrd">void</span> CheckRecordsAlwaysStartAt100ForNewInstances()</pre>
  
  <pre><span class="lnum">     3: </span>{</pre>
  
  <pre><span class="lnum">     4: </span>    IList payRecords = <span class="kwrd">new</span> ArrayList();</pre>
  
  <pre><span class="lnum">     5: </span>    payRecords.Add(<span class="kwrd">new</span> PayRecord(<span class="str">"Bill"</span>, 1200, <span class="str">"05/01/2004"</span>));</pre>
  
  <pre><span class="lnum">     6: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     7: </span>    StringWriter firstCheckData = <span class="kwrd">new</span> StringWriter();</pre>
  
  <pre><span class="lnum">     8: </span>    CheckWriter firstWriter = <span class="kwrd">new</span> CheckWriter(firstCheckData);</pre>
  
  <pre><span class="lnum">     9: </span>    firstWriter.Write(payRecords);</pre>
  
  <pre><span class="lnum">    10: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    11: </span>    Assert.AreEqual(<span class="str">"Check,100,Bill,$1200,05/01/2004"</span> + System.Environment.NewLine, firstCheckData.ToString());</pre>
  
  <pre><span class="lnum">    12: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    13: </span>    StringWriter secondCheckData = <span class="kwrd">new</span> StringWriter();</pre>
  
  <pre><span class="lnum">    14: </span>    CheckWriter secondWriter = <span class="kwrd">new</span> CheckWriter(secondCheckData);</pre>
  
  <pre><span class="lnum">    15: </span>    secondWriter.Write(payRecords);</pre>
  
  <pre><span class="lnum">    16: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    17: </span>    Assert.AreEqual(<span class="str">"Check,100,Bill,$1200,05/01/2004"</span> + System.Environment.NewLine, secondCheckData.ToString());</pre>
  
  <pre><span class="lnum">    18: </span>}</pre>
  
  <pre><span class="lnum">    19: </span>&nbsp;</pre>
</div>

And it passed the first time, since we&#8217;re hardcoding in the check number in the output string. We could go back and extract that hardcoded value from the output string in CheckWriter right now, or we could implement the next test to make us do that. I think I&#8217;d rather do the second thing, just because it sounds more interesting to me. You could certainly go back in now and refactor the hardcoded value into an instance variable now if you choose to, but I think I want to wait until I have a test that demands it, so I&#8217;m certain that I implement it the right way. Here&#8217;s the next test:

<div class="csharpcode">
  <pre><span class="lnum">     1: </span>[Test]</pre>
  
  <pre><span class="lnum">     2: </span><span class="kwrd">public</span> <span class="kwrd">void</span> CheckNumbersIncrementEachTimeWriteMethodIsCalled()</pre>
  
  <pre><span class="lnum">     3: </span>{</pre>
  
  <pre><span class="lnum">     4: </span>    IList payRecords = <span class="kwrd">new</span> ArrayList();</pre>
  
  <pre><span class="lnum">     5: </span>    payRecords.Add(<span class="kwrd">new</span> PayRecord(<span class="str">"Bill"</span>, 1200, <span class="str">"05/01/2004"</span>));</pre>
  
  <pre><span class="lnum">     6: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     7: </span>    StringWriter checkData = <span class="kwrd">new</span> StringWriter();</pre>
  
  <pre><span class="lnum">     8: </span>    CheckWriter writer = <span class="kwrd">new</span> CheckWriter(checkData);</pre>
  
  <pre><span class="lnum">     9: </span>    writer.Write(payRecords);</pre>
  
  <pre><span class="lnum">    10: </span>    writer.Write(payRecords);</pre>
  
  <pre><span class="lnum">    11: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    12: </span>    Assert.AreEqual(<span class="str">"Check,100,Bill,$1200,05/01/2004"</span> + System.Environment.NewLine +</pre>
  
  <pre><span class="lnum">    13: </span>                    <span class="str">"Check,101,Bill,$1200,05/01/2004"</span> + System.Environment.NewLine, checkData.ToString());</pre>
  
  <pre><span class="lnum">    14: </span>}</pre>
</div>

Now, on lines 9 and 10, I call the Write() method twice, and I expect the check number to change. I know that it doesn&#8217;t make sense to pay Bill twice for the same payday, but, hey, I own this business, and I can do as I please! The important thing here is to make the check number increment. I can handle validation logic of what is being printed somewhere else if I choose to. The responsibility of the CheckWriter class is just to write the output. If a PayRecord is in its input, it should show up in its output. So, let&#8217;s go make that change inside the CheckWriter class. 

Step one is to ignore the test we are trying to implement now. This test isn&#8217;t going to work until we make this refactoring in CheckWriter, and I don&#8217;t like refactoring with broken tests. So, I ignore it, and then move on to the refactoring. 

The smallest step I can take here at first is to extract the hardcoded &#8220;100&#8221; from the string in Write() and make it a local variable:

<div class="csharpcode">
  <pre><span class="lnum">     1: </span><span class="kwrd">public</span> <span class="kwrd">void</span> Write(IList payRecords)</pre>
  
  <pre><span class="lnum">     2: </span>{</pre>
  
  <pre><span class="lnum">     3: </span>    <span class="kwrd">string</span> name = ((PayRecord)payRecords[0]).Name;</pre>
  
  <pre><span class="lnum">     4: </span>    <span class="kwrd">int</span> pay = ((PayRecord)payRecords[0]).Pay;</pre>
  
  <pre><span class="lnum">     5: </span>    <span class="kwrd">string</span> date = ((PayRecord)payRecords[0]).PayDate;</pre>
  
  <pre><span class="lnum">     6: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     7: </span>    <span class="kwrd">int</span> checkNumber = 100;</pre>
  
  <pre><span class="lnum">     8: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     9: </span>    <span class="kwrd">string</span> payData = <span class="str">"Check,"</span> + checkNumber + <span class="str">","</span> + name + <span class="str">",$"</span> + pay + <span class="str">","</span> + date;</pre>
  
  <pre><span class="lnum">    10: </span>    checkData.WriteLine(payData);</pre>
  
  <pre><span class="lnum">    11: </span>}</pre>
</div>

Compile and run tests, see that they all work, and then promote the local variable into an instance variable. Compile again, run tests, all works. The key in this step is that I didn&#8217;t make the jump to an instance variable all in one big leap. I&#8217;m pretty sure I could have, and gotten it right, but the challenge in refactoring is to make changes in small steps. This was an extreme example, but there are certainly times when I do things in steps that are this small. Here is the current CheckWriter code, after this change:

<div class="csharpcode">
  <pre><span class="lnum">     1: </span><span class="kwrd">public</span> <span class="kwrd">class</span> CheckWriter</pre>
  
  <pre><span class="lnum">     2: </span>{</pre>
  
  <pre><span class="lnum">     3: </span>    <span class="kwrd">private</span> TextWriter checkData; </pre>
  
  <pre><span class="lnum">     4: </span>    <span class="kwrd">private</span> <span class="kwrd">int</span> checkNumber = 100;</pre>
  
  <pre><span class="lnum">     5: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     6: </span>    <span class="kwrd">public</span> CheckWriter(TextWriter checkData)</pre>
  
  <pre><span class="lnum">     7: </span>    {</pre>
  
  <pre><span class="lnum">     8: </span>        <span class="kwrd">this</span>.checkData = checkData;</pre>
  
  <pre><span class="lnum">     9: </span>    }</pre>
  
  <pre><span class="lnum">    10: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    11: </span>    <span class="kwrd">public</span> <span class="kwrd">void</span> Write(IList payRecords)</pre>
  
  <pre><span class="lnum">    12: </span>    {</pre>
  
  <pre><span class="lnum">    13: </span>        <span class="kwrd">string</span> name = ((PayRecord)payRecords[0]).Name;</pre>
  
  <pre><span class="lnum">    14: </span>        <span class="kwrd">int</span> pay = ((PayRecord)payRecords[0]).Pay;</pre>
  
  <pre><span class="lnum">    15: </span>        <span class="kwrd">string</span> date = ((PayRecord)payRecords[0]).PayDate;</pre>
  
  <pre><span class="lnum">    16: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    17: </span>        <span class="kwrd">string</span> payData = <span class="str">"Check,"</span> + checkNumber + <span class="str">","</span> + name + <span class="str">",$"</span> + pay + <span class="str">","</span> + date;</pre>
  
  <pre><span class="lnum">    18: </span>        checkData.WriteLine(payData);</pre>
  
  <pre><span class="lnum">    19: </span>    }</pre>
  
  <pre><span class="lnum">    20: </span>}</pre>
</div>

Now, lets un-ignore the test we were implementing, and make that work. I won&#8217;t bore you with seeing the code again after this change. All I had to do was to add ++ after the checkNumber on line 17, and the incrementing works just fine. On to our next test, paying multiple PayRecords in a single call to Write().

Here is the code for that test:

<div class="csharpcode">
  <pre><span class="lnum">     1: </span>[Test]</pre>
  
  <pre><span class="lnum">     2: </span><span class="kwrd">public</span> <span class="kwrd">void</span> WriteOutputForAllPayRecordsInGivenList()</pre>
  
  <pre><span class="lnum">     3: </span>{</pre>
  
  <pre><span class="lnum">     4: </span>    IList payRecords = <span class="kwrd">new</span> ArrayList();</pre>
  
  <pre><span class="lnum">     5: </span>    payRecords.Add(<span class="kwrd">new</span> PayRecord(<span class="str">"Tom"</span>, 100, <span class="str">"01/01/2004"</span>));</pre>
  
  <pre><span class="lnum">     6: </span>    payRecords.Add(<span class="kwrd">new</span> PayRecord(<span class="str">"Sue"</span>, 500, <span class="str">"02/01/2004"</span>));</pre>
  
  <pre><span class="lnum">     7: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     8: </span>    StringWriter checkData = <span class="kwrd">new</span> StringWriter();</pre>
  
  <pre><span class="lnum">     9: </span>    CheckWriter writer = <span class="kwrd">new</span> CheckWriter(checkData);</pre>
  
  <pre><span class="lnum">    10: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    11: </span>    writer.Write(payRecords);</pre>
  
  <pre><span class="lnum">    12: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    13: </span>    Assert.AreEqual(<span class="str">"Check,100,Tom,$100,01/01/2004"</span> + System.Environment.NewLine +</pre>
  
  <pre><span class="lnum">    14: </span>                    <span class="str">"Check,101,Sue,$500,02/01/2004"</span> + System.Environment.NewLine, checkData.ToString());</pre>
  
  <pre><span class="lnum">    15: </span>}</pre>
</div>

Now that this test is written, we finally have an excuse to add the iteration to the Write() method, and we do so very simply:

<div class="csharpcode">
  <pre><span class="lnum">     1: </span><span class="kwrd">public</span> <span class="kwrd">void</span> Write(IList payRecords)</pre>
  
  <pre><span class="lnum">     2: </span>{</pre>
  
  <pre><span class="lnum">     3: </span>    <span class="kwrd">foreach</span>(PayRecord payRecord <span class="kwrd">in</span> payRecords)</pre>
  
  <pre><span class="lnum">     4: </span>    {</pre>
  
  <pre><span class="lnum">     5: </span>        <span class="kwrd">string</span> name = payRecord.Name;</pre>
  
  <pre><span class="lnum">     6: </span>        <span class="kwrd">int</span> pay = payRecord.Pay;</pre>
  
  <pre><span class="lnum">     7: </span>        <span class="kwrd">string</span> date = payRecord.PayDate;</pre>
  
  <pre><span class="lnum">     8: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     9: </span>        <span class="kwrd">string</span> payData = <span class="str">"Check,"</span> + checkNumber++ + <span class="str">","</span> + name + <span class="str">",$"</span> + pay + <span class="str">","</span> + date;</pre>
  
  <pre><span class="lnum">    10: </span>        checkData.WriteLine(payData);</pre>
  
  <pre><span class="lnum">    11: </span>    }</pre>
  
  <pre><span class="lnum">    12: </span>}</pre>
</div>

Once again, we rerun all of our tests, and everything passes, so we&#8217;re just about finished. The last thing I want to do is to get rid of all the local variables in the Write() method. Now that we have the foreach loop, we don&#8217;t have to do the nasty casting we had in the code previously, so I&#8217;m not sure the locals are really helping me out any more. And I can get rid of payData as well, I think, putting everything into the checkData.WriteLine() line.

The final point I want to make about this is that it was interesting that I was testing code whose job it was to write to an output file, yet I never touched a single file in any of my tests. There is one big reason I can do this &#8212; polymorphism. .Net doesn&#8217;t care what _kind_ of TextWriterI&#8217;m writing to, and I&#8217;m taking advantage of that. I&#8217;ve written my code to the base TextWriter class, which allows me to use StringWriters in my tests for convenience and StreamWriters in my final version to write to the file system. This way I don&#8217;t have to clutter my test code with file handling logic, including file creation, deletion, reading, etc. Everything is neatly wrapped up in a StringWriter that I can access with a simple ToString(). It makes the tests much easier to read and understand, reducing all that extra plumbing noise. I do this where ever possible &#8212; write my interfaces to the most base class I can. That gives me the most freedom at runtime to choose between different kinds of implementations to use.

Here is the final code for this episode:

<div class="cf">
  <span class="cb1"><font color="#0000ff">using</font></span> System.Collections;<br /><span class="cb1"><font color="#0000ff">using</font></span> System.IO;<br /><span class="cb1"><font color="#0000ff">using</font></span> NUnit.Framework;</p> 
  
  <p>
    <span class="cb1"><font color="#0000ff">namespace</font></span> PayrollExercise<br />{<br />&nbsp;&nbsp;&nbsp; [TestFixture]<br />&nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">class</font></span> PayrollFixture<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; [Test]<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">void</font></span> NoOnePaidIfNoEmployees()<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; EmployeeList employees = <span class="cb1"><font color="#0000ff">new</font></span> EmployeeList();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Payroll payroll = <span class="cb1"><font color="#0000ff">new</font></span> Payroll(employees);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; IList payrollOutput = payroll.Pay(&#8220;05/01/2004&#8221;);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(0, payrollOutput.Count);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; [Test]<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">void</font></span> PayOneEmployeeOnFirstOfMonth()<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; EmployeeList employees = <span class="cb1"><font color="#0000ff">new</font></span> EmployeeList();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; employees.Add(&#8220;Bill&#8221;, 1200);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Payroll payroll = <span class="cb1"><font color="#0000ff">new</font></span> Payroll(employees);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; IList payrollOutput = payroll.Pay(&#8220;05/01/2004&#8221;);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(1, payrollOutput.Count);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; PayRecord billsPay = payrollOutput[0] <span class="cb1"><font color="#0000ff">as</font></span> PayRecord;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;Bill&#8221;, billsPay.Name);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(100, billsPay.Pay);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;05/01/2004&#8221;, billsPay.PayDate);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; [Test]<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">void</font></span> PayAllEmployeesOnFirstOfMonth()<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; EmployeeList employees = <span class="cb1"><font color="#0000ff">new</font></span> EmployeeList();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; employees.Add(&#8220;Bill&#8221;, 1200);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; employees.Add(&#8220;Tom&#8221;, 2400);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Payroll payroll = <span class="cb1"><font color="#0000ff">new</font></span> Payroll(employees);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; IList payRecords = payroll.Pay(&#8220;05/01/2004&#8221;);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(2, payRecords.Count);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; PayRecord billsPay = payRecords[0] <span class="cb1"><font color="#0000ff">as</font></span> PayRecord;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;Bill&#8221;, billsPay.Name);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(100, billsPay.Pay);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;05/01/2004&#8221;, billsPay.PayDate);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; PayRecord tomsPay = payRecords[1] <span class="cb1"><font color="#0000ff">as</font></span> PayRecord;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;Tom&#8221;, tomsPay.Name);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(200, tomsPay.Pay);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;05/01/2004&#8221;, tomsPay.PayDate);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; [Test]<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">void</font></span> NoEmployeePaidIfNotFirstOfMonth()<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; EmployeeList employees = <span class="cb1"><font color="#0000ff">new</font></span> EmployeeList();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; employees.Add(&#8220;Johnny&#8221;, 3600);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Payroll payroll = <span class="cb1"><font color="#0000ff">new</font></span> Payroll(employees);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; IList emptyList = payroll.Pay(&#8220;05/02/2004&#8221;);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(0, emptyList.Count);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">class</font></span> Payroll<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">private</font></span> EmployeeList employees;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">private</font></span> ArrayList payRecords;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">private</font></span> <span class="cb1"><font color="#0000ff">string</font></span> payDate;
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> Payroll(EmployeeList employees)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">this</font></span>.employees = employees;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> IList Pay(<span class="cb1"><font color="#0000ff">string</font></span> payDate)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">this</font></span>.payDate = payDate;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; payRecords = <span class="cb1"><font color="#0000ff">new</font></span> ArrayList();
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; employees.Apply(<span class="cb1"><font color="#0000ff">new</font></span> EmployeeList.ApplyAction(PayEmployee));
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">return</font></span> payRecords;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">private</font></span> <span class="cb1"><font color="#0000ff">void</font></span> PayEmployee(Employee employee)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; employee.Pay(payDate, payRecords);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">class</font></span> EmployeeList<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">private</font></span> ArrayList employees = <span class="cb1"><font color="#0000ff">new</font></span> ArrayList();
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">delegate</font></span> <span class="cb1"><font color="#0000ff">void</font></span> ApplyAction(Employee employee);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">void</font></span> Apply(ApplyAction action)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">foreach</font></span>(Employee employee <span class="cb1"><font color="#0000ff">in</font></span> employees)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; action(employee);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">void</font></span> Add(<span class="cb1"><font color="#0000ff">string</font></span> employeeName, <span class="cb1"><font color="#0000ff">int</font></span> yearlySalary)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; employees.Add(<span class="cb1"><font color="#0000ff">new</font></span> Employee(employeeName, yearlySalary));<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">int</font></span> Count<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">get</font></span> { <span class="cb1"><font color="#0000ff">return</font></span> employees.Count; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">class</font></span> Employee<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">private</font></span> <span class="cb1"><font color="#0000ff">string</font></span> name;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">private</font></span> <span class="cb1"><font color="#0000ff">int</font></span> salary;
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> Employee(<span class="cb1"><font color="#0000ff">string</font></span> name, <span class="cb1"><font color="#0000ff">int</font></span> yearlySalary)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">this</font></span>.name = name;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">this</font></span>.salary = yearlySalary;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">private</font></span> <span class="cb1"><font color="#0000ff">string</font></span> Name<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">get</font></span> { <span class="cb1"><font color="#0000ff">return</font></span> name; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">private</font></span> <span class="cb1"><font color="#0000ff">int</font></span> CalculatePay()<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">return</font></span> salary/12;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">void</font></span> Pay(<span class="cb1"><font color="#0000ff">string</font></span> payDate, IList payRecords)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">if</font></span>(IsPayday(payDate))<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; PayRecord payRecord = <span class="cb1"><font color="#0000ff">new</font></span> PayRecord(Name, CalculatePay(), payDate);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; payRecords.Add(payRecord);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">private</font></span> <span class="cb1"><font color="#0000ff">bool</font></span> IsPayday(<span class="cb1"><font color="#0000ff">string</font></span> payDate)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">string</font></span> [] dateParts = payDate.Split(<span class="cb1"><font color="#0000ff">new</font></span> <span class="cb1"><font color="#0000ff">char</font></span>[] {&#8216;/&#8217;});<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">return</font></span> dateParts[1] == &#8220;01&#8221;;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">class</font></span> PayRecord<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">private</font></span> <span class="cb1"><font color="#0000ff">string</font></span> name;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">private</font></span> <span class="cb1"><font color="#0000ff">int</font></span> pay;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">private</font></span> <span class="cb1"><font color="#0000ff">string</font></span> payDate;
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> PayRecord(<span class="cb1"><font color="#0000ff">string</font></span> name, <span class="cb1"><font color="#0000ff">int</font></span> pay, <span class="cb1"><font color="#0000ff">string</font></span> payDate)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">this</font></span>.name = name;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">this</font></span>.pay = pay;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">this</font></span>.payDate = payDate;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">string</font></span> Name<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">get</font></span> { <span class="cb1"><font color="#0000ff">return</font></span> name; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">int</font></span> Pay<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">get</font></span> { <span class="cb1"><font color="#0000ff">return</font></span> pay; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">string</font></span> PayDate<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">get</font></span> { <span class="cb1"><font color="#0000ff">return</font></span> payDate; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; [TestFixture]<br />&nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">class</font></span> CheckWriterFixture<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; [Test]<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">void</font></span> NoOutputWrittenIfNoPayRecords()<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; IList payRecords = <span class="cb1"><font color="#0000ff">new</font></span> ArrayList();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; StringWriter checkData = <span class="cb1"><font color="#0000ff">new</font></span> StringWriter();
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; CheckWriter writer = <span class="cb1"><font color="#0000ff">new</font></span> CheckWriter(checkData);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; writer.Write(payRecords);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(<span class="cb1"><font color="#0000ff">string</font></span>.Empty, checkData.ToString());<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; [Test]<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">void</font></span> SinglePayRecordFormattedCorrectlyWhenWritten()<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; IList payRecords = <span class="cb1"><font color="#0000ff">new</font></span> ArrayList();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; payRecords.Add(<span class="cb1"><font color="#0000ff">new</font></span> PayRecord(&#8220;Bill&#8221;, 1000, &#8220;05/01/2004&#8221;));
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; StringWriter checkData = <span class="cb1"><font color="#0000ff">new</font></span> StringWriter();
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; CheckWriter writer = <span class="cb1"><font color="#0000ff">new</font></span> CheckWriter(checkData);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; writer.Write(payRecords);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;Check,100,Bill,$1000,05/01/2004&#8221; + System.Environment.NewLine, checkData.ToString());<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; [Test]<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">void</font></span> CheckRecordsAlwaysStartAt100ForNewInstances()<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; IList payRecords = <span class="cb1"><font color="#0000ff">new</font></span> ArrayList();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; payRecords.Add(<span class="cb1"><font color="#0000ff">new</font></span> PayRecord(&#8220;Bill&#8221;, 1200, &#8220;05/01/2004&#8221;));
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; StringWriter firstCheckData = <span class="cb1"><font color="#0000ff">new</font></span> StringWriter();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; CheckWriter firstWriter = <span class="cb1"><font color="#0000ff">new</font></span> CheckWriter(firstCheckData);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; firstWriter.Write(payRecords);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;Check,100,Bill,$1200,05/01/2004&#8221; + System.Environment.NewLine, firstCheckData.ToString());
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; StringWriter secondCheckData = <span class="cb1"><font color="#0000ff">new</font></span> StringWriter();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; CheckWriter secondWriter = <span class="cb1"><font color="#0000ff">new</font></span> CheckWriter(secondCheckData);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; secondWriter.Write(payRecords);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;Check,100,Bill,$1200,05/01/2004&#8221; + System.Environment.NewLine, secondCheckData.ToString());<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; [Test]<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">void</font></span> CheckNumbersIncrementEachTimeWriteMethodIsCalled()<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; IList payRecords = <span class="cb1"><font color="#0000ff">new</font></span> ArrayList();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; payRecords.Add(<span class="cb1"><font color="#0000ff">new</font></span> PayRecord(&#8220;Bill&#8221;, 1200, &#8220;05/01/2004&#8221;));
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; StringWriter checkData = <span class="cb1"><font color="#0000ff">new</font></span> StringWriter();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; CheckWriter writer = <span class="cb1"><font color="#0000ff">new</font></span> CheckWriter(checkData);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; writer.Write(payRecords);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; writer.Write(payRecords);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;Check,100,Bill,$1200,05/01/2004&#8221; + System.Environment.NewLine +<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &#8220;Check,101,Bill,$1200,05/01/2004&#8221; + System.Environment.NewLine, checkData.ToString());<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; [Test]<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">void</font></span> WriteOutputForAllPayRecordsInGivenList()<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; IList payRecords = <span class="cb1"><font color="#0000ff">new</font></span> ArrayList();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; payRecords.Add(<span class="cb1"><font color="#0000ff">new</font></span> PayRecord(&#8220;Tom&#8221;, 100, &#8220;01/01/2004&#8221;));<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; payRecords.Add(<span class="cb1"><font color="#0000ff">new</font></span> PayRecord(&#8220;Sue&#8221;, 500, &#8220;02/01/2004&#8221;));
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; StringWriter checkData = <span class="cb1"><font color="#0000ff">new</font></span> StringWriter();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; CheckWriter writer = <span class="cb1"><font color="#0000ff">new</font></span> CheckWriter(checkData);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; writer.Write(payRecords);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;Check,100,Tom,$100,01/01/2004&#8221; + System.Environment.NewLine +<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &#8220;Check,101,Sue,$500,02/01/2004&#8221; + System.Environment.NewLine, checkData.ToString());<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">class</font></span> CheckWriter<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">private</font></span> TextWriter checkData; <br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">private</font></span> <span class="cb1"><font color="#0000ff">int</font></span> checkNumber = 100;
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> CheckWriter(TextWriter checkData)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">this</font></span>.checkData = checkData;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">public</font></span> <span class="cb1"><font color="#0000ff">void</font></span> Write(IList payRecords)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1"><font color="#0000ff">foreach</font></span>(PayRecord payRecord <span class="cb1"><font color="#0000ff">in</font></span> payRecords)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; checkData.WriteLine(&#8220;Check,&#8221; + checkNumber++ + &#8220;,&#8221; + <br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; payRecord.Name + &#8220;,$&#8221; + <br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; payRecord.Pay + &#8220;,&#8221; + payRecord.PayDate);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
    
    <p>
      <!--EndFragment-->
    </p>