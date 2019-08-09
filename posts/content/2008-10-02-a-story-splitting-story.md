---
title: A Story Splitting Story
author: Brian Button
type: post
date: 2008-10-02T09:29:00+00:00
url: /index.php/2008/10/02/a-story-splitting-story/
sfw_comment_form_password:
  - vD1VqT1xj5D9
sfw_pwd:
  - w3vL0s3aQyWq
categories:
  - 111

---
This is a true story from a true client I&#8217;m working with . The names and details have been changed to protect the innocent&#8230;

**Story splitting**

Several of us were attending a pre-sprint planning meeting yesterday, trying to flesh out the user stories that the product owner was planning to bring to sprint planning in a few days. They are still pretty early in their agile adoption as well as their technology adoption, so there are lots of questions floating around about process and tools.

A story came up in the meeting that described the interaction that a user would take when visiting the site the first time, more specifically around the user agreement presented to them the first time they logged into the site. The story was something like:

&#8220;As a user, I want to be to able to accept the user agreement so that I can access my content&#8221;

The details of this story included a specific workflow to follow if the user didn&#8217;t agree, including errors to show them, and a need to refrain from showing the user agreement again after agreeing to it the first time.

Conversation around this story went on for a while, mainly focusing around the second part, how to handle remembering what the user did the last time they visited the site. There were technical details about where this information needed to be stored that hadn&#8217;t been agreed to yet, and team spun a bit around this issue.

The suggestion was made to split the story into two. The first story would be the same as the first, &#8220;As a user, I want to be able to accept the user agreement so that I can access my content&#8221;, and it included all the acceptance criteria other than the remembering part. The second story would be &#8220;As a previously logged in user, I will not be presented with the user agreement, since I had already agreed to it&#8221;, which picked up the remembering part.

By splitting the story in this way, they were able to work out the important part for the customer, which was the user agreement workflow, and defer the technical issues over where to store the agreement status until they could discuss the issue more.

**Moral of the story**

When discussing a story, if there is contention about how part of it is done, it is sometimes possible to split the story so that the understood part is separated from the not understood part, allowing progress to be made. In this case, we knew how to write the workflow, but not how to prevent the user from seeing the agreement each time. We split the story at that particular edge, which allowed the team to build something useful, and to defer what they didn&#8217;t know yet until they knew more about it later.

&#8212; bab