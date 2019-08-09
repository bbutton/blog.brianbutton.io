---
title: Episode 2 – The InputReader and the start of the Processor
author: Brian Button
type: post
date: 2007-09-17T09:42:00+00:00
url: /index.php/2007/09/17/episode-2-the-inputreader-and-the-start-of-the-processor/
sfw_comment_form_password:
  - NIlugAxcVXvr
sfw_pwd:
  - A6ayRtvth139
categories:
  - 111
  - 112

---
OK, so this stuff is different. Really different. So different that i feel like a TDD rookie all over again. I find myself questioning everything that I do, and wondering if I&#8217;m going in the right direction. But it&#8217;s fun learning something new&#8230;

**When I last left you&#8230;**

When we finished episode 1, we had created a couple of customer tests and had used Interaction Based Testing to drive out the basics of our architecture. In looking back at what we drove out, I wonder about some of those classes. I can see that I have an input side, and processing middle, and an output side, but I see an awful lot of generalization having happened already. I&#8217;m going to watch out for this throughout the rest of this exercise. It is possible that this style of writing tests drives you towards early generalization, but I&#8217;m pretty sure it is just my unfamiliarity with how to drive code through these tests that is making this happen.

**The Input Side**

According to the first test I wrote, this is the interface that the input side needs to have:

    public interface IInputReader
    {
        List<BatchInput> ReadAllInputs();
    }
    

I don&#8217;t know anything about a _BatchInput_ yet, or how to read the input lines, but I think I may be about to find out.

So my job now is to drive out how the _IInputReader_ will be implemented by some class. As it turns out, this is really not very interesting. The interaction-based testing that we&#8217;ve been doing has been very useful at driving out interactions, but the _InputReader_ seems to stand alone. It is at the very end of the call chain, which means that it doesn&#8217;t interact with anything else. This means that state-based tests will do just fine to test this piece of the system.

Here is the first test I wrote for this class:

    [Test]
    public void InputReaderImplementsIInputReader()
    {
        Assert.IsInstanceOfType(typeof(IInputReader), new InputReader(null));
    }
    

I&#8217;ve started writing tests like these to force me to make the class I&#8217;m writing implement a specific interface. I started doing this because I&#8217;ve found myself going along writing a class, knowing full well that it has to implement some interface, but forgetting to actually do it. I end up writing the whole class to the wrong API, and I have to go back and refactor the API to match what it should be. Hence, I write this test now to enforce me implementing the right interface.

Here are the rest of the tests:

    [Test]
    public void EmptyInputStreamGeneratesEmptyOutputList()
    {
        StringReader reader = new StringReader(String.Empty);
        InputReader inputReader = new InputReader(reader);
    
        List<BatchInput> input = inputReader.ReadAllInputs();
    
        Assert.AreEqual(0, input.Count);
    }
    
    [Test]
    public void SingleCommandInputStringGeneratesSingleElementOutputList()
    {
        StringReader reader = new StringReader("a|b" + System.Environment.NewLine);
        InputReader inputReader = new InputReader(reader);
    
        List<BatchInput> input = inputReader.ReadAllInputs();
    
        Assert.AreEqual(1, input.Count);
        Assert.AreEqual("a|b", input[0].ToString());
    }
    
    [Test]
    public void MultipleCommandInputStringGeneratesMultipleElementsInOutputList()
    {
        StringReader reader = new StringReader("a|b" + System.Environment.NewLine + "b|c" + Environment.NewLine);
        InputReader inputReader = new InputReader(reader);
    
        List<BatchInput> input = inputReader.ReadAllInputs();
    
        Assert.AreEqual(2, input.Count);
        Assert.AreEqual("a|b", input[0].ToString());
        Assert.AreEqual("b|c", input[1].ToString());
    }
    

These tests follow the usual _0, 1, many_ pattern for implementing functionality. Make sure something works for 0 elements, which fleshes out the API, then make sure it works for a single element, which puts the business logic in, and then make it work for multiple elements, which adds the looping logic. Here is the oh, so complicated code to implement these tests:

    public class InputReader : IInputReader
    {
        private readonly TextReader reader;
    
        public InputReader(TextReader reader)
        {
            this.reader = reader;
        }
    
        public List<BatchInput> ReadAllInputs()
        {
            List<BatchInput> inputData = new List<BatchInput>();
            ReadAllLines().ForEach(delegate(string newLine) 
                { inputData.Add(new BatchInput(newLine)); });
            return inputData;
        }
    
        private List<string> ReadAllLines()
        {
            List<string> inputLines = new List<string>();
            while (reader.Peek() != -1)
            {
                inputLines.Add(reader.ReadLine());
            }
    
            return inputLines;
        }
    }
    

And that should pretty well handle the input side of this system.

**On to the _Processor_**

The _Processor_ class takes the input _BatchInput_ list and converts it into _ProcessOutput_ objects, which are then written to the output section of the program. Here is the interface again that rules this section of code:

    public interface IProcessor
    {
        List<ProcessOutput> Process(List<BatchInput> inputs);
    }
    

First of all, let&#8217;s make sure that my class is going to implement the correct interface:

    [Test]
    public void ProcessorImplementsIProcessor()
    {
        Assert.IsInstanceOfType(typeof(IProcessor), new Processor(null, null));
    }
    

Now, the responsibilities that seem to have to happen here are that each _BatchInput_ object needs to be turned into something representing a payroll input line, and that new object needs to be executed in some way. Those thought processes lead me to this test:

    [Test]
    public void SingleBatchInputCausesStuffToHappenOnce()
    {
        MockRepository mocks = new MockRepository();
    
        IPayrollProcessorFactory factory = mocks.CreateMock<IPayrollProcessorFactory>();
        IPayrollExecutor executor = mocks.CreateMock<IPayrollExecutor>();
        Processor processor = new Processor(factory, executor);
        PayrollCommand commonPayrollCommand = new PayrollCommand();
    
        List<BatchInput> batches = TestDataFactory.CreateBatchInput();
    
        using (mocks.Record())
        {
            Expect.Call(factory.Create(batches[0])).Return(commonPayrollCommand).Repeat.Once();
            executor.Execute(commonPayrollCommand);
            LastCall.Constraints(Is.Equal(commonPayrollCommand)).Repeat.Once();
        }
    
        using (mocks.Playback())
        {
            processor.Process(batches);
        }
    }
    

There is tons of stuff to see in this test method now. Immediately after I create my _MockRepository_, I create my system. This consists of three objects:

  * **_IPayrollProcessorFactory_** &#8212; responsible for converting the _BatchInput_ object into a _PayrollCommand_
  * **_IPayrollExecutor_** &#8212; responsible for executing the _PayrollCommand_ after it is created
  * **_Processor_** &#8212; the driver of the system

Together, these three classes make up this portion of our system. If I were doing SBT (state-based testing), I&#8217;m not entirely sure at all that I would have these two embedded objects yet. I would probably have written code and then refactored to get to where I am now. But, with IBT, you have to _think_ in terms of who the collaborators are that the method under test is going to use, and jump to having those collaborators now rather than later. In fact, the whole _IPayrollExecutor_ seems kind of contrived at this point to me, but I need to have something there to interact with, so I can write an IBT for this.

On the next line, I create an instance of my _PayrollCommand_. I specifically use this instance as the returned value from the _factory.Create_ call in the first expectation and as a constraint to the _executor.Execute_ in the second expectation. This was something I was struggling with earlier in my experimentation with IBT. What I want to have happen is that I want to force my code to take the object that is returned from the _Create_ call and pass it to the _Execute_ call. By having a common object that I use in the expectations, and having the _Is.Equal_ constraint in the second expectation, I can actually force that to happen. It took me a while to figure this out, and I&#8217;m pretty sure that this is a Rhino Mocks thing, rather than a generic IBT thing, but I found this to be helpful.

Then I drop into the record section, where I set some expectations on the objects I&#8217;m collaborating with. The first expectation says that I expect an instance of a _BatchInput_ to be provided to this _Execute_ method when called. Please note, and it took me a while to intellectually really grasp this, the batches[0] that I&#8217;m passing to the Create method is really just a place holder. This is the weird part here &#8212; I&#8217;m not actually calling the factory.Create method here, I&#8217;m signaling the mocking framework that this is a method I&#8217;m about to set some expectations on. I could have just as easily, in this case, passed in null in place of the argument, but I thought null didn&#8217;t communicate very clearly. What I do mean is that I expect some instance of a _BatchInput_ to be provided to this method. Maybe I would have done better by new&#8217;ing one up in place of using batches[0]???? It is not the value or identity of the object that matters here at all, it is the type, and only because a) the compiler needs it and b) it communicates test intent. The rest of that expectation states that I&#8217;m only going to expect this method to be called once, and is allowing me to specify what object will be returned when this method is called. This last part is one of the hardest parts for me to have initially grasped. I was unsure whether this framework was asserting that the mocked method would return the value I passed it, or whether it was allowing me to set up the value that would be returned when it was called. In looking back, the second option is the only one that makes any sense at all, since these expectations are being set on methods that are 100% mocked out and have no ability to return anything without me specifying it in some way. Doh!

The second expectation is where I set up the fact that I expect the same object that was returned from the Create call to be the object passed to this call. Again, I do this through the Constraint, not through the value actually passed to the executor.Execute() method. I could just as easily passed in null there, but it wouldn&#8217;t have communicated as clearly.

Finally, I get to the playback section, call my method, and the test is over.

This is the code that I wrote to make this test pass:

    public List<ProcessOutput> Process(List<BatchInput> batches)
    {
        List<ProcessOutput> results = new List<ProcessOutput>();
    
        PayrollCommand command = factory.Create(batches[0]);
        executor.Execute(command);
    
        return results;
    }
    

I know I&#8217;m not handling the results at all yet, but I&#8217;m pretty sure I can flesh out what will happen with those at some point soon.

In my second test, I&#8217;ll worry about how to handle multiple _BatchInput_ objects. Again, this is a very common pattern for me, starting with one of something to get the logic right, and then moving on to multiple, to put in any looping logic I need. Here is the second test:

    [Test]
    public void MultipleBatchInputsCausesStuffToHappenMultipleTimes()
    {
        MockRepository mocks = new MockRepository();
    
        IPayrollProcessorFactory factory = mocks.CreateMock<IPayrollProcessorFactory>();
        IPayrollExecutor executor = mocks.CreateMock<IPayrollExecutor>();
        Processor processor = new Processor(factory, executor);
        PayrollCommand commonPayrollCommand = new PayrollCommand();
    
        List<BatchInput> batches = TestDataFactory.CreateMultipleBatches(2);
    
        using (mocks.Record())
        {
            Expect.Call(factory.Create(batches[0])).
                    Constraints(List.OneOf(batches)).Return(commonPayrollCommand).Repeat.Twice();
            executor.Execute(commonPayrollCommand);
            LastCall.Constraints(Is.Equal(commonPayrollCommand)).Repeat.Twice();
        }
    
        using (mocks.Playback())
        {
            processor.Process(batches);
        }
    }
    

Almost all of this test is exactly the same, except I add two _BatchInput_ objects to my list. The only other thing I need to enforce is that the object that is passed to the _factory.Create_ method is a _BatchInput_ object that is a member of the list I passed in, which I do with the List Constraint to the first expectation.

Here is the modified _Processor_ code:

    public List<ProcessOutput> Process(List<BatchInput> batches)
    {
        List<ProcessOutput> results = new List<ProcessOutput>();
    
        foreach (BatchInput batch in batches)
        {
            PayrollCommand command = factory.Create(batch);
            executor.Execute(command);
        }
    
        return results;
    }
    

_Object Mother_

In both of these tests, you&#8217;ll see a reference to _TestDataFactory_. This is a class whose responsibility it is to create test data for me when asked. I use it to remove irrelevant details about test data from my tests and move it someplace else. This is called the Object Mother pattern.

**In the next episode&#8230;**

That&#8217;s about enough for now. If any of this wasn&#8217;t clear, please let me know, and I&#8217;ll update the text to be better. In the next episode, I&#8217;ll go ahead and build the factory using SBT, since it isn&#8217;t going to interact with anything and then dive into the _Processor_ code, which should prove interesting.

Overall, I&#8217;m pretty happy with how IBT is allowing me to focus on interactions between objects and ignore details like the contents of my domain classes entirely until I get to a class who manipulates the contents of those domain classes.

My biggest question lies in the area of premature generalization. Am I thinking too much and ignoring YAGNI? Do these tests reflect the simplest thing that can possibly work? I&#8217;m truly not sure. I tried to do better in this episode to focus on just payroll stuff and not make generic classes, like the _IInputReader_. I have a _PayrollProcessorFactory_, for example, instead of a _ProcessorFactory_. Those refactorings will come, and I want to wait for the code to tell me about them. IBT, I think, makes it easier to see those abstractions ahead of time, but I need to resist!

Please write with questions and comments. This continues to be an interesting journey for me, and I&#8217;m not at all sure where I&#8217;m going yet! But it is fun!

&#8212; bab