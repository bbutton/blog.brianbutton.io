---
title: “Cannot Create SSPI Context” and how to fix it
author: Brian Button
type: post
date: 2005-01-09T13:51:00+00:00
url: /index.php/2005/01/09/cannot-create-sspi-context-and-how-to-fix-it/
sfw_comment_form_password:
  - Ct8qI9iTSw2I
sfw_pwd:
  - Ok6r0eSCFWiT
categories:
  - Uncategorized

---
Just a quick note for anyone who has ever gotten this error before: &ldquo;Cannot create SSPI context&rdquo;. I started getting this error when I was trying to establish a connection to a SQL Server when I wasn&rsquo;t connected to the internal Microsoft corporate network. Connection strings that worked just fine when I was connected just wouldn&rsquo;t work at all, and I could not figure out how to fix it.

GIYF (Google Is Your Friend) I googled it and found out that I had my connection string set wrong. I was using localhost for the server name in the connection string, which is not correct. I needed to use the SQL Server name, not the hostname.

So I changed the server to brian-thinkpad, my machine name, and everything worked just fine.

Hopefully this will save someone else the hour or so of confusion I spent trying to fix this.

&mdash; bab

&nbsp;