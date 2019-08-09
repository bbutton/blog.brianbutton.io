---
title: Using Powershell to diagnose installation failures
author: Brian Button
type: post
date: 2007-11-17T15:25:00+00:00
url: /index.php/2007/11/17/using-powershell-to-diagnose-installation-failures/
sfw_comment_form_password:
  - 6d9bHInsnvoh
sfw_pwd:
  - a2SeYJIKuYAZ
categories:
  - Uncategorized

---
I was trying to install the Application Block Software Factory, part of Enterprise Library 3.1, the other day, and I ran into a problem. During the installation, I got a failure stating that the necessary installer types could not be found in &#8220;c:program filesMicrosoft Visual Studio 8common7ideMicrosoft.Practices.EnterpriseLibrary.BlockFactoryInstaller.dll&#8221;. I was instructed to see the LoaderExceptions property of the exception for details.

Huh? How in the world was I supposed to see this property of an exception that I didn&#8217;t even have access to?????

**Powershell to the rescue**

Hmmm, I thought. Based on a previous blog posting, I remember that I found a way to load an assembly from a file, and I knew that I could inspect the types in an assembly once it was loaded. Maybe I could follow this process to learn something about what was happening.

So, I fired up powershell, and typed in the following command (note that I&#8217;m at home and not at work in front of the PC where I did this. The paths are as close as I can remember&#8230;)

> $assembly = [System.Reflection.Assembly]::LoadFile(&#8220;c:program filesMicrosoft Visual Studio 8common7ideMicrosoft.Practices.EnterpriseLibrary.BlockFactoryInstaller.dll&#8221;)

Once I had the assembly loaded like this, I used its GetTypes() method to inspect the types in the assembly, and that&#8217;s when I got the same exception as before. 

After a little investigation, I came across the _$Error_ special variable, which seems to hold an array of the last exceptions through during powershell execution. I was able to get to the exact exception I saw at the command line through this variable by typing $Error[0].

I investigated further by using the get-member cmdlet, as

> $Error[0] | get-member

which told me that the object returned from $Error[0] had an Exception property on it. I followed on a bit, and looked at the members of the exception I could get to using $Error[0].Exception. Here, it turned out, there was a property called LoaderExceptions, which was the exact property that I had been instructed to see by the error message.

Looking at that property as:

> $Error[0].Exception.LoaderException[0]

gave me the exact right answer. It was looking for Microsoft.Practices.Recipes.dll, an assembly loaded by GAX, but it couldn&#8217;t find it. I searched for that assembly, and I did eventually find it, but it was installed beneath Orcas, not Whidbey, both of which I had installed on my machine.

**The solution**

So, to make a long story short, I reinstalled GAX, this time installing it for VS.Net 2005, and all was well. I was able to install the Enterprise Library in its entirety, and I was able to proceed.

But, without the ability of powershell to let me iteratively understand what was happening, and explore the objects involved, I don&#8217;t know how I would have otherwise solved this problem.

&#8212; bab