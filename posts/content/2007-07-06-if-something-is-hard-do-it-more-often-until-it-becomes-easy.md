---
title: If something is hard, do it more often, until it becomes easy!
author: Brian Button
type: post
date: 2007-07-06T09:32:00+00:00
url: /index.php/2007/07/06/if-something-is-hard-do-it-more-often-until-it-becomes-easy/
sfw_comment_form_password:
  - NO7CyK7H153I
sfw_pwd:
  - SwFQfYjGVDxx
categories:
  - 111

---
A team I was managing recently shipped a pretty complex, interactive web site, <http://www.sothebyshomes.com> . Feel free to check it out and let us know how you feel. During this project, there were a bunch of things that were really hard for us to do, and we invented ways of making them easier. By making them easier, we did them more frequently, and their value to the project and customer increased.

**Deployment**
  
The particular aspect of our system I want to talk about is our deployment process. I&#8217;ll go ahead and credit [Adam Esterline][1] with coming up with our scheme, but I&#8217;m pretty sure that the rest of the team had significant input into it.

_Solving the local issue_
  
So when we started this project, we all shared a single SQLServer instance, running on our build server. It was filled with a bunch of canned data against which our tests ran and we manually played around with our system. Over time, as we had to add more and more data to our system to make individual tests work, and had to alter the schema to add functionality, it became harder to share a single instance of the database. Adam at this point adopted the Rails idea of Migrations, and implemented it for us in .Net. This allowed us to do a checkout and build locally, which ended up creating a local database for us on each pairing station, where the database was fully up-to-date with everything that had been done so far. The way it was set up, the mere act of checking out our code and running a build gave us a fully working system, which is just what you want.

_Solving the staging issue_
  
As the project progressed further, we wanted to do deployments to our staging server located somewhere on the East Coast of the US. So we started off doing this deployment manually for a month or so, and it was getting to be a major pain. There was a wiki page on our local server that outlined the multi-step process, including how to log into the VPN, log into the staging server, how and where to copy our files, how to deploy them once they were there, and so on. We had a multi-gigabyte database image that needed to be uploaded over a very shaky VPN connection, which could take several days to do successfully, so we only did it when absolutely necessary. It was ugly. This process took like an hour to do manually (aside from the DB copy, which took 6 hours on a good day), and we were doing it multiple times a week. It was really painful, but also really necessary. So we adapted our build system to allow us to log into the staging server and run our standard build process. Like above, this gave us the ability to just do a checkout and kick off a build, and everything was updated to where it should be, courtesy of the migrations we had. So this problem was solved. Deployment to our staging server was something that we could trivially do. Yea!

_Solving the production issue_
  
As we got closer to the end, we had to deploy our system to yet another set of servers. This time, we needed to put our system onto the production servers so that we could do our final testing before release. This situation was different, as the production servers were a pair of load balanced machines with a single backend SQLServer box. We figured that we would be deploying many times over the lifetime of our project, so it made sense to make the deployment process as easy as possible. So, we just adapted our existing deployment process to add the new target of the production servers, which allowed us to log into either of the web servers, do a build, and have a working system with a single command. Then we could log into the other web server, run another build, and have both servers updated trivially.

Before we could get to this point, however, we had to spend about 3 days getting a version of our database up there, manually tweak the deployment process a few times to get around environmental issues that existed on the deployment web and database servers that didn&#8217;t exist in staging (permissions mostly), and practice doing it. But once we got to the Thursday night that we were asked to go live, we did it. About 4 times 🙂 And its been trivial ever since.

**The lesson**
  
Deploying our system to staging and production were important activities for us to do. We had to do them often, and we had to do them reliably. The process was completely identical from deploy to deploy, so it seemed to be an ideal candidate for automation. So, after doing this process by hand a bazillion times, we finally automated it, and it got better. Instantly. We found something that was very hard for us to do, did it enough times to understand the problem, and automated the problem away.

The curious part is that this scenario is not unique to our project at all. So many of my clients have completely manual deployment processes, spanning several departments and management ladders, and their deployments often fail. When they fail, developers and operations people take hours or days to figure out what went wrong this time. In many of these cases, these people could automate away their problems. It would take cooperation across groups, cooperation across departments, it would take some people letting go of their fiefdoms of deployment. But it would help the overall company succeed and become more, dare I say it, agile.

&#8212; bab

 [1]: http://www.adamesterline.com