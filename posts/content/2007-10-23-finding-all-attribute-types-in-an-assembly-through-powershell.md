---
title: Finding all Attribute types in an assembly through powershell
author: Brian Button
type: post
date: 2007-10-23T12:57:00+00:00
url: /index.php/2007/10/23/finding-all-attribute-types-in-an-assembly-through-powershell/
sfw_comment_form_password:
  - uMRmib7mkbKm
sfw_pwd:
  - L1aiQ0M0uVHR
categories:
  - 142

---
I was using the new xunit.net testing framework, and I wanted to see a list of all the attributes they had. _This looks like a job for Powershell!!!_

`<br />
[System.Reflection.Assembly]::LoadFile("pathToFile.dll").GetTypes() | where-object { $_ -match "Attribute" }<br />
` 

That did the trick!

&#8212; bab