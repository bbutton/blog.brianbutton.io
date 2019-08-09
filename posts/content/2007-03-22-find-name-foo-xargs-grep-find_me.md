---
title: 'find -name foo.* | xargs grep “find_me”'
author: Brian Button
type: post
date: 2007-03-22T16:50:00+00:00
url: /index.php/2007/03/22/find-name-foo-xargs-grep-find_me/
sfw_comment_form_password:
  - UgHctiqvxLzr
sfw_pwd:
  - mxG0TYDmS9A6
categories:
  - 142

---
**[Update from Brad Wilson and Scott Dukes]**

I&#8217;ve been wanting a powershell script to replace my favorite unix command for ages, and I took a stab at it today. This got me very close to what I wanted yesterday, which was just the names of files where the matches occurred. 

<pre>get-childitem -include foo.* -recurse | where-object { get-content $_ | select-string find_me }</pre>

Scott Dukes pointed out that select-string would take the FileInfo object that was passed to it and search through the contents for the string file_me, and this would give me the exact same kind of output my unix command used to. Thanks, Scott! This command was exactly what I needed.

Brad went _way_ past this and showed some [very interesting other changes to the script][1] to do some cool things.

Thanks again to both of them for correcting this PowerShell newbie. I&#8217;ve been a long-time Unix scripting weenie, with bash code flowing out my fingertips at will (in XEmacs of course :)), but I think PowerShell just blows that away.

&#8212; bab

 [1]: http://feeds.feedburner.com/~r/BradWilson-ThenetGuy/~3/103713896/22511.aspx