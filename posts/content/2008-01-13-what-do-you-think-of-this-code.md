---
title: What do you think of this code?
author: Brian Button
type: post
date: 2008-01-13T21:15:00+00:00
url: /index.php/2008/01/13/what-do-you-think-of-this-code/
sfw_comment_form_password:
  - 5iZpPIBzW6wI
sfw_pwd:
  - JPDtdLCHWV17
categories:
  - 111
  - 112

---
I recently finished 6 weeks of coding for a client, and it was heaven! I actually got a chance to code every day, for 6 solid weeks. It was a chance for me to learn C# 3.0, and a chance to work on testing things that are hard to test. It was great!

Out of the work, came several interesting observations and coding techniques, all rooted in C# 3.0. Since no one at work has any experience with these new idioms I &#8220;invented&#8221;, &#8220;discovered&#8221;, or just &#8220;copied&#8221;, I&#8217;d love to get some reader feedback. I&#8217;ll start with this one trick I tried, and follow on with more as the mood strikes me over time.

**Trick 1: Using extension methods and a marker interface in place of implementation inheritance**

I had an instance of code duplication in two parallel hierarchies of classes, and I wanted to find a way to share the code. One option would be to use inheritance, factoring out another base class above BaseResponse and BaseRequest. This is where methods common to requests and responses could both live. Using inheritance as a way to reuse code in a single inheritance language is a pretty heavyweight thing to do. I&#8217;d rather find a way to use delegation, since that preserves the SRP in my class hierarchy. Instead, I decided to try an extension method, and just use that method where I needed it. To avoid polluting Object with unnecessary methods, however, I came up with the idea of using a marker interface on the classes I wanted to have these extension methods, limiting the scope where these extra methods were visible. (No idea if anyone else has done this yet or not)

 <img style="border-top-width: 0px; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="296" alt="ClassDiagram1" src="http://www.agilestl.com/BlogImages/ClassDiagram1.jpg" width="647" border="0" />

For each request and response class, in the two parallel&nbsp; hierarchies, my client requirements made it necessary to add an XmlRoot attribute to tell the XmlSerializer that this object was the root of an XML document and to specify the runtime name of this element. To let me get the runtime name of each request and response object, for auditing and logging purposes, both hierarchies had a CommandName property, containing the exact same code. This was the code in question that I was trying to share.

As a simple exercise, I created an extension method to deal with this:

<pre><span style="color: #0000ff">internal</span> <span style="color: #0000ff">static</span> <span style="color: #0000ff">class</span> SssMessageExtensionMethods
    {
        <span style="color: #0000ff">public</span> <span style="color: #0000ff">static</span> <span style="color: #0000ff">string</span> GetCommandNameFromXmlRootAttribute(<span style="color: #0000ff">this</span> object message)
        {
            <span style="color: #0000ff">object</span>[] attributes = message.GetType().GetCustomAttributes(<span style="color: #0000ff">typeof</span>(XmlRootAttribute), <span style="color: #0000ff">true</span>);
            <span style="color: #0000ff">if</span> (attributes.Length == 0) <span style="color: #0000ff">return</span> message.GetType().Name;

            XmlRootAttribute xmlRootAttribute = attributes[0] <span style="color: #0000ff">as</span> XmlRootAttribute;

            <span style="color: #0000ff">return</span> xmlRootAttribute.ElementName;
        }
    }</pre>

This solution worked just fine, and the code ran correctly, but I still wasn&#8217;t happy with my solution. The problem I was sensing was that I was adding yet another extension method to Object, and Object&#8217;s neighborhood was already pretty crowded with all the Linq methods in there. I wanted my extension methods to show up only on those classes to which I wanted to apply them. 

The solution that I came up with was to use a marker interface whose sole purpose is to limit the visibility of the extension methods to classes that I intend to apply them to. In this case, I made BaseRequest and BaseResponse each implement IMessageMarker, an interface with no methods. And I changed the extension method to be:

<pre><span style="color: #0000ff">internal</span> <span style="color: #0000ff">static</span> <span style="color: #0000ff">class</span> SssMessageExtensionMethods
    {
        <span style="color: #0000ff">public</span> <span style="color: #0000ff">static</span> <span style="color: #0000ff">string</span> GetCommandNameFromXmlRootAttribute(<span style="color: #0000ff">this</span> ISssMessageMarker message)
        {
            <span style="color: #0000ff">object</span>[] attributes = message.GetType().GetCustomAttributes(<span style="color: #0000ff">typeof</span>(XmlRootAttribute), <span style="color: #0000ff">true</span>);
            <span style="color: #0000ff">if</span> (attributes.Length == 0) <span style="color: #0000ff">return</span> message.GetType().Name;

            XmlRootAttribute xmlRootAttribute = attributes[0] <span style="color: #0000ff">as</span> XmlRootAttribute;

            <span style="color: #0000ff">return</span> xmlRootAttribute.ElementName;
        }
    }</pre>

Now I have the same extension method defined, but it only appears on those classes that implement the marker.

What do you think of this technique? In a more powerful language, like Ruby or C++ (ducking and running for cover!), this kind of trickery wouldn&#8217;t be needed. But C# can only get you so far, so I felt this was a good tradeoff between adding the methods for needed functionality and making the most minimal change in my classes to hide these methods so that only those places that needed them could see them.

&#8212; bab