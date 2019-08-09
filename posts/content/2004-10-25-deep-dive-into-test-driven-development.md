---
title: Deep Dive into Test Driven Development
author: Brian Button
type: post
date: 2004-10-25T06:11:00+00:00
url: /index.php/2004/10/25/deep-dive-into-test-driven-development/
sfw_comment_form_password:
  - et9xuvOV8Uhp
sfw_pwd:
  - sWu4hoTZ1gN5
categories:
  - Uncategorized

---
In a class I recently taught, the students created a simple payroll system using Test Driven Development. Different students made different amounts of progress, some almost finishing the example I&#8217;m about to post, and some not quite so far. But they all asked for my solution. I have already posted the code to my solution, but now I want to talk about how I went about creating it. Hopefully this will share my Test Driven thought processes with my students and anyone else who might be reading.

### So, here&#8217;s the problem&#8230;

I own a small business, and I need to pay my few employees. Right now, I only have salaried employees, but I might hire some hourly folks later. I have no immediate plans to do any hiring at all, I just have a need to pay my employees.

My first requirement of this system is that it has to allow me to pay my 2 salaried employees on the first day of the month 1/12 of their yearly salary. I want to be able to run my payroll system based off an input batch file that specifies the date on which to pretend to run the program. The input looks like this:

<font face="Times New Roman">Payroll,05/01/2004<br />Payroll,05/15/2004<br />Payroll,06/01/2004</font>

In response to this input file, the system should run payroll 3 times. The first time it is run as if the current date is May 1, 2004. The second is run as if it is May 15th, and so on. This allows me to rerun payroll at will to try different scenarios, etc.

For this input, I need to generate an output file that my check writing company uses to cut checks for me. My payroll program doesn&#8217;t need to actually write the checks, it just needs to create a specifically formatted output file. For the previous input, I expect this as an output:

<font face="Times New Roman">Check,100,Frank Furter,$10000,05/01/2004<br />Check,101,Howard Hog,$12000,05/01/2004<br />Check,100,Frank Furter,$10000,06/01/2004<br />Check,101,Howard Hog,$12000,06/01/2004</font>

That&#8217;s it. I need a payroll program to do that. It needs to, at the end of the day, have a main routine that allows me to specify an input file and output file on the command line, and it needs to produce the given output for the given input as its acceptance test.

### My solution&#8230;

Given that I&#8217;m pretty well hooked on TDD, it seems pretty obvious that my first instinct is to write a test. But before I do that, I want to think about the problem a bit. I do know that we are reading an input file, and that the input file has a transactiony kind of feel to it. That&#8217;s going to influence my design a bit, but not overly. Yet. This is an important point of TDD. You don&#8217;t have to blindly charge ahead &#8212; you&#8217;re allowed to think about the shape of the problem and consider how that might affect your solution. You just have to be careful not to allow that forethought to affect your decisions overly much. But by considering the requirements, it is possible that your design might be subtly guided towards certain choices and away from others. It&#8217;s OK to think ahead a bit, but not too far&#8230;

So, given that this system feels like a bunch of transactions that will be executed, I have a feeling that there will be something in the system that feels like a Command object. The Command design pattern talks about creating little objects that embody some kind of processing that can be created in one place, passed around, and eventually executed someplace else. Think of Command objects as little workers that your system can create, pass around, and run at will, when the mood strikes.

Now where should we begin? Given the requirements of this first story, where should we start writing tests and code. There will obviously be more than one class here, including something to handle input from a file, output to a file, and the actual payroll processing. The natural inclination of most programmers is to start with the file IO stuff, but for a very interesting reason. I credit this insight to a very good friend of mine, Kyle Cordes, who observed that many programmers start with the parts of their program that communicate with the outside world because without these pieces, they can&#8217;t test their system. They are used to manually testing things, which means that they have to run them by hand and observer their behavior through a debugger or through print statements. To run the program, you have to have the input and output stuff finished first. So that&#8217;s what they work on first. I contend that the important part to work on first is the part that is the essence of the business problem. In this case, that means to work on the part that is responsible for actually paying someone. I know I can write the input and output stuff pretty easily &#8212; that&#8217;s just tech stuff. But the business problem is where all the interesting stuff happens. Since I&#8217;m going to be writing unit tests for my code, I don&#8217;t need to have the input and output stuff working to let me test my system, so I can afford to write them later. And I will.

Armed with this knowledge, I&#8217;m pretty confident that the place to start is to write some tests and code around paying an employee or two. Before we create our first test, however, we need to consider what this little piece of our system will actually do. We need to create a Test List that will help us think about our system, about what it does, how ti reacts to inputs, creates outputs, and get our thoughts focused on the task at hand. I&#8217;m pretty big on creating these test lists as they serve a few different purposes. The first purpose I just described above &#8212; it helps us get our mind around the class, module, or whatever we&#8217;re about to write. The other really important reason to create a Test List is that it serves as the center point of documentation that others will use when they come in later to read, understand, and modify our code. 

<Shameless Plug>  
I have an article on this very topic coming out in Better Software magazine in February. I haven&#8217;t been told the title yet, but it should be something like &#8220;Using Unit Tests as Agile Documentation&#8221;.  
</Shameless Plug>

So this is my test list:

  * No one is paid if it is not first of month
  * One employee is paid if it is first of month
  * Multiple employees are paid if it is first of month
  * No employees are paid if it is not first of month

As far as I can consider right now, if I implement those tests, I&#8217;ll be able to pay folks exactly as I want to, and I&#8217;ll be happy. And now I&#8217;m ready to write my first test. Finally!

#### Our first test

<pre>[TestFixture]<br />    public class PayrollFixture<br />    {<br />        [Test]<br />        public void NoOnePaidIfNoEmployees()<br />        {<br />            EmployeeList employees = new EmployeeList();<br />            Payroll payroll = new Payroll(employees);<br />            string payrollOutput = payroll.Pay("05/01/2004");<br />            Assert.IsNull(payrollOutput);<br />        }<br /><br />        private class Payroll<br />        {<br />            public Payroll(EmployeeList employees)<br />            {<br />            }<br />            public string Pay(string payDate)<br />            {<br />                return null;<br />            }<br />        }<br /> <br />        private class EmployeeList<br />        {<br />        }<br />    }   </pre>

In this test, I took the first, most basic item off my test list and implemented it. My thinking in designing it was that I knew I had to use the Payroll object to pay some folks, and I needed to be able to pass those folks into it. This led me to creating the EmployeeList object, which merely encapsulates a list of employees. And <font face="Courier New">payroll.Pay(string payDate)</font> seems like the obvious way to get them paid. As far as how to tell if they were paid or not, I don&#8217;t really know enough about the problem yet to do anything different than just returning a string. I&#8217;m sure I&#8217;ll learn more about this later, but without a few more examples, I&#8217;ll be just guessing.

I know the implementation is really, _really_ simple at this point, but I trust that I&#8217;ll learn more very soon, and I&#8217;ll be able to tell where to take it then.

As a sidenote, when I&#8217;m just starting off, I&#8217;ll frequently put the test class and the application class in the same file for a while, until the classes get too big, at which time I&#8217;ll extract them to their own files and deal with switching between buffers. In this case, Resharper built the application classes for me, which was really cool!

#### Our second test

<pre>[TestFixture]<br />    public class PayrollFixture<br />    {<br />        /* First test omitted */<br />        [Test]<br />        <font color="#ff0000">public void PayOneEmployeeOnFirstOfMonth()<br />        {<br />            EmployeeList employees = new EmployeeList();<br />            employees.Add("Bill", 1200);<br /> <br />            Payroll payroll = new Payroll(employees);<br /> <br />            string payrollOutput = payroll.Pay("05/01/2004"); <br />            Assert.AreEqual("Check,100,Bill,$100,05/01/2004", payrollOutput);<br />        }</font>   <br /><br />   <br />        private class Payroll<br />        {<br />            private EmployeeList employees;<br /> <br />            public Payroll(EmployeeList employees)<br />            {<br />                this.employees = employees;<br />            }<br /> <br />            <font color="#ff0000">public string Pay(string payDate)<br />            {<br />                if(employees.Count == 0) return null;<br />                int pay = employees.Pay / 12;<br />                string name = employees.Name;<br />                return "Check,100," + name + ",$" + pay + "," +payDate;<br />            }<br /></font>        }<br /> <br />        private class EmployeeList<br />        {<br />            private string employeeName;<br />            private int yearlySalary;<br />            private int employeeCount = 0;<br /> <br /><br />            public void Add(string employeeName, int yearlySalary)<br />            {<br />                this.employeeName = employeeName;<br />                this.yearlySalary = yearlySalary;<br />                this.employeeCount++;<br />            } <br />            public int Count<br />            {<br />                get { return employeeCount; }<br />            }<br /> <br />            public int Pay<br />            {<br />                get { return yearlySalary; }<br />            }<br /> <br />            public string Name<br />            {<br />                get { return employeeName; }<br />            } <br />        }<br />    }</pre>

At this point, we&#8217;ve gone as far as teaching the system how to pay a single employee. We had to do a little trickery to keep our first test working still. The interesting bits of the change are highlighted in red. The first piece is the new test itself. We haven&#8217;t really fleshed out any new interfaces here other than the ability to Add an employee to the EmployeeList. Note that we have not created an Employee class yet. There doesn&#8217;t seem to be any pressing need for one net, but I&#8217;ll keep an eye out for a reason to refactor one out of thing air 🙂 Also, our Pay method in Payroll has gotten a bit smarter. It now knows how to pay folks the appropriate amount of money and how to format the check output at the appropriate time.

Hmm, in describing the responsibilities of that method, I used the word _and_ at least once. This is a big clue to me that perhaps this method may have gotten too smart. Indeed, if we look at it, we find out that it not only has the business policy in it of knowing that people get paid, it also knows the details of how their salary calculations happen and how the output is formatted. Sounds like a smelly method to me, that is screaming out for refactoring. Based on this simple smell, I&#8217;m going to refactor this method a bit and see what happens&#8230;

#### First smell

The first thing about this method that particularly bothers me is that the EmployeeList class is serving back primitive information about an employee, and the Pay method is using it in interesting ways, ways that should probably be encapsulated in another object. Now we have a _reason_ to create our Employee class. Employees know how to pay themselves. Simple responsibility, but that&#8217;s really where it belongs. Let&#8217;s make that change.

<pre>private class Payroll<br />        {<br />            private EmployeeList employees;<br /> <br />            public Payroll(EmployeeList employees)<br />            {<br />                this.employees = employees;<br />            }<br /><br /> <br />            public string Pay(string payDate)<br />            {<br />                if(employees.Count == 0) return null;<br /> <br />                Employee theEmployee = employees.Employee;<br />                return "Check,100," + theEmployee.Name + ",$" + theEmployee.CalculatePay() + "," +payDate;<br />            }<br />        }<br /> <br />        private class EmployeeList<br />        {<br />            private int employeeCount = 0;<br />            private Employee employee;<br /> <br />            public void Add(string employeeName, int yearlySalary)<br />            {<br />                employee = new Employee(employeeName, yearlySalary);<br />                this.employeeCount++;<br />            }<br /> <br />            public int Count<br />            {<br />                get {return employeeCount; }<br />            } <br /> <br />            public Employee Employee<br />            {<br />                get { return employee; }<br />            }<br />        }<br /> <br />        private class Employee<br />        {<br />            private string name;<br />            private int salary;<br />            <br />            public Employee(string name, int yearlySalary)<br />            {<br />                this.name = name;<br />                this.salary = yearlySalary;<br />            }<br /> <br />            public string Name<br />            {<br />                get { return name; }<br />            }<br /> <br />            public int CalculatePay()<br />            {<br />                return salary / 12;<br />            }<br />        }</pre>

We ended up simplifying the Payroll.Pay method considerably by moving most of the responsibility of it into a new Employee class. 

#### We&#8217;ve reached a good stopping point

There is still one more refactoring that&#8217;s needed before I&#8217;ll be happy with this code.The Pay method still reaches inside the Employee class and pulls out pieces,then formats the output line explicitly in its body. I think there are a couple different problems in there that should be fixed that will leave Payroll largely ignorant of the internals of an Employee and of the details of output formatting. This is our next refactoring.

Stay tuned.

**Now playing:** Alice In Chains &#8211; Dirt &#8211; Sickman