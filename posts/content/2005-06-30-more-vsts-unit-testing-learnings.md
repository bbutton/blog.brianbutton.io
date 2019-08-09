---
title: More VSTS Unit Testing learnings
author: Brian Button
type: post
date: 2005-06-30T13:37:00+00:00
url: /index.php/2005/06/30/more-vsts-unit-testing-learnings/
sfw_comment_form_password:
  - 6FV3853c2Ot2
sfw_pwd:
  - wSWNZmdBrfud
categories:
  - 112

---
I was having problems getting a very simple test to work this morning using VSTT, and I&nbsp;distilled my problem down to its most&nbsp;simple form:

<pre>using System;
using Microsoft.VisualStudio.QualityTools.UnitTesting.Framework;
using System.IO;

namespace FileCopyingBug
{
    [TestClass]
    public class FileCopyFixture
    {
        [TestMethod]
        public void WillCopyFileWhenRun()
        {
            Assert.IsTrue(File.Exists("TestFile.txt"));
        }
    }
}</pre>

And I created the external TestFile.txt in my project directory and set its properties to have it copied to the output directory always.

Depending on how I chose to run this test, it would either work or fail. If I ran it using the&nbsp;Test View pane in VSTT and I chose &ldquo;Run&rdquo; or &ldquo;Debug&rdquo; the test would fail.&nbsp;If I ran it through TestDriven.Net, it would work if I ran the test, but fail if I debugged the test. And if I translated the test to NUnit, it would work through TestDriven.Net all the time. Very interesting.

It would seem that, according to the Principal of Least Surprise, this test should just work.

But it turns out that VSTT copies your executable and its dependencies to another directory whenever it runs your tests, so just because you made sure some files showed up in your binDebug directory doesn&rsquo;t actually mean that they showed up where your program was being executed from. This seems a bit fishy to me, but at least I know about it now.

**The Fix &mdash; Deployment Items**

Many thanks to Tom Arnold, the PM for the unit testing tools in VSTS,&nbsp;and the people who work with him for giving me the answer to this very quickly. I really do appreciate it!

There is an attribute that you can apply to your TestMethods called the DeploymentItemAttribute. If you apply this attribute and give it the name of the file you want copied, it will make sure that it copies the named file to the _real_ output directory. Once I did this, my test worked just fine.

You can also apply this attribute to your TestClasses, but one web site I saw said that there was a bug in this. If you ran your tests through the IDE, it would not respect this attribute. If you ran them from the command line using MSTest.exe, it would work fine. I did not verify this, so it may apply to an earlier verion, etc.

Finally, you can also make this fix by editing the Run Configuration for your test. If you open the Test menu and choose Edit Test Run Configurations, a dialog box pops up. On this dialog, you can detail which files you would like treated as deployment items. I fixed my problem like this, and once I did, everything worked great.

**Conclusion**

Once again, I really do feel that these tests should just work. The fact that VSTT is doing magic behind the scenes for whatever personal reasons shouldn&rsquo;t matter to me, as that was an implementation decision that they made. Fortunately there is this very simple fix for it, however, and I wanted to write about it so I could remember it a month from now when it bit me again ![][1]

&mdash; bab

&nbsp;

 [1]: http://www.agilestl.com/private/blog/smile1.gif