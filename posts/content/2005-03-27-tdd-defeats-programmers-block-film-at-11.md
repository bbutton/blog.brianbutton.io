---
title: TDD defeats Programmer’s Block — Film at 11
author: Brian Button
type: post
date: 2005-03-27T11:05:00+00:00
url: /index.php/2005/03/27/tdd-defeats-programmers-block-film-at-11/
sfw_comment_form_password:
  - ZJAQuQFxUrbP
sfw_pwd:
  - fSqoDuPhKHt3
categories:
  - 111
  - 115

---
Cheesy title, but it caught your eye, eh? The real point of this article is to describe a TDD experience I had the other day (Friday),&nbsp;and how it changed my life (OK, a bit over the top, but hey,&nbsp; it kept you reading&hellip;)

Here is the scene. I&rsquo;m working with [Peter Provost][1] and [Jim Newkirk][2], building a Continuous Integration system to be used internally in [patterns & practices][3]. Peter and I have been the devs on it, and Jim provided the customer&rsquo;s point of view. It has taken longer than we thought, mostly because things were harder than they seemed at first 🙂 (Does that ever happen to you???) But we&rsquo;re winding up the initial implementation of this system, with one final piece left before we can put this thing into use.

**Continuum**

The general architecture of this thing is built based on several disconnected services. There is a piece that monitors several different kinds of source code repositories, including subversion and an internal one, called Source Depot. This was originally written as a trigger that lived in the same place as each repository, but we have lately come to realize that we&rsquo;re not going to be able to have co-located code on the repository machines. So I have to convert our triggers into pollers, which is where I am right now. These triggers, and soon to be pollers, will talk to a web service, called StarterService, and uses the ConfigurationService web service to look up config info on each project to build, and then sends a BuildCommand to a windows service, BuildService, which runs a BuildWorker that queues all builds for a particular project and executes them one by one. Whew! That&rsquo;s the system in a nutshell. As of right now, with triggers, this all works great. But I have to create these monitors, which is where my knock-me-over-the-head moment happened.

**Where TDD Comes In**

So, I was sitting at my little table in [Scott Densmore][4]&rsquo;s office, my home away from home, with my hands on the keyboard, and no idea what to type. I had all kinds of thoughts running through my head, trying to figure out what to start with. I knew I wanted to work in how to use the existing trigger code in my poller, so I could keep my dev time down. I had promised to finish this thing this week, so I was feeling a lot of time pressure. And I didn&rsquo;t know what to test. My head started to hurt.

Then, all of a sudden, a calm came over me. I remembered something [Kent Beck][5] had said a while ago &mdash; [&ldquo;What would you do if you had all the time in the world? Do that.&rdquo;][6] Simple words from a Master. I stopped worrying about the existing code, the deadline, and everything else. I just thought about what my poller needed to do. And I wrote this test:

<pre>[Test]
        public void StartingBuildWithNoPreviousStateOnlyStartsBuildForLastChange()
        {
            SourceDepotRepositoryMonitor monitor = new SourceDepotRepositoryMonitor();
            monitor.StartBuilds();
        }</pre>

Now I was at least thinking in terms of the system I was trying to build, and how it would work. In order to test something, though, I had to find a way to _sense_ ([Michael Feathers][7]&rsquo; word in his great book, [WELC][8]) what happened. I knew that my SourceDepotRepositoryMonitor had to talk to a repository of some sort, and I didn&rsquo;t want to be colored by any previous implementation decisions. So I created a MockSourceDepotRepositoryTrigger and an ISourceDepotRepositoryTrigger, but I didn&rsquo;t put any methods in either of them yet, because I didn&rsquo;t know what they did. Yet. That led the test to change to this:

<pre>[Test]
        public void StartingBuildWithNoPreviousStateOnlyStartsBuildForLastChange()
        {
            MockSourceDepotTrigger trigger = new MockSourceDepotTrigger("localhost:9876");
            SourceDepotRepositoryMonitor monitor = new SourceDepotRepositoryMonitor(trigger);
            monitor.StartBuilds();

            Assert.AreEqual("localhost:9876", trigger.GivenRepositoryLocation);
            Assert.AreEqual(19, trigger.GivenRevisionNumber);
        }</pre>

Now I had something I could test, and I was feeling better. I had quit worrying about what was and started thinking about what I wanted it _to be_. I still had a problem, because the SourceDepotRepositoryMonitor had to talk to a repository to get the data that it needed. I guess I should explain what this monitor is supposed to do. Its job is to ping the repository server every now and then what the latest change number is. Then it has to kick off a build for each build revision that have not been built yet. That&rsquo;s it. So our Monitor has to be have a Repository to talk to, so it can ask it the, &ldquo;What&rsquo;s the last change number&rdquo; question. That means that the Monitor needed a SourceDepotRepository in order to talk to something. I already had this class built, and it had an interface that was usable, so I changed it a bit to let me create a mock to avoid the actual round trip to the repository service. This led to a MockSourceDepotRepository that allowed me to prime the pump with the fake data that I needed. Now my test looked like this:

<pre>[Test]
        public void StartingBuildWithNoPreviousStateOnlyStartsBuildForLastChange()
        {
            MockSourceDepotTrigger trigger = new MockSourceDepotTrigger("localhost:9876");
            MockSourceDepotRepository repository = new MockSourceDepotRepository("localhost:9876", 19);
            SourceDepotRepositoryMonitor monitor = new SourceDepotRepositoryMonitor(trigger, repository);
            monitor.StartBuilds();

            Assert.AreEqual("localhost:9876", trigger.GivenRepositoryLocation);
            Assert.AreEqual(19, trigger.GivenRevisionNumber);
        }
</pre>

And I could write the code to make that test pass. 

On to the next test! This first test let me build a system that could start out fresh, without any notion of saved state, and start a build for the most recently checked in revision. But our goal _is_ to maintain some state, so that we can kick off all the builds needed to bring our system up to date. So I started to think about how I might manage this previous build state. It really is just a number, so do I need any special processing for it at all? Isn&rsquo;t it silly to wrap an int with a class? It sure felt like it was overkill.

But the fact was that I didn&rsquo;t know where this number came from. I didn&rsquo;t know where it had to go. I didn&rsquo;t know how I was going to change it to reflect it the newer builds that have just occurred. Questions, questions, questions. Since I didn&rsquo;t have the answers to these questions, but I wanted to preserve the right to answer these questions later, I went ahead, almost against my better judgement, and create a PreviousBuildState class, along with its corresponding mock, MockPreviousBuildState. This led to this test:

<pre>[Test]
        public void StartingBuildWithPreviousStateOfOneBeforeCurrentStartsBuildForLastChange()
        {
            MockPreviousBuildState previousBuildState = new MockPreviousBuildState(12);
            MockSourceDepotTrigger trigger = new MockSourceDepotTrigger("localhost:9876");
            MockSourceDepotRepository repository = new MockSourceDepotRepository("localhost:9876", 13);
            SourceDepotRepositoryMonitor monitor = new SourceDepotRepositoryMonitor(previousBuildState, trigger, repository);
            monitor.StartBuilds();

            Assert.AreEqual("localhost:9876", trigger.GivenRepositoryLocation);
            Assert.AreEqual(13, trigger.GivenRevisionNumber);
        }
</pre>

The point of this test is to prove that if the previous build number is one before this newest build number, we would kick off exactly one build. I was able to directly implement this behavior, and I was really starting to like where this was going. I still wasn&rsquo;t sure about the PreviousBuildState class, but I was willing to give it some time. The next test to write was to try to start several builds, and I was able to do that with the same test code, just changing the previous build state to a few before the build number that was being requested. Not a big deal to implement. This left me only one more thing to test before I got to testing error conditions &mdash; I had to make sure that I was updating the PreviousBuildState after each build kicked off. It was at this point that the shear genius of the PreviousBuildState class became apparent to me 🙂 Since I had wrapped this number with a class, I had something to tell to update it, and I didn&rsquo;t have to care how it happened. I knew that I was going to store it in a file for now, I was going to send it back to our ConfigurationService later, and maybe store it in a database. This class was going to be my ticket to let me do this without changing any existing code! I had actually made the right choice, even though it felt wrong at that point. This led to the following test:

<pre>[Test]
        public void PreviousBuildNumberIsIncrementedAfterSuccessfullStartedBuild()
        {
            MockPreviousBuildState previousBuildState = new MockPreviousBuildState(12);
            MultiMockSourceDepotTrigger trigger = new MultiMockSourceDepotTrigger("localhost:9876");
            MockSourceDepotRepository repository = new MockSourceDepotRepository("localhost:9876", 14);
            SourceDepotRepositoryMonitor monitor = new SourceDepotRepositoryMonitor(previousBuildState, trigger, repository);
            monitor.StartBuilds();

            Assert.AreEqual(14, previousBuildState.GetLastBuildRevision());
        }
</pre>

All that was left to do after this was some housekeeping stuff, like making sure that I didn&rsquo;t increment the PreviousBuildState if I failed to start the build correctly for some reason. Those tests looked like this:

<pre>[Test]
        public void FailedBuildDoesNotIncrementLastBuiltStateForOneRequestedBuild()
        {
            MockPreviousBuildState previousBuildState = new MockPreviousBuildState(12);
            ThrowingMockSourceDepotTrigger trigger = new ThrowingMockSourceDepotTrigger("localhost:9876", 0);
            MockSourceDepotRepository repository = new MockSourceDepotRepository("localhost:9876", 13);
            SourceDepotRepositoryMonitor monitor = new SourceDepotRepositoryMonitor(previousBuildState, trigger, repository);
            monitor.StartBuilds();

            Assert.AreEqual(12, previousBuildState.GetLastBuildRevision());
        }

        [Test]
        public void LastBuildFailingLeavesLastBuildSetToPreviousBuild()
        {
            MockPreviousBuildState previousBuildState = new MockPreviousBuildState(12);
            ThrowingMockSourceDepotTrigger trigger = new ThrowingMockSourceDepotTrigger("localhost:9876", 2);
            MockSourceDepotRepository repository = new MockSourceDepotRepository("localhost:9876", 15);
            SourceDepotRepositoryMonitor monitor = new SourceDepotRepositoryMonitor(previousBuildState, trigger, repository);
            monitor.StartBuilds();

            Assert.AreEqual(14, previousBuildState.GetLastBuildRevision());
        }
</pre>

The implementation for these tests led to this class and associated interfaces:

<pre>using System;
using System.Collections.Generic;
using System.Text;
using Continuum.Triggers.Common;

namespace Continuum.SourceDepotTrigger
{
    public class SourceDepotRepositoryMonitor
    {
        PreviousBuildState previousBuildState;
        ISourceDepotTrigger trigger;
        SourceDepotRepository repository;

        public SourceDepotRepositoryMonitor(PreviousBuildState previousBuildState, ISourceDepotTrigger trigger, SourceDepotRepository repository)
        {
            this.previousBuildState = previousBuildState;
            this.trigger = trigger;
            this.repository = repository;
        }

        public void StartBuilds()
        {
            int latestRevisionNumber = repository.GetLatestRevisionNumber();
            int lastSuccessfullyBuiltRevision = previousBuildState.GetLastBuildRevision();

            int lastRevisionStartedSuccessfully = BuildAllRevisions(lastSuccessfullyBuiltRevision, latestRevisionNumber);

            previousBuildState.UpdateLastBuildRevision(lastRevisionStartedSuccessfully);
        }

        private int BuildAllRevisions(int lastSuccessfullyBuiltRevision, int lastRevisionToBuild)
        {
            int firstRevisionToBuild = (lastSuccessfullyBuiltRevision == PreviousBuildState.NoPreviousBuildStateAvailable)
                ? lastRevisionToBuild
                : lastSuccessfullyBuiltRevision + 1;
            int lastBuildStartedSuccessfully = lastSuccessfullyBuiltRevision;

            for (int revisionToBuild = firstRevisionToBuild; revisionToBuild &lt;= lastRevisionToBuild; revisionToBuild++)
            {
                try
                {
                    trigger.StartBuild(revisionToBuild);
                    lastBuildStartedSuccessfully = revisionToBuild;
                }
                // Exception handled in trigger. We just have this here to maintain our counts
                catch { }
            }

            return lastBuildStartedSuccessfully;
        }
    }
}</pre>

I&#8217;m not too happy with the BuildAllRevisions() method, but I don&#8217;t know how to refactor it better yet. I&#8217;ll come back to it later when I have a few spare cycles to make it more readable. I&#8217;m wondering if there is a Build class hiding in there somewhere that would manage a lot of the stuff in this method. Or maybe a BuildableCollection that would have a ForEach method that would have the loop in it, or something like that.

This is the PreviousBuildState class. It is an abstract class because I wanted to have a constant in there, and I couldn&rsquo;t if it was an interface.

<pre>using System;
using System.Collections.Generic;
using System.Text;

namespace Continuum.Triggers.Common
{
    public abstract class PreviousBuildState
    {
        public const int NoPreviousBuildStateAvailable = -1;

        public abstract int GetLastBuildRevision();
        public abstract void UpdateLastBuildRevision(int lastBuiltRevision);
    }
}
</pre>

This is the interface over the trigger class that I expect to adapt to the currently implemented SourceDepotRepositoryTrigger class.

<pre>using System;
using System.Collections.Generic;
using System.Text;

namespace Continuum.SourceDepotTrigger
{
    public interface ISourceDepotTrigger
    {
        void StartBuild(int revisionNumber);
    }
}
</pre>

And finally the SourceDepotRepository class is a concrete class, as I described above, but I made the method that actually talks to the repository a virtual method, and overrode it in the Mock version, so I wouldn&rsquo;t have to make the round trip to the SD box.

Once I finished with these tests, I knew exactly how to proceed to finish this task. I just had to implement the real versions of the Mock classes I had, wrap the SourceDepotRepositoryMonitor in a thread, stick it in a service, and I was finished. Those were tasks I knew how to do easily, so my crisis had passed.

And it was the calmness that came from remembering Kent&rsquo;s words and from just writing that first test without regard to what I already had, that let me make any progress at all. I consider this a complete and total victory for TDD over my panic, and I was able to leave for home feeling good that I could finish this task very soon.

&mdash; bab

 [1]: http://peterprovost.org/
 [2]: http://blogs.msdn.com/jamesnewkirk
 [3]: http://www.microsoft.com/practices
 [4]: http://blogs.msdn.com/scottdensmore
 [5]: http://www.threeriversinstitute.org/Kent%20Beck.htm
 [6]: http://c2.com/cgi/wiki?TooMuchToDo
 [7]: http://www.michaelfeathers.com/
 [8]: http://www.amazon.com/exec/obidos/redirect?tag=agilesolution-20&path=tg/detail/-/0131177052/qid=1111941527/sr=8-1/ref=pd_csp_1?v=glance&s=books&n=507846