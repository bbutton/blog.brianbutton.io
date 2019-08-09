---
title: Serendipity
author: Brian Button
type: post
date: 2004-09-22T07:36:00+00:00
url: /index.php/2004/09/22/serendipity/
sfw_comment_form_password:
  - aRZmviPmyYHS
sfw_pwd:
  - SqFeLpqFJFmh
categories:
  - 111
  - 115

---
Sometimes you accomplish nothing but you learn everything. That&#8217;s what happened to me yesterday in the Triangle Lounge. Quick background &#8212; I&#8217;m working on the Enterprise Library project in the Microsoft patterns & practices group. We&#8217;ve been working on consolidating many of the current MS Application Blocks into a single, coherent offering. We all sit in one room, called the Triangle Lounge, including the 3 remaining developers and the 3 testers.

This post centers around our relationship with the testers. They sit in the same room as us, laugh with us, talk with us, but I don&#8217;t feel like they&#8217;re really part of the team. They&#8217;re _the testers_. While we&#8217;re busy developing code and writing tests, they are still manually inspecting and testing everything that we do, clearly apart from our culture. This bothers me at several levels.

First of all, there is this natural tension in our relationship, since they are busy attacking everything that we do. That&#8217;s their job, and they are the best that I&#8217;ve ever met at doing it. But I feel like I&#8217;m on the defensive when I&#8217;m talking to them, justifying my design and code. The words that I most hate hearing are, &#8220;Brian, can I ask you a question?&#8221;, because this always leads to an issue they found in the code, and leads to me feeling defensive. I don&#8217;t like that, and I&#8217;m not sure what to do about it.

Second, I don&#8217;t like that they manually test everything. We spend all this time writing automated tests for our software, and they write small test programs that they drive manually. All of their knowledge about what they&#8217;ve tested and how they&#8217;ve found bugs is wrapped up either in their heads or bug reports, and we can&#8217;t easily get at it or use it. This is how they were trained, and I&#8217;m not seeing any inclination to change. The problem with it is that it makes any changes to the software harder to justify, since there has to be a separate, manual QA pass through the code once we&#8217;re finished. If their tests were automated&#8230; (Side note &#8212; would I feel less defensive about my code if I were presented with an automated test that I could run and inspect, rather than just a bug report? Interesting question)

Third, they write too many bugs. I mean this seriously. I feel that the testing team is an island, cut off from input from our customer, the Product Manager. They write bugs on any issue they see, whether it is major or exceedingly minor, and onus is on someone else to figure out if the bug is worth fixing. I guess this is probably the role of backend QA on a project, and I need to look at how we can improve our process to prevent us from spending time fixing things that don&#8217;t need to be fixed. But that additional step feels aggravating to me. And that&#8217;s where this story begins (finally!)

This post is really about what happens on a team when there are two cultures interacting. I&#8217;m trying really hard to get the developers to walk into our customer&#8217;s office whenever we have a question about how something should work, and get the answer straight from the horse&#8217;s mouth (Sorry, Tom, I&#8217;m not calling you a horse!). After all, he is the guy who understands the context where our product will live, and he is ultimately responsible for its content. And we, as a development team, are doing a really good job of that. To be honest, the job has become easier over time, as the development team makeup has changed, and we&#8217;ve gotten smaller and filled with people who are more devoutly agile. Our team is now three developers, me, [Scott Densmore][1], and [Peter Provost][2]. We just lost [TSHAK][3], who was a bit younger, but easily test-infected and really good. With Scott and Peter left on the team, we&#8217;re definitely feeling pretty agile about ourselves, so we&#8217;re doing a lot better at involving Tom. But the testing team just seems different. They are an island. There have been questions raised before where interaction with our customer would have sped things up tremendously, but I&#8217;ve never seen it happen. The testers log issues in our bug tracking tool, and wait until someone notices them before anyone starts talking. And this is what got me yesterday.

There was a bug logged that in certain, exceptional circumstances would cause an exception to be logged to the event log twice. It would happen exceedingly rarely, there was a pretty easy workaround for it, it was minimally harmful, and it was only found through manually injecting code to cause exceptions into the application code.&nbsp;This was a great catch in finding it, but I&#8217;m not sure if it was handled properly.&nbsp;I hope it doesn&#8217;t seem that I&#8217;m dumping on the testers, because I don&#8217;t want to. The same tester who wrote this bug also helped me tremendously in getting the Caching Application Block tested to the level of quality where it is today &#8212; I respect the work that our testers do tremendously (Prashant, Rohit, and Mani), I just really want to change _how_ they work.

Anyhow, this bug was written, and it was given a severity of 2, which is pretty high. In fact, we&#8217;re not supposed to ship with any Sev 2&#8217;s, so I spent all day yesterday trying to write a test to reproduce it, so I could fix it (Remember, TDD? Write a failing test, then make it pass. Words to live by). The best way that I could figure out to write a test to expose this bug involved creating some CAS-modifying code, so that when the application code tried to access the EventLog, it would fail, and send me down the appropriate error chain to cause the bug. I wrote this test, I was all proud of it, cuz I was being _really_ clever, and then I tried to run it.

_Security Exception at line XXX. Additional information: Request failed._

Well, that was helpful. I spent the next 5 hours trying to figure out why this was happening, asked questions of everyone I could find, had Peter call in favors from guys he knew across the country, and involved the Program Manager who is in charge of CAS for the entire .Net framework _and his test team_. Finally, after hours of struggling, it came out that I was seeing an interaction between strongly named assemblies, explicit CAS Deny requests, and reflection. It turns out that strongly named assemblies have an implicit LinkDemand for FullTrust in front of all their public interfaces. When trying to instantiate a type through reflection from an assembly such as this, the LinkDemand is converted to a regular Demand for FullTrust, which was running into my Deny in my test, which caused the Demand stack walk to fail, and give me that lovely error message. But it took most of the combined resources of Microsoft to figure this out. And the way to solve it was to add [Assembly:AllowPartiallyTrustedCode] to the AssemblyInfo file of any assembly where a type was being created through reflection. Without this attribute, the creation process would always fail unless the calling code had FullTrust.

So, the serendipity in all of this (remember the name of this lengthy article?) was that it raised the issue of how our project would interact with partially trusted code. No one had considered this before, but my day spent doing this raised a number of issues and problems, which I talked with Tom and the test team about, and now we are considering what to do about partially trusted code.

The other part of this, and this is the part that really bothers me, and ties together this whole post, is that I also explained the bug I spent an entire day fixing to Tom, and he was amazed that I had put so much effort into something that was clearly not worth it. He said to resolve it as &#8220;Won&#8217;t fix&#8221;. He had better things for me to do with an entire day&#8217;s worth of work. So I reverted all of my code, closed the bug and moved on.

And why did this bother me? Because, due to a lack of communication on all parts, I wasted a day&#8217;s work. Our bugs go through a triage process, and Tom needs to be involved with that, to make sure that&nbsp;bug prioritization matches his business prioritization. &nbsp;The test team needs a better definition of what they should and should not prioritize as important. And I need to be more cognizant of getting input whenever I have a question about a bug. I can try to affect the first two, but I&#8217;m definitely going to change the last point through my own actions.

I wrote this post because I care about agile development processes, and we clearly were not being agile here. We followed our process to the letter, but it ended up wasting time because we didn&#8217;t interact as people. That, to me, was the most important bug of the day.

Sorry for the rambling.

&#8212; bab

&nbsp;

 [1]: http://weblogs.asp.net/scottdensmore
 [2]: http://peterprovost.org/
 [3]: http://dotnetjunkies.com/weblog/tshak