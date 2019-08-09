---
title: WMI, LUA, and a surprise for me!
author: Brian Button
type: post
date: 2005-06-24T13:40:00+00:00
url: /index.php/2005/06/24/wmi-lua-and-a-surprise-for-me/
sfw_comment_form_password:
  - cG5I6akN4Uir
sfw_pwd:
  - 02Vsd8ubBiWS
categories:
  - 112
  - 115

---
Note to self: WMI and LUA don&rsquo;t play together nicely.

I&rsquo;ve been researching a bug that many of you Enterprise Library users may have encountered. According to our instructions, you have to run installutil against all EL assemblies, to allow them to load up their performance counters, event log sources, and WMI schema. If you do this as an admin, things work beautifully. If you _run_ your EL-based app with less than admin privileges, interesting things happen with WMI, but that has been covered on other blogs.

What I want to cover today is what happens during development when you are creating code that attempts to publish WMI events or data.

**Example Test**

Here is an example test to show what I&rsquo;m talking about. The behavior of this test is different, depending on whether you&rsquo;re running as an admin or not. But the difference it not something that you might intuitively expect to happen.

<pre>[TestClass]
    public class WMIExplorationFixture
    {
        List&lt;mydata> inputData = new List&lt;mydata>();

        [TestCleanup]
        public void RevokeAllInstances()
        {
            foreach (MyData instance in inputData)
            {
                Instrumentation.Revoke(instance);
            }
        }

        [TestMethod]
        public void CanSendSinglePieceOfData()
        {
            MyData myData = Create("foo!!!", 7);
            myData.Published = true;

            int instanceCount = GetInstanceCount();
            List&lt;mydata> results = GetInstances();

            Assert.AreEqual(1, instanceCount);
            Assert.AreEqual&lt;mydata>(myData, results[0]);
        }

        private MyData Create(string myFoo, int myCount)
        {
            MyData instance = new MyData(myFoo, myCount);
            inputData.Add(instance);

            return instance;
        }

        private List&lt;mydata> GetInstances()
        {
            List&lt;mydata> results = new List&lt;mydata>();
            using (ManagementClass wmiClass = new ManagementClass(@"\.rootWMIExploration:MyData"))
            {
                foreach (ManagementObject instance in wmiClass.GetInstances())
                {
                    int count = (int)instance["MyCount"];
                    string value = (string)instance["MyFoo"];

                    results.Add(new MyData(value, count));

                    instance.Dispose();
                }
            }
            return results;
        }

        private int GetInstanceCount()
        {
            int instanceCount = 0;
            using (ManagementClass wmiClass = new ManagementClass(@"\.rootWMIExploration:MyData"))
            {
                instanceCount = wmiClass.GetInstances().Count;
            }
            return instanceCount;
        }
    }
</pre>

And here is the class that represents the WMI schema:

<pre>public class MyData : Instance
    {
        private string myFoo;
        private int myCount;

        public MyData(string myFoo, int myCount)
        {
            this.myFoo = myFoo;
            this.myCount = myCount;
        }

        public string MyFoo { get { return myFoo;  } }
        public int MyCount { get { return myCount; } }

        public override bool Equals(object obj)
        {
            if (obj.GetType() != typeof(MyData)) return false;

            MyData other = (MyData)obj;
            return this.MyCount == other.MyCount && this.MyFoo == other.MyFoo;
        }

        public override int GetHashCode()
        {
            return 1;
        }
    }</pre>

So, if you&rsquo;re LUA, this test never passes. But, depending on what action that were taken, it can fail for one of two basic reasons. 

The first reason that it can fail is that the schema may never have been installed into WMI. This is the exception you see in that case:

<pre>------ Test started: Assembly: WMISpikes.dll ------

TestCase '' failed: Test method WMISpikes.WMIExplorationFixture.CanSendSinglePieceOfData threw exception:  System.Exception: This schema for this assembly has not been registered with WMI..
    at System.Management.Instrumentation.Instrumentation.Initialize(Assembly assembly)
    at System.Management.Instrumentation.Instrumentation.GetInstrumentedAssembly(Assembly assembly)
    at System.Management.Instrumentation.Instance.set_Published(Boolean value)
    C:DevelopmentSourceDepotEnterpriseLibrarySpikesWMISpikesWMISpikesWMIExplorationFixture.cs(28,0): at WMISpikes.WMIExplorationFixture.CanSendSinglePieceOfData()


0 succeeded, 1 failed, 0 skipped, took 0.00 seconds.
</pre>

You can fix this by installing the schema, using installutil. Once you&rsquo;ve done that as an admin and gone back to running your tests as LUA, your tests now fail for this reason:

<pre>------ Test started: Assembly: WMISpikes.dll ------

TestCase '' failed: Test method WMISpikes.WMIExplorationFixture.CanSendSinglePieceOfData threw exception:  System.Runtime.InteropServices.COMException: Exception from HRESULT: 0x80041003.
    at System.Management.ThreadDispatch.Start()
    at System.Management.Instrumentation.InstrumentedAssembly..ctor(Assembly assembly, SchemaNaming naming)
    at System.Management.Instrumentation.Instrumentation.Initialize(Assembly assembly)
    at System.Management.Instrumentation.Instrumentation.GetInstrumentedAssembly(Assembly assembly)
    at System.Management.Instrumentation.Instance.set_Published(Boolean value)
    C:DevelopmentSourceDepotEnterpriseLibrarySpikesWMISpikesWMISpikesWMIExplorationFixture.cs(28,0): at WMISpikes.WMIExplorationFixture.CanSendSinglePieceOfData()


0 succeeded, 1 failed, 0 skipped, took 0.00 seconds.</pre>

This error (0x80041003) says that you have no permission to be sending this data to WMI, which is true if you&rsquo;re running LUA. By default, only a very limited set of users is allowed to send data into WMI, and changing this appears to be rather twisted and convoluted (it can be done, but probably only by experts).

**Now for the surprising twist**

If I recompile my program and rerun the tests, while still running as LUA, I go back to the first exception message. What apparently happens is that compiling your program invalidates the schema registration and you have to rerun installutil. Surprise!

**Surprising twist #2**

If you are running your tests as a Local Administrator, registration of your schema class happens automatically for you when the program is run the first time. So&nbsp;the above test works all the time, without ever having to run installutil.&nbsp;Surprise!

**Why am I posting this?**

I&rsquo;m posting this because I&rsquo;ve seen a lot of Enterprise Library users having this exact problem. I spent a while today researching it, and I wanted to write my conclusions down somewhere so that I can refer to them later when I have this problem again 🙂 The page I used to find most of this out was [here][1].

My main conclusion is that it is very difficult to run WMI-publishing code as LUA. It seems to almost require being an admin to run correctly and easily. You can add some sort of security descriptor to your data or event class to allow it to be given to WMI, but that&rsquo;s pretty confusing from the explanations I&rsquo;ve seen. You can use wmimgmt.msc to give certain users permission to write to particular WMI namespaces, but this also seems to&nbsp;be a pretty big hurdle for Enterprise Library customers to have to climb. It just seems like WMI needs to be run as admin to work easily and correctly. Not real happy about that answer.

I hope that this information is going to help someone, sometime to avoid wasting a lot of time tracking down this issue. With any luck, that person will be me 🙂

&mdash; bab

&nbsp;

**Now playing:** Alice In Chains &#8211; Dirt &#8211; Rain When I Die

 [1]: http://msdn.microsoft.com/library/default.asp?url=/library/en-us/cpguide/html/cpconregisteringtheschemaforaninstrumentedapplication.asp