---
title: Episode 1 of Deep Dive Revisited — Setting the stage with customer tests
author: Brian Button
type: post
date: 2007-09-02T13:14:00+00:00
url: /index.php/2007/09/02/episode-1-of-deep-dive-revisited-setting-the-stage-with-customer-tests/
sfw_comment_form_password:
  - ClT1xDazFUk4
sfw_pwd:
  - dxiqxlVdeuw1
categories:
  - Uncategorized

---
So let&#8217;s begin our reimplementation of the sample payroll system introduced [previously][1]. Briefly, the problem stated that I had a batch payroll system that I needed written to pay the few employees that I had right now for my small company. They are all salaried as of now, but I can imagine hiring some hourly employees later.

Story number one said that, &#8220;As the owner, I want to be able to run payroll so that I can pay my employees&#8221;. Further clarification said that I have an input file that consists of single-line commands:

    Payroll|05/01/2007
    Payroll|05/15/2007
    Payroll|06/01/2007
    

When reading this input file, the system should create a single output file containing all paychecks to be written to my employees for each date in the input file that is the first of the month. Having this batch payroll input file allows me, the customer, to run and rerun payroll to my heart&#8217;s content.

I also have an output file that I pass off to some other company who creates checks for me. The format of the output file looks like this:

    Check|100|Frank Furter|$1000|05/01/2007
    Check|101|Howard Hog|$2000|05/01/2007
    Check|102|Frank Furter|$1000|06/01/2007
    Check|103|Howard Hog|$2000|06/01/2007
    

_Check_ is a keyword specifying that this is a check payment line, followed by a check number, the name of the person to whom the check should be written, the amount, and the paydate.

So that&#8217;s what I need. (Incidentally, as I went back and reviewed the first installment of this from 2004, I found a bug in the specifications. The check number (100-103 above) is supposed to be strictly increasing. I had it restarting with each pay period in the original write up.) I&#8217;d like to have a command-line program that I can write that will read the given input file and create the given output file.

**We begin by specifying Customer Tests**

One change in my development practices since 2004 is that I&#8217;ve become committed to having customer tests to define all work that I do. Since I&#8217;ve specified some behavior for my system, I&#8217;ll need to define a few customer tests to verify that the system is doing the right thing. Fortunately for us, this system is completely command-line driven, so it will be easy to write these customer tests using NUnit. Here are those tests:

    [TestFixture]
    public class ATFixture
    {
        [Test]
        [Ignore("AT not implemented yet")]
        public void All_employees_are_paid_on_first_of_month()
        {
            StringReader inputs = new StringReader("Payday|01/01/2007" + System.Environment.NewLine);
            StringWriter outputs = new StringWriter();
            PayrollSystem payrollSystem = new PayrollSystem(inputs, outputs);
    
            payrollSystem.Run();
    
            Assert.AreEqual("Check|100|Billy Bob|$10000|01/01/2007" + System.Environment.NewLine +
                            "Check|101|Sally Jo|$20000|01/01/2007" + System.Environment.NewLine, outputs.ToString());
        }
    
        [Test]
        [Ignore("AT not implemented yet")]
        public void No_employees_are_paid_if_provided_date_is_not_the_first_of_the_month()
        {
            StringReader inputs = new StringReader("Payday|01/02/2007" + System.Environment.NewLine);
            StringWriter outputs = new StringWriter();
            PayrollSystem payrollSystem = new PayrollSystem(inputs, outputs);
    
            payrollSystem.Run();
    
            Assert.AreEqual("", outputs.ToString());
        }
    }
    

Now, I&#8217;m cheating ever so slightly here, as I&#8217;m not reading and writing files, but using _StringReader_s and _StringWriter_s. I&#8217;m just assuming that I can plug in the files at a later date, and things will just work. Email me if you find this cheat offensive, and I&#8217;ll consider adding other tests that really do touch the file system. I&#8217;m reluctant to do that, because touching the file system brings its own set of worries with it:

  * Where are the files actually located at runtime?
  * Do I have read and write permission to the directory where they&#8217;re located?
  * Who is going to clean up the output file after the test is finished?
  * Touching the file system is much slower than doing things in memory

and so on.

These customer tests are pure and simple State Based Tests, because it seems to me that this is the right technology to use at this level. They are state-based because the state of the system is what the user is concerned with &#8212; if I pass this into the system, this is what comes out. Makes sense to me. So I have two tests for right now, one specifying what happens on the first of the month, and another specifying what happens on any other day of the month. Between those two tests, this should characterize what this story does (absent error checking, of course, which is left as an exercise for the reader).

One final note &#8212; these tests are written assuming a very simple API for accessing our program. It is entirely possible that we&#8217;ll learn more about how we use our system as write our programmer tests, which will necessitate us changing our customer tests as we go. This will become less and less frequent the further we go into the project, but we&#8217;re at the very start now, and our architecture is very likely to change.

**Implementing our first programmer tests**

And now we&#8217;re off. This is going to mark another change to my development style as practiced 3 years ago. Back then, when I started this problem, I recognized the fact that there was an input section, a processing section, and an output section. I assumed that I could get the input and output sections working in some way when I needed to, so I focused on solving the critical business problem in the middle. My thinking was that by doing this I would be fleshing out the requirements of how the inputs and outputs communicated through the middle. I could then write _main_ after I finished the middle, and then write the input or output code and be finished.

Now, I want to write a single test that goes through the whole system as a whole first, and use that to tease out the important abstractions earlier than I did before. So I am going to start with an interaction based test that flows directly from the customer tests. It will take the single _PayrollSystem.Run()_ method and begin to flesh out how it works. This clearly becomes an act of design. My first test:

    [TestFixture]
    public class PayrollSystemFixture
    {
        [Test]
        public void CreateControlFlowThroughSystem()
        {
            MockRepository mocks = new MockRepository();
    
            IInputReader reader = mocks.CreateMock<IInputReader>();
            IOutputWriter writer = mocks.CreateMock<IOutputWriter>();
            IProcessor processor = mocks.CreateMock<IProcessor>();
    
            PayrollSystem payrollSystem = new PayrollSystem(reader, processor, writer);
    
            List<BatchInput> inputs = new List<BatchInput>();
            List<ProcessOutput> outputs = new List<ProcessOutput>();
    
            using(mocks.Record())
            {
                Expect.Call(reader.ReadAllInputs()).Return(inputs).Repeat.Once();
                Expect.Call(processor.Process(inputs)).Return(outputs).Repeat.Once();
                writer.WriteAllOutputs(outputs);
                LastCall.On(writer).Repeat.Once();
            }
    
            using(mocks.Playback())
            {
                payrollSystem.Run();
            }
        }
    }
    

Just writing this test has already taught me something new about my _PayrollSystem_ class. In my customer tests, I had just the _TextReader_ and _TextWriter_ passed into the _PayrollSystem_. Now, in thinking more about the problem from a design point of view, I&#8217;m finding that there are other pieces that should be passed in. This doesn&#8217;t mean that the constructor defined in the customer test is wrong, just that I&#8217;ve discovered another one possibly.

Let&#8217;s look at this test in more detail. This is an interaction based test, as I described a couple of blog postings ago. Its purpose in life is to design the interactions of this class with the classes that are its immediate neighbors. This means that we&#8217;re going to have to do some design here, and make some guesses about other interfaces and methods on them. Writing IBTs is truly an act of design 🙂 (I have a few words to say about this process and YAGNI in a moment)

I find that these kinds of tests are much easier to understand if I read them backwards. In this case, the code in the playback section of the test is the code that is being run by the test. In this case, we&#8217;re trying to design the interactions of the _PayrollSystem.Run()_ method.

In the record section, we see what we expect this method to do. In our case, it is going to call _reader.ReadAllInputs()_, which is going to return _inputs_, which is _List<BatchInput>_. These _inputs_ will be passed along to our _processor_, which has a _Process_ method that returns _outputs_, as a _List<ProcessOutput>_.

This is finally passed to the _writer.WriteAllOutputs()_ method.

This is my first guess at a high-level design for this system, but I&#8217;m certainly open and eager to change this if needed. One thing I&#8217;m suspicious about is the way that the problem is broken down into three physically separate processing steps. I like this, because it really does keep the inter-step coupling down as much as possible, but it doesn&#8217;t quite feel right to me. When I&#8217;ve solved this problem in the past, I&#8217;ve had a main method, like _Run()_, that had a loop that called the input side, got a single record, processed it, and the act of processing caused the writing to happen. I guess this is the difference between a streaming design and a procedural, step-by-step design. I&#8217;m going to keep an eye out for anything that will guide me towards either of these choices as I go. For right now, I&#8217;m going with what I have written.

Above the recording section is where you can define objects that will be used throughout the test. In our case, we&#8217;re defining our _PayrollSystem_ and the two lists that we&#8217;ve mentioned previously.

Finally, or firstly I you look at it right-side up, we define the mock objects that we&#8217;re going to need in our system.

One thing that I&#8217;m finding that I like about writing tests this way is that I get to defer implementation decisions about things until the Last Responsible Moment. For example, to get this test to compile, I had to create three interfaces, add a single method to each of them, define empty _BatchInput_ and _ProcessOutput_ classes, and my _PayrollSystem_ class. I made as few decisions about anything as possible while writing this test, and I like that. I have a feeling that I would have had to at least define something about my _BatchInput_ and _ProcessOutput_ classes if I had been doing a state-based test, as well as defined hand-coded stubs for my interfaces.

Let&#8217;s look at the code that implements this test.

**First attempt at implementation**

One complaint about interaction-based testing is that you create the same code twice, once in the expectations of the test, and again in your source code. There is definitely some truth to this. If you look at the code in the _Run()_ method, it is exactly the same as what was in the record section of the test. I don&#8217;t think that this is a problem, though. IBTs force you to think at a really high level, forcing out high level abstractions every early. These high-level abstractions are unlikely to change much once you get into your system a bit, so the duplication doesn&#8217;t really hurt you. I think it also helps a reader understand how data and control flows through your system, just through reading the tests.

So here is the code I wrote to make this test pass:

    public class PayrollSystem
    {
        private readonly IInputReader reader;
        private readonly IProcessor processor;
        private readonly IOutputWriter writer;
    
        public PayrollSystem(TextReader inputs, TextWriter outputs)
        {
    
        }
    
        public PayrollSystem(IInputReader reader, IProcessor processor, IOutputWriter writer)
        {
            this.reader = reader;
            this.processor = processor;
            this.writer = writer;
        }
    
        public void Run()
        {
            List<BatchInput> inputs = reader.ReadAllInputs();
            List<ProcessOutput> outputs = processor.Process(inputs);
            writer.WriteAllOutputs(outputs);
        }
    }
    

**What does this test NOT address?**

Note that I haven&#8217;t done anything at all about date-specific processing. I don&#8217;t even have a place to put it yet. This is another one of those things I like about IBT. It seems to me that writing tests in this style is driving me towards putting responsibilities for lower level details down at a lower level. It is doing this by making it difficult for me to write tests for implementation details like date processing. I have other thoughts about how these tests are making me follow the [Law of Demeter][2] much more closely and reducing the amount of refactoring that I&#8217;m having to do as I write this code. In fact, I&#8217;m finding that I&#8217;m refactoring my code less now, typically only when I&#8217;m changing my mind about how things are structured. The IBTs create systems that are already OO in nature very early, which means that I&#8217;m not feeling the need for the post-test-working refactoring step anywhere nearly as much. We&#8217;ll see if it continues to work this way as we get further into this.

**What about YAGNI?**

One concern I have at fleshing out these abstractions so early in my project is that I&#8217;m not sure I need them yet. Maybe I could have driven out different, less abstract abstractions (?) by focusing on just payroll behavior, and if so, that would be my fault. But this did feel like the shape of this problem to me, so I went with it. I&#8217;m going to watch for premature generalizations throughout this exercise, in an effort to comply with YAGNI.

**Next step**

OK, so we have the basic high-level design of our system in place. Given our design, I can now start to pick out any one of the three major legs of the design to start working on first, since they&#8217;re really totally independent. I&#8217;m going to do the input side first, just because its easy, and knock that out in the next installment in the next few days.

**Please ask questions**

Readers, I beg you.. I&#8217;m learning this stuff, too, and I learn best when people challenge me on what I&#8217;ve done. Ask me questions if something seems strange or silly. There is every chance that I&#8217;ve made some choice that could be better, and we&#8217;ll all learn from it as we go.

Thanks for sticking with this post for so long, and I hope it was useful.

&#8212; bab

 [1]: http://www.agileprogrammer.com/oneagilecoder/archive/2004/10/25/2805.aspx
 [2]: http://en.wikipedia.org/wiki/Law_of_Demeter