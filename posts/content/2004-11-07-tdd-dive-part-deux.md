---
title: TDD Dive — Part Deux
author: Brian Button
type: post
date: 2004-11-07T22:55:00+00:00
url: /index.php/2004/11/07/tdd-dive-part-deux/
sfw_comment_form_password:
  - KUubUXYsTPn3
sfw_pwd:
  - j94GUfSOJq6z
categories:
  - Uncategorized

---
When last I left [you][1], we had just about started implementing a simple payroll system using TDD. We had written two tests and done some refactoring, but there were still some code smells that I didn&#8217;t care for that we were going to look at before proceeding.

This is the current Payroll.Pay method:

<div class="csharpcode">
  <pre><span class="lnum">     1: </span><span class="kwrd">public</span> <span class="kwrd">string</span> Pay(<span class="kwrd">string</span> payDate)</pre>
  
  <pre><span class="lnum">     2: </span>{</pre>
  
  <pre><span class="lnum">     3: </span>    <span class="kwrd">if</span>(employees.Count == 0) <span class="kwrd">return</span> <span class="kwrd">null</span>;</pre>
  
  <pre><span class="lnum">     4: </span>    Employee theEmployee = employees.Employee;</pre>
  
  <pre><span class="lnum">     5: </span>    <span class="kwrd">return</span> <span class="str">"Check,100,"</span> + theEmployee.Name + <span class="str">",$"</span> + theEmployee.CalculatePay() + <span class="str">","</span> +payDate;</pre>
  
  <pre><span class="lnum">     6: </span>}</pre>
</div>

My biggest problems here are that this method, inside the Payroll class, knows how to dip inside the Employee class to get names and pay amounts, and it know how to format the output according to what our check writing company needs. Let&#8217;s try to fix both of these, and see where this takes us.

My first instinct is that we could move this behavior inside Employee. This would remove the knowledge of the primitive accessors from the Payroll class, and would move all logic about creating pay information inside the Employee. This leaves us with:

<div class="csharpcode">
  <pre><span class="lnum">     1:</span> <span class="kwrd">public</span> <span class="kwrd">string</span> Pay(<span class="kwrd">string</span> payDate)</pre>
  
  <pre><span class="lnum">     2:</span> {</pre>
  
  <pre><span class="lnum">     3:</span>     <span class="kwrd">if</span>(employees.Count == 0) <span class="kwrd">return</span> <span class="kwrd">null</span>;</pre>
  
  <pre><span class="lnum">     4:</span>     Employee theEmployee = employees.Employee;</pre>
  
  <pre><span class="lnum">     5:</span>     <span class="kwrd">return</span> Pay(payDate, theEmployee);</pre>
  
  <pre><span class="lnum">     6:</span> }</pre>
  
  <pre><span class="lnum">     7: </span>  </pre>
  
  <pre><span class="lnum">     8:</span> <span class="kwrd">private</span> <span class="kwrd">string</span> Pay(<span class="kwrd">string</span> payDate, Employee theEmployee)</pre>
  
  <pre><span class="lnum">     9:</span> {</pre>
  
  <pre><span class="lnum">    10:</span>     <span class="kwrd">return</span> <span class="str">"Check,100,"</span> + theEmployee.Name + <span class="str">",$"</span> + theEmployee.CalculatePay() + <span class="str">","</span> +payDate;</pre>
  
  <pre><span class="lnum">    11:</span> }</pre>
</div>

Step one was to do an ExtractMethod refactoring to move the creation of the string into its own method. Now that its here, we can look at it more closely, and see if we can&#8217;t figoure out where the code really wants to be. It sure looks like all the data that this method is using comes from the Employee class. This is a code smell called FeatureEnvy, where code that exists in one place is accessing private parts of another class, and the code really _wants_ to be in that other class. Let&#8217;s do a MoveMethod and move it there&#8230;

<div class="csharpcode">
  <pre><span class="lnum">     1:</span> <span class="kwrd">private</span> <span class="kwrd">class</span> Payroll</pre>
  
  <pre><span class="lnum">     2:</span> {</pre>
  
  <pre><span class="lnum">     3:</span>     <span class="kwrd">private</span> EmployeeList employees;</pre>
  
  <pre><span class="lnum">     4:</span></pre>
  
  <pre><span class="lnum">     5:</span>     <span class="kwrd">public</span> Payroll(EmployeeList employees)</pre>
  
  <pre><span class="lnum">     6:</span>     {</pre>
  
  <pre><span class="lnum">     7:</span>         <span class="kwrd">this</span>.employees = employees;</pre>
  
  <pre><span class="lnum">     8:</span>     }</pre>
  
  <pre><span class="lnum">     9: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    10:</span>     <span class="kwrd">public</span> <span class="kwrd">string</span> Pay(<span class="kwrd">string</span> payDate)</pre>
  
  <pre><span class="lnum">    11:</span>     {</pre>
  
  <pre><span class="lnum">    12:</span>         <span class="kwrd">if</span> (employees.Count == 0) <span class="kwrd">return</span> <span class="kwrd">null</span>;</pre>
  
  <pre><span class="lnum">    13:</span>         Employee theEmployee = employees.Employee;</pre>
  
  <pre><span class="lnum">    14:</span>         <span class="kwrd">return</span> theEmployee.Pay(payDate);</pre>
  
  <pre><span class="lnum">    15:</span>     }</pre>
  
  <pre><span class="lnum">    16:</span> }</pre>
  
  <pre><span class="lnum">    17: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    18:</span> <span class="kwrd">private</span> <span class="kwrd">class</span> Employee</pre>
  
  <pre><span class="lnum">    19:</span> {</pre>
  
  <pre><span class="lnum">    20:</span>     <span class="kwrd">private</span> <span class="kwrd">string</span> name;</pre>
  
  <pre><span class="lnum">    21: </span>    <span class="kwrd">private</span> <span class="kwrd">int</span> salary;</pre>
  
  <pre><span class="lnum">    22: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    23: </span>    <span class="kwrd">public</span> Employee(<span class="kwrd">string</span> name, <span class="kwrd">int</span> yearlySalary)</pre>
  
  <pre><span class="lnum">    24: </span>    {</pre>
  
  <pre><span class="lnum">    25: </span>        <span class="kwrd">this</span>.name = name;</pre>
  
  <pre><span class="lnum">    26: </span>        <span class="kwrd">this</span>.salary = yearlySalary;</pre>
  
  <pre><span class="lnum">    27: </span>    }</pre>
  
  <pre><span class="lnum">    28: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    29: </span>    <span class="kwrd">private</span> <span class="kwrd">string</span> Name</pre>
  
  <pre><span class="lnum">    30: </span>    {</pre>
  
  <pre><span class="lnum">    31: </span>        get { <span class="kwrd">return</span> name; }</pre>
  
  <pre><span class="lnum">    32: </span>    }</pre>
  
  <pre><span class="lnum">    33: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    34: </span>    <span class="kwrd">private</span> <span class="kwrd">int</span> CalculatePay()</pre>
  
  <pre><span class="lnum">    35: </span>    {</pre>
  
  <pre><span class="lnum">    36: </span>        <span class="kwrd">return</span> salary/12;</pre>
  
  <pre><span class="lnum">    37: </span>    }</pre>
  
  <pre><span class="lnum">    38: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    39: </span>    <span class="kwrd">public</span> <span class="kwrd">string</span> Pay(<span class="kwrd">string</span> payDate)</pre>
  
  <pre><span class="lnum">    40: </span>    {</pre>
  
  <pre><span class="lnum">    41: </span>        <span class="kwrd">return</span> <span class="str">"Check,100,"</span> + Name + <span class="str">",$"</span> + CalculatePay() + <span class="str">","</span> + payDate;</pre>
  
  <pre><span class="lnum">    42: </span>    }</pre>
  
  <pre><span class="lnum">    43: </span>}</pre>
</div>

After this change, line 14 has been changed to call the Pay method of Employee, and Payroll is ignorant of any other behavior or implementation detail of Employee. This is a Good Thing.

The remaining smell in our code at this point is that the Pay method now knows about check formatting, and it probably shouldn&#8217;t. What I&#8217;d really like to have happen is that this method would return some dumb data object that another class could use to format the output at some later point. That way I&#8217;ve separated production of the payroll data from the formatting and reporting of that data. Each of these concepts could vary independently, so they really don&#8217;t belong in the same place. This leads me to create a PayRecord class, whose responsibility it is to transport pay data between the Employee class and the still to-be-designed check formatting class.

<div class="csharpcode">
  <pre><span class="lnum">     1: </span><span class="kwrd">private</span> <span class="kwrd">class</span> Employee</pre>
  
  <pre><span class="lnum">     2: </span>{</pre>
  
  <pre><span class="lnum">     3: </span>    <span class="kwrd">public</span> <span class="kwrd">string</span> Pay(<span class="kwrd">string</span> payDate)</pre>
  
  <pre><span class="lnum">     4: </span>    {</pre>
  
  <pre><span class="lnum">     5: </span>        PayRecord payRecord = <span class="kwrd">new</span> PayRecord(Name, CalculatePay());</pre>
  
  <pre><span class="lnum">     6: </span>        <span class="kwrd">return</span> <span class="str">"Check,100,"</span> + payRecord.Name + <span class="str">",$"</span> + payRecord.Pay + <span class="str">","</span> + payDate;</pre>
  
  <pre><span class="lnum">     7: </span>    }</pre>
  
  <pre><span class="lnum">     8: </span>}</pre>
  
  <pre><span class="lnum">     9: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    10: </span><span class="kwrd">private</span> <span class="kwrd">class</span> PayRecord</pre>
  
  <pre><span class="lnum">    11: </span>{</pre>
  
  <pre><span class="lnum">    12: </span>    <span class="kwrd">private</span> <span class="kwrd">string</span> name;</pre>
  
  <pre><span class="lnum">    13: </span>    <span class="kwrd">private</span> <span class="kwrd">int</span> pay;</pre>
  
  <pre><span class="lnum">    14: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    15: </span>    <span class="kwrd">public</span> PayRecord(<span class="kwrd">string</span> name, <span class="kwrd">int</span> pay)</pre>
  
  <pre><span class="lnum">    16: </span>    {</pre>
  
  <pre><span class="lnum">    17: </span>        <span class="kwrd">this</span>.name = name;</pre>
  
  <pre><span class="lnum">    18: </span>        <span class="kwrd">this</span>.pay = pay;</pre>
  
  <pre><span class="lnum">    19: </span>    }</pre>
  
  <pre><span class="lnum">    20: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    21: </span>    <span class="kwrd">public</span> <span class="kwrd">string</span> Name</pre>
  
  <pre><span class="lnum">    22: </span>    {</pre>
  
  <pre><span class="lnum">    23: </span>        get { <span class="kwrd">return</span> name; }</pre>
  
  <pre><span class="lnum">    24: </span>    }</pre>
  
  <pre><span class="lnum">    25: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    26:  </span>   <span class="kwrd">public</span> <span class="kwrd">int</span> Pay</pre>
  
  <pre><span class="lnum">    27: </span>    {</pre>
  
  <pre><span class="lnum">    28: </span>        get { <span class="kwrd">return</span> pay; }</pre>
  
  <pre><span class="lnum">    29: </span>    }</pre>
  
  <pre><span class="lnum">    30: </span>}</pre>
</div>

Sometimes it gets challenging to imagine what the smallest step along the way could be. In this case, it would have been pretty easy to create a PayRecord class, change the signature of the Pay method to return one of these buggers, and then change my tests to match. But I think I can do it is a smaller step. I can do as I show above &#8212; I can create the PayRecord class inside the Pay method and still return the string. I can now test this,and I&#8217;m certain that my code all still works. The next refactoring is the ChangeMethodSignature, where I&#8217;ll change this method to return a PayRecord and change the tests to match. Remember, refactoring is about making small, measured changes to your source code, and verifying their correctness before moving on. Taking big steps increases the risk that something can go wrong, and you&#8217;ll have to take extra time to figure out what that was and fix it.

Now here is the final version of the code as far as we are now. This last step was to change the method signature of the Pay method in Employee and Payroll to both return a PayRecord, and I updated the tests to look inside the PayRecord to confirm that the right data was produced.

<div class="csharpcode">
  <pre><span class="lnum">     1: </span><span class="kwrd">using</span> NUnit.Framework;</pre>
  
  <pre><span class="lnum">     2: </span>&nbsp;</pre>
  
  <pre><span class="lnum">     3: </span><span class="kwrd">namespace</span> PayrollExercise</pre>
  
  <pre><span class="lnum">     4: </span>{</pre>
  
  <pre><span class="lnum">     5: </span>    [TestFixture]</pre>
  
  <pre><span class="lnum">     6: </span>    <span class="kwrd">public</span> <span class="kwrd">class</span> PayrollFixture</pre>
  
  <pre><span class="lnum">     7: </span>    {</pre>
  
  <pre><span class="lnum">     8: </span>        [Test]</pre>
  
  <pre><span class="lnum">     9: </span>        <span class="kwrd">public</span> <span class="kwrd">void</span> NoOnePaidIfNoEmployees()</pre>
  
  <pre><span class="lnum">    10: </span>        {</pre>
  
  <pre><span class="lnum">    11: </span>            EmployeeList employees = <span class="kwrd">new</span> EmployeeList();</pre>
  
  <pre><span class="lnum">    12: </span>            Payroll payroll = <span class="kwrd">new</span> Payroll(employees);</pre>
  
  <pre><span class="lnum">    13: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    14: </span>            PayRecord payrollOutput = payroll.Pay(<span class="str">"05/01/2004"</span>);</pre>
  
  <pre><span class="lnum">    15: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    16: </span>            Assert.IsNull(payrollOutput);</pre>
  
  <pre><span class="lnum">    17: </span>        }</pre>
  
  <pre><span class="lnum">    18: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    19: </span>        [Test]</pre>
  
  <pre><span class="lnum">    20: </span>        <span class="kwrd">public</span> <span class="kwrd">void</span> PayOneEmployeeOnFirstOfMonth()</pre>
  
  <pre><span class="lnum">    21: </span>        {</pre>
  
  <pre><span class="lnum">    22: </span>            EmployeeList employees = <span class="kwrd">new</span> EmployeeList();</pre>
  
  <pre><span class="lnum">    23: </span>            employees.Add(<span class="str">"Bill"</span>, 1200);</pre>
  
  <pre><span class="lnum">    24: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    25: </span>            Payroll payroll = <span class="kwrd">new</span> Payroll(employees);</pre>
  
  <pre><span class="lnum">    26: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    27: </span>            PayRecord payrollOutput = payroll.Pay(<span class="str">"05/01/2004"</span>);</pre>
  
  <pre><span class="lnum">    28: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    29: </span>            Assert.AreEqual(<span class="str">"Bill"</span>, payrollOutput.Name);</pre>
  
  <pre><span class="lnum">    30: </span>            Assert.AreEqual(100, payrollOutput.Pay);</pre>
  
  <pre><span class="lnum">    31: </span>        }</pre>
  
  <pre><span class="lnum">    32: </span>    }</pre>
  
  <pre><span class="lnum">    33: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    34: </span>    <span class="kwrd">public</span> <span class="kwrd">class</span> Payroll</pre>
  
  <pre><span class="lnum">    35: </span>    {</pre>
  
  <pre><span class="lnum">    36: </span>        <span class="kwrd">private</span> EmployeeList employees;</pre>
  
  <pre><span class="lnum">    37: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    38: </span>        <span class="kwrd">public</span> Payroll(EmployeeList employees)</pre>
  
  <pre><span class="lnum">    39: </span>        {</pre>
  
  <pre><span class="lnum">    40: </span>            <span class="kwrd">this</span>.employees = employees;</pre>
  
  <pre><span class="lnum">    41: </span>        }</pre>
  
  <pre><span class="lnum">    42: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    43: </span>        <span class="kwrd">public</span> PayRecord Pay(<span class="kwrd">string</span> payDate)</pre>
  
  <pre><span class="lnum">    44: </span>        {</pre>
  
  <pre><span class="lnum">    45: </span>            <span class="kwrd">if</span> (employees.Count == 0) <span class="kwrd">return</span> <span class="kwrd">null</span>;</pre>
  
  <pre><span class="lnum">    46: </span>            Employee theEmployee = employees.Employee;</pre>
  
  <pre><span class="lnum">    47: </span>            <span class="kwrd">return</span> theEmployee.Pay(payDate);</pre>
  
  <pre><span class="lnum">    48: </span>        }</pre>
  
  <pre><span class="lnum">    49: </span>    }</pre>
  
  <pre><span class="lnum">    50: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    51: </span>    <span class="kwrd">public</span> <span class="kwrd">class</span> Employee</pre>
  
  <pre><span class="lnum">    52: </span>    {</pre>
  
  <pre><span class="lnum">    53: </span>        <span class="kwrd">private</span> <span class="kwrd">string</span> name;</pre>
  
  <pre><span class="lnum">    54: </span>        <span class="kwrd">private</span> <span class="kwrd">int</span> salary;</pre>
  
  <pre><span class="lnum">    55: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    56: </span>        <span class="kwrd">public</span> Employee(<span class="kwrd">string</span> name, <span class="kwrd">int</span> yearlySalary)</pre>
  
  <pre><span class="lnum">    57: </span>        {</pre>
  
  <pre><span class="lnum">    58: </span>            <span class="kwrd">this</span>.name = name;</pre>
  
  <pre><span class="lnum">    59: </span>            <span class="kwrd">this</span>.salary = yearlySalary;</pre>
  
  <pre><span class="lnum">    60: </span>        }</pre>
  
  <pre><span class="lnum">    61: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    62: </span>        <span class="kwrd">private</span> <span class="kwrd">string</span> Name</pre>
  
  <pre><span class="lnum">    63: </span>        {</pre>
  
  <pre><span class="lnum">    64: </span>            get { <span class="kwrd">return</span> name; }</pre>
  
  <pre><span class="lnum">    65: </span>        }</pre>
  
  <pre><span class="lnum">    66: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    67: </span>        <span class="kwrd">private</span> <span class="kwrd">int</span> CalculatePay()</pre>
  
  <pre><span class="lnum">    68: </span>        {</pre>
  
  <pre><span class="lnum">    69: </span>            <span class="kwrd">return</span> salary/12;</pre>
  
  <pre><span class="lnum">    70: </span>        }</pre>
  
  <pre><span class="lnum">    71: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    72: </span>        <span class="kwrd">public</span> PayRecord Pay(<span class="kwrd">string</span> payDate)</pre>
  
  <pre><span class="lnum">    73: </span>        {</pre>
  
  <pre><span class="lnum">    74: </span>            PayRecord payRecord = <span class="kwrd">new</span> PayRecord(Name, CalculatePay());</pre>
  
  <pre><span class="lnum">    75: </span>            <span class="kwrd">return</span> payRecord;</pre>
  
  <pre><span class="lnum">    76: </span>        }</pre>
  
  <pre><span class="lnum">    77: </span>    }</pre>
  
  <pre><span class="lnum">    78: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    79: </span>    <span class="kwrd">public</span> <span class="kwrd">class</span> PayRecord</pre>
  
  <pre><span class="lnum">    80: </span>    {</pre>
  
  <pre><span class="lnum">    81: </span>        <span class="kwrd">private</span> <span class="kwrd">string</span> name;</pre>
  
  <pre><span class="lnum">    82: </span>        <span class="kwrd">private</span> <span class="kwrd">int</span> pay;</pre>
  
  <pre><span class="lnum">    83: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    84: </span>        <span class="kwrd">public</span> PayRecord(<span class="kwrd">string</span> name, <span class="kwrd">int</span> pay)</pre>
  
  <pre><span class="lnum">    85: </span>        {</pre>
  
  <pre><span class="lnum">    86: </span>            <span class="kwrd">this</span>.name = name;</pre>
  
  <pre><span class="lnum">    87: </span>            <span class="kwrd">this</span>.pay = pay;</pre>
  
  <pre><span class="lnum">    88: </span>        }</pre>
  
  <pre><span class="lnum">    89: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    90: </span>        <span class="kwrd">public</span> <span class="kwrd">string</span> Name</pre>
  
  <pre><span class="lnum">    91: </span>        {</pre>
  
  <pre><span class="lnum">    92: </span>            get { <span class="kwrd">return</span> name; }</pre>
  
  <pre><span class="lnum">    93: </span>        }</pre>
  
  <pre><span class="lnum">    94: </span>&nbsp;</pre>
  
  <pre><span class="lnum">    95: </span>        <span class="kwrd">public</span> <span class="kwrd">int</span> Pay</pre>
  
  <pre><span class="lnum">    96: </span>        {</pre>
  
  <pre><span class="lnum">    97: </span>            get { <span class="kwrd">return</span> pay; }</pre>
  
  <pre><span class="lnum">    98: </span>        }</pre>
  
  <pre><span class="lnum">    99: </span>    }</pre>
  
  <pre><span class="lnum">   100: </span>&nbsp;</pre>
  
  <pre><span class="lnum">   101: </span>    <span class="kwrd">public</span> <span class="kwrd">class</span> EmployeeList</pre>
  
  <pre><span class="lnum">   102: </span>    {</pre>
  
  <pre><span class="lnum">   103: </span>        <span class="kwrd">private</span> <span class="kwrd">int</span> employeeCount = 0;</pre>
  
  <pre><span class="lnum">   104: </span>        <span class="kwrd">private</span> Employee employee;</pre>
  
  <pre><span class="lnum">   105: </span>&nbsp;</pre>
  
  <pre><span class="lnum">   106: </span>        <span class="kwrd">public</span> <span class="kwrd">void</span> Add(<span class="kwrd">string</span> employeeName, <span class="kwrd">int</span> yearlySalary)</pre>
  
  <pre><span class="lnum">   107: </span>        {</pre>
  
  <pre><span class="lnum">   108: </span>            employee = <span class="kwrd">new</span> Employee(employeeName, yearlySalary);</pre>
  
  <pre><span class="lnum">   109: </span>            <span class="kwrd">this</span>.employeeCount++;</pre>
  
  <pre><span class="lnum">   110: </span>        }</pre>
  
  <pre><span class="lnum">   111: </span>&nbsp;</pre>
  
  <pre><span class="lnum">   112: </span>        <span class="kwrd">public</span> <span class="kwrd">int</span> Count</pre>
  
  <pre><span class="lnum">   113: </span>        {</pre>
  
  <pre><span class="lnum">   114: </span>            get { <span class="kwrd">return</span> employeeCount; }</pre>
  
  <pre><span class="lnum">   115: </span>        }</pre>
  
  <pre><span class="lnum">   116: </span>&nbsp;</pre>
  
  <pre><span class="lnum">   117: </span>        <span class="kwrd">public</span> Employee Employee</pre>
  
  <pre><span class="lnum">   118: </span>        {</pre>
  
  <pre><span class="lnum">   119: </span>            get { <span class="kwrd">return</span> employee; }</pre>
  
  <pre><span class="lnum">   120: </span>        }</pre>
  
  <pre><span class="lnum">   121: </span>    }</pre>
  
  <pre><span class="lnum">   122: </span>}</pre>
</div>

The point that I really want to make is that refactoring is **_really_** important. Test Driven Development is the process of adding behavior incrementally, driven through mini-use cases of the software you&#8217;re building. Each test forces some new behavior to be added to the system, but it doesn&#8217;t say anything at all about the _design_ of the system. The tests help you get the interface right between the objects you&#8217;re talking to,&nbsp;but that&#8217;s at far as they go. Refactoring is the design engine in the TDD process. It is the process through which other classes are born, code is made simple and readable, and systems evolve and grow.

If you are doing TDD and you are not spending a significant amount of your time refactoring, you are doing yourself and your team a disservice.

I&#8217;ll leave you on that cheery note 🙂 More of this example to come shortly.

&#8212; bab

**Now playing:** Dio &#8211; The Last In Line &#8211; One Night In The City

 [1]: http://dotnetjunkies.com/WebLog/oneagilecoder/archive/2004/10/25/29610.aspx