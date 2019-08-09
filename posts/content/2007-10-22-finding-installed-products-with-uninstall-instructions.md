---
title: Finding installed products with uninstall instructions
author: Brian Button
type: post
date: 2007-10-22T20:35:00+00:00
url: /index.php/2007/10/22/finding-installed-products-with-uninstall-instructions/
sfw_comment_form_password:
  - xSekzMbFq17r
sfw_pwd:
  - z4TxzR4EXC7g
categories:
  - 142

---
I was repaving a machine the other day, and I had to load all my development tools. There were a bunch of them, and when I got finished, I noticed that IIS and SQL Server failed to install properly. So I uninstalled IIS and reinstalled it, no problem. SQL Server was another story.

I uninstalled it, and it only went part way. Then I tried to reinstall it, and it said it was already installed. I went around and around like this a few time, with a few reboots thrown in for good measure.

About this time, I started to google around for how to manually uinstall SQL Server. I came across a KB article on msdn.com somewhere, and it said to crawl through the registry in HKLM:SoftwareMicrosoftWindowsCurrentVersionUninstall, inspect all the GUIDs found there for those that had a DisplayName that contained SQL Server as part of it. Once I found a matching GUID, I was to use the UninstallString to manually uninstall it.

The only problem was that there were dozens of these GUIDs in there. I sure wasn&#8217;t going to crawl through them all by hand.

So, what was a handy shell programmer to do? Well, I pulled out powershell and whipped up a script.

`<br />
dir HKLM:SoftwareMicrosoftWindowsCurrentVersionUninstall | foreach-object {get-itemproperty $<em>.PSPath} | where-object {$</em>.DisplayName -match "SQL Server"} | select-object DisplayName,uninstallstring<br />
` 

Taking this script apart, piece by piece&#8230;

_dir HKLM:SoftwareMicrosoftWindowsCurrentVersionUninstall_ lists all the registry keys beneath that location. It doesn&#8217;t just spit out a string name for each item like a Unix shell would, it returns a list of RegistryKey objects. These objects are passed to the next command in the pipeline&#8230;

_foreach-object {get-itemproperty $_.PSPath}_ is basically a for loop over each of those objects. It looks at the PSPath property of the RegistryKey objects and calls get-itemproperty on that path to return a list of registry items.

_where-object {$_.DisplayName -match &#8220;SQL Server&#8221;}_ selects just those registry items where the DisplayName property of the registry items match &#8220;SQL Server&#8221;. Finally, we clean up the output&#8230;

_select-object DisplayName,uninstallstring_ essentially takes the objects that are passed to it from the previous pipeline stage and slices them into smaller pieces, creating a new object for each object passed to it. The new object contains just the two properties specified on the command, DisplayPath and UninstallString.

Running this command gives me this output:

<pre>DisplayName                                                 UninstallString
-----------                                                 ---------------
GDR 1406 for SQL Server Integration Services 2005 (64-bi... C:WINDOWSDTS9_KB932557_ENU_64Hotfix.exe /Uninstall
GDR 1406 for SQL Server Notification Services 2005 (64-b... C:WINDOWSNS9_KB932557_ENU_64Hotfix.exe /Uninstall
GDR 1406 for SQL Server Analysis Services 2005 (64-bit) ... C:WINDOWSOLAP9_KB932557_ENU_64Hotfix.exe /Uninstall
GDR 1406 for SQL Server Reporting Services 2005 (64-bit)... C:WINDOWSRS9_KB932557_ENU_64Hotfix.exe /Uninstall
GDR 1406 for SQL Server Database Services 2005 (64-bit) ... C:WINDOWSSQL9_KB932557_ENU_64Hotfix.exe /Uninstall
GDR 1406 for SQL Server Tools and Workstation Components... C:WINDOWSSQLTools9_KB932557_ENU_64Hotfix.exe /Uninstall
Microsoft SQL Server 2005 (64-bit)                          "C:Program FilesMicrosoft SQL Server90Setup Bootstra...
Microsoft SQL Server Setup Support Files (English)          MsiExec.exe /X{18C5A65B-0A39-40B5-B958-63055AFAB65C}
Microsoft SQL Server VSS Writer                             MsiExec.exe /I{50822200-2E95-4E62-A8D8-41C3B308DF5E}
Microsoft SQL Server 2005 Analysis Services (64-bit)        MsiExec.exe /I{54C2B4E9-DD13-4AA4-B09A-A6EF68F9359A}
Microsoft SQL Server Native Client                          MsiExec.exe /I{6E740973-8E71-42F9-A910-C18452E60450}
Microsoft SQL Server 2005 Integration Services (64-bit)     MsiExec.exe /I{8A52D844-0DA7-40B0-8602-0567C068C081}
Microsoft SQL Server 2005 Reporting Services (64-bit)       MsiExec.exe /I{BEE3EC3D-0C91-4A3E-A42C-7634D32968F4}
Microsoft SQL Server 2005 Backward compatibility            MsiExec.exe /I{C92556F2-4950-48CF-ABA3-F0026B05BCE8}
MySQL Server 5.0                                            MsiExec.exe /I{D84E063A-AE58-41AF-B6FC-313B12DC89A6}
Microsoft SQL Server 2005 Notification Services (64-bit)    MsiExec.exe /I{EA145881-7452-4004-80B9-971FC3D1D8D8}
Microsoft SQL Server 2005 (64-bit)                          MsiExec.exe /I{F14F2E25-99AF-42A9-977C-F6D0352DC59F}
Microsoft SQL Server 2005 Tools (64-bit)                    MsiExec.exe /I{FE7C8861-3195-4CA5-98EB-094652478192}
</pre>

which is exactly what I wanted to find out in the first place. If I wanted to go further, I could run the uninstall command for these things automatically, but since I only had about 3 items I had to reinstall in my case, doing it by hand was no big deal.

Anyhow, consider this published so that when I need this trick next time, it will be waiting here, safe and sound, on my blog, ready for me to read again.

&#8212; bab