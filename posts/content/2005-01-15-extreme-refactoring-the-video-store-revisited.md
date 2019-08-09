---
title: “Extreme” Refactoring — The Video Store Revisited
author: Brian Button
type: post
date: 2005-01-15T22:07:00+00:00
url: /index.php/2005/01/15/extreme-refactoring-the-video-store-revisited/
sfw_comment_form_password:
  - HBbpIGhMhwuS
sfw_pwd:
  - 4NNHFrAK5tpJ
categories:
  - Uncategorized

---
In [Fowler][1]&rsquo;s [Refactoring][2] book, he has an extended example&nbsp; of refactoring procedural code into object oriented code. I&rsquo;ve gone through this example in talks a bunch of times, doing the refactorings Fowler does for the most part, with my own little twists to it.

Today, however, I wanted to have a little fun. I wanted to turn my refactoring knob up to about 12 and see what happened. So I started with the Customer class after it was refactored in the Video Store example and see how much further I could take things.

My goals were these:

  * Methods should be 1 line long. Anything longer than that needs to be looked at closely.
  * Aggressively eliminate all duplication, specifically duplication involved with iterating over containers several different times in similar ways
  * Use no private methods.

I had no idea if I could get to these points, but I thought it might be fun to try. So here&rsquo;s how it went&hellip;

**Starting Point**

This is the Customer class as I started. This is the end point of this class in the Refactoring book, and it is the starting point from which I&rsquo;m going to take off. (Not saying that Martin didn&rsquo;t finish, but that I&rsquo;m going further than a cost/benefit analysis might otherwise suggest :))

<div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
  <span style="COLOR: blue">&nbsp;&nbsp;&nbsp; public</span> <span style="COLOR: blue">class</span> Customer<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> name;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> ArrayList rentals = <span style="COLOR: blue">new</span> ArrayList();</p> 
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> Customer(<span style="COLOR: blue">string</span> name)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.name = name;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">void</span> addRental(Rental rental)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; rentals.Add(rental);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">string</span> getName()<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> name;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">string</span> statement()<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">string</span> result = &#8220;Rental Record for &#8221; + getName() + System.Environment.NewLine;
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">foreach</span> (Rental each <span style="COLOR: blue">in</span> rentals)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">double</span> thisAmount = each.CalculateRentalCost();
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; result += &#8220;t&#8221; + each.getMovie().getTitle() + &#8220;t&#8221;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; + thisAmount.ToString() + System.Environment.NewLine;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; result += &#8220;You owed &#8221; + CalculateTotalRentalCost().ToString() + System.Environment.NewLine;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; result += &#8220;You earned &#8221; + CalculateTotalFrequentRenterPoints().ToString() + &#8221; frequent renter points&#8221; + System.Environment.NewLine;
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> result;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">int</span> CalculateTotalFrequentRenterPoints()<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">int</span> frequentRenterPoints = 0;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">foreach</span> (Rental each <span style="COLOR: blue">in</span> rentals)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; frequentRenterPoints += each.CalculateFrequentRenterPoints();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> frequentRenterPoints;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
  </p>
  
  <p>
    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">double</span> CalculateTotalRentalCost()<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">double</span> totalAmount = 0.0;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">foreach</span> (Rental each <span style="COLOR: blue">in</span> rentals)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; totalAmount += each.CalculateRentalCost();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> totalAmount;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; }</div> 
    
    <p>
      <strong>Step 1 &mdash; Eliminate duplication in loops</strong>
    </p>
    
    <p>
      So what struck me immediately about this code is that there is a 3x duplication in the looping over the Rental collection. I made one additional refactoring of the statement() method to show the third instance:
    </p>
    
    <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
      <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintLineItems()<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">string</span> result = &#8220;&#8221;;<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">foreach</span> (Rental each <span style="COLOR: blue">in</span> rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; result += &#8220;t&#8221; + each.getMovie().getTitle() + &#8220;t&#8221;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; + each.CalculateRentalCost().ToString() + System.Environment.NewLine;<br />&nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> result;<br />}</p> 
      
      <p>
        <span style="COLOR: blue">private</span> <span style="COLOR: blue">int</span> CalculateTotalFrequentRenterPoints()<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">int</span> frequentRenterPoints = 0;<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">foreach</span> (Rental each <span style="COLOR: blue">in</span> rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; frequentRenterPoints += each.CalculateFrequentRenterPoints();<br />&nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> frequentRenterPoints;<br />}
      </p>
      
      <p>
        <span style="COLOR: blue">private</span> <span style="COLOR: blue">double</span> CalculateTotalRentalCost()<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">double</span> totalAmount = 0.0;<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">foreach</span> (Rental each <span style="COLOR: blue">in</span> rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; totalAmount += each.CalculateRentalCost();<br />&nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> totalAmount;<br />}</div> 
        
        <p>
          Now, I&rsquo;d love to find a way to share this looping code. I know that this isn&rsquo;t that big a deal, but, hey, this article is called &ldquo;Extreme&rdquo; Refactoring, right???? Part of the problem lies with the language here &mdash; looping in C++, Java, C#, and any other C-based language takes a lot of code. In Ruby, for instance, each of these loops would collapse down to a single line of code, and we&rsquo;d be happy.
        </p>
        
        <p>
          So, since we are using C#, we need to do something to share this code. And this is what we need to do. We need to replace the external iteration over the collection with a single iteration contained in some collection class that can be shared. I gave an example of this in a previous post, my <a href="http://dotnetjunkies.com/WebLog/oneagilecoder/archive/2004/11/25/33603.aspx">TDD Deep Dive Part 4</a>.
        </p>
        
        <p>
          What I did is to create a strongly typed&nbsp;RentalCollection class and give it an Apply()-like method. This was a little tricky to do, and I&rsquo;ll explain why in a second. The first step in the process was to do an ExtractClass to create the RentalCollection. I did a SelfEncapsulateField on rentals in Customer so that I could more easily change how Customer got to the rentals ArrayList. Then I created an instance of RentalCollection called rentalCollection, moved the ArrayList to the new class, and provided access to that collection through a public property, as such:
        </p>
        
        <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
          <span style="COLOR: blue">&nbsp;&nbsp;&nbsp; public</span> <span style="COLOR: blue">class</span> Customer<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> name;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> RentalCollection rentalCollection = <span style="COLOR: blue">new</span> RentalCollection();</p> 
          
          <p>
            &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> ArrayList Rentals<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">get</span> { <span style="COLOR: blue">return</span> rentalCollection.Rentals; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">set</span> { rentalCollection.Rentals = <span style="COLOR: blue">value</span>; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
          </p>
          
          <p>
            &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> Customer(<span style="COLOR: blue">string</span> name)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.name = name;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Rentals = <span style="COLOR: blue">new</span> ArrayList();<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
          </p>
          
          <p>
            &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">void</span> addRental(Rental rental)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Rentals.Add(rental);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</div> 
            
            <p>
            </p>
            
            <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
              <span style="COLOR: blue">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; private</span> <span style="COLOR: blue">class</span> RentalCollection<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> ArrayList rentals;</p> 
              
              <p>
                &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> ArrayList Rentals<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">get</span> { <span style="COLOR: blue">return</span> rentals; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">set</span> { rentals = <span style="COLOR: blue">value</span>; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</div> 
                
                <p>
                  Now that I have this, I have a place to put the shared loop that will help me get rid of the duplication in the Customer class. Step one in making this change is to create a single delegate that can be used to replace the body of each of those 3 foreach loops. This is actually harder than it seems since the types involved with all three loops are different, and we have to add and concatenate as we go. It took me a bit to get this right, but I tested it out by creating the delegate in the Customer class and replacing the loop bodies with calls to the delegate. This was the smallest step I could take:
                </p>
                
                <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                  <span style="COLOR: blue">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; private</span> <span style="COLOR: blue">delegate</span> <span style="COLOR: blue">object</span> Collector(<span style="COLOR: blue">object</span> initialValue, Rental rental);</p> 
                  
                  <p>
                    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintLineItems()<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">object</span> result = &#8220;&#8221;;
                  </p>
                  
                  <p>
                    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Collector collector = <span style="COLOR: blue">new</span> Collector(LinePrinter);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">foreach</span> (Rental each <span style="COLOR: blue">in</span> Rentals)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">object</span> runningTotal = collector(result, each);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; result = runningTotal;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
                  </p>
                  
                  <p>
                    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> (<span style="COLOR: blue">string</span>)result;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
                  </p>
                  
                  <p>
                    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">object</span> LinePrinter(<span style="COLOR: blue">object</span> initialValue, Rental rental)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">string</span> result = (<span style="COLOR: blue">string</span>)initialValue;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; result += &#8220;t&#8221; + rental.getMovie().getTitle() + &#8220;t&#8221;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; + rental.CalculateRentalCost().ToString() + System.Environment.NewLine;
                  </p>
                  
                  <p>
                    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> result;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</div> 
                    
                    <p>
                      Then I factored out the part of the PrintLineItems() method that had nothing to do with the line items themselves into a method called Collect(), which, I&rsquo;m hoping, will be reusable:
                    </p>
                    
                    <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                      <span style="COLOR: blue">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; private</span> <span style="COLOR: blue">delegate</span> <span style="COLOR: blue">object</span> Collector(<span style="COLOR: blue">object</span> initialValue, Rental rental);</p> 
                      
                      <p>
                        &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintLineItems()<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Collector collector = <span style="COLOR: blue">new</span> Collector(LinePrinter);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">string</span> result = (<span style="COLOR: blue">string</span>)Collect(collector, &#8220;&#8221;);
                      </p>
                      
                      <p>
                        &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> result;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
                      </p>
                      
                      <p>
                        &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">object</span> Collect(Collector collector, <span style="COLOR: blue">object</span> initialValue)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">foreach</span> (Rental rental <span style="COLOR: blue">in</span> Rentals)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">object</span> runningTotal = collector(initialValue, rental);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; initialValue = runningTotal;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> initialValue;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }
                      </p>
                      
                      <p>
                        &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">object</span> LinePrinter(<span style="COLOR: blue">object</span> initialValue, Rental rental)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">string</span> result = (<span style="COLOR: blue">string</span>)initialValue;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; result += &#8220;t&#8221; + rental.getMovie().getTitle() + &#8220;t&#8221;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; + rental.CalculateRentalCost().ToString() + System.Environment.NewLine;
                      </p>
                      
                      <p>
                        &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> result;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</div> 
                        
                        <p>
                          Now I can go ahead and change the other two methods to work like PrintLineItems() does:
                        </p>
                        
                        <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                          <span style="COLOR: blue">private</span> <span style="COLOR: blue">object</span> Collect(Collector collector, <span style="COLOR: blue">object</span> initialValue)<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">foreach</span> (Rental rental <span style="COLOR: blue">in</span> Rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">object</span> runningTotal = collector(initialValue, rental);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; initialValue = runningTotal;<br />&nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> initialValue;<br />}</p> 
                          
                          <p>
                            <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintLineItems()<br />{<br />&nbsp;&nbsp;&nbsp; Collector collector = <span style="COLOR: blue">new</span> Collector(LinePrinter);<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">string</span> result = (<span style="COLOR: blue">string</span>)Collect(collector, &#8220;&#8221;);
                          </p>
                          
                          <p>
                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> result;<br />}
                          </p>
                          
                          <p>
                            <span style="COLOR: blue">private</span> <span style="COLOR: blue">object</span> LinePrinter(<span style="COLOR: blue">object</span> initialValue, Rental rental)<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">string</span> result = (<span style="COLOR: blue">string</span>)initialValue;<br />&nbsp;&nbsp;&nbsp; result += &#8220;t&#8221; + rental.getMovie().getTitle() + &#8220;t&#8221;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; + rental.CalculateRentalCost().ToString() + System.Environment.NewLine;
                          </p>
                          
                          <p>
                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> result;<br />}
                          </p>
                          
                          <p>
                            <span style="COLOR: blue">private</span> <span style="COLOR: blue">int</span> CalculateTotalFrequentRenterPoints()<br />{<br />&nbsp;&nbsp;&nbsp; Collector collector = <span style="COLOR: blue">new</span> Collector(FrequentRenterPointsSummer);<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">int</span> frequentRenterPoints = (<span style="COLOR: blue">int</span>)Collect(collector, 0);
                          </p>
                          
                          <p>
                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> frequentRenterPoints;<br />}
                          </p>
                          
                          <p>
                            <span style="COLOR: blue">private</span> <span style="COLOR: blue">object</span> FrequentRenterPointsSummer(<span style="COLOR: blue">object</span> initialValue, Rental rental)<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">int</span> frequentRenterPoints = (<span style="COLOR: blue">int</span>)initialValue;<br />&nbsp;&nbsp;&nbsp; frequentRenterPoints += rental.CalculateFrequentRenterPoints();
                          </p>
                          
                          <p>
                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> frequentRenterPoints;<br />}
                          </p>
                          
                          <p>
                            <span style="COLOR: blue">private</span> <span style="COLOR: blue">double</span> CalculateTotalRentalCost()<br />{<br />&nbsp;&nbsp;&nbsp; Collector collector = <span style="COLOR: blue">new</span> Collector(RentalCostSummer);<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">double</span> rentalAmount = (<span style="COLOR: blue">double</span>)Collect(collector, 0.0);
                          </p>
                          
                          <p>
                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> rentalAmount;<br />}
                          </p>
                          
                          <p>
                            <span style="COLOR: blue">private</span> <span style="COLOR: blue">object</span> RentalCostSummer(<span style="COLOR: blue">object</span> initialValue, Rental rental)<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">double</span> rentalAmount = (<span style="COLOR: blue">double</span>)initialValue;<br />&nbsp;&nbsp;&nbsp; rentalAmount += rental.CalculateRentalCost();
                          </p>
                          
                          <p>
                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> rentalAmount;<br />}</div> 
                            
                            <p>
                              <strong>Step 2 &mdash; Move looping and delegate into RentalCollection</strong>
                            </p>
                            
                            <p>
                              And we&rsquo;ve now removed the loops from the individual methods and put it into the Collect() method, eliminating that duplication. The iteration logic and delegate really belong over in the RentalCollection class, so I&rsquo;ll move them there:
                            </p>
                            
                            <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                              <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> RentalCollection<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> ArrayList rentals;</p> 
                              
                              <p>
                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> ArrayList Rentals<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">get</span> { <span style="COLOR: blue">return</span> rentals; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">set</span> { rentals = <span style="COLOR: blue">value</span>; }<br />&nbsp;&nbsp;&nbsp; }
                              </p>
                              
                              <p>
                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">delegate</span> <span style="COLOR: blue">object</span> Collector(<span style="COLOR: blue">object</span> initialValue, Rental rental);
                              </p>
                              
                              <p>
                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">object</span> Collect(Collector collector, <span style="COLOR: blue">object</span> initialValue)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">foreach</span> (Rental rental <span style="COLOR: blue">in</span> Rentals)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">object</span> runningTotal = collector(initialValue, rental);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; initialValue = runningTotal;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> initialValue;<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                
                                <p>
                                  <strong>Step 3 &mdash; Getting rid of all those private methods</strong>
                                </p>
                                
                                <p>
                                  I have all the iteration out of the Customer class, but now I have to get rid of all those private methods. They are hidden nuggets of implementation that you can only see by looking at the code. I believe that if we make them public methods of another class, they will form another aspect of our design that will then be visible from the outside.
                                </p>
                                
                                <p>
                                  What I want to do is to move the two private methods for each item being collected into their own classes. One of those methods will become public, and one will have to remain private for reasons that will become apparent soon. I&rsquo;m not initially going to give these three classes a base class because no one is going to initially use these polymorphically. Here is where this ends up:
                                </p>
                                
                                <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                  <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintLineItems()<br />{<br />&nbsp;&nbsp;&nbsp; LineItemPrinter printer = <span style="COLOR: blue">new</span> LineItemPrinter(rentalCollection);<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> printer.PrintLineItems();<br />}</p> 
                                  
                                  <p>
                                    <span style="COLOR: blue">private</span> <span style="COLOR: blue">int</span> CalculateTotalFrequentRenterPoints()<br />{<br />&nbsp;&nbsp;&nbsp; FrequentRenterPointsTotaller totaller = <span style="COLOR: blue">new</span> FrequentRenterPointsTotaller(rentalCollection);<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> totaller.CalculateTotalFrequentRenterPoints();<br />}
                                  </p>
                                  
                                  <p>
                                    <span style="COLOR: blue">private</span> <span style="COLOR: blue">double</span> CalculateTotalRentalCost()<br />{<br />&nbsp;&nbsp;&nbsp; RentalCostTotaller totaller = <span style="COLOR: blue">new</span> RentalCostTotaller(rentalCollection);<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> totaller.CalculateTotalRentalCost();<br />}</div> 
                                    
                                    <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                      <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> LineItemPrinter<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">readonly</span> RentalCollection rentals;</p> 
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> LineItemPrinter(RentalCollection rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.rentals = rentals;<br />&nbsp;&nbsp;&nbsp; }
                                      </p>
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">string</span> PrintLineItems()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; RentalCollection.Collector collector = <span style="COLOR: blue">new</span> RentalCollection.Collector(LinePrinter);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">string</span> result = (<span style="COLOR: blue">string</span>) rentals.Collect(collector, &#8220;&#8221;);
                                      </p>
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> result;<br />&nbsp;&nbsp;&nbsp; }
                                      </p>
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">object</span> LinePrinter(<span style="COLOR: blue">object</span> initialValue, Rental rental)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">string</span> result = (<span style="COLOR: blue">string</span>) initialValue;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; result += &#8220;t&#8221; + rental.getMovie().getTitle() + &#8220;t&#8221;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; + rental.CalculateRentalCost().ToString() + System.Environment.NewLine;
                                      </p>
                                      
                                      <p>
                                        &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> result;<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                        
                                        <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                          <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> FrequentRenterPointsTotaller<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">readonly</span> RentalCollection rentals;</p> 
                                          
                                          <p>
                                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> FrequentRenterPointsTotaller(RentalCollection rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.rentals = rentals;<br />&nbsp;&nbsp;&nbsp; }
                                          </p>
                                          
                                          <p>
                                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">int</span> CalculateTotalFrequentRenterPoints()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; RentalCollection.Collector collector = <span style="COLOR: blue">new</span> RentalCollection.Collector(FrequentRenterPointsSummer);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">int</span> frequentRenterPoints = (<span style="COLOR: blue">int</span>) rentals.Collect(collector, 0);
                                          </p>
                                          
                                          <p>
                                            &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> frequentRenterPoints;<br />&nbsp;&nbsp;&nbsp; }
                                          </p>
                                          
                                          <p>
                                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">object</span> FrequentRenterPointsSummer(<span style="COLOR: blue">object</span> initialValue, Rental rental)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">int</span> frequentRenterPoints = (<span style="COLOR: blue">int</span>) initialValue;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; frequentRenterPoints += rental.CalculateFrequentRenterPoints();
                                          </p>
                                          
                                          <p>
                                            &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> frequentRenterPoints;<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                            
                                            <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                              <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> RentalCostTotaller<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">readonly</span> RentalCollection rentals;</p> 
                                              
                                              <p>
                                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> RentalCostTotaller(RentalCollection rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.rentals = rentals;<br />&nbsp;&nbsp;&nbsp; }
                                              </p>
                                              
                                              <p>
                                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">double</span> CalculateTotalRentalCost()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; RentalCollection.Collector collector = <span style="COLOR: blue">new</span> RentalCollection.Collector(RentalCostSummer);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">double</span> rentalAmount = (<span style="COLOR: blue">double</span>) rentals.Collect(collector, 0.0);
                                              </p>
                                              
                                              <p>
                                                &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> rentalAmount;<br />&nbsp;&nbsp;&nbsp; }
                                              </p>
                                              
                                              <p>
                                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">object</span> RentalCostSummer(<span style="COLOR: blue">object</span> initialValue, Rental rental)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">double</span> rentalAmount = (<span style="COLOR: blue">double</span>) initialValue;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; rentalAmount += rental.CalculateRentalCost();
                                              </p>
                                              
                                              <p>
                                                &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> rentalAmount;<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                                
                                                <p>
                                                  What this has let us do is to get rid of the private methods inside Customer, except for the three mini-methods that invoke our new totalling classes. Those methods are OK, in my mind, since they are not places where logic exists &mdash; these methods exist merely to help explain the inner workings of our code. And there is one private method left in each of the new classes, but those methods have to be there to serve as targets for the delegates. I don&rsquo;t think I can get rid of any of the private methods I just mentioned.
                                                </p>
                                                
                                                <p>
                                                  <strong>Step 4 &mdash; More optimization in Customer</strong>
                                                </p>
                                                
                                                <p>
                                                  Going back to the Customer class, let&rsquo;s look at the private&nbsp;methods and see if I can make them into single-line methods, just for fun.
                                                </p>
                                                
                                                <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                  <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintLineItems()<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> <span style="COLOR: blue">new</span> LineItemPrinter(rentalCollection).PrintLineItems();<br />}</p> 
                                                  
                                                  <p>
                                                    <span style="COLOR: blue">private</span> <span style="COLOR: blue">int</span> CalculateTotalFrequentRenterPoints()<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> <span style="COLOR: blue">new</span> FrequentRenterPointsTotaller(rentalCollection).CalculateTotalFrequentRenterPoints();<br />}
                                                  </p>
                                                  
                                                  <p>
                                                    <span style="COLOR: blue">private</span> <span style="COLOR: blue">double</span> CalculateTotalRentalCost()<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> <span style="COLOR: blue">new</span> RentalCostTotaller(rentalCollection).CalculateTotalRentalCost();<br />}</div> 
                                                    
                                                    <p>
                                                      Not bad, and we&rsquo;ll revisit the rest of the class later. Now lets look at anything we can share among the classes we just created
                                                    </p>
                                                    
                                                    <p>
                                                      <strong>Step 5 &mdash; ExtractSuperclass on totalling classes</strong>
                                                    </p>
                                                    
                                                    <p>
                                                      The first obvious thing we can do is to create a superclass and put the RentalCollection into the base class. Then all three of those classes can be made into subclasses of the new class, and their constructors can be changed to call the base constructor.
                                                    </p>
                                                    
                                                    <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                      <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> Collector<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">readonly</span> RentalCollection rentals;</p> 
                                                      
                                                      <p>
                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">protected</span> RentalCollection Rentals<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">get</span> { <span style="COLOR: blue">return</span> rentals; }<br />&nbsp;&nbsp;&nbsp; }
                                                      </p>
                                                      
                                                      <p>
                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> Collector(RentalCollection rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.rentals = rentals;<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                                        
                                                        <p>
                                                          and I&rsquo;ll just show one of the derived classes:
                                                        </p>
                                                        
                                                        <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                          <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> RentalCostTotaller : Collector<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> RentalCostTotaller(RentalCollection rentals) : <span style="COLOR: blue">base</span>(rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; }</p> 
                                                          
                                                          <p>
                                                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">double</span> CalculateTotalRentalCost()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; RentalCollection.Collector collector = <span style="COLOR: blue">new</span> RentalCollection.Collector(RentalCostSummer);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">double</span> rentalAmount = (<span style="COLOR: blue">double</span>) Rentals.Collect(collector, 0.0);
                                                          </p>
                                                          
                                                          <p>
                                                            &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> rentalAmount;<br />&nbsp;&nbsp;&nbsp; }
                                                          </p>
                                                          
                                                          <p>
                                                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">object</span> RentalCostSummer(<span style="COLOR: blue">object</span> initialValue, Rental rental)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">double</span> rentalAmount = (<span style="COLOR: blue">double</span>) initialValue;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; rentalAmount += rental.CalculateRentalCost();
                                                          </p>
                                                          
                                                          <p>
                                                            &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> rentalAmount;<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                                            
                                                            <p>
                                                              Now we&rsquo;ll make the delegate method of each of these classes have the same name. I&rsquo;ll call them all DoCollect() instead of RentalCostSummer() for instance. This lets me move the creation of the Collector into the constructor of the base class. Note that I&rsquo;m intentionally violating a .Net Design guideline here by using a method of a derived class in a constructor, but I know I&rsquo;m doing it and it is a conscious tradeoff. Here is the Collector class:
                                                            </p>
                                                            
                                                            <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                              <span style="COLOR: blue">public</span> <span style="COLOR: blue">abstract</span> <span style="COLOR: blue">class</span> Collector<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">readonly</span> RentalCollection rentals;<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">readonly</span> RentalCollection.Collector collectDelegate;</p> 
                                                              
                                                              <p>
                                                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">protected</span> RentalCollection.Collector CollectDelegate<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">get</span> { <span style="COLOR: blue">return</span> collectDelegate; }<br />&nbsp;&nbsp;&nbsp; }
                                                              </p>
                                                              
                                                              <p>
                                                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">protected</span> RentalCollection Rentals<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">get</span> { <span style="COLOR: blue">return</span> rentals; }<br />&nbsp;&nbsp;&nbsp; }
                                                              </p>
                                                              
                                                              <p>
                                                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> Collector(RentalCollection rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.rentals = rentals;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.collectDelegate = <span style="COLOR: blue">new</span> RentalCollection.Collector(DoCollect);<br />&nbsp;&nbsp;&nbsp; }
                                                              </p>
                                                              
                                                              <p>
                                                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">protected</span> <span style="COLOR: blue">abstract</span> <span style="COLOR: blue">object</span> DoCollect(<span style="COLOR: blue">object</span> initialValue, Rental rental);<br />}</div> 
                                                                
                                                                <p>
                                                                  <!--EndFragment-->
                                                                  
                                                                  <br /> and one of the derived classes:
                                                                </p>
                                                                
                                                                <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                  <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> RentalCostTotaller : Collector<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> RentalCostTotaller(RentalCollection rentals) : <span style="COLOR: blue">base</span>(rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; }</p> 
                                                                  
                                                                  <p>
                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">double</span> CalculateTotalRentalCost()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">double</span> rentalAmount = (<span style="COLOR: blue">double</span>) Rentals.Collect(CollectDelegate, 0.0);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> rentalAmount;<br />&nbsp;&nbsp;&nbsp; }
                                                                  </p>
                                                                  
                                                                  <p>
                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">protected</span> <span style="COLOR: blue">override</span> <span style="COLOR: blue">object</span> DoCollect(<span style="COLOR: blue">object</span> initialValue, Rental rental)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">double</span> rentalAmount = (<span style="COLOR: blue">double</span>) initialValue;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; rentalAmount += rental.CalculateRentalCost();
                                                                  </p>
                                                                  
                                                                  <p>
                                                                    &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> rentalAmount;<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                                                    
                                                                    <p>
                                                                      Now we can rewrite the CalculateTotalRentalCost() method to be a little more generic, which will allow us to refactor out a bit more code:
                                                                    </p>
                                                                    
                                                                    <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                      <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> RentalCostTotaller : Collector<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> RentalCostTotaller(RentalCollection rentals) : <span style="COLOR: blue">base</span>(rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; }</p> 
                                                                      
                                                                      <p>
                                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">double</span> CalculateTotalRentalCost()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> (<span style="COLOR: blue">double</span>)PerformCollection(0.0);<br />&nbsp;&nbsp;&nbsp; }
                                                                      </p>
                                                                      
                                                                      <p>
                                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">protected</span> <span style="COLOR: blue">override</span> <span style="COLOR: blue">object</span> DoCollect(<span style="COLOR: blue">object</span> initialValue, Rental rental)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">double</span> rentalAmount = (<span style="COLOR: blue">double</span>) initialValue;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> rentalAmount + rental.CalculateRentalCost();<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                                                        
                                                                        <p>
                                                                          with Collector turning into:
                                                                        </p>
                                                                        
                                                                        <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                          <span style="COLOR: blue">public</span> <span style="COLOR: blue">abstract</span> <span style="COLOR: blue">class</span> Collector<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">readonly</span> RentalCollection rentals;<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">readonly</span> RentalCollection.Collector collectDelegate;</p> 
                                                                          
                                                                          <p>
                                                                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">protected</span> RentalCollection.Collector CollectDelegate<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">get</span> { <span style="COLOR: blue">return</span> collectDelegate; }<br />&nbsp;&nbsp;&nbsp; }
                                                                          </p>
                                                                          
                                                                          <p>
                                                                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">protected</span> RentalCollection Rentals<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">get</span> { <span style="COLOR: blue">return</span> rentals; }<br />&nbsp;&nbsp;&nbsp; }
                                                                          </p>
                                                                          
                                                                          <p>
                                                                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> Collector(RentalCollection rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.rentals = rentals;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.collectDelegate = <span style="COLOR: blue">new</span> RentalCollection.Collector(DoCollect);<br />&nbsp;&nbsp;&nbsp; }
                                                                          </p>
                                                                          
                                                                          <p>
                                                                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">protected</span> <span style="COLOR: blue">object</span> PerformCollection(<span style="COLOR: blue">object</span> initialValue)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> Rentals.Collect(CollectDelegate, initialValue);<br />&nbsp;&nbsp;&nbsp; }
                                                                          </p>
                                                                          
                                                                          <p>
                                                                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">protected</span> <span style="COLOR: blue">abstract</span> <span style="COLOR: blue">object</span> DoCollect(<span style="COLOR: blue">object</span> initialValue, Rental rental);<br />}</div> 
                                                                            
                                                                            <p>
                                                                              <strong>Step 6 &mdash; Simplifying everything</strong>
                                                                            </p>
                                                                            
                                                                            <p>
                                                                              Now I think we&rsquo;re about there as far as classes go, so lets run back around our classes and see if we can&rsquo;t simplify the code and create some one-line methods.
                                                                            </p>
                                                                            
                                                                            <p>
                                                                              Collector and each derived class can be simplified:
                                                                            </p>
                                                                            
                                                                            <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                              <span style="COLOR: blue">public</span> <span style="COLOR: blue">abstract</span> <span style="COLOR: blue">class</span> Collector<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">readonly</span> RentalCollection rentals;<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">readonly</span> RentalCollection.Collector collectDelegate;</p> 
                                                                              
                                                                              <p>
                                                                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> Collector(RentalCollection rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.rentals = rentals;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.collectDelegate = <span style="COLOR: blue">new</span> RentalCollection.Collector(DoCollect);<br />&nbsp;&nbsp;&nbsp; }
                                                                              </p>
                                                                              
                                                                              <p>
                                                                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">protected</span> <span style="COLOR: blue">object</span> PerformCollection(<span style="COLOR: blue">object</span> initialValue)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> rentals.Collect(collectDelegate, initialValue);<br />&nbsp;&nbsp;&nbsp; }
                                                                              </p>
                                                                              
                                                                              <p>
                                                                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">protected</span> <span style="COLOR: blue">abstract</span> <span style="COLOR: blue">object</span> DoCollect(<span style="COLOR: blue">object</span> initialValue, Rental rental);<br />}</div> 
                                                                                
                                                                                <p>
                                                                                  Nothing bug one-liners there. And now each of the derived classes can be simplified to:
                                                                                </p>
                                                                                
                                                                                <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                                  <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> RentalCostTotaller : Collector<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> RentalCostTotaller(RentalCollection rentals) : <span style="COLOR: blue">base</span>(rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; }</p> 
                                                                                  
                                                                                  <p>
                                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">double</span> CalculateTotalRentalCost()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> (<span style="COLOR: blue">double</span>)PerformCollection(0.0);<br />&nbsp;&nbsp;&nbsp; }
                                                                                  </p>
                                                                                  
                                                                                  <p>
                                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">protected</span> <span style="COLOR: blue">override</span> <span style="COLOR: blue">object</span> DoCollect(<span style="COLOR: blue">object</span> rentalCost, Rental rental)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> (<span style="COLOR: blue">double</span>)rentalCost + rental.CalculateRentalCost();<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                                                                    
                                                                                    <p>
                                                                                      <strong>Step 7 &mdash; Final simplifications in Customer class</strong>
                                                                                    </p>
                                                                                    
                                                                                    <p>
                                                                                      There are some simplifications that I still see in the Customer class. I think there is still structural duplication in the three private methods that I can make a little bit better by creating static methods on each of the Collector classes. Those private methods are now:
                                                                                    </p>
                                                                                    
                                                                                    <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                                      <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintLineItems()<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> LineItemPrinter.Collect(rentalCollection);<br />}</p> 
                                                                                      
                                                                                      <p>
                                                                                        <span style="COLOR: blue">private</span> <span style="COLOR: blue">int</span> CalculateTotalFrequentRenterPoints()<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> FrequentRenterPointsTotaller.Collect(rentalCollection);<br />}
                                                                                      </p>
                                                                                      
                                                                                      <p>
                                                                                        <span style="COLOR: blue">private</span> <span style="COLOR: blue">double</span> CalculateTotalRentalCost()<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> RentalCostTotaller.Collect(rentalCollection);<br />}</div> 
                                                                                        
                                                                                        <p>
                                                                                          I think that&rsquo;s a bit better. Not sure why it is better, but I think it is. I think. Now let&rsquo;s look back at the statement() method of this class:
                                                                                        </p>
                                                                                        
                                                                                        <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                                          <span style="COLOR: blue">public</span> <span style="COLOR: blue">string</span> statement()<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">string</span> result = &#8220;Rental Record for &#8221; + getName() + System.Environment.NewLine;</p> 
                                                                                          
                                                                                          <p>
                                                                                            &nbsp;&nbsp;&nbsp; result += PrintLineItems();
                                                                                          </p>
                                                                                          
                                                                                          <p>
                                                                                            &nbsp;&nbsp;&nbsp; result += &#8220;You owed &#8221; + CalculateTotalRentalCost().ToString() + System.Environment.NewLine;<br />&nbsp;&nbsp;&nbsp; result += &#8220;You earned &#8221; + CalculateTotalFrequentRenterPoints().ToString() + &#8221; frequent renter points&#8221; + System.Environment.NewLine;
                                                                                          </p>
                                                                                          
                                                                                          <p>
                                                                                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> result;<br />}</div> 
                                                                                            
                                                                                            <p>
                                                                                              We can simplify this to:
                                                                                            </p>
                                                                                            
                                                                                            <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                                              <span style="COLOR: blue">public</span> <span style="COLOR: blue">string</span> statement()<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">string</span> result = PrintHeader();<br />&nbsp;&nbsp;&nbsp; result += PrintLineItems();<br />&nbsp;&nbsp;&nbsp; result += PrintFooter();</p> 
                                                                                              
                                                                                              <p>
                                                                                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> result;<br />}
                                                                                              </p>
                                                                                              
                                                                                              <p>
                                                                                                <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintFooter()<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">string</span> result = &#8220;&#8221;;<br />&nbsp;&nbsp;&nbsp; result += &#8220;You owed &#8221; + CalculateTotalRentalCost().ToString() + System.Environment.NewLine;<br />&nbsp;&nbsp;&nbsp; result += &#8220;You earned &#8221; + CalculateTotalFrequentRenterPoints().ToString() + &#8221; frequent renter points&#8221; + System.Environment.NewLine;<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> result;<br />}
                                                                                              </p>
                                                                                              
                                                                                              <p>
                                                                                                <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintHeader()<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> &#8220;Rental Record for &#8221; + getName() + System.Environment.NewLine;<br />}
                                                                                              </p>
                                                                                              
                                                                                              <p>
                                                                                                <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintLineItems()<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> LineItemPrinter.Collect(rentalCollection);<br />}</div> 
                                                                                                
                                                                                                <p>
                                                                                                  and statement() can be further simplified to :
                                                                                                </p>
                                                                                                
                                                                                                <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                                                  <span style="COLOR: blue">public</span> <span style="COLOR: blue">string</span> statement()<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> PrintHeader() + PrintLineItems() + PrintFooter();<br />}
                                                                                                </div>
                                                                                                
                                                                                                <p>
                                                                                                  and PrintFooter() to :
                                                                                                </p>
                                                                                                
                                                                                                <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                                                  <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintFooter()<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> &#8220;You owed &#8221; + CalculateTotalRentalCost().ToString() + System.Environment.NewLine +<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp; &#8220;You earned &#8221; + CalculateTotalFrequentRenterPoints().ToString() + &#8221; frequent renter points&#8221; + System.Environment.NewLine;<br />}
                                                                                                </div>
                                                                                                
                                                                                                <p>
                                                                                                  At this point, Customer has only single-line methods in it, and just those three explaining private methods:
                                                                                                </p>
                                                                                                
                                                                                                <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                                                  <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> Customer<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> name;<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> RentalCollection rentalCollection = <span style="COLOR: blue">new</span> RentalCollection();</p> 
                                                                                                  
                                                                                                  <p>
                                                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> ArrayList Rentals<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">get</span> { <span style="COLOR: blue">return</span> rentalCollection.Rentals; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">set</span> { rentalCollection.Rentals = <span style="COLOR: blue">value</span>; }<br />&nbsp;&nbsp;&nbsp; }
                                                                                                  </p>
                                                                                                  
                                                                                                  <p>
                                                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> Customer(<span style="COLOR: blue">string</span> name)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.name = name;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Rentals = <span style="COLOR: blue">new</span> ArrayList();<br />&nbsp;&nbsp;&nbsp; }
                                                                                                  </p>
                                                                                                  
                                                                                                  <p>
                                                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">void</span> addRental(Rental rental)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Rentals.Add(rental);<br />&nbsp;&nbsp;&nbsp; }
                                                                                                  </p>
                                                                                                  
                                                                                                  <p>
                                                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">string</span> getName()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> name;<br />&nbsp;&nbsp;&nbsp; }
                                                                                                  </p>
                                                                                                  
                                                                                                  <p>
                                                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">string</span> statement()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> PrintHeader() + PrintLineItems() + PrintFooter();<br />&nbsp;&nbsp;&nbsp; }
                                                                                                  </p>
                                                                                                  
                                                                                                  <p>
                                                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintFooter()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> &#8220;You owed &#8221; + CalculateTotalRentalCost().ToString() + System.Environment.NewLine +<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp; &#8220;You earned &#8221; + CalculateTotalFrequentRenterPoints().ToString() + &#8221; frequent renter points&#8221; + System.Environment.NewLine;<br />&nbsp;&nbsp;&nbsp; }
                                                                                                  </p>
                                                                                                  
                                                                                                  <p>
                                                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintHeader()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> &#8220;Rental Record for &#8221; + getName() + System.Environment.NewLine;<br />&nbsp;&nbsp;&nbsp; }
                                                                                                  </p>
                                                                                                  
                                                                                                  <p>
                                                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintLineItems()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> LineItemPrinter.Collect(rentalCollection);<br />&nbsp;&nbsp;&nbsp; }
                                                                                                  </p>
                                                                                                  
                                                                                                  <p>
                                                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">int</span> CalculateTotalFrequentRenterPoints()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> FrequentRenterPointsTotaller.Collect(rentalCollection);<br />&nbsp;&nbsp;&nbsp; }
                                                                                                  </p>
                                                                                                  
                                                                                                  <p>
                                                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">double</span> CalculateTotalRentalCost()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> RentalCostTotaller.Collect(rentalCollection);<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                                                                                    
                                                                                                    <p>
                                                                                                      In looking at this class, I can get rid of the Rentals property by adding an Add method to RentalCollection, simplifying Customer a bit more. But the important thing to notice here is that I have several methods that kind of seem to belong together, in a place by themselves.
                                                                                                    </p>
                                                                                                    
                                                                                                    <p>
                                                                                                      The contents of the statement() method and the three PrintXXX() methods seem to belong to a RentalStatement class. This is a class whose job it is to produce the rental statement. Let&rsquo;s do that refactoring and see where it takes us :
                                                                                                    </p>
                                                                                                    
                                                                                                    <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                                                      <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> RentalStatement<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">readonly</span> RentalCollection rentals;<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">readonly</span> <span style="COLOR: blue">string</span> customerName;</p> 
                                                                                                      
                                                                                                      <p>
                                                                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> RentalStatement(RentalCollection rentals, <span style="COLOR: blue">string</span> customerName)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.rentals = rentals;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.customerName = customerName;<br />&nbsp;&nbsp;&nbsp; }
                                                                                                      </p>
                                                                                                      
                                                                                                      <p>
                                                                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">string</span> GenerateStatement()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> PrintHeader() + PrintLineItems() + PrintFooter();<br />&nbsp;&nbsp;&nbsp; }
                                                                                                      </p>
                                                                                                      
                                                                                                      <p>
                                                                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintFooter()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> &#8220;You owed &#8221; + CalculateTotalRentalCost().ToString() + System.Environment.NewLine +<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &#8220;You earned &#8221; + CalculateTotalFrequentRenterPoints().ToString() + &#8221; frequent renter points&#8221; + System.Environment.NewLine;<br />&nbsp;&nbsp;&nbsp; }
                                                                                                      </p>
                                                                                                      
                                                                                                      <p>
                                                                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintHeader()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> &#8220;Rental Record for &#8221; + customerName + System.Environment.NewLine;<br />&nbsp;&nbsp;&nbsp; }
                                                                                                      </p>
                                                                                                      
                                                                                                      <p>
                                                                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintLineItems()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> LineItemPrinter.Collect(rentals);<br />&nbsp;&nbsp;&nbsp; }
                                                                                                      </p>
                                                                                                      
                                                                                                      <p>
                                                                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">int</span> CalculateTotalFrequentRenterPoints()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> FrequentRenterPointsTotaller.Collect(rentals);<br />&nbsp;&nbsp;&nbsp; }
                                                                                                      </p>
                                                                                                      
                                                                                                      <p>
                                                                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">double</span> CalculateTotalRentalCost()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> RentalCostTotaller.Collect(rentals);<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                                                                                        
                                                                                                        <p>
                                                                                                          In factoring out the RentalStatement class, I had to take along the CalculateTotalFrequentRenterPoints() and CalculateTotalRentalCost() methods as well. I&rsquo;m not entirely sure that I want these methods in this class, but if I keep them in the Customer class then I have some processing of the RentalCollection in that class and some in this class. I also have to pass in the result of these calculations into either the constructor or the GenerateStatement() method, and I&rsquo;m not sure I like that either. This is a judgement call.
                                                                                                        </p>
                                                                                                        
                                                                                                        <p>
                                                                                                          The Customer class is reduced to this:
                                                                                                        </p>
                                                                                                        
                                                                                                        <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                                                          <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> Customer<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> name;<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> RentalCollection rentalCollection = <span style="COLOR: blue">new</span> RentalCollection();</p> 
                                                                                                          
                                                                                                          <p>
                                                                                                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> Customer(<span style="COLOR: blue">string</span> name)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.name = name;<br />&nbsp;&nbsp;&nbsp; }
                                                                                                          </p>
                                                                                                          
                                                                                                          <p>
                                                                                                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">void</span> addRental(Rental rental)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; rentalCollection.Add(rental);<br />&nbsp;&nbsp;&nbsp; }
                                                                                                          </p>
                                                                                                          
                                                                                                          <p>
                                                                                                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">string</span> getName()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> name;<br />&nbsp;&nbsp;&nbsp; }
                                                                                                          </p>
                                                                                                          
                                                                                                          <p>
                                                                                                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">string</span> statement()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return <span style="COLOR: blue">new</span> RentalStatement(rentalCollection, getName()).GenerateStatement();<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                                                                                            
                                                                                                            <p>
                                                                                                              <strong>Conclusion</strong>
                                                                                                            </p>
                                                                                                            
                                                                                                            <p>
                                                                                                              With this, I believe I&rsquo;m finished. I&rsquo;ve taken the original Customer class and applied some interesting refactorings to it. I&rsquo;ve gotten rid of all private methods that do anything more than just explain a single line of code, and those are just in the RentalStatement class. Every method is a single line except for some constructors for classes with more than one member variable, except for the loop in the RentalCollection class. And there is no duplication anywhere that I can see.
                                                                                                            </p>
                                                                                                            
                                                                                                            <p>
                                                                                                              Now for the questions. Is this code more clear than the original Customer class? I&rsquo;m not sure. In some senses it is. If I want to go see how the statement is generated, I can now go look at a RentalStatement class and see it. Looking ahead a bit, knowing that one of the changes Martin talks about in his book is that we need to support an HTML statement as well as a text statement, so by creating the RentalStatement class, we&rsquo;re well prepared to make that change. I&rsquo;m never sure if the ReplaceExternalIterationWithInternalIteration ever makes code more clear, but it does eliminate duplication.
                                                                                                            </p>
                                                                                                            
                                                                                                            <p>
                                                                                                              I&rsquo;m not sure that I would ever go this far in real life, but it is nice to know that I could.
                                                                                                            </p>
                                                                                                            
                                                                                                            <p>
                                                                                                              What do you think?
                                                                                                            </p>
                                                                                                            
                                                                                                            <p>
                                                                                                              Here is the final code:
                                                                                                            </p>
                                                                                                            
                                                                                                            <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                                                              <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> Customer<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> name;<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> RentalCollection rentalCollection = <span style="COLOR: blue">new</span> RentalCollection();</p> 
                                                                                                              
                                                                                                              <p>
                                                                                                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> Customer(<span style="COLOR: blue">string</span> name)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.name = name;<br />&nbsp;&nbsp;&nbsp; }
                                                                                                              </p>
                                                                                                              
                                                                                                              <p>
                                                                                                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">void</span> addRental(Rental rental)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; rentalCollection.Add(rental);<br />&nbsp;&nbsp;&nbsp; }
                                                                                                              </p>
                                                                                                              
                                                                                                              <p>
                                                                                                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">string</span> getName()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> name;<br />&nbsp;&nbsp;&nbsp; }
                                                                                                              </p>
                                                                                                              
                                                                                                              <p>
                                                                                                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">string</span> statement()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> <span style="COLOR: blue">new</span> RentalStatement(rentalCollection, getName()).GenerateStatement();<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                                                                                                
                                                                                                                <p>
                                                                                                                  <!--EndFragment-->
                                                                                                                </p>
                                                                                                                
                                                                                                                <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                                                                  <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> RentalCollection<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> ArrayList rentals = <span style="COLOR: blue">new</span> ArrayList();</p> 
                                                                                                                  
                                                                                                                  <p>
                                                                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> ArrayList Rentals<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">get</span> { <span style="COLOR: blue">return</span> rentals; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">set</span> { rentals = <span style="COLOR: blue">value</span>; }<br />&nbsp;&nbsp;&nbsp; }
                                                                                                                  </p>
                                                                                                                  
                                                                                                                  <p>
                                                                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">delegate</span> <span style="COLOR: blue">object</span> Collector(<span style="COLOR: blue">object</span> initialValue, Rental rental);
                                                                                                                  </p>
                                                                                                                  
                                                                                                                  <p>
                                                                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">object</span> Collect(Collector collector, <span style="COLOR: blue">object</span> initialValue)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">foreach</span> (Rental rental <span style="COLOR: blue">in</span> Rentals)<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">object</span> runningTotal = collector(initialValue, rental);<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; initialValue = runningTotal;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> initialValue;<br />&nbsp;&nbsp;&nbsp; }
                                                                                                                  </p>
                                                                                                                  
                                                                                                                  <p>
                                                                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">void</span> Add(Rental rental)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; rentals.Add(rental);<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                                                                                                    
                                                                                                                    <p>
                                                                                                                      <!--EndFragment-->
                                                                                                                    </p>
                                                                                                                    
                                                                                                                    <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                                                                      <span style="COLOR: blue">public</span> <span style="COLOR: blue">abstract</span> <span style="COLOR: blue">class</span> Collector<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">readonly</span> RentalCollection rentals;<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">readonly</span> RentalCollection.Collector collectDelegate;</p> 
                                                                                                                      
                                                                                                                      <p>
                                                                                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> Collector(RentalCollection rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.rentals = rentals;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.collectDelegate = <span style="COLOR: blue">new</span> RentalCollection.Collector(DoCollect);<br />&nbsp;&nbsp;&nbsp; }
                                                                                                                      </p>
                                                                                                                      
                                                                                                                      <p>
                                                                                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">protected</span> <span style="COLOR: blue">object</span> PerformCollection(<span style="COLOR: blue">object</span> initialValue)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> rentals.Collect(collectDelegate, initialValue);<br />&nbsp;&nbsp;&nbsp; }
                                                                                                                      </p>
                                                                                                                      
                                                                                                                      <p>
                                                                                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">protected</span> <span style="COLOR: blue">abstract</span> <span style="COLOR: blue">object</span> DoCollect(<span style="COLOR: blue">object</span> initialValue, Rental rental);<br />}</div> 
                                                                                                                        
                                                                                                                        <p>
                                                                                                                          <!--EndFragment-->
                                                                                                                        </p>
                                                                                                                        
                                                                                                                        <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                                                                          <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> LineItemPrinter : Collector<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">static</span> <span style="COLOR: blue">string</span> Collect(RentalCollection rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> <span style="COLOR: blue">new</span> LineItemPrinter(rentals).PrintLineItems();<br />&nbsp;&nbsp;&nbsp; }</p> 
                                                                                                                          
                                                                                                                          <p>
                                                                                                                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> LineItemPrinter(RentalCollection rentals) : <span style="COLOR: blue">base</span>(rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; }
                                                                                                                          </p>
                                                                                                                          
                                                                                                                          <p>
                                                                                                                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">string</span> PrintLineItems()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> (<span style="COLOR: blue">string</span>)PerformCollection(&#8220;&#8221;);<br />&nbsp;&nbsp;&nbsp; }
                                                                                                                          </p>
                                                                                                                          
                                                                                                                          <p>
                                                                                                                            &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">protected</span> <span style="COLOR: blue">override</span> <span style="COLOR: blue">object</span> DoCollect(<span style="COLOR: blue">object</span> initialValue, Rental rental)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> (<span style="COLOR: blue">string</span>)initialValue + &#8220;t&#8221; + rental.getMovie().getTitle() + &#8220;t&#8221;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; + rental.CalculateRentalCost().ToString() + System.Environment.NewLine;<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                                                                                                            
                                                                                                                            <p>
                                                                                                                              <!--EndFragment-->
                                                                                                                            </p>
                                                                                                                            
                                                                                                                            <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                                                                              <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> FrequentRenterPointsTotaller : Collector<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">static</span> <span style="COLOR: blue">int</span> Collect(RentalCollection rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> <span style="COLOR: blue">new</span> FrequentRenterPointsTotaller(rentals).CalculateTotalFrequentRenterPoints();<br />&nbsp;&nbsp;&nbsp; }</p> 
                                                                                                                              
                                                                                                                              <p>
                                                                                                                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> FrequentRenterPointsTotaller(RentalCollection rentals) : <span style="COLOR: blue">base</span>(rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; }
                                                                                                                              </p>
                                                                                                                              
                                                                                                                              <p>
                                                                                                                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">int</span> CalculateTotalFrequentRenterPoints()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> (<span style="COLOR: blue">int</span>)PerformCollection(0);<br />&nbsp;&nbsp;&nbsp; }
                                                                                                                              </p>
                                                                                                                              
                                                                                                                              <p>
                                                                                                                                &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">protected</span> <span style="COLOR: blue">override</span> <span style="COLOR: blue">object</span> DoCollect(<span style="COLOR: blue">object</span> frequentRenterPoints, Rental rental)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> (<span style="COLOR: blue">int</span>)frequentRenterPoints + rental.CalculateFrequentRenterPoints();<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                                                                                                                
                                                                                                                                <p>
                                                                                                                                  <!--EndFragment-->
                                                                                                                                </p>
                                                                                                                                
                                                                                                                                <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                                                                                  <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> RentalCostTotaller : Collector<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">static</span> <span style="COLOR: blue">double</span> Collect(RentalCollection rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> <span style="COLOR: blue">new</span> RentalCostTotaller(rentals).CalculateTotalRentalCost();<br />&nbsp;&nbsp;&nbsp; }</p> 
                                                                                                                                  
                                                                                                                                  <p>
                                                                                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> RentalCostTotaller(RentalCollection rentals) : <span style="COLOR: blue">base</span>(rentals)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; }
                                                                                                                                  </p>
                                                                                                                                  
                                                                                                                                  <p>
                                                                                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">double</span> CalculateTotalRentalCost()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> (<span style="COLOR: blue">double</span>)PerformCollection(0.0);<br />&nbsp;&nbsp;&nbsp; }
                                                                                                                                  </p>
                                                                                                                                  
                                                                                                                                  <p>
                                                                                                                                    &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">protected</span> <span style="COLOR: blue">override</span> <span style="COLOR: blue">object</span> DoCollect(<span style="COLOR: blue">object</span> rentalCost, Rental rental)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> (<span style="COLOR: blue">double</span>)rentalCost + rental.CalculateRentalCost();<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                                                                                                                    
                                                                                                                                    <p>
                                                                                                                                      <!--EndFragment-->
                                                                                                                                    </p>
                                                                                                                                    
                                                                                                                                    <div style="BORDER-RIGHT: windowtext 1pt solid; PADDING-RIGHT: 0pt; BORDER-TOP: windowtext 1pt solid; PADDING-LEFT: 0pt; FONT-SIZE: 10pt; BACKGROUND: white; PADDING-BOTTOM: 0pt; BORDER-LEFT: windowtext 1pt solid; COLOR: black; PADDING-TOP: 0pt; BORDER-BOTTOM: windowtext 1pt solid; FONT-FAMILY: Courier New">
                                                                                                                                      <span style="COLOR: blue">public</span> <span style="COLOR: blue">class</span> RentalStatement<br />{<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">readonly</span> RentalCollection rentals;<br />&nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">readonly</span> <span style="COLOR: blue">string</span> customerName;</p> 
                                                                                                                                      
                                                                                                                                      <p>
                                                                                                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> RentalStatement(RentalCollection rentals, <span style="COLOR: blue">string</span> customerName)<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.rentals = rentals;<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">this</span>.customerName = customerName;<br />&nbsp;&nbsp;&nbsp; }
                                                                                                                                      </p>
                                                                                                                                      
                                                                                                                                      <p>
                                                                                                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">public</span> <span style="COLOR: blue">string</span> GenerateStatement()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> PrintHeader() + PrintLineItems() + PrintFooter();<br />&nbsp;&nbsp;&nbsp; }
                                                                                                                                      </p>
                                                                                                                                      
                                                                                                                                      <p>
                                                                                                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintFooter()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> &#8220;You owed &#8221; + CalculateTotalRentalCost().ToString() + System.Environment.NewLine +<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &#8220;You earned &#8221; + CalculateTotalFrequentRenterPoints().ToString() + &#8221; frequent renter points&#8221; + System.Environment.NewLine;<br />&nbsp;&nbsp;&nbsp; }
                                                                                                                                      </p>
                                                                                                                                      
                                                                                                                                      <p>
                                                                                                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintHeader()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> &#8220;Rental Record for &#8221; + customerName + System.Environment.NewLine;<br />&nbsp;&nbsp;&nbsp; }
                                                                                                                                      </p>
                                                                                                                                      
                                                                                                                                      <p>
                                                                                                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">string</span> PrintLineItems()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> LineItemPrinter.Collect(rentals);<br />&nbsp;&nbsp;&nbsp; }
                                                                                                                                      </p>
                                                                                                                                      
                                                                                                                                      <p>
                                                                                                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">int</span> CalculateTotalFrequentRenterPoints()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> FrequentRenterPointsTotaller.Collect(rentals);<br />&nbsp;&nbsp;&nbsp; }
                                                                                                                                      </p>
                                                                                                                                      
                                                                                                                                      <p>
                                                                                                                                        &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">private</span> <span style="COLOR: blue">double</span> CalculateTotalRentalCost()<br />&nbsp;&nbsp;&nbsp; {<br />&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="COLOR: blue">return</span> RentalCostTotaller.Collect(rentals);<br />&nbsp;&nbsp;&nbsp; }<br />}</div> 
                                                                                                                                        
                                                                                                                                        <p>
                                                                                                                                          <!--EndFragment-->&mdash; bab
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                          
                                                                                                                                          <!--EndFragment-->
                                                                                                                                        </p>

 [1]: http://www.martinfowler.com/
 [2]: http://www.amazon.com/exec/obidos/tg/detail/-/0201485672/qid=1105844395/sr=8-1/ref=pd_csp_1/103-6828178-8917456?v=glance&s=books&n=507846