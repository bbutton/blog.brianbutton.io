---
title: TDD Dive — Chapter 6
author: Brian Button
type: post
date: 2004-12-04T17:35:00+00:00
url: /index.php/2004/12/04/tdd-dive-chapter-6/
sfw_comment_form_password:
  - AvEWqVTkf23k
sfw_pwd:
  - uOo0uGQRDxB4
categories:
  - Uncategorized

---
In this installment, we&rsquo;re going to code up the input side. This is going to be very much like the last installment, where we did the output. The key to making this easy is to do everything in terms of TextReaders instead of specific kinds of TextReaders. This will allow us to use StringReaders in our tests, and substitute in a StreamReader later, in main. Armed with this knowledge, we can put our test code and test data in the tests themselves, as opposed to having the data spread out in little files all over the place.

So, our end goal for this part of the story is to read in an input line, parse out the Payroll command on that line, create a Payroll object, and run it. Pretty simple. Let&rsquo;s start with a test list for the input reader:

  1. If no payroll input, no date is returned.
  2. If single payroll input, only one date is returned
  3. if multiple payrolls, can get all of them one at a time

I know I&rsquo;ve been ignoring all error checks throughout this example. That&rsquo;s because its really not the point of the exercise. If I wanted to be completey robust here, I&rsquo;d stick in some stuff about making sure the input is formatted correctly, etc, but I&rsquo;m really not interested in that. If this were a real system, I absolutely would be, and I&rsquo;d write extra tests for those case. 

So, I can&rsquo;t think of any more test cases for this off the top of my head, although I might come back to this later. As usual, I want to implement the simplest test first. Here it is:

You know, I had every intention of writing that first test, but I just realized I don&rsquo;t know enough to. I have no idea, in code, how this input stuff is going to be used. Proceeding in the face of this unknown seems like a recipe to build the wrong thing, so I really need to take a minute and figure out how the input side is going to be used. For right now, I&rsquo;ll assume this code is going to go in main. Here is main as I&rsquo;ve sketched it out. I know it is not complete yet, but this is just a thought experiement:

<div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
  <span style="COLOR: blue">public</span> <span style="COLOR: blue">static</span> <span style="COLOR: blue">void</span> Main(<span style="COLOR: blue">string</span>[] args)<br />{<br />&nbsp;&nbsp;&nbsp; StreamReader inputStream = <span style="COLOR: blue">new</span> StreamReader(args[0]);<br />&nbsp;&nbsp;&nbsp; InputReader reader = <span style="COLOR: blue">new</span> InputReader(inputStream);</p> 
  
  <p>
    &nbsp;&nbsp;&nbsp; StreamWriter outputStream = <span style="COLOR: blue">new</span> StreamWriter(args[1]);<br />&nbsp;&nbsp;&nbsp; CheckWriter writer = <span style="COLOR: blue">new</span> CheckWriter(outputStream);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; EmployeeList employees = <span style="COLOR: blue">new</span> EmployeeList();<br />&nbsp;&nbsp;&nbsp; employees.Add(&#8220;Bill&#8221;, 144000);<br />&nbsp;&nbsp;&nbsp; employees.Add(&#8220;Frank&#8221;, 100000);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; Payroll payroll = <span style="COLOR: blue">new</span> Payroll(employees);
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">string</span> payDate = <span style="COLOR: blue">null</span>;<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">while</span>((payDate = reader.GetNext()) != <span style="COLOR: blue">null</span>)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; IList payRecords = payroll.Pay(payDate);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; writer.Write(payRecords);<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
    
    <p>
      As far as I can tell, that&rsquo;s about how main is going to look. As of right now, the InputReader is going to produce a payDate for each line in its input. I&rsquo;m pretty sure that that is going to change a bit later, but I&rsquo;ll worry about that later. I don&rsquo;t want to take the time now to guess about what that class&rsquo;s generic behavior is going to be, as I&rsquo;ll <em>know</em> for certain in a subsequent story.
    </p>
    
    <p>
      Now I can go back to my test:
    </p>
    
    <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
      [TestFixture]<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> InputReaderFixture<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; [Test]<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">void</span> NoPayrollDateReadFromEmptyInputStream()<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; StringReader inputStream = <span style="COLOR: blue">new</span> StringReader(&#8220;&#8221;);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; InputReader reader = <span style="COLOR: blue">new</span> InputReader(inputStream);</p> 
      
      <p>
        &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.IsNull(reader.GetNext());<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; }</div> 
        
        <p>
          Very simple, and, like a similar test for the output, worked without me having to actually write any application code beyond just creating the classes and methods.
        </p>
        
        <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
          <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> InputReader<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> InputReader(TextReader inputStream)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; }</p> 
          
          <p>
            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">string</span> GetNext()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> <span style="COLOR: blue">null</span>;<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
            
            <p>
              Next test is to include one payday command on the input and make sure I get the right date out:
            </p>
            
            <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
              [Test]<br /><span style="COLOR: blue">public</span> <span style="COLOR: blue">void</span> WillReadSinglePayrollDateFromInput()<br />{<br />&nbsp;&nbsp;&nbsp; StringReader inputStream = <span style="COLOR: blue">new</span> StringReader(&#8220;Payday,05/01/2004&#8221; + System.Environment.NewLine);<br />&nbsp;&nbsp;&nbsp; InputReader reader = <span style="COLOR: blue">new</span> InputReader(inputStream);</p> 
              
              <p>
                &nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;05/01/2004&#8221;, reader.GetNext());<br />}</div> 
                
                <p>
                  At this point, I&rsquo;m getting a little nervous about my idea of just returning a date string from GetNext(). I&rsquo;m beginning to think I&rsquo;m going to need an IList of tokens from the input line. I don&rsquo;t actually need that yet, but the shape of this system is a transaction processor, where the input comes in, one transaction per line, and we act on it. To make that happen, I think we&rsquo;ll need a list of tokens per line. The question now is whether I should do this now, or wait until I actually need it.
                </p>
                
                <p>
                  As a side point, this kind of self-examination of your code and flashes of insight are what good TDDers do all the time. It is no longer as simple as drawing up a design in Visio and implementing it. We, as TDD-programmers, have to be constantly listening to our code, re-evaluating choices we&rsquo;ve made, waiting for those fundamental insights, and acting on them. That is what makes TDD more difficult than Big Design Up Front (BDUF) programming, but it is also what makes it much better.
                </p>
                
                <p>
                  I&rsquo;m really torn about whether I should put this insight into the code now, or whether I should wait until later. The lazy programmer in me says that I would have less code to change in my tests if I made the change now. There is a very slight risk that I could get the abstraction wrong, as I don&rsquo;t <em>actually</em> need it right now, but I don&rsquo;t think it would be too tough to get it right, now. I&rsquo;ll do it, as soon as I get this test working.
                </p>
                
                <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                  <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> InputReader<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">readonly</span> TextReader inputStream;</p> 
                  
                  <p>
                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> InputReader(TextReader inputStream)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.inputStream = inputStream;<br />&nbsp;&nbsp;&nbsp; }
                  </p>
                  
                  <p>
                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">string</span> GetNext()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">string</span> entireLine = inputStream.ReadLine();<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">if</span>(entireLine == <span style="COLOR: blue">null</span>) <span style="COLOR: blue">return</span> <span style="COLOR: blue">null</span>;
                  </p>
                  
                  <p>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">string</span> [] tokens = entireLine.Split(&#8216;,&#8217;);<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> tokens[1];<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                    
                    <p>
                      Now the test works, but the GetNext() method is a bit ugly. I have the magic character and magic number in there, and the special case stuff. Don&rsquo;t like it at all. Then again, we&rsquo;re about to refactor it&#8230;
                    </p>
                    
                    <p>
                      This turned out to be a really simple change, and I think I&rsquo;m glad I did it now. The test changed a bit, and I think I like it more now:
                    </p>
                    
                    <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                      [Test]<br /><span style="COLOR: blue">public</span> <span style="COLOR: blue">void</span> WillReadSinglePayrollDateFromInput()<br />{<br />&nbsp;&nbsp;&nbsp; StringReader inputStream = <span style="COLOR: blue">new</span> StringReader(&#8220;Payday,05/01/2004&#8221; + System.Environment.NewLine);<br />&nbsp;&nbsp;&nbsp; InputReader reader = <span style="COLOR: blue">new</span> InputReader(inputStream);</p> 
                      
                      <p>
                        &nbsp;&nbsp;&nbsp; IList commandTokens = reader.GetNext();<br />&nbsp;&nbsp;&nbsp; Assert.AreEqual(2, commandTokens.Count);<br />&nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;Payday&#8221;, commandTokens[0]);<br />&nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;05/01/2004&#8221;, commandTokens[1]);<br />}</div> 
                        
                        <p>
                          Now we can assert something about the entire input line. We can confirm that it only had 2 tokens on it, and we can confirm what they were. I just like that better &mdash; it seems more complete. And, in InputReader, all I had to do now was to return the array of tokens returned from Split, rather than pull the array apart and just returning one piece of it. Very simple.
                        </p>
                        
                        <p>
                          All that is left to do now is to get more than one set of tokens from the InputReader, and I think this class is done.
                        </p>
                        
                        <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                          [Test]<br /><span style="COLOR: blue">public</span> <span style="COLOR: blue">void</span> WillReadAllSetsOfTokensInInputStream()<br />{<br />&nbsp;&nbsp;&nbsp; StringReader inputStream = <br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">new</span> StringReader(&#8220;Payday,05/01/2004&#8221; + System.Environment.NewLine +<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &#8220;Payday,06/01/2004&#8221; + System.Environment.NewLine);<br />&nbsp;&nbsp;&nbsp; InputReader reader = <span style="COLOR: blue">new</span> InputReader(inputStream);</p> 
                          
                          <p>
                            &nbsp;&nbsp;&nbsp; IList firstCommandTokens = reader.GetNext();<br />&nbsp;&nbsp;&nbsp; Assert.AreEqual(2, firstCommandTokens.Count);<br />&nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;Payday&#8221;, firstCommandTokens[0]);<br />&nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;05/01/2004&#8221;, firstCommandTokens[1]);
                          </p>
                          
                          <p>
                            &nbsp;&nbsp;&nbsp; IList secondCommandTokens = reader.GetNext();<br />&nbsp;&nbsp;&nbsp; Assert.AreEqual(2, secondCommandTokens.Count);<br />&nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;Payday&#8221;, secondCommandTokens[0]);<br />&nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;06/01/2004&#8221;, secondCommandTokens[1]);
                          </p>
                          
                          <p>
                            &nbsp;&nbsp;&nbsp; IList emptyCommandTokens = reader.GetNext();<br />&nbsp;&nbsp;&nbsp; Assert.IsNull(emptyCommandTokens);<br />}</div> 
                            
                            <p>
                              Once I wrote this test, to my surprise, it worked. I guess I wasn&rsquo;t thinking about it clearly enough, but the initial implementation of GetNext() was sufficient. I really expected to have to write a while look in that method, to let me get each line of tokens. Looking back at the code, I understand completely why I didn&rsquo;t need to, but I expected to. Had I just sat down and written the code, I may very well have written that loop, only to discover that I didn&rsquo;t need it! Not real bright of me, but sometimes that happens. My tests saved me from doing something dumb.
                            </p>
                            
                            <p>
                              This is the finished InputReader class:
                            </p>
                            
                            <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                              <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> InputReader<br />{<br />&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">readonly</span> TextReader inputStream;</p> 
                              
                              <p>
                                &nbsp;&nbsp; <span style="COLOR: blue">public</span> InputReader(TextReader inputStream)<br />&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.inputStream = inputStream;<br />&nbsp;&nbsp; }
                              </p>
                              
                              <p>
                                &nbsp;&nbsp; <span style="COLOR: blue">public</span> IList GetNext()<br />&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">string</span> entireLine = inputStream.ReadLine();<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">if</span>(entireLine == <span style="COLOR: blue">null</span>) <span style="COLOR: blue">return</span> <span style="COLOR: blue">null</span>;
                              </p>
                              
                              <p>
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> entireLine.Split(&#8216;,&#8217;);<br />&nbsp;&nbsp; }<br />}</div> 
                                
                                <p>
                                  <strong>The <em>main</em> program</strong>
                                </p>
                                
                                <p>
                                  Since that was so easy, let&rsquo;s look at main now and make sure that it works correctly. After our earlier refactoring to change to IList of tokens, here is main:
                                </p>
                                
                                <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                  <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> PayrollMain<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">static</span> <span style="COLOR: blue">void</span> Main(<span style="COLOR: blue">string</span>[] args)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; StreamReader inputStream = <span style="COLOR: blue">new</span> StreamReader(args[0]);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; InputReader reader = <span style="COLOR: blue">new</span> InputReader(inputStream);</p> 
                                  
                                  <p>
                                    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; StreamWriter outputStream = <span style="COLOR: blue">new</span> StreamWriter(args[1]);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; CheckWriter writer = <span style="COLOR: blue">new</span> CheckWriter(outputStream);
                                  </p>
                                  
                                  <p>
                                    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; EmployeeList employees = <span style="COLOR: blue">new</span> EmployeeList();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; employees.Add(&#8220;Bill&#8221;, 144000);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; employees.Add(&#8220;Frank&#8221;, 100000);
                                  </p>
                                  
                                  <p>
                                    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; IList tokens = reader.GetNext();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">while</span>(tokens.Count > 0)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Payroll payroll = <span style="COLOR: blue">new</span> Payroll(employees);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">string</span> payDate = tokens[1] <span style="COLOR: blue">as</span> <span style="COLOR: blue">string</span>;
                                  </p>
                                  
                                  <p>
                                    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; IList payRecords = payroll.Pay(payDate);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; writer.Write(payRecords);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                    
                                    <p>
                                      After running this, there were a few minor problems that I had to find through debugging, which tells me that I really should have written this code the same way I wrote the rest of it, driving it through TDD. This is also a bit complex for a main, and the while loop at least should be refactored out, but I think I can stand leaving this for now right where it is. I&rsquo;m pretty sure it will get refactored out during the next story into a factory or something, as soon as we start creating other kinds of commands, but I&rsquo;ll leave that for another day.
                                    </p>
                                    
                                    <p>
                                      At this point, I consider this first story to be finished. It works, there are no more refactorings I can think of, we have our main built. Main worked pretty much the first time I tried it.&nbsp;The only two changes I had to make were to change the loop condition to checking to see if tokens was null instead of checking that the count of tokens was 0, and I had to add a TextWriter.Flush()&nbsp;call into CheckWriter.Write(). Let&rsquo;s&nbsp;pretend that this last change was a bug that slipped through our testing&nbsp;that was found in production. In the&nbsp;next, and last, installment for this story, we&rsquo;ll talk about how to&nbsp;fix bugs in TDD.
                                    </p>
                                    
                                    <p>
                                      Here is the final code for main and the InputReader and its tests:
                                    </p>
                                    
                                    <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                      [TestFixture]<br /><span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> InputReaderFixture<br />{<br />&nbsp;&nbsp;&nbsp; [Test]<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">void</span> NoPayrollDateReadFromEmptyInputStream()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; StringReader inputStream = <span style="COLOR: blue">new</span> StringReader(&#8220;&#8221;);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; InputReader reader = <span style="COLOR: blue">new</span> InputReader(inputStream);</p> 
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.IsNull(reader.GetNext());<br />&nbsp;&nbsp;&nbsp; }
                                      </p>
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; [Test]<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">void</span> WillReadSinglePayrollDateFromInput()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; StringReader inputStream = <span style="COLOR: blue">new</span> StringReader(&#8220;Payday,05/01/2004&#8221; + System.Environment.NewLine);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; InputReader reader = <span style="COLOR: blue">new</span> InputReader(inputStream);
                                      </p>
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; IList commandTokens = reader.GetNext();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(2, commandTokens.Count);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;Payday&#8221;, commandTokens[0]);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;05/01/2004&#8221;, commandTokens[1]);<br />&nbsp;&nbsp;&nbsp; }
                                      </p>
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; [Test]<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">void</span> WillReadAllSetsOfTokensInInputStream()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; StringReader inputStream = <br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">new</span> StringReader(&#8220;Payday,05/01/2004&#8221; + System.Environment.NewLine +<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &#8220;Payday,06/01/2004&#8221; + System.Environment.NewLine);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; InputReader reader = <span style="COLOR: blue">new</span> InputReader(inputStream);
                                      </p>
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; IList firstCommandTokens = reader.GetNext();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(2, firstCommandTokens.Count);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;Payday&#8221;, firstCommandTokens[0]);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;05/01/2004&#8221;, firstCommandTokens[1]);
                                      </p>
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; IList secondCommandTokens = reader.GetNext();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(2, secondCommandTokens.Count);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;Payday&#8221;, secondCommandTokens[0]);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.AreEqual(&#8220;06/01/2004&#8221;, secondCommandTokens[1]);
                                      </p>
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; IList emptyCommandTokens = reader.GetNext();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Assert.IsNull(emptyCommandTokens);<br />&nbsp;&nbsp;&nbsp; }<br />}
                                      </p>
                                      
                                      <p>
                                        <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> InputReader<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">readonly</span> TextReader inputStream;
                                      </p>
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> InputReader(TextReader inputStream)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.inputStream = inputStream;<br />&nbsp;&nbsp;&nbsp; }
                                      </p>
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> IList GetNext()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">string</span> entireLine = inputStream.ReadLine();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">if</span>(entireLine == <span style="COLOR: blue">null</span>) <span style="COLOR: blue">return</span> <span style="COLOR: blue">null</span>;
                                      </p>
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> entireLine.Split(&#8216;,&#8217;);<br />&nbsp;&nbsp;&nbsp; }<br />}
                                      </p>
                                      
                                      <p>
                                        <span style="COLOR: blue">public</span> <span style="COLOR: blue">static</span> <span style="COLOR: blue">void</span> Main(<span style="COLOR: blue">string</span>[] args)<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">if</span>(args.Length != 2)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Console.Out.WriteLine(&#8220;usage: PayrollMain <inputFile> <outputFile>&#8221;);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span>;<br />&nbsp;&nbsp;&nbsp; }
                                      </p>
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; StreamReader inputStream = <span style="COLOR: blue">new</span> StreamReader(args[0]);<br />&nbsp;&nbsp;&nbsp; InputReader reader = <span style="COLOR: blue">new</span> InputReader(inputStream);
                                      </p>
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; StreamWriter outputStream = <span style="COLOR: blue">new</span> StreamWriter(args[1]);<br />&nbsp;&nbsp;&nbsp; CheckWriter writer = <span style="COLOR: blue">new</span> CheckWriter(outputStream);
                                      </p>
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; EmployeeList employees = <span style="COLOR: blue">new</span> EmployeeList();<br />&nbsp;&nbsp;&nbsp; employees.Add(&#8220;Frank Furter&#8221;, 120000);<br />&nbsp;&nbsp;&nbsp; employees.Add(&#8220;Howard Hog&#8221;, 144000);
                                      </p>
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; IList tokens = reader.GetNext();<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">while</span>(tokens != <span style="COLOR: blue">null</span>)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Payroll payroll = <span style="COLOR: blue">new</span> Payroll(employees);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">string</span> payDate = tokens[1] <span style="COLOR: blue">as</span> <span style="COLOR: blue">string</span>;
                                      </p>
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; IList payRecords = payroll.Pay(payDate);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; writer.Write(payRecords);
                                      </p>
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; tokens = reader.GetNext();<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                        
                                        <p>
                                          <!--EndFragment-->
                                        </p>