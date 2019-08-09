---
title: Test Driving a WPF application using MVVM and TDD
author: Brian Button
type: post
date: 2009-08-17T05:31:00+00:00
url: /index.php/2009/08/17/test-driving-a-wpf-application-using-mvvm-and-tdd/
sfw_comment_form_password:
  - cidnYcXvkPUy
sfw_pwd:
  - a8HclvzmMd5t
categories:
  - 111
  - 112

---
This is a preview of the material I’m going to be presenting at the [St. Louis Day of Dot Net][1] in a couple weeks. 

**Introduction**

For those of you who are reading this blog for the first time, I’m pretty much the St. Louis Agile Zealot. Long hair, flowing robes… you get the picture 🙂 I’ve been advocating Agile and XP in St. Louis since around 2000, through speaking at various user groups and local conferences, teaching at local companies, giving talks in the park, dropping leaflets from airplanes, and so on. I live Agile in my day job at [Asynchrony Solutions][2], where I lead their Agile training and mentoring group. I am totally sold on Test Driven Development as the best way for me to write my code, and I’ve been occasionally known to share that opinion with others.

As far as WPF experience goes, I’m still pretty new in my learning curve.&nbsp; I’ve been playing with a project on my own for a few months, trying new things, reading, and experimenting. When I first started out, I completely wrote a Winforms app in WPF. I used a full-on MVP/MVC architecture, had my button click methods in my window classes, etc. A complete mess… Then I started reading about MVVM and that sparked something inside me that realized that this finally made sense. This was something that gave me a lot of the advantages of the MVP-like architectures, such as being able to test my UI without actually running the UI, but without the overhead of wiring all that junk up myself.

What follows are the lessons I’ve learned in the process of rethinking my original app and in writing this sample app for my talk.

**The Application**

My daughter plays select softball for one of the organizations here in St. Louis. They have a web site that lists all their stats throughout the year, and I thought it would be fun to mimic that site as a desktop app. The application would list all the girls’ total stats on the front page and give you the ability to drill down into detailed stats for each game on subsequent pages. For fun, I wanted to be able to add stats for new games, and add and delete players. With that set of features, it seemed that I’d be able to drive out a lot of interesting opportunities to change around the design to let me write the code in a TDD manner.

Here is the main page of the application, in all its glory. Remember that I am but a poor developer, with a developer’s eye for style 🙂

[<img style="border-bottom: 0px; border-left: 0px; display: inline; border-top: 0px; border-right: 0px" title="image" border="0" alt="image" src="http://www.agilestl.com/BlogImages/TestDrivingaWPFapplicationusingMVVMandTD_5BD2/image_thumb.png" width="564" height="340" />][3] 

The display of stats isn’t complete yet, but it was enough to validate that my data binding was working. Let’s look at what it took to get this far…

_Note: If you want to skip the setup stuff and get right to the parts where behavior is added, jump ahead to Step 3._

**Our Roadmap**

As a quick review, before we dive in, here is an overview of the MVVM design pattern and the players involved.

[<img style="border-bottom: 0px; border-left: 0px; display: inline; margin-left: 0px; border-top: 0px; margin-right: 0px; border-right: 0px" title="MVVM Architecture" border="0" alt="MVVM Architecture" src="http://www.agilestl.com/BlogImages/TestDrivingaWPFapplicationusingMVVMandTD_5BD2/MVVMArchitecture_thumb.png" width="402" height="253" />][4] 

The View represents the surface that the user interacts with. It is the WPF code, the UI, and XAML… all that stuff that users see and that is hard to test in an automated fashion. Our goal is to take as much logic out of there as possible, to allow us to have the highest amount of confidence and the greatest amount of test coverage that we can achieve.

Next to the View is the ViewModel. The ViewModel represents the entire set of data and behavior contained in the View. It has properties to expose all the different pieces of data that the View will&nbsp; need to display, and it exposes another set of properties for all the behavior that the View will need to invoke.

The View and ViewModel are tied together in two separate, but very similar, ways. Through Data Binding, data travels between the View and ViewModel automatically. WPF, through the wonders of its internal magic, keeps consistent the data shown in the View and the data held in the ViewModel. There is a bit of work that we have to do to ensure this happens, but it mostly all automatic. The Commands are representations of the behavior that users invoke through the View. Individual commands are exposed through properties on the ViewModel and tied to controls on the View. When the user presses a button, for example, the command attached to that button fires and something happens. You can think of Commands as little controllers, focused on a specific topic, whose responsibility it is to respond to a user action in a particular manner by coordinating the response to that action between the View and ViewModel.

Our goal here is to put all logic about the View into the ViewModel. The View should be very thin and code-less, and the Commands should be thin shims that merely provide an execution conduit between the gesture being made and the behavior being invoked in the ViewModel. Code in the View or in Commands should be looked up with suspicion, with an eye towards trying to move it into someplace more testable. Sometimes you can move that code, and sometimes its entirely appropriate where it is, but the question should always be asked.

**Step 1 – Modify the template to sup****port TDD**

When you create a WPF application using the Visual Studio New Project dialog, you get the framework of an empty application. There is no code anywhere, other than an InitializeComponent() call here and there. Most of the interesting behavior, at this point, takes place through XAML – things like instantiating the Application object, creating the main window and causing it to display, and other basic things like that. While this works, and works fine for the empty application, we’re going to need more control over how this initiation process occurs, for reasons we’ll discuss later in this post or a subsequent one. 

So, to control the initial creation, there are a few changes we need to make. The first step is to put ourselves in control of when and where the main window is created. As time goes on, there are aspects of this creation process that we’re going to want to control, like wiring together other objects, so we’ll need full control over the how windows and controls are born.

_App.xaml_

When first created, App.xaml looks like this:

<div style="border-bottom: silver 1px solid; text-align: left; border-left: silver 1px solid; padding-bottom: 4px; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; padding-left: 4px; width: 97.5%; padding-right: 4px; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; border-top: silver 1px solid; cursor: text; border-right: silver 1px solid; padding-top: 4px" id="codeSnippetWrapper">
  <div style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px" id="codeSnippet">
    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum1">   1:</span> &lt;Application x:Class=<span style="color: #006080">"WpfApplication1.App"</span></pre>
    
    <p>
      <!--CRLF-->
    </p>
    
    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum2">   2:</span>     xmlns=<span style="color: #006080">"http://schemas.microsoft.com/winfx/2006/xaml/presentation"</span></pre>
    
    <p>
      <!--CRLF-->
    </p>
    
    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum3">   3:</span>     xmlns:x=<span style="color: #006080">"http://schemas.microsoft.com/winfx/2006/xaml"</span></pre>
    
    <p>
      <!--CRLF-->
    </p>
    
    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum4">   4:</span>     StartupUri=<span style="color: #006080">"Window1.xaml"</span>&gt;</pre>
    
    <p>
      <!--CRLF-->
    </p>
    
    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum5">   5:</span>     &lt;Application.Resources&gt;</pre>
    
    <p>
      <!--CRLF-->
    </p>
    
    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum6">   6:</span>          </pre>
    
    <p>
      <!--CRLF-->
    </p>
    
    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum7">   7:</span>     &lt;/Application.Resources&gt;</pre>
    
    <p>
      <!--CRLF-->
    </p>
    
    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum8">   8:</span> &lt;/Application&gt;</pre>
    
    <p>
      <!--CRLF--></div> </div> 
      
      <p>
        The StartupUri attribute of the Application element is what causes the class defined in Window1.xaml to be instantiated. We want to prevent this from happening until we’re ready for it, so we have to take this out. We’ll still need to create this window, however, so we’ll need to arrange for another way to create objects as the system is starting. It turns out that WPF exposes and event that is perfect for this initialization, the Startup event. By providing a handler for the Startup event, we can have a place to put all our initialization code.
      </p>
      
      <p>
        App.xaml now looks like this:
      </p>
      
      <div style="border-bottom: silver 1px solid; text-align: left; border-left: silver 1px solid; padding-bottom: 4px; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; padding-left: 4px; width: 97.5%; padding-right: 4px; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; border-top: silver 1px solid; cursor: text; border-right: silver 1px solid; padding-top: 4px" id="codeSnippetWrapper">
        <div style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px" id="codeSnippet">
          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum1">   1:</span> &lt;Application x:Class=<span style="color: #006080">"WpfApplication1.App"</span></pre>
          
          <p>
            <!--CRLF-->
          </p>
          
          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum2">   2:</span>     xmlns=<span style="color: #006080">"http://schemas.microsoft.com/winfx/2006/xaml/presentation"</span></pre>
          
          <p>
            <!--CRLF-->
          </p>
          
          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum3">   3:</span>     xmlns:x=<span style="color: #006080">"http://schemas.microsoft.com/winfx/2006/xaml"</span></pre>
          
          <p>
            <!--CRLF-->
          </p>
          
          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum4">   4:</span>     Startup=<span style="color: #006080">"Application_Startup"</span>&gt;</pre>
          
          <p>
            <!--CRLF-->
          </p>
          
          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum5">   5:</span>     &lt;Application.Resources&gt;</pre>
          
          <p>
            <!--CRLF-->
          </p>
          
          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum6">   6:</span>&nbsp; </pre>
          
          <p>
            <!--CRLF-->
          </p>
          
          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum7">   7:</span>     &lt;/Application.Resources&gt;</pre>
          
          <p>
            <!--CRLF-->
          </p>
          
          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum8">   8:</span> &lt;/Application&gt;</pre>
          
          <p>
            <!--CRLF--></div> </div> 
            
            <p>
              Now we have to add some code into the App.xaml.cs file to create the objects we need and to wire them together. Please note that I’m not writing tests for this code, because this is configuration code, not business logic. I view logic such as this the same way I view a Main method, and I tend not to test Main’s. It is where objects are created and wired together and then told to go on their merry way. This is not meant to be reusable code and should be just simple declarations of objects and assignments of variables. If I manage to screw up Main, the application isn’t going to work anyhow, and I’m pretty sure I’ll know it 🙂
            </p>
            
            <div style="border-bottom: silver 1px solid; text-align: left; border-left: silver 1px solid; padding-bottom: 4px; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; padding-left: 4px; width: 97.5%; padding-right: 4px; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; border-top: silver 1px solid; cursor: text; border-right: silver 1px solid; padding-top: 4px" id="codeSnippetWrapper">
              <div style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px" id="codeSnippet">
                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum1">   1:</span> <span style="color: #0000ff">using</span> System.Windows;</pre>
                
                <p>
                  <!--CRLF-->
                </p>
                
                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum2">   2:</span>&nbsp; </pre>
                
                <p>
                  <!--CRLF-->
                </p>
                
                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum3">   3:</span> <span style="color: #0000ff">namespace</span> WpfApplication1</pre>
                
                <p>
                  <!--CRLF-->
                </p>
                
                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum4">   4:</span> {</pre>
                
                <p>
                  <!--CRLF-->
                </p>
                
                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum5">   5:</span>     <span style="color: #0000ff">public</span> <span style="color: #0000ff">partial</span> <span style="color: #0000ff">class</span> App : Application</pre>
                
                <p>
                  <!--CRLF-->
                </p>
                
                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum6">   6:</span>     {</pre>
                
                <p>
                  <!--CRLF-->
                </p>
                
                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum7">   7:</span>         <span style="color: #0000ff">private</span> <span style="color: #0000ff">void</span> Application_Startup(<span style="color: #0000ff">object</span> sender, StartupEventArgs e)</pre>
                
                <p>
                  <!--CRLF-->
                </p>
                
                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum8">   8:</span>         {</pre>
                
                <p>
                  <!--CRLF-->
                </p>
                
                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum9">   9:</span>             Current.MainWindow = <span style="color: #0000ff">new</span> MainWindow();</pre>
                
                <p>
                  <!--CRLF-->
                </p>
                
                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum10">  10:</span>             Current.MainWindow.Show();</pre>
                
                <p>
                  <!--CRLF-->
                </p>
                
                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum11">  11:</span>         }</pre>
                
                <p>
                  <!--CRLF-->
                </p>
                
                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum12">  12:</span>     }</pre>
                
                <p>
                  <!--CRLF-->
                </p>
                
                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum13">  13:</span> }</pre>
                
                <p>
                  <!--CRLF--></div> </div> 
                  
                  <p>
                    The final step is to rename the template-provided window name of Window1 to MainWindow and make sure I instantiate it with the proper class name in the Application_Startup method, the handler for the Startup event. Once that is done, you can start the project, and an empty window should appear.
                  </p>
                  
                  <p>
                    <a href="http://www.agilestl.com/BlogImages/TestDrivingaWPFapplicationusingMVVMandTD_5BD2/image_3.png"><img style="border-bottom: 0px; border-left: 0px; display: inline; border-top: 0px; border-right: 0px" title="image" border="0" alt="image" src="http://www.agilestl.com/BlogImages/TestDrivingaWPFapplicationusingMVVMandTD_5BD2/image_thumb_3.png" width="244" height="244" /></a>
                  </p>
                  
                  <p>
                    &nbsp;<em>One more change…</em>
                  </p>
                  
                  <p>
                    Before going further, I’d like to introduce <a href="http://codeplex.com/unity" target="_blank">Unity</a> into the codebase. Unity is the dependency injection library from Microsoft, and I’ve found it to be very useful in my WPF applications. Here is the previous code after injecting Unity (<em>injecting Unity – HA! I kill myself)</em>.
                  </p>
                  
                  <div style="border-bottom: silver 1px solid; text-align: left; border-left: silver 1px solid; padding-bottom: 4px; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; padding-left: 4px; width: 97.5%; padding-right: 4px; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; border-top: silver 1px solid; cursor: text; border-right: silver 1px solid; padding-top: 4px" id="codeSnippetWrapper">
                    <div style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px" id="codeSnippet">
                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum1">   1:</span> <span style="color: #0000ff">using</span> System.Windows;</pre>
                      
                      <p>
                        <!--CRLF-->
                      </p>
                      
                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum2">   2:</span> <span style="color: #0000ff">using</span> Microsoft.Practices.Unity;</pre>
                      
                      <p>
                        <!--CRLF-->
                      </p>
                      
                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum3">   3:</span>&nbsp; </pre>
                      
                      <p>
                        <!--CRLF-->
                      </p>
                      
                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum4">   4:</span> <span style="color: #0000ff">namespace</span> WpfApplication1</pre>
                      
                      <p>
                        <!--CRLF-->
                      </p>
                      
                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum5">   5:</span> {</pre>
                      
                      <p>
                        <!--CRLF-->
                      </p>
                      
                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum6">   6:</span>     <span style="color: #0000ff">public</span> <span style="color: #0000ff">partial</span> <span style="color: #0000ff">class</span> App : Application</pre>
                      
                      <p>
                        <!--CRLF-->
                      </p>
                      
                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum7">   7:</span>     {</pre>
                      
                      <p>
                        <!--CRLF-->
                      </p>
                      
                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum8">   8:</span>         <span style="color: #0000ff">private</span> <span style="color: #0000ff">readonly</span> IUnityContainer container = <span style="color: #0000ff">new</span> UnityContainer();</pre>
                      
                      <p>
                        <!--CRLF-->
                      </p>
                      
                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum9">   9:</span>&nbsp; </pre>
                      
                      <p>
                        <!--CRLF-->
                      </p>
                      
                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum10">  10:</span>         <span style="color: #0000ff">private</span> <span style="color: #0000ff">void</span> Application_Startup(<span style="color: #0000ff">object</span> sender, StartupEventArgs e)</pre>
                      
                      <p>
                        <!--CRLF-->
                      </p>
                      
                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum11">  11:</span>         {</pre>
                      
                      <p>
                        <!--CRLF-->
                      </p>
                      
                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum12">  12:</span>             container.RegisterType&lt;MainWindow&gt;(<span style="color: #0000ff">new</span> ContainerControlledLifetimeManager());</pre>
                      
                      <p>
                        <!--CRLF-->
                      </p>
                      
                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum13">  13:</span>&nbsp; </pre>
                      
                      <p>
                        <!--CRLF-->
                      </p>
                      
                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum14">  14:</span>             Current.MainWindow = container.Resolve&lt;MainWindow&gt;();</pre>
                      
                      <p>
                        <!--CRLF-->
                      </p>
                      
                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum15">  15:</span>             Current.MainWindow.Show();</pre>
                      
                      <p>
                        <!--CRLF-->
                      </p>
                      
                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum16">  16:</span>         }</pre>
                      
                      <p>
                        <!--CRLF-->
                      </p>
                      
                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum17">  17:</span>     }</pre>
                      
                      <p>
                        <!--CRLF-->
                      </p>
                      
                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum18">  18:</span> }</pre>
                      
                      <p>
                        <!--CRLF--></div> </div> 
                        
                        <p>
                          Briefly, the point of this code is to register a type, MainWindow, with the Unity container, and then use the container to instantiate the MainWindow object as the application’s main window. The reason I introduced Unity is to separate myself from the semantics of object creation. Unity will take care of instantiating any objects I ask for, as well as any objects that the class being created needs. Its just a way of relieving myself of having to worry about constructor signatures, basically.
                        </p>
                        
                        <p>
                          <strong>Step 2 – Adding the initial content</strong>
                        </p>
                        
                        <p>
                          Its time to fill in the empty window with some content. We’ll avoid adding any behavior yet, we just want to see something. The strategy that we’re going to use is to keep the MainWindow class as the one window in our application, and we’ll swap in and out different pieces of content to show in it. In my projects I’ve found this pattern to be useful, because it lets me layer content to mimic a workflow in the application, and have the content always show up in the same place, be the same size, and not take extra work to manage.
                        </p>
                        
                        <p>
                          So our goal now is to set the MainWindow’s content to be the initial view we want to show people when they first open the application. The design for this looks like this:
                        </p>
                        
                        <p>
                          <a href="http://www.agilestl.com/BlogImages/TestDrivingaWPFapplicationusingMVVMandTD_5BD2/DesignWithTeamStatControlAndViewModel.png"><img style="border-bottom: 0px; border-left: 0px; display: inline; border-top: 0px; border-right: 0px" title="DesignWithTeamStatControlAndViewModel" border="0" alt="DesignWithTeamStatControlAndViewModel" src="http://www.agilestl.com/BlogImages/TestDrivingaWPFapplicationusingMVVMandTD_5BD2/DesignWithTeamStatControlAndViewModel_thumb.png" width="563" height="190" /></a>
                        </p>
                        
                        <p>
                          And the implementation is easy, too.
                        </p>
                        
                        <p>
                          First, I create my user control, TeamStatsControl:
                        </p>
                        
                        <p>
                          <a href="http://www.agilestl.com/BlogImages/TestDrivingaWPFapplicationusingMVVMandTD_5BD2/image_4.png"><img style="border-bottom: 0px; border-left: 0px; display: inline; border-top: 0px; border-right: 0px" title="image" border="0" alt="image" src="http://www.agilestl.com/BlogImages/TestDrivingaWPFapplicationusingMVVMandTD_5BD2/image_thumb_4.png" width="386" height="305" /></a>
                        </p>
                        
                        <p>
                          At the same time, I create a ResourceDictionary to hold styles that I’ll be using around the app and merged that dictionary into my UserControl.Resources section. I created a menu, a somewhat attractive header, and a couple of buttons. There’s no behavior in it yet, but that’s coming shortly.
                        </p>
                        
                        <p>
                          Now, for the fun part, let’s make the simple change to make the content show up in the MainWindow. Since we’re creating a new object, our TeamStatControl, we have to make a few simple changes in App.Application_Startup. We need to register the user control with Unity so that it can create it as needed, and then resolve an instance of it as the Content property of the MainWindow. Once that is done, WPF takes care of making it appear in the window.
                        </p>
                        
                        <div style="border-bottom: silver 1px solid; text-align: left; border-left: silver 1px solid; padding-bottom: 4px; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; padding-left: 4px; width: 97.5%; padding-right: 4px; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; border-top: silver 1px solid; cursor: text; border-right: silver 1px solid; padding-top: 4px" id="codeSnippetWrapper">
                          <div style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px" id="codeSnippet">
                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum1">   1:</span> <span style="color: #0000ff">private</span> <span style="color: #0000ff">void</span> Application_Startup(<span style="color: #0000ff">object</span> sender, StartupEventArgs e)</pre>
                            
                            <p>
                              <!--CRLF-->
                            </p>
                            
                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum2">   2:</span> {</pre>
                            
                            <p>
                              <!--CRLF-->
                            </p>
                            
                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum3">   3:</span>     container.RegisterType&lt;MainWindow&gt;(<span style="color: #0000ff">new</span> ContainerControlledLifetimeManager());</pre>
                            
                            <p>
                              <!--CRLF-->
                            </p>
                            
                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum4">   4:</span>     container.RegisterType&lt;TeamStatControl&gt;(<span style="color: #0000ff">new</span> ContainerControlledLifetimeManager());</pre>
                            
                            <p>
                              <!--CRLF-->
                            </p>
                            
                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum5">   5:</span>&nbsp; </pre>
                            
                            <p>
                              <!--CRLF-->
                            </p>
                            
                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum6">   6:</span>     Current.MainWindow = container.Resolve&lt;MainWindow&gt;();</pre>
                            
                            <p>
                              <!--CRLF-->
                            </p>
                            
                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum7">   7:</span>     Current.MainWindow.Content = container.Resolve&lt;TeamStatControl&gt;();</pre>
                            
                            <p>
                              <!--CRLF-->
                            </p>
                            
                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum8">   8:</span>     Current.MainWindow.Show();</pre>
                            
                            <p>
                              <!--CRLF-->
                            </p>
                            
                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum9">   9:</span> }</pre>
                            
                            <p>
                              <!--CRLF--></div> </div> 
                              
                              <p>
                                And, by the way, I also changed the Width and Height properties in MainWindow to be 600 and 1000 respectively so that the entire user control would be visible.
                              </p>
                              
                              <p>
                                <strong>Step 3 – Adding behavior</strong>
                              </p>
                              
                              <p>
                                Now that the shell is in place, we can add the behavior that we want. First, lets add the basic behavior of exiting the application in an orderly way. We want to be sure to do this in a way that all the code that we write is testable, and that is going to require a bit of extra work over and above just writing the simplest code. This is the price one pays when writing code using TDD, but the extra effort pays off in systems that work.
                              </p>
                              
                              <p>
                                Let’s start by writing our first test. This test will be a test of the Command object, which is the object that the view will interact with. An underlying force of the MVVM pattern is that the ViewModel encapsulates the visible data and behavior of the View. And the Command object acts as the conduit through which the gestures of the user are translated into tangible actions in the ViewModel. Here is a sequence diagram showing this behavior:
                              </p>
                              
                              <p>
                                <a href="http://www.agilestl.com/BlogImages/TestDrivingaWPFapplicationusingMVVMandTD_5BD2/CommandExecutionSequenceDiagram.png"><img style="border-bottom: 0px; border-left: 0px; display: inline; border-top: 0px; border-right: 0px" title="CommandExecutionSequenceDiagram" border="0" alt="CommandExecutionSequenceDiagram" src="http://www.agilestl.com/BlogImages/TestDrivingaWPFapplicationusingMVVMandTD_5BD2/CommandExecutionSequenceDiagram_thumb.png" width="454" height="195" /></a>
                              </p>
                              
                              <p>
                                Clicking the button causes the Command.Execute method to fire, which calls a method in the ViewModel. That method does the real work of this system, with the calls coming before it just part of the plumbing to cause things to happen.
                              </p>
                              
                              <p>
                                So lets write a test to show that the above sequence is what will actually happen – that calling the Execute method of some Command object will invoke some sort of behavior that causes the application to exit.
                              </p>
                              
                              <p>
                                Our first test:
                              </p>
                              
                              <div style="border-bottom: silver 1px solid; text-align: left; border-left: silver 1px solid; padding-bottom: 4px; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; padding-left: 4px; width: 97.5%; padding-right: 4px; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; border-top: silver 1px solid; cursor: text; border-right: silver 1px solid; padding-top: 4px" id="codeSnippetWrapper">
                                <div style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px" id="codeSnippet">
                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum1">   1:</span> <span style="color: #0000ff">namespace</span> ViewModelFixtures</pre>
                                  
                                  <p>
                                    <!--CRLF-->
                                  </p>
                                  
                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum2">   2:</span> {</pre>
                                  
                                  <p>
                                    <!--CRLF-->
                                  </p>
                                  
                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum3">   3:</span>     <span style="color: #0000ff">public</span> <span style="color: #0000ff">class</span> ApplicationExitBehaviorFixture</pre>
                                  
                                  <p>
                                    <!--CRLF-->
                                  </p>
                                  
                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum4">   4:</span>     {</pre>
                                  
                                  <p>
                                    <!--CRLF-->
                                  </p>
                                  
                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum5">   5:</span>         [Fact]</pre>
                                  
                                  <p>
                                    <!--CRLF-->
                                  </p>
                                  
                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum6">   6:</span>         <span style="color: #0000ff">public</span> <span style="color: #0000ff">void</span> ApplicationExitingBehaviorInvokedWhenExecuteCalled()</pre>
                                  
                                  <p>
                                    <!--CRLF-->
                                  </p>
                                  
                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum7">   7:</span>         {</pre>
                                  
                                  <p>
                                    <!--CRLF-->
                                  </p>
                                  
                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum8">   8:</span>             var exiter = <span style="color: #0000ff">new</span> Mock&lt;IApplicationExitAdapter&gt;();</pre>
                                  
                                  <p>
                                    <!--CRLF-->
                                  </p>
                                  
                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum9">   9:</span>             ApplicationExitCommand command = <span style="color: #0000ff">new</span> ApplicationExitCommand(exiter.Object);</pre>
                                  
                                  <p>
                                    <!--CRLF-->
                                  </p>
                                  
                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum10">  10:</span>             exiter.Setup(e =&gt; e.ExitApplication()).Verifiable();</pre>
                                  
                                  <p>
                                    <!--CRLF-->
                                  </p>
                                  
                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum11">  11:</span>&nbsp; </pre>
                                  
                                  <p>
                                    <!--CRLF-->
                                  </p>
                                  
                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum12">  12:</span>             command.Execute(<span style="color: #0000ff">null</span>);</pre>
                                  
                                  <p>
                                    <!--CRLF-->
                                  </p>
                                  
                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum13">  13:</span>&nbsp; </pre>
                                  
                                  <p>
                                    <!--CRLF-->
                                  </p>
                                  
                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum14">  14:</span>             exiter.Verify(e =&gt; e.ExitApplication());</pre>
                                  
                                  <p>
                                    <!--CRLF-->
                                  </p>
                                  
                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum15">  15:</span>         }</pre>
                                  
                                  <p>
                                    <!--CRLF-->
                                  </p>
                                  
                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum16">  16:</span>     }</pre>
                                  
                                  <p>
                                    <!--CRLF-->
                                  </p>
                                  
                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum17">  17:</span> }</pre>
                                  
                                  <p>
                                    <!--CRLF--></div> </div> 
                                    
                                    <p>
                                      <em>For those of you unfamiliar with the tools used in this test, I’m using </em><a href="http://code.google.com/p/moq" target="_blank"><em>Moq</em></a><em> as my mocking framework and </em><a href="http://xunit.codeplex.com" target="_blank"><em>xUnit</em></a><em> for my tests. These are my two favorite tools for TDD as of now, and I highly recommend both of them.</em>
                                    </p>
                                    
                                    <p>
                                      Beginning on line 7, defines the behavior of the system when my ApplicationExitCommand.Execute method is called. I’m defining the interface that the command is going to talk to, IApplicationExitAdapter, and I’m doing this in total and complete ignorance of what class is ever going to implement that interface (OK, I’m lying – its going to be my view model, but let’s keep that our secret for now).
                                    </p>
                                    
                                    <p>
                                      And the code that we write to get this test to compile:
                                    </p>
                                    
                                    <div style="border-bottom: silver 1px solid; text-align: left; border-left: silver 1px solid; padding-bottom: 4px; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; padding-left: 4px; width: 97.5%; padding-right: 4px; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; border-top: silver 1px solid; cursor: text; border-right: silver 1px solid; padding-top: 4px" id="codeSnippetWrapper">
                                      <div style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px" id="codeSnippet">
                                        <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum1">   1:</span> <span style="color: #0000ff">namespace</span> ViewModels</pre>
                                        
                                        <p>
                                          <!--CRLF-->
                                        </p>
                                        
                                        <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum2">   2:</span> {</pre>
                                        
                                        <p>
                                          <!--CRLF-->
                                        </p>
                                        
                                        <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum3">   3:</span>     <span style="color: #0000ff">public</span> <span style="color: #0000ff">interface</span> IApplicationExitAdapter</pre>
                                        
                                        <p>
                                          <!--CRLF-->
                                        </p>
                                        
                                        <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum4">   4:</span>     {</pre>
                                        
                                        <p>
                                          <!--CRLF-->
                                        </p>
                                        
                                        <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum5">   5:</span>         <span style="color: #0000ff">void</span> ExitApplication();</pre>
                                        
                                        <p>
                                          <!--CRLF-->
                                        </p>
                                        
                                        <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum6">   6:</span>     }</pre>
                                        
                                        <p>
                                          <!--CRLF-->
                                        </p>
                                        
                                        <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum7">   7:</span> }</pre>
                                        
                                        <p>
                                          <!--CRLF--></div> </div> 
                                          
                                          <div style="border-bottom: silver 1px solid; text-align: left; border-left: silver 1px solid; padding-bottom: 4px; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; padding-left: 4px; width: 97.5%; padding-right: 4px; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; border-top: silver 1px solid; cursor: text; border-right: silver 1px solid; padding-top: 4px" id="codeSnippetWrapper">
                                            <div style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px" id="codeSnippet">
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum1">   1:</span> <span style="color: #0000ff">namespace</span> ViewModels</pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum2">   2:</span> {</pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum3">   3:</span>     <span style="color: #0000ff">public</span> <span style="color: #0000ff">class</span> ApplicationExitCommand : ICommand</pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum4">   4:</span>     {</pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum5">   5:</span>         <span style="color: #0000ff">public</span> ApplicationExitCommand(IApplicationExitAdapter exitAdapter)</pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum6">   6:</span>         {</pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum7">   7:</span>             <span style="color: #0000ff">throw</span> <span style="color: #0000ff">new</span> NotImplementedException();</pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum8">   8:</span>         }</pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum9">   9:</span>&nbsp; </pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum10">  10:</span>         <span style="color: #0000ff">public</span> <span style="color: #0000ff">void</span> Execute(<span style="color: #0000ff">object</span> o)</pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum11">  11:</span>         {</pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum12">  12:</span>             <span style="color: #0000ff">throw</span> <span style="color: #0000ff">new</span> NotImplementedException();</pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum13">  13:</span>         }</pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum14">  14:</span>&nbsp; </pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum15">  15:</span>         <span style="color: #0000ff">public</span> <span style="color: #0000ff">bool</span> CanExecute(<span style="color: #0000ff">object</span> parameter)</pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum16">  16:</span>         {</pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum17">  17:</span>             <span style="color: #0000ff">throw</span> <span style="color: #0000ff">new</span> NotImplementedException();</pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum18">  18:</span>         }</pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum19">  19:</span>&nbsp; </pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum20">  20:</span>         <span style="color: #0000ff">public</span> <span style="color: #0000ff">event</span> EventHandler CanExecuteChanged;</pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum21">  21:</span>     }</pre>
                                              
                                              <p>
                                                <!--CRLF-->
                                              </p>
                                              
                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum22">  22:</span> }</pre>
                                              
                                              <p>
                                                <!--CRLF--></div> </div> 
                                                
                                                <p>
                                                  Strictly speaking, I went a little further than I had to here, choosing to implement ICommand, but all commands that are hooked through a View as we’re discussing need to implement this interface (or one of a couple of others that are more advanced), so I just went ahead and did it.
                                                </p>
                                                
                                                <p>
                                                  <strong><em>Short Aside – Projects and Solution Structure</em></strong>
                                                </p>
                                                
                                                <p>
                                                  <em>Before we go further, we should discuss the projects I’ve chosen to use in this solution, and why they were chosen. I have one project that holds the view and a separate project that holds the view models. I intentionally kept the Views and ViewModels separate to enforce the direction of the relationship between them. The Application class and the other WPF controls need to have access to the ViewModels, if only to create them and assign them to DataContexts. ViewModels, however, should be 100% ignorant of their views. The simplest way to enforce this constraint is to put all view model code into another assembly, which is what I’ve done.</em>
                                                </p>
                                                
                                                <p>
                                                  Now its a simple matter of implementing the code to make the test pass:
                                                </p>
                                                
                                                <div style="border-bottom: silver 1px solid; text-align: left; border-left: silver 1px solid; padding-bottom: 4px; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; padding-left: 4px; width: 97.5%; padding-right: 4px; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; border-top: silver 1px solid; cursor: text; border-right: silver 1px solid; padding-top: 4px" id="codeSnippetWrapper">
                                                  <div style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px" id="codeSnippet">
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum1">   1:</span> <span style="color: #0000ff">public</span> <span style="color: #0000ff">class</span> ApplicationExitCommand : ICommand</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum2">   2:</span> {</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum3">   3:</span>     <span style="color: #0000ff">private</span> <span style="color: #0000ff">readonly</span> IApplicationExitAdapter exitAdapter;</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum4">   4:</span>&nbsp; </pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum5">   5:</span>     <span style="color: #0000ff">public</span> ApplicationExitCommand(IApplicationExitAdapter exitAdapter)</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum6">   6:</span>     {</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum7">   7:</span>         <span style="color: #0000ff">this</span>.exitAdapter = exitAdapter;</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum8">   8:</span>     }</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum9">   9:</span>&nbsp; </pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum10">  10:</span>     <span style="color: #0000ff">public</span> <span style="color: #0000ff">void</span> Execute(<span style="color: #0000ff">object</span> o)</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum11">  11:</span>     {</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum12">  12:</span>         exitAdapter.ExitApplication();</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum13">  13:</span>     }</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum14">  14:</span>&nbsp; </pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum15">  15:</span>     <span style="color: #0000ff">public</span> <span style="color: #0000ff">bool</span> CanExecute(<span style="color: #0000ff">object</span> parameter)</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum16">  16:</span>     {</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum17">  17:</span>         <span style="color: #0000ff">return</span> <span style="color: #0000ff">true</span>;</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum18">  18:</span>     }</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum19">  19:</span>&nbsp; </pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum20">  20:</span>     <span style="color: #0000ff">public</span> <span style="color: #0000ff">event</span> EventHandler CanExecuteChanged</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum21">  21:</span>     {</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum22">  22:</span>         add { CommandManager.RequerySuggested += <span style="color: #0000ff">value</span>; }</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum23">  23:</span>         remove { CommandManager.RequerySuggested -= <span style="color: #0000ff">value</span>; }</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum24">  24:</span>     }</pre>
                                                    
                                                    <p>
                                                      <!--CRLF-->
                                                    </p>
                                                    
                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum25">  25:</span> }</pre>
                                                    
                                                    <p>
                                                      <!--CRLF--></div> </div> 
                                                      
                                                      <p>
                                                        I also went ahead and added some boilerplate code into the CanExecute and CanExecuteChanged method and event inside this class. This boilerplate code is what you start with every time you write a command. You can think of this as creating a command using a code template inside Visual Studio.
                                                      </p>
                                                      
                                                      <p>
                                                        At this point, the command should be invoking the behavior that we want, as seen in this diagram:
                                                      </p>
                                                      
                                                      <p>
                                                        <a href="http://www.agilestl.com/BlogImages/TestDrivingaWPFapplicationusingMVVMandTD_5BD2/ApplicationExitCommandSequenceDiagram.png"><img style="border-bottom: 0px; border-left: 0px; display: inline; border-top: 0px; border-right: 0px" title="ApplicationExitCommandSequenceDiagram" border="0" alt="ApplicationExitCommandSequenceDiagram" src="http://www.agilestl.com/BlogImages/TestDrivingaWPFapplicationusingMVVMandTD_5BD2/ApplicationExitCommandSequenceDiagram_thumb.png" width="509" height="140" /></a>
                                                      </p>
                                                      
                                                      <p>
                                                        Now that the behavior is being called inside the IApplicationExitAdapter, we’ll need to make the giant leap and assume that it is, indeed, our view model class that is going to be implementing that interface. This only make sense, since the Command is invoking behavior on some class that represents the behavior of the View, and the class that represents a View’s behavior is that View’s ViewModel. Q.E.D. Once we’ve crossed that intellectual chasm, we’ll go ahead and implement the functionality inside the view model.
                                                      </p>
                                                      
                                                      <p>
                                                        For that, we write this test:
                                                      </p>
                                                      
                                                      <div style="border-bottom: silver 1px solid; text-align: left; border-left: silver 1px solid; padding-bottom: 4px; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; padding-left: 4px; width: 97.5%; padding-right: 4px; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; border-top: silver 1px solid; cursor: text; border-right: silver 1px solid; padding-top: 4px" id="codeSnippetWrapper">
                                                        <div style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px" id="codeSnippet">
                                                          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum1">   1:</span> [Fact] </pre>
                                                          
                                                          <p>
                                                            <!--CRLF-->
                                                          </p>
                                                          
                                                          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum2">   2:</span> <span style="color: #0000ff">public</span> <span style="color: #0000ff">void</span> ApplicationControllerInvokedWhenViewModelExitApplicationCalled()</pre>
                                                          
                                                          <p>
                                                            <!--CRLF-->
                                                          </p>
                                                          
                                                          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum3">   3:</span> {</pre>
                                                          
                                                          <p>
                                                            <!--CRLF-->
                                                          </p>
                                                          
                                                          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum4">   4:</span>     var applicationController = <span style="color: #0000ff">new</span> Mock&lt;IApplicationController&gt;();</pre>
                                                          
                                                          <p>
                                                            <!--CRLF-->
                                                          </p>
                                                          
                                                          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum5">   5:</span>     TeamStatControlViewModel viewModel = <span style="color: #0000ff">new</span> TeamStatControlViewModel(applicationController.Object);</pre>
                                                          
                                                          <p>
                                                            <!--CRLF-->
                                                          </p>
                                                          
                                                          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum6">   6:</span>     applicationController.Setup(ac =&gt; ac.ExitApplication()).Verifiable();</pre>
                                                          
                                                          <p>
                                                            <!--CRLF-->
                                                          </p>
                                                          
                                                          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum7">   7:</span>&nbsp; </pre>
                                                          
                                                          <p>
                                                            <!--CRLF-->
                                                          </p>
                                                          
                                                          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum8">   8:</span>     viewModel.ExitApplication();</pre>
                                                          
                                                          <p>
                                                            <!--CRLF-->
                                                          </p>
                                                          
                                                          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum9">   9:</span>&nbsp; </pre>
                                                          
                                                          <p>
                                                            <!--CRLF-->
                                                          </p>
                                                          
                                                          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum10">  10:</span>     applicationController.Verify(ac =&gt; ac.ExitApplication());</pre>
                                                          
                                                          <p>
                                                            <!--CRLF-->
                                                          </p>
                                                          
                                                          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum11">  11:</span> }</pre>
                                                          
                                                          <p>
                                                            <!--CRLF--></div> </div> 
                                                            
                                                            <p>
                                                              This test causes us to make a few design decisions. First, we’ve discovered an interface called IApplicationController that is going to be responsible for controlling application-wide behavior, which would certainly include things like exiting at the appropriate time. We’re also creating the view model class, TeamStatControlViewModel, since we have to add behavior directly to it now. And finally, we’ve discovered that the view model needs to have a reference to the IApplicationController interface, to allow it to invoke functionality through that interfacee. This leads us to creating a constructor for the view model through which we can inject the interface at creation.
                                                            </p>
                                                            
                                                            <p>
                                                              Here is the resulting code. First, the simple IApplicationController interface:
                                                            </p>
                                                            
                                                            <div style="border-bottom: silver 1px solid; text-align: left; border-left: silver 1px solid; padding-bottom: 4px; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; padding-left: 4px; width: 97.5%; padding-right: 4px; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; border-top: silver 1px solid; cursor: text; border-right: silver 1px solid; padding-top: 4px" id="codeSnippetWrapper">
                                                              <div style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px" id="codeSnippet">
                                                                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum1">   1:</span> <span style="color: #0000ff">namespace</span> ViewModels</pre>
                                                                
                                                                <p>
                                                                  <!--CRLF-->
                                                                </p>
                                                                
                                                                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum2">   2:</span> {</pre>
                                                                
                                                                <p>
                                                                  <!--CRLF-->
                                                                </p>
                                                                
                                                                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum3">   3:</span>     <span style="color: #0000ff">public</span> <span style="color: #0000ff">interface</span> IApplicationController</pre>
                                                                
                                                                <p>
                                                                  <!--CRLF-->
                                                                </p>
                                                                
                                                                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum4">   4:</span>     {</pre>
                                                                
                                                                <p>
                                                                  <!--CRLF-->
                                                                </p>
                                                                
                                                                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum5">   5:</span>         <span style="color: #0000ff">void</span> ExitApplication();</pre>
                                                                
                                                                <p>
                                                                  <!--CRLF-->
                                                                </p>
                                                                
                                                                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum6">   6:</span>     }</pre>
                                                                
                                                                <p>
                                                                  <!--CRLF-->
                                                                </p>
                                                                
                                                                <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum7">   7:</span> }</pre>
                                                                
                                                                <p>
                                                                  <!--CRLF--></div> </div> 
                                                                  
                                                                  <p>
                                                                    and now the TeamStatControlViewModel:
                                                                  </p>
                                                                  
                                                                  <div style="border-bottom: silver 1px solid; text-align: left; border-left: silver 1px solid; padding-bottom: 4px; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; padding-left: 4px; width: 97.5%; padding-right: 4px; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; border-top: silver 1px solid; cursor: text; border-right: silver 1px solid; padding-top: 4px" id="codeSnippetWrapper">
                                                                    <div style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px" id="codeSnippet">
                                                                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum1">   1:</span> <span style="color: #0000ff">namespace</span> ViewModels</pre>
                                                                      
                                                                      <p>
                                                                        <!--CRLF-->
                                                                      </p>
                                                                      
                                                                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum2">   2:</span> {</pre>
                                                                      
                                                                      <p>
                                                                        <!--CRLF-->
                                                                      </p>
                                                                      
                                                                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum3">   3:</span>     <span style="color: #0000ff">public</span> <span style="color: #0000ff">class</span> TeamStatControlViewModel : IApplicationExitAdapter</pre>
                                                                      
                                                                      <p>
                                                                        <!--CRLF-->
                                                                      </p>
                                                                      
                                                                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum4">   4:</span>     {</pre>
                                                                      
                                                                      <p>
                                                                        <!--CRLF-->
                                                                      </p>
                                                                      
                                                                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum5">   5:</span>         <span style="color: #0000ff">private</span> <span style="color: #0000ff">readonly</span> IApplicationController applicationController;</pre>
                                                                      
                                                                      <p>
                                                                        <!--CRLF-->
                                                                      </p>
                                                                      
                                                                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum6">   6:</span>&nbsp; </pre>
                                                                      
                                                                      <p>
                                                                        <!--CRLF-->
                                                                      </p>
                                                                      
                                                                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum7">   7:</span>         <span style="color: #0000ff">public</span> TeamStatControlViewModel(IApplicationController applicationController)</pre>
                                                                      
                                                                      <p>
                                                                        <!--CRLF-->
                                                                      </p>
                                                                      
                                                                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum8">   8:</span>         {</pre>
                                                                      
                                                                      <p>
                                                                        <!--CRLF-->
                                                                      </p>
                                                                      
                                                                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum9">   9:</span>             <span style="color: #0000ff">this</span>.applicationController = applicationController;</pre>
                                                                      
                                                                      <p>
                                                                        <!--CRLF-->
                                                                      </p>
                                                                      
                                                                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum10">  10:</span>         }</pre>
                                                                      
                                                                      <p>
                                                                        <!--CRLF-->
                                                                      </p>
                                                                      
                                                                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum11">  11:</span>&nbsp; </pre>
                                                                      
                                                                      <p>
                                                                        <!--CRLF-->
                                                                      </p>
                                                                      
                                                                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum12">  12:</span>         <span style="color: #0000ff">public</span> <span style="color: #0000ff">void</span> ExitApplication()</pre>
                                                                      
                                                                      <p>
                                                                        <!--CRLF-->
                                                                      </p>
                                                                      
                                                                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum13">  13:</span>         {</pre>
                                                                      
                                                                      <p>
                                                                        <!--CRLF-->
                                                                      </p>
                                                                      
                                                                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum14">  14:</span>             applicationController.ExitApplication();</pre>
                                                                      
                                                                      <p>
                                                                        <!--CRLF-->
                                                                      </p>
                                                                      
                                                                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum15">  15:</span>         }</pre>
                                                                      
                                                                      <p>
                                                                        <!--CRLF-->
                                                                      </p>
                                                                      
                                                                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum16">  16:</span>     }</pre>
                                                                      
                                                                      <p>
                                                                        <!--CRLF-->
                                                                      </p>
                                                                      
                                                                      <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum17">  17:</span> }</pre>
                                                                      
                                                                      <p>
                                                                        <!--CRLF--></div> </div> 
                                                                        
                                                                        <p>
                                                                          That’s just enough code to make that test pass, so we’re momentarily happy. However, our <em>system</em> isn’t going to work yet, because we haven’t found anyone to implement the IApplicationController interface. That’s our next major decision.
                                                                        </p>
                                                                        
                                                                        <p>
                                                                          <a href="http://www.agilestl.com/BlogImages/TestDrivingaWPFapplicationusingMVVMandTD_5BD2/ClassDiagramExceptForFinalClass.png"><img style="border-bottom: 0px; border-left: 0px; display: inline; border-top: 0px; border-right: 0px" title="ClassDiagramExceptForFinalClass" border="0" alt="ClassDiagramExceptForFinalClass" src="http://www.agilestl.com/BlogImages/TestDrivingaWPFapplicationusingMVVMandTD_5BD2/ClassDiagramExceptForFinalClass_thumb.png" width="550" height="181" /></a>
                                                                        </p>
                                                                        
                                                                        <p>
                                                                          I’m going to choose to put this interface onto the App class, at least for now, since it seems to be the one place in our application that has knowledge of the entire application. It may turn out later that we need to move this responsibility somewhere else, but we’ll leave it here for now.
                                                                        </p>
                                                                        
                                                                        <p>
                                                                          We’ll go ahead and make the easy changes to App.xaml.cs, which consist of making it implement IApplicationController and writing the ExitApplication method, which simply calls Current.Shutdown().
                                                                        </p>
                                                                        
                                                                        <div style="border-bottom: silver 1px solid; text-align: left; border-left: silver 1px solid; padding-bottom: 4px; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; padding-left: 4px; width: 97.5%; padding-right: 4px; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; border-top: silver 1px solid; cursor: text; border-right: silver 1px solid; padding-top: 4px" id="codeSnippetWrapper">
                                                                          <div style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px" id="codeSnippet">
                                                                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum1">   1:</span> <span style="color: #0000ff">public</span> <span style="color: #0000ff">partial</span> <span style="color: #0000ff">class</span> App : Application, IApplicationController</pre>
                                                                            
                                                                            <p>
                                                                              <!--CRLF-->
                                                                            </p>
                                                                            
                                                                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum2">   2:</span> {</pre>
                                                                            
                                                                            <p>
                                                                              <!--CRLF-->
                                                                            </p>
                                                                            
                                                                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum3">   3:</span>     <span style="color: #0000ff">private</span> <span style="color: #0000ff">readonly</span> IUnityContainer container = <span style="color: #0000ff">new</span> UnityContainer();</pre>
                                                                            
                                                                            <p>
                                                                              <!--CRLF-->
                                                                            </p>
                                                                            
                                                                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum4">   4:</span>&nbsp; </pre>
                                                                            
                                                                            <p>
                                                                              <!--CRLF-->
                                                                            </p>
                                                                            
                                                                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum5">   5:</span>     <span style="color: #0000ff">private</span> <span style="color: #0000ff">void</span> Application_Startup(<span style="color: #0000ff">object</span> sender, StartupEventArgs e) {...}</pre>
                                                                            
                                                                            <p>
                                                                              <!--CRLF-->
                                                                            </p>
                                                                            
                                                                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum6">   6:</span>  </pre>
                                                                            
                                                                            <p>
                                                                              <!--CRLF-->
                                                                            </p>
                                                                            
                                                                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum7">   7:</span>     <span style="color: #0000ff">public</span> <span style="color: #0000ff">void</span> ExitApplication()</pre>
                                                                            
                                                                            <p>
                                                                              <!--CRLF-->
                                                                            </p>
                                                                            
                                                                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum8">   8:</span>     {</pre>
                                                                            
                                                                            <p>
                                                                              <!--CRLF-->
                                                                            </p>
                                                                            
                                                                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum9">   9:</span>         Current.Shutdown();</pre>
                                                                            
                                                                            <p>
                                                                              <!--CRLF-->
                                                                            </p>
                                                                            
                                                                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum10">  10:</span>     }</pre>
                                                                            
                                                                            <p>
                                                                              <!--CRLF-->
                                                                            </p>
                                                                            
                                                                            <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum11">  11:</span> }</pre>
                                                                            
                                                                            <p>
                                                                              <!--CRLF--></div> </div> 
                                                                              
                                                                              <p>
                                                                                The important point to note is that the IApplicationController interface lives in the ViewModel assembly, even though it is being implemented by the App class in the main WPF assembly. This means that the main WPF application project has to have a reference to the ViewModel project, which is the direction we want the dependencies to flow. By moving the ViewModel classes and interfaces into an a project separate from the view classes, we’re enforcing our dependency management design as we described earlier.
                                                                              </p>
                                                                              
                                                                              <p>
                                                                                This now leaves us with this for a design:
                                                                              </p>
                                                                              
                                                                              <p>
                                                                                <a href="http://www.agilestl.com/BlogImages/TestDrivingaWPFapplicationusingMVVMandTD_5BD2/ClassDiagramFinal.png"><img style="border-bottom: 0px; border-left: 0px; display: inline; border-top: 0px; border-right: 0px" title="ClassDiagramFinal" border="0" alt="ClassDiagramFinal" src="http://www.agilestl.com/BlogImages/TestDrivingaWPFapplicationusingMVVMandTD_5BD2/ClassDiagramFinal_thumb.png" width="532" height="175" /></a>
                                                                              </p>
                                                                              
                                                                              <p>
                                                                                So we’re in the home stretch now. We have all our code built – what is lacking now are the few scattered bits and pieces needed to wire this whole thing together. There are several of these pieces, and we’ll look at them one at a time.
                                                                              </p>
                                                                              
                                                                              <p>
                                                                                Let’s start with the object creation changes needed in App.Application_Startup. Over these last few changes, we’ve created a new interface for the App class, so we need to tell Unity that when I ask for an instance of an IApplicationController, it should pass back a reference to the App class. You can see this code on line 3 below. We also created a TeamStatControlViewModel, which we tell Unity about on line 5.
                                                                              </p>
                                                                              
                                                                              <div style="border-bottom: silver 1px solid; text-align: left; border-left: silver 1px solid; padding-bottom: 4px; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; padding-left: 4px; width: 97.5%; padding-right: 4px; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; border-top: silver 1px solid; cursor: text; border-right: silver 1px solid; padding-top: 4px" id="codeSnippetWrapper">
                                                                                <div style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px" id="codeSnippet">
                                                                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum1">   1:</span> <span style="color: #0000ff">private</span> <span style="color: #0000ff">void</span> Application_Startup(<span style="color: #0000ff">object</span> sender, StartupEventArgs e)</pre>
                                                                                  
                                                                                  <p>
                                                                                    <!--CRLF-->
                                                                                  </p>
                                                                                  
                                                                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum2">   2:</span> {</pre>
                                                                                  
                                                                                  <p>
                                                                                    <!--CRLF-->
                                                                                  </p>
                                                                                  
                                                                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum3">   3:</span>     container.RegisterInstance&lt;IApplicationController&gt;(<span style="color: #0000ff">this</span>);</pre>
                                                                                  
                                                                                  <p>
                                                                                    <!--CRLF-->
                                                                                  </p>
                                                                                  
                                                                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum4">   4:</span>&nbsp; </pre>
                                                                                  
                                                                                  <p>
                                                                                    <!--CRLF-->
                                                                                  </p>
                                                                                  
                                                                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum5">   5:</span>     container.RegisterType&lt;TeamStatControlViewModel&gt;(<span style="color: #0000ff">new</span> ContainerControlledLifetimeManager());</pre>
                                                                                  
                                                                                  <p>
                                                                                    <!--CRLF-->
                                                                                  </p>
                                                                                  
                                                                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum6">   6:</span>     container.RegisterType&lt;TeamStatControl&gt;(<span style="color: #0000ff">new</span> ContainerControlledLifetimeManager());</pre>
                                                                                  
                                                                                  <p>
                                                                                    <!--CRLF-->
                                                                                  </p>
                                                                                  
                                                                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum7">   7:</span>&nbsp; </pre>
                                                                                  
                                                                                  <p>
                                                                                    <!--CRLF-->
                                                                                  </p>
                                                                                  
                                                                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum8">   8:</span>     container.RegisterType&lt;MainWindow&gt;(<span style="color: #0000ff">new</span> ContainerControlledLifetimeManager());</pre>
                                                                                  
                                                                                  <p>
                                                                                    <!--CRLF-->
                                                                                  </p>
                                                                                  
                                                                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum9">   9:</span>     </pre>
                                                                                  
                                                                                  <p>
                                                                                    <!--CRLF-->
                                                                                  </p>
                                                                                  
                                                                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum10">  10:</span>     Current.MainWindow = container.Resolve&lt;MainWindow&gt;();</pre>
                                                                                  
                                                                                  <p>
                                                                                    <!--CRLF-->
                                                                                  </p>
                                                                                  
                                                                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum11">  11:</span>     Current.MainWindow.Content = container.Resolve&lt;TeamStatControl&gt;();</pre>
                                                                                  
                                                                                  <p>
                                                                                    <!--CRLF-->
                                                                                  </p>
                                                                                  
                                                                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum12">  12:</span>     Current.MainWindow.Show();</pre>
                                                                                  
                                                                                  <p>
                                                                                    <!--CRLF-->
                                                                                  </p>
                                                                                  
                                                                                  <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum13">  13:</span> }</pre>
                                                                                  
                                                                                  <p>
                                                                                    <!--CRLF--></div> </div> 
                                                                                    
                                                                                    <p>
                                                                                      Next, we know that TeamStatControlViewModel is going to be the DataContext for the TeamStatViewModel, so let’s make that happen in code. The easiest way is to change the constructor for the TeamStatControl to take the view model and assign it to be its DataContext in its constructor. The really cool part of this is that we don’t have to make any changes in App.ApplicationStartup based on this constructor changing. Unity will just build all the dependent objects for us and call whatever constructors it can find, and it all just works.
                                                                                    </p>
                                                                                    
                                                                                    <div style="border-bottom: silver 1px solid; text-align: left; border-left: silver 1px solid; padding-bottom: 4px; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; padding-left: 4px; width: 97.5%; padding-right: 4px; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; border-top: silver 1px solid; cursor: text; border-right: silver 1px solid; padding-top: 4px" id="codeSnippetWrapper">
                                                                                      <div style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px" id="codeSnippet">
                                                                                        <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum1">   1:</span> <span style="color: #0000ff">public</span> TeamStatControl(TeamStatControlViewModel viewModel)</pre>
                                                                                        
                                                                                        <p>
                                                                                          <!--CRLF-->
                                                                                        </p>
                                                                                        
                                                                                        <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum2">   2:</span> {</pre>
                                                                                        
                                                                                        <p>
                                                                                          <!--CRLF-->
                                                                                        </p>
                                                                                        
                                                                                        <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum3">   3:</span>     DataContext = viewModel;</pre>
                                                                                        
                                                                                        <p>
                                                                                          <!--CRLF-->
                                                                                        </p>
                                                                                        
                                                                                        <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum4">   4:</span>     InitializeComponent();</pre>
                                                                                        
                                                                                        <p>
                                                                                          <!--CRLF-->
                                                                                        </p>
                                                                                        
                                                                                        <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum5">   5:</span> }</pre>
                                                                                        
                                                                                        <p>
                                                                                          <!--CRLF--></div> </div> 
                                                                                          
                                                                                          <p>
                                                                                            Now that we have the objects built and wired up, we need to do the data binding to put the commands into the controls on the interface. The first place to do this is in TeamStatControl, where we define the Quit button. We need to assign an instance of the ApplicationExitCommand to the Command attribute of the button. Here is the XAML code that will do this for the Quit button:
                                                                                          </p>
                                                                                          
                                                                                          <div style="border-bottom: silver 1px solid; text-align: left; border-left: silver 1px solid; padding-bottom: 4px; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; padding-left: 4px; width: 97.5%; padding-right: 4px; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; border-top: silver 1px solid; cursor: text; border-right: silver 1px solid; padding-top: 4px" id="codeSnippetWrapper">
                                                                                            <div style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px" id="codeSnippet">
                                                                                              <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum1">   1:</span> <span style="color: #0000ff">&lt;</span><span style="color: #800000">Button</span> <span style="color: #ff0000">Command</span><span style="color: #0000ff">="{Binding ApplicationExit}"</span> <span style="color: #ff0000">Grid</span>.<span style="color: #ff0000">Column</span><span style="color: #0000ff">="1"</span> <span style="color: #ff0000">Content</span><span style="color: #0000ff">="Quit"</span> <span style="color: #ff0000">HorizontalAlignment</span><span style="color: #0000ff">="Left"</span> <span style="color: #ff0000">Style</span><span style="color: #0000ff">="{StaticResource NormalButton}"</span><span style="color: #0000ff">/&gt;</span></pre>
                                                                                              
                                                                                              <p>
                                                                                                <!--CRLF--></div> </div> 
                                                                                                
                                                                                                <p>
                                                                                                  We do this by creating a binding to the ApplicationExit property of our data context, the TeamStatControlViewModel. The view is now expecting the view model to expose a property called ApplicationExit, of type ICommand, through which it can get the command. We don’t have that property right now, so lets write a test that makes us create it.
                                                                                                </p>
                                                                                                
                                                                                                <div style="border-bottom: silver 1px solid; text-align: left; border-left: silver 1px solid; padding-bottom: 4px; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; padding-left: 4px; width: 97.5%; padding-right: 4px; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; border-top: silver 1px solid; cursor: text; border-right: silver 1px solid; padding-top: 4px" id="codeSnippetWrapper">
                                                                                                  <div style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px" id="codeSnippet">
                                                                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum1">   1:</span> [Fact]</pre>
                                                                                                    
                                                                                                    <p>
                                                                                                      <!--CRLF-->
                                                                                                    </p>
                                                                                                    
                                                                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum2">   2:</span> <span style="color: #0000ff">public</span> <span style="color: #0000ff">void</span> ViewModelExposesApplicationExitCommandAsICommand()</pre>
                                                                                                    
                                                                                                    <p>
                                                                                                      <!--CRLF-->
                                                                                                    </p>
                                                                                                    
                                                                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum3">   3:</span> {</pre>
                                                                                                    
                                                                                                    <p>
                                                                                                      <!--CRLF-->
                                                                                                    </p>
                                                                                                    
                                                                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum4">   4:</span>     TeamStatControlViewModel viewModel = <span style="color: #0000ff">new</span> TeamStatControlViewModel(<span style="color: #0000ff">null</span>);</pre>
                                                                                                    
                                                                                                    <p>
                                                                                                      <!--CRLF-->
                                                                                                    </p>
                                                                                                    
                                                                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum5">   5:</span>&nbsp; </pre>
                                                                                                    
                                                                                                    <p>
                                                                                                      <!--CRLF-->
                                                                                                    </p>
                                                                                                    
                                                                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum6">   6:</span>     Assert.IsAssignableFrom&lt;ApplicationExitCommand&gt;(viewModel.ApplicationExit);</pre>
                                                                                                    
                                                                                                    <p>
                                                                                                      <!--CRLF-->
                                                                                                    </p>
                                                                                                    
                                                                                                    <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum7">   7:</span> }</pre>
                                                                                                    
                                                                                                    <p>
                                                                                                      <!--CRLF--></div> </div> 
                                                                                                      
                                                                                                      <p>
                                                                                                        This test says that we can get an ICommand from the view model and the ICommand we get is actually an ApplicationExitCommand, which is what we need. We just need to implement that through creating a simple auto-property in the view model. That satisfies what we need for the binding we defined in the XAML. Now, we construct the command in the constructor of the TeamStatControlViewModel class and pass an instance of the view model to the constructor of its command to wire that up, and we’re set!
                                                                                                      </p>
                                                                                                      
                                                                                                      <div style="border-bottom: silver 1px solid; text-align: left; border-left: silver 1px solid; padding-bottom: 4px; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; padding-left: 4px; width: 97.5%; padding-right: 4px; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; border-top: silver 1px solid; cursor: text; border-right: silver 1px solid; padding-top: 4px" id="codeSnippetWrapper">
                                                                                                        <div style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px" id="codeSnippet">
                                                                                                          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum1">   1:</span> <span style="color: #0000ff">public</span> TeamStatControlViewModel(IApplicationController applicationController)</pre>
                                                                                                          
                                                                                                          <p>
                                                                                                            <!--CRLF-->
                                                                                                          </p>
                                                                                                          
                                                                                                          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum2">   2:</span> {</pre>
                                                                                                          
                                                                                                          <p>
                                                                                                            <!--CRLF-->
                                                                                                          </p>
                                                                                                          
                                                                                                          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum3">   3:</span>     <span style="color: #0000ff">this</span>.applicationController = applicationController;</pre>
                                                                                                          
                                                                                                          <p>
                                                                                                            <!--CRLF-->
                                                                                                          </p>
                                                                                                          
                                                                                                          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum4">   4:</span>     ApplicationExit = <span style="color: #0000ff">new</span> ApplicationExitCommand(<span style="color: #0000ff">this</span>);</pre>
                                                                                                          
                                                                                                          <p>
                                                                                                            <!--CRLF-->
                                                                                                          </p>
                                                                                                          
                                                                                                          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: white; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum5">   5:</span> }</pre>
                                                                                                          
                                                                                                          <p>
                                                                                                            <!--CRLF-->
                                                                                                          </p>
                                                                                                          
                                                                                                          <pre style="border-bottom-style: none; text-align: left; padding-bottom: 0px; line-height: 12pt; border-right-style: none; background-color: #f4f4f4; margin: 0em; padding-left: 0px; width: 100%; padding-right: 0px; font-family: 'Courier New', courier, monospace; direction: ltr; border-top-style: none; color: black; font-size: 8pt; border-left-style: none; overflow: visible; padding-top: 0px"><span style="color: #606060" id="lnum6">   6:</span>&nbsp; </pre>
                                                                                                          
                                                                                                          <p>
                                                                                                            <!--CRLF--></div> </div> 
                                                                                                            
                                                                                                            <p>
                                                                                                              After all this, running the application and clicking the Quit button should cause the app to vanish silently, slipping into the night, never to be seen again. <em>Whew!</em>
                                                                                                            </p>
                                                                                                            
                                                                                                            <p>
                                                                                                              <strong>A Bonus</strong>
                                                                                                            </p>
                                                                                                            
                                                                                                            <p>
                                                                                                              Now that all this hard work is done, we can also&nbsp; hook this same logic to the menu button. If we go into the XAML and find the line where we define the menu item, we just set its Command attribute to be a binding to ApplicationExit as well, and now it works, too.
                                                                                                            </p>
                                                                                                            
                                                                                                            <p>
                                                                                                              <strong>Conclusion</strong>
                                                                                                            </p>
                                                                                                            
                                                                                                            <p>
                                                                                                              As I said at the beginning, this blog entry, and the couple more that will follow this week, will form the basis for my St. Louis Day of Dot Net talk on this same subject. I’d appreciate any and all feedback on this article, especially including things that weren’t clear, design&nbsp; leaps I made without a clear reason, and alternative ways to do the same things I did.
                                                                                                            </p>
                                                                                                            
                                                                                                            <p>
                                                                                                              You can find the <a href="http://www.agilestl.com/downloads/TestDrivingWPFWithMVVMSampleCode.zip" target="_blank">complete project</a> for this on my website. You may need to install <a href="http://unity.codeplex.com" target="_blank">Unity</a> to get the solution to compile.
                                                                                                            </p>
                                                                                                            
                                                                                                            <p>
                                                                                                              Thanks for reading, and I hope it helps!
                                                                                                            </p>
                                                                                                            
                                                                                                            <p>
                                                                                                              &nbsp;
                                                                                                            </p>
                                                                                                            
                                                                                                            <p>
                                                                                                              &#8212; bab
                                                                                                            </p>

 [1]: http://www.stlouisdayofdotnet.com
 [2]: http://asolutions.com
 [3]: http://www.agilestl.com/BlogImages/TestDrivingaWPFapplicationusingMVVMandTD_5BD2/image.png
 [4]: http://www.agilestl.com/BlogImages/TestDrivingaWPFapplicationusingMVVMandTD_5BD2/MVVMArchitecture.png