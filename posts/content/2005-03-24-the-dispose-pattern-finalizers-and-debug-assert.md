---
title: The Dispose pattern, Finalizers, and Debug.Assert?
author: Brian Button
type: post
date: 2005-03-24T09:09:00+00:00
url: /index.php/2005/03/24/the-dispose-pattern-finalizers-and-debug-assert/
sfw_comment_form_password:
  - 64fEr5I9Hvr6
sfw_pwd:
  - ohsc7dy3Lwgy
categories:
  - 112
  - 115

---
Peter Provost, Scott Densmore, and I were talking about some additions to our project coding guidelines, and I proposed a new one that we wanted to get some feedback on from the community.

According to the Dispose pattern, you&rsquo;re supposed to create classes that look like this:

<pre>public class BuildProcess : IDisposable
    {
        ~BuildProcess()
        {
            Dispose(false);
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (disposing)
            {
            }
        }
    }</pre>

Now the issue here is what should happen if your class is disposable and the finalizer gets called? Is this an error? I believe that it is. The only way for the finalizer to get called for this class is for me to have forgotten to dispose of the instance when I was finished with it. So my proposal for a change to the coding guidelines was to change the finalizer to have Debug.Assert() in it, so that I&rsquo;ll _know_ when I forget to call it.

What does the community think about this? Is this reasonable? Is there some deep, dark .Net secret that would prevent me from doing this? Any opinions greatly appreciated.

&mdash; bab