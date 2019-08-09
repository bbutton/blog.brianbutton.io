---
title: “You get what you measure” versus “What you measure, you can manage” – The Agile Metrics Dichotomy
author: wp-root
type: post
date: 2013-10-27T00:51:21+00:00
url: /index.php/2013/10/26/you-get-what-you-measure-versus-what-you-measure-you-can-manage-the-agile-metrics-dichotomy/
sfw_pwd:
  - N7GhvOdkYOoM
categories:
  - Uncategorized

---
_(I just reinstalled Windows Live Writer and reconnected it to my blog, and it pulled down some drafts I wrote years ago. So, I have no idea when I actually wrote this, what the context was that was in my head, but it seems like a decent article. So I’m posting it :))_

I’ve long been a fan of the “You get what you measure” school of metrics doubters, especially in agile projects. Its really easy to decide to measure something, have the people being measured act in a totally predictable and rational way, and screw up a team beyond belief. For example, if I measure how productive individual programmers are, then its to the advantage of individuals to focus on their own work and spend less (or no!) time helping others. Completely kills teamwork 🙁

On the other hand, in our environment, where we are responsible for delivering projects to clients on time, on budget, etc, we have a responsibility and an obligation to know what is happening in each of our project teams. Management needs to know if we’re going to make our deadlines, customers need to know what is coming, project leaders need to be able to manage and set expectations, we need to satisfy contractual obligations, etc.

The challenge is to come up with a set of metrics and an unobtrusive way to gather data that allows metrics to be reported to interested stakeholders, and yet does not disrupt the team.

This is my challenge. And what follows are the basic metrics I’ve been using as a way of meeting that challenge. These metrics are balanced between measuring things that meaningfully describe what’s happening inside teams, and creating the right environment and behaviors that will help the team reach its goals rather than incent poor behavior.

**How Fast Are We Going?**

The gold standard of progress on an agile team is its velocity. This can be measured in story points per week for teams following a more “traditional” agile process like Scrum or XP, or it be measured in cycle time for those teams that have evolved to a Lean or Kanban approach. The team I’m coaching now is somewhere in the middle, closer to Scrumban.

So our standard metric is points per week. We measure weekly, and our measurements are reasonably accurate, varying between 25 and 30 points a week. We have the occasional week when we’re significantly below this, and some weeks where we way overachieve. Our historical velocity chart looks like this:

 <img src="http://www.agilestl.com/images/AsynchBlog/Velocity.png" width="527" height="258" />

At first, our velocity varied a lot, mostly because we were still learning the codebase (this project has a large legacy codebase that we are adding functionality to). As of late, though, we’ve become a lot more consistent in what we finish each week. Not perfect, but a lot better.

**But What About Quality?**

Measuring velocity is not enough, as teams can find ways to go faster when pressed to do so. This is a great example of measuring something that is going to create the wrong behavior. If a team is rated on how fast they go, they are going to go as fast as they need to. They’ll either cut corners and quality will slip, or they’ll inflate the estimates to make the numbers start to look better without actually accomplishing anything more.

What I’ve found is that the best way to avoid incenting the team to cut corners is to keep an eye on quality, too. So, in addition to tracking&nbsp; velocity, I also track defect counts. These charts look like this:

&nbsp;<img src="http://www.agilestl.com/images/AsynchBlog/WeeklyDefects.png" width="527" height="292" />

This shows our weekly quality over time since the beginning of our project. We started off pretty high, put in some good effort to get our quality back under control, and have done a decent job of keeping it under control most of the time.

**Looking at the Bigger Picture**

What I do is to use these two metrics together to help me understand what’s happening on the team and to ask questions about what may be causing ebbs and flows in velocity or quality. We did a good job of keeping the defect count pretty low during February and March, but the count crept back up, pretty quickly, to 20 or so active defects by the beginning of April. It was towards the end of this relatively quiet period that the time began to feel pressure to deliver more functionality more quickly. They did what they thought was best and focused more on getting stories “finished” without spending quite a much time on making sure everything worked. They worked to what was being measured.

Up steps Project Manager Man (that’s me, for those of you following along at home), and I was able to point out what was happening with quality and, with their help, relate that back to the feeling of pressure they were feeling. Together, we came up with the idea that velocity and quality have to improve together or teams create false progress. I helped the team manage this mini-issue on their own by pointing it out to them through metrics.

**The Final Velocity/Quality Metric**

As a way to keep an eye on the general trend of where the work is going on the team, I also track time spent working on Acceptance Tests versus time spent fixing defects (defects include stories that are kicked back from QA or the Product Owners prior to acceptance) versus time spent developing. My feeling is that if we can maximize development effort and minimize defect remediation time, then the team is operating as effectively as it can, given its circumstances.

**The Most Important Point About Metrics**

Metrics should never be used to judge a team or used to form conclusions about what is happening. They should be treated as a signpost along the way, an indicator of things that are not easily observed in real time but can be measured to point out trends. They should always serve as the starting point for a conversation, the beginnings of understanding an issue. If a manager or executive begins to use metrics as a way to judge a team, the metrics will be gamed and played from that point on. They will become useless, because they will be a reflection of what reality the manager _wants_ to see, rather than what is truly happening.

In each and every one of these cases, I have used the metrics to confirm what I thought I was seeing, as the starting point of a conversation with the team about what they saw happening, and a way to measure the impact of issues on the team. After speaking with the team, the metrics are also useful to judge whether the changes chosen by the team to improve are effective.

Metrics are no substitute for being on the ground with your team, in their team room, pairing with devs and testers, working with product owners, feeling the vibe in the room. Remember, its people over process, right? 🙂

&#8212; bab