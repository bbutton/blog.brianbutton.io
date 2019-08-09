---
title: Using programmer tests in place of some or all documentation?
author: Brian Button
type: post
date: 2004-08-25T09:15:00+00:00
url: /index.php/2004/08/25/using-programmer-tests-in-place-of-some-or-all-documentation/
sfw_comment_form_password:
  - IYRNsQNRhkfp
sfw_pwd:
  - i4qRuLsaBD6R
categories:
  - Uncategorized

---
I&#8217;m writing an article for an agile software magazine about how to use programmer tests in place of some or all written documentation, and I&#8217;d appreciate some feedback on a very early outline for the article. This is what I intend to cover:

<OL type="I">
  <br /> 
  
  <LI>
    Different audiences for documentation
  </LI>
  <br /> 
  
  <OL type="A">
    <br /> 
    
    <LI>
      Application programmers &#8212; users of our libraries
    </LI>
    <br /> 
    
    <LI>
      Maintenance programmers &#8212; modifiers and extenders of our libraries
    </LI>
    <br />
  </OL>
  
  <br /> 
  
  <LI>
    Components of a good test
  </LI>
  <br /> 
  
  <OL type="A">
    <br /> 
    
    <LI>
      Good names
    </LI>
    <br /> 
    
    <LI>
      Clearly defined setup, processing, and asserting sections
    </LI>
    <br />
  </OL>
  
  <br /> 
  
  <LI>
    Test sufficiency &#8212; do I tell the whole story with my tests
  </LI>
  <br /> 
  
  <OL type="A">
    <br /> 
    
    <LI>
      Capturing design decisions<LI>
        <br /> <LI>
          Covering interesting use cases
        </LI>
        <br /> <LI>
          Showing error behavior
        </LI>
        <br /> <LI>
          Interactions with the environment
        </LI>
        <br /> <LI>
          Test organization for different audiences
        </LI>
        <br /> <OL type="i">
          <br /> 
          
          <LI>
            Application Programmers want to find common scenarios easily
          </LI>
          <br /> 
          
          <LI>
            Maintenance Programmers want to follow original developer&#8217;s train of thought
          </LI>
          <br />
        </OL>
        
        <br /> </OL><br /> <LI>
          What prose and UML are needed to supplement these tests
        </LI>
        <br /> <LI>
          Future directions in Tests as Documentation (Automation topics mostly)
        </LI>
        <br /> </OL></p> <p>
          <P>
            Obviously this is still pretty rough. I intend to use the tests for a Caching block I just wrote for Microsoft Enterprise Library along with pseudocode for the library to show the design decisions. The goal is to show devs how to create tests that will server as documentation.
          </P>
        </p>
        
        <p>
          <P>
            Does this sound remotely interesting? Any suggestions about other things to cover?
          </P>
        </p>
        
        <p>
          <P>
            And for those of you in St. Louis, I&#8217;m going to be giving a talk on this subject at this month&#8217;s XPSTL (9/1).
          </P>
        </p>
        
        <p>
          &#8212; bab
        </p>