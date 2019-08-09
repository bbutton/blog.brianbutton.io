---
title: Another powershell quickie – removing all bin and obj directories beneath VS.Net projects
author: Brian Button
type: post
date: 2007-06-23T10:32:00+00:00
url: /index.php/2007/06/23/another-powershell-quickie-removing-all-bin-and-obj-directories-beneath-vs-net-projects/
sfw_comment_form_password:
  - UPVueA0FvLZm
sfw_pwd:
  - VEvJJ0Q12qXL
categories:
  - 110
  - 112
  - 142

---
<font face="Courier New">gci -recurse -include bin,obj . | ri -recurse</font>

I was playing around with how to get this to work, and I couldn&#8217;t seem to figure out why these commands didn&#8217;t find the same locations to delete:

  * <font face="courier new">gci -recurse -include bin,obj .</font>
  * <font face="courier new">ri -recurse -force -include bin,obj -whatif .</font>

I finally got so baffled that I RTFMed remove-item, and there was my answer. In the fine print, nestled away in an example that did what I was looking for, and in the documentation for the recurse parameter was my answer&#8230;

_-recurse <SwitchParameter>  
Deletes the items in the specified locations and in all child items of the locations._ 

_**The Recurse parameter in this cmdlet does not work properly.**_

Ah ha! That&#8217;s when I went to the format that I finally settled on, and everything worked.

Another blog posting mostly written to help me remember how I solved this problem the next time I encounter it!

&#8212; bab