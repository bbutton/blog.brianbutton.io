---
title: Updated outline for Agile Tests as Documentation
author: Brian Button
type: post
date: 2004-09-01T04:55:00+00:00
url: /index.php/2004/09/01/updated-outline-for-agile-tests-as-documentation/
sfw_comment_form_password:
  - 0WRiq4VX16nx
sfw_pwd:
  - HjGJ7hQcew6Q
categories:
  - Uncategorized

---
I&#8217;ve updated my outline a bit and fleshed it out some. This is the new outline, so please feel free to comment.

<OL type="I">
  <br /> 
  
  <LI>
    Introduction<br /> <OL type="A">
      <br /> 
      
      <LI>
        problem
      </LI>
      <br /> 
      
      <OL type="i">
        <br /> 
        
        <LI>
          Documentation is an expensive anchor around a team&#8217;s neck<br /> <LI>
            Lots of money to produce (40% on current project)<br /> <LI>
              Expensive to change (increases inertia and cost of change)<br /> <LI>
                Difficult to make comprehensive (need source anyways)<br /> </OL><br /> <LI>
                  Need something different that will promote minimal inertia, cost, and is accurate and comprehensive.</p> <pre><code>&lt;LI&gt;Agile Developers write tests for code as it is developed
</code></pre>
                  
                  <p>
                    <OL type="i">
                      <br /> 
                      
                      <LI>
                        Tests assert behavior of system (create invariant)<br /> <LI>
                          Tests provide record of development stream (thought processes of developer)<br /> <LI>
                            Tests change as code changes<br /> </OL><br /> <LI>
                              Can tests be used as documentation?<br /> </OL><br /> <LI>
                                Who is our audience and what do they need?<br /> <OL type="A">
                                  <br /> 
                                  
                                  <LI>
                                    Application programmers &#8212; users of our libraries<br /> <OL type="i">
                                      <br /> 
                                      
                                      <LI>
                                        Concerned with finding out what they want to know and getting back to work quickly.<br /> <LI>
                                          Concerned with most common usage scenarios most times, but still care about exception cases. Order of tests not important<br /> </OL><br /> <LI>
                                            Maintenance programmers &#8212; modifiers and extenders of our libraries<br /> <OL type="i">
                                              <br /> 
                                              
                                              <LI>
                                                Concerned with understanding underlying design and decisions<br /> <LI>
                                                  Need guide through code. Order of tests important to them.<br /> </OL><br /> <LI>
                                                    Evaluators &#8212; tire kickers<br /> <OL type="i">
                                                      <br /> 
                                                      
                                                      <LI>
                                                        Want to get moving quickly<br /> <LI>
                                                          Less concerned with tests than sample code and quick starts<br /> <LI>
                                                            Still want to understand architecture and design as part of evaluation, so will act as maintenance programmer in some ways.<br /> </OL><br /> </OL><br /> <LI>
                                                              My contention is that tests can do part of the job, but some text is still needed<br /> <LI>
                                                                Description of Caching design &#8212; equivalent to short text and few UML diagrams<br /> <OL type="A">
                                                                  <br /> 
                                                                  
                                                                  <LI>
                                                                    Basic functions (add, remove, get, flush)<br /> <LI>
                                                                      Factories and equivalency of CacheManagers<br /> <LI>
                                                                        Background operations<br /> <LI>
                                                                          Liveliness of cache references (missing test???)<br /> </OL><br /> <LI>
                                                                            Components of a good test<br /> <OL type="A">
                                                                              <br /> 
                                                                              
                                                                              <LI>
                                                                                3 A-s (Bill Wake)<br /> <OL type="i">
                                                                                  <br /> 
                                                                                  
                                                                                  <LI>
                                                                                    Arrange<br /> <LI>
                                                                                      Act<br /> <LI>
                                                                                        Assert<br /> </OL><br /> <LI>
                                                                                          Strong names for everything<br /> <OL type="i">
                                                                                            <br /> 
                                                                                            
                                                                                            <LI>
                                                                                              Test name tells what is being tested. Makes interesting tests easier to find<br /> <LI>
                                                                                                Good variable names inside tests. Makes code easier to read<br /> </OL><br /> <LI>
                                                                                                  Clear assertions. Defines purpose of test. Assertion should assert strongest thing that can be said about test. Should show thought into what underlying code does<br /> <LI>
                                                                                                    Suite name should tell reader what task fixture is testing/documenting<br /> </OL><br /> <LI>
                                                                                                      Test sufficiency &#8212; do I tell the whole story with my tests<br /> <OL type="A">
                                                                                                        <br /> 
                                                                                                        
                                                                                                        <LI>
                                                                                                          Capturing design decisions<br /> <LI>
                                                                                                            Covering interesting use cases<br /> <LI>
                                                                                                              Showing error behavior<br /> <LI>
                                                                                                                Interactions with the environment<br /> <LI>
                                                                                                                  Test organization for different audiences<br /> <OL type="i">
                                                                                                                    <br /> 
                                                                                                                    
                                                                                                                    <LI>
                                                                                                                      Application Programmers want to find common scenarios easily<br /> <LI>
                                                                                                                        Maintenance Programmers want to follow original developer&#8217;s train of thought<br /> </OL><br /> </OL><br /> <LI>
                                                                                                                          Conclusion: What prose and UML are needed to supplement these tests<br /> <LI>
                                                                                                                            Future directions in Tests as Documentation (Automation topics mostly)<br /> <LI>
                                                                                                                              Final question &#8212; Did using tests as documentation save me anything?<br /> </OL></p>