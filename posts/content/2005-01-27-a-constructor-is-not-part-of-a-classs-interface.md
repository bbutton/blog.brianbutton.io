---
title: A constructor is not part of a class’s interface
author: Brian Button
type: post
date: 2005-01-27T17:23:00+00:00
url: /index.php/2005/01/27/a-constructor-is-not-part-of-a-classs-interface/
sfw_comment_form_password:
  - 8k0wLVhfCDNK
sfw_pwd:
  - NtLHdGnQFZB6
categories:
  - Uncategorized

---
[Peter Provost][1] and I were talking today about some [code that we&rsquo;re working on together][2]. We&rsquo;re constructing a class right now, called a Starter. The job of a Starter is to stitch together a Repository, a class whose job it is interact with a source control repository, subversion in our case, a Builder, which is responsible for causing a Project to be built, and a BuildLogger. All of this stuff has to be aware of configuration changes, so we also&nbsp; have to pass in a Configuration object that is able to tell us the current configuration values. The constructor signature looks like this:

public Starter(IStarterConfiguration, IRepository, IBuilder, IBuildLogger) // excuse the shorthand

When I write code, I typically have constructors that look like this. I believe that it is not the job of the class to know where its bits and pieces come from, because this would tightly couple the Starter class to specific types of configs, repositories, etc, which is a bad thing. So, I frequently have a different class, like a factory or a builder whose job it is to construct the objects and send them along their merry way. Creating code like this lets me keep the methods of the class as clean as possible, and allows me to vary the actual type of objects passed in.

The downside of this is that construction of my objects can get a little complicated. My constructors can end up taking several different kinds of objects that are really only exposed because I want to avoid the tight coupling. But I don&rsquo;t consider this to be a problem.

Others do not share my opinion.

I believe that the interface of the class are only that class&rsquo;s member functions and properties. Constructors are not part of the interface. Constructors never appear in an interface, and are not what typical clients use. They just call the regular methods.

It turns out that this style of creating classes creates systems that are amenable to dependency injection techniques, both manually and through using tools like [pico][3]. This lets you create flexible systems at the price of exposing some of your implementation through constructor arguments. I haven&rsquo;t played with tools like this yet, but I&rsquo;m starting to get the itch&hellip;

Sorry for the rambling, but that&rsquo;s what was on my mind today.

&mdash; bab

&nbsp;

 [1]: http://www.peterprovost.org/
 [2]: http://www.peterprovost.org/archive/2005/01/25/2607.aspx
 [3]: http://www.picocontainer.org/