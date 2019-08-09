---
title: The Present I Promised
author: Brian Button
type: post
date: 2004-08-11T05:34:00+00:00
url: /index.php/2004/08/11/the-present-i-promised/
sfw_comment_form_password:
  - szTDqafTIrfq
sfw_pwd:
  - 32rQRExp0jRi
categories:
  - 112
  - 115

---
As promised in the previous blog entry, here is the code I used to implement the Active Object pattern on a .Net project I&#8217;ve been working on.

Here&#8217;s the setup for the pattern again. I was working on rewriting some caching functionality on this project, and I had some housekeeping operations that had to happen in the background. This meant that I had to have multiple threads operating at the same time, but I had several choices as to how to do this.

Kind of the default way of doing stuff on multiple threads in .Net is to kick off the processing on a ThreadPool thread. This works out well if you don&#8217;t need to actively manage the threads, but just want them to operate on their own. Users of this functionality start it using the usual asynchronous method invocation stuff in .Net. The problem with this is that the threading policy is exposed to the entire world. If you ever wanted to change to programmatically controlled threads rather than thread pool threads, or wanted to call the methods in the same thread of the caller, etc, you&#8217;d have to change all of the calling code in the entire application. This is Bad.

What you&#8217;d rather do is to encapsulate the threading policy inside a class. That way, changing your mind is easy and cheap.

Now that we&#8217;ve decided where to put the logic, we have to decide how to represent it. What we&#8217;d really like to happen is for clients to talk to our class as if they were directly calling a method, but to have our class invoke the method for us, on our own thread of control. This is the essence of Active Object. It is used to decouple the invocation of a method from that method&#8217;s execution. The advantage of it is that allows you to serialize these method invocations, eliminating threading concerns from the invoked code. Single threaded code is much more simple to write, much less error prone, and generally to be preferred if at all possible.

So, how is this done? It&#8217;s actually pretty easy. The overall process involves a few moving parts.

  * Target Class &#8212; class on which methods are called
  * Command Classes &#8212; Part of communication mechanism between threads
  * Command Queue &#8212; Transfers command objects between threads

## Target Class

The target class needs to have two different sets of methods. The first methods make up the public API, and is used by outside callers. This API doesn&#8217;t actually cause the behavior to happen, but it does arrange for the other set of APIs, the private set, to be called through the communication mechanism. In my case, this class was called the BackgroundScheduler, and it was responsible for allowing scavenging-type operations to happen when needed.

<pre>using System;
using System.Threading;

namespace Example
{
    internal class BackgroundScheduler
    {
        private ProducerConsumerQueue inputQueue = new ProducerConsumerQueue();
        private Thread inputQueueThread;
        private ScavengerTask scavenger;

        public BackgroundScheduler(ScavengerTask scavenger)
        {
            this.scavenger = scavenger;

            ThreadStart queueReader = new ThreadStart(QueueReader);
            inputQueueThread = new Thread(queueReader);
            inputQueueThread.IsBackground = true;
        }

        public void StartScavenging()
        {
            inputQueue.Enqueue(new StartScavengingMsg(this));
        }

        internal void DoStartScavenging()
        {
            scavenger.DoScavenging();
        }

        private void QueueReader()
        {
            while (true)
            {
                IQueueMessage msg = inputQueue.Dequeue() as IQueueMessage;
                try
                {
                    msg.Run();
                }
                catch (ThreadAbortException)
                {
                }
            }
        }
    }
}
</pre>

BackgroundScheduler is responsible for orchestrating all the activities in this little drama. It owns something called a ProducerConsumerQueue, which is what holds the IQueueMessage objects as they are passed between threads. It also owns and manages its own internal thread, which is where the processing actually happens. When a request to do something comes in, the BackgroundScheduler takes that request, creates a derived IQueueMessage, queues that message, and returns to the caller. Later, the internal thread runs, picks up the message from the other side of the ProducerConsumerQueue, and executes it. The nice part about this is that each operation runs to completion before the next background task starts. Single threaded code!
  


## Queue Messages


  
The IQueueMessage interface is really very simple, consisting of only a simple Run method.

<pre>namespace Example
{
    internal interface IQueueMessage
    {
        void Run();
    }
}
</pre>

This method is implemented in the StartScavengingMessage.

<pre>namespace Example
{
    internal class StartScavengingMsg : IQueueMessage
    {
        private BackgroundScheduler callback;

        public StartScavengingMsg(BackgroundScheduler callback)
        {
            this.callback = callback;
        }

        public void Run()
        {
            callback.DoStartScavenging();
        }
    }
}
</pre>

When the Run method of this class is called, it just calls back to the BackgroundScheduler, invoking the internal API to cause the behavior to get run. At construction, each IQueueMessage instance is given a reference to the object to callback, so that it can invoke the behavior. One of the criticisms I received on this piece of code during the review of it was that I could have used a delegate instead of the IQueueMessage interface and saved myself from having to write simple command class derived classes, but I thought that the explicit interface communicated better than a delegate. Maybe that&#8217;s my old C++ background shining through, but I think it is easier to read like this, so I kept it as you see it.
  


## Producer Consumer Queue


  
The final piece of the puzzle is the ProducerConsumerQueue. This is a special kind of queue where producers can store their messages onto one side of the queue from any thread in the system, but the queue is drained from a single consumer on its own thread. The consumer waits until there is a message to read from the queue, then reads it and returns it.

<pre>using System;
using System.Collections;
using System.Threading;

namespace Example
{
    internal class ProducerConsumerQueue
    {
        private object lockObject = new Object();
        private Queue queue = new Queue();

        public int Count
        {
            get { return queue.Count; }
        }

        public object Dequeue()
        {
            lock (lockObject)
            {
                while (queue.Count == 0)
                {
                    if (WaitUntilInterrupted())
                    {
                        return null;
                    }
                }

                return queue.Dequeue();
            }
        }

        public void Enqueue(object o)
        {
            lock (lockObject)
            {
                queue.Enqueue(o);
                Monitor.Pulse(lockObject);
            }
        }

        private bool WaitUntilInterrupted()
        {
            try
            {
                Monitor.Wait(lockObject);
            }
            catch (ThreadInterruptedException)
            {
                return true;
            }

            return false;
        }
    }
}
</pre>

This class is actually pretty simple. There is a Mutex that is shared between the Enqueue and Dequeue methods. In Dequeue, the code waits for the Mutex to be pulsed. When it receives this pulse, it pulls off an object and returns it to the caller. In the meantime, from any other thread in the system, other code is free to add messages to the front of the queue. Each of these enqueue operations causes the Mutex to be pulsed, triggering the dequeue in the other thread.

Obviously, given the multithreaded nature of this class, all operations that consume any of the shared state of the ProducerConsumerQueue must be locked using the lockObject. This is the only place in the BackgroundScheduler that explicitly has to understand threading issues.
  


## Conclusion


  
That&#8217;s all there is to it. Using these few simple classes, I was able to allow callers to invoke behavior that my implementation chose to run in the background. The caller didn&#8217;t know anything about my threading policy, as it was entirely contained in my BackgroundScheduler object, so I was free to change that policy on a whim. I was able to keep the code inside the ScavengerTask (not shown) single threaded, since I was guaranteed that only one instance of it would be running at a time, and I was able to control when and where that code ran.

The only improvement I&#8217;d like to make in this little grouping is that I&#8217;d like to find a way to pass only an interface to the callback methods to the IQueueMessage objects. In C++, I&#8217;d do this by creating a private base class and passing that reference to the objects, but I can&#8217;t figure out a similar solution in .Net. There are some times that I long for the expressiveness and power that is C++ 🙂

Hopefully some of you actually read down to here, and if so, thanks for listening!

&#8212; bab