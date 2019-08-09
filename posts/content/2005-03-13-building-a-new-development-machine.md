---
title: Building a new development machine
author: Brian Button
type: post
date: 2005-03-13T08:32:00+00:00
url: /index.php/2005/03/13/building-a-new-development-machine/
sfw_comment_form_password:
  - IA999AkixvFV
sfw_pwd:
  - HfI6n4VVrMSh
categories:
  - Uncategorized

---
Update &mdash; Brad Wilson has given me some advice about RAM and video cards, and Sean Malloy advised me away from 25ms response time LCDs, so its back to the drawing board for those. I may also change out the Zalman cooler for one from Silenx as well as a couple new case fans.&nbsp;The Zalman cooler is actually about the same in terms of cost and noise,&nbsp;but the Silenx one doesn&rsquo;t have the freaky blue LEDs in it 🙂 The Silenx case fans are supposed to be&nbsp;_really_ quiet, so I may upgrade to those after the fact.&nbsp;

I have a little clarity now into my short to medium term future, which seems to be centered on windows development for a while. And I&rsquo;m getting tired of doing all my work on my little laptop keyboard and monitor. So I want to build a desktop machine that I can use while I&rsquo;m home. The only complication to it is that I want to be able to take my work with me when I go on the road. So here&rsquo;s what I decided to do:

First of all, I&rsquo;m going to jump on the Virtual Server bandwagon. I intend to build a PC that will allow me to do my development work in VPCs. These VPCs will live on an external 7200 RPM disk most of the time, but can be copied to my desktop machine for work when I&rsquo;m home. I&rsquo;ve become very pleased with the VPC style of development, especially in light of what happened to me last week. I was happily working away in VS.Net 2005 on a VPC and all of a sudden, everything locked up. I tried all kinds of things to get the VPC working again, until I finally tried to just copy the image some place else on the external drive. When this failed, I realized that my drive had failed.

No big deal at all. [Peter Provost][1] keeps a bunch of VPC images sysprepped based on our common dev environment, so I replace the hard drive, copied over a new VPC, set up the extra &ldquo;stuff&rdquo; that was needed, reinstalled VS.Net 2005, reloaded our dev software, and got our tests running. Start to finish of this process &mdash; 3 hours. Not bad 🙂

I figure I want to build the biggest, baddest PC I can, so it will support all this VPC stuff, and will also be upgradable over time. These are the parts I chose:

  * [Asus A8N-SLI Deluxe MB][2] &mdash; Asus customer service is terrible, awful, horrible, very bad. But they make a \*really\* nice MB. I had a graphics card of theirs die and they never got back to me about replacing it. I vowed never again to buy Asus, but their MBs are just so nice. I&rsquo;ll change my pledge to not buy anything else but their MBs 🙂 Anyhow, this is an AMD 64 board with a Socket 939 on it, does SLI, PCIe, has 8 SATA connections, 2 EIDE connections, a ton of RAID options, and all kinds of other features. Very cool board and very overclockable.
  * [AMD Athlon 64 3500+][3] &mdash; This seems to be at the right place in the price/performance curve right now. There are faster chips, but their price goes up quickly after this. When the 64 FX chip prices come down, I&rsquo;ll probably upgrade to that.
  * [Zalman CPU Cooler][4] &mdash; Supposed to be about the best air-cooler out there for Socket 939 boards
  * [PQI Turbo Series DDR400/PC3200 Dual Channel Platinum 1GBx2 RAM][5]
  * [BFG GeForce 6600GT OC 128Meg 2&ndash;DVI PCI-e][6] &mdash; Brad clued me in that there were video cards with dual-DVI output, which I really want to drive both of my LCDs. This card got great reviews and is very moderately priced
  * [2x WD 7200 RPM 40G 8M Cache EIDE drives][7] &mdash; 1 for the OS, 1 for swap
  * [Maxtor 7200.8 300G SATA drive][8] &mdash; for VPCs
  * [Plextor 16x DVD+-RW SATA drive][9]
  * [Samsung SymcMaster 711T 17&rdquo; LCD][10] &mdash; Still waffling on this one. It is still 25ms response time, but so is my 172T, and I haven&rsquo;t had any problems with that. I also don&rsquo;t play many games&hellip;
  * [Antec mid-tower case][11] &mdash; I already have one of these for a PC I built a couple of years ago, and I love it.
  * [Logitech LX700 Wireless keyboard and mouse][12] &mdash; Tried this at a store this weekend and not wild about it. Still looking

I&rsquo;d really love any comments about these choices. I intend this to the be the best dev PC I can build for the money, and game playing, etc is completely ancillary. If anyone has any suggestions about different components I should use, or has advice about these components, I&rsquo;d love to hear it.

I&rsquo;m also looking for a decent, but inexpensive, 2&ndash;port DVI/USB KVM. The Belkin one is supposed to be &ldquo;less than good&rdquo;, and the others are >$400 🙁

&mdash; bab

 [1]: http://peterprovost.org/
 [2]: http://usa.asus.com/products/mb/socket939/a8nsli-d/overview.htm
 [3]: http://www.amd.com/us-en/Processors/ProductInformation/0,,30_118_9485_9487,00.html
 [4]: http://www.zalmanusa.com/usa/product/view.asp?idx=147&code=005009
 [5]: http://www.pqimemory.com/spec.asp?link=/dc/PQI3200-2048DP.htm
 [6]: http://www.bfgtech.com/6600GT.html
 [7]: http://www.wdc.com/en/products/products.asp?DriveID=36
 [8]: http://www.seagate.com/cda/products/discsales/marketing/detail/0,1081,631,00.html
 [9]: http://www.plextor.com/english/products/716SA.htm
 [10]: http://product.samsung.com/cgi-bin/nabc/product/b2c_product_detail.jsp?eUser=&prod_id=MJ17BSABE&selTab=Specifications
 [11]: http://www.antec-inc.com/pro_details_enclosure.php?ProdID=80843
 [12]: http://www.logitech.com/index.cfm/products/details/CA/EN,CRID=486,CONTENTID=9438