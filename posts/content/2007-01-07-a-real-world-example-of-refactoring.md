---
title: A Real World Example of Refactoring
author: Brian Button
type: post
date: 2007-01-07T12:41:00+00:00
url: /index.php/2007/01/07/a-real-world-example-of-refactoring/
sfw_comment_form_password:
  - b2yK8rJbaJLU
sfw_pwd:
  - mc7r6637DAE9
categories:
  - 111
  - 112

---
<!--
{rtf1ansiansicpglang1024noproof1252uc1 deff0{fonttbl{f0fnilfcharset0fprq1 Courier New;}}{colortbl;red0green0blue0;red0green0blue255;red0green255blue255;red0green255blue0??;red255green0blue255;red255green0blue0;red255green255blue0;red255green255blue255;??red0green0blue128;red0green128blue128;red0green128blue0;??red128green0blue128;red128green0blue0;red128green128blue0;red128green128blue128;??red192green192blue192;}??fs20     [cf10 TestFixturecf0 ]par ??    cf2 publiccf0  cf2 classcf0  cf10 ImageWriterFixturepar ??cf0     {par ??        cf2 privatecf0  cf10 Imagecf0  fullSizeLandscapeImage;par ??        cf2 privatecf0  cf10 Imagecf0  fullSizePortraitImage;par ??        cf2 privatecf0  cf10 MemoryStreamcf0  imageInStream;par ??par ??        [cf10 SetUpcf0 ]par ??        cf2 publiccf0  cf2 voidcf0  SetUp()par ??        {par ??            fullSizeLandscapeImage = cf2 newcf0  cf10 Bitmapcf0 (800, 600);par ??            fullSizePortraitImage = cf2 newcf0  cf10 Bitmapcf0 (600, 800);par ??            imageInStream = cf2 newcf0  cf10 MemoryStreamcf0 ();par ??        }par ??par ??        [cf10 TearDowncf0 ]par ??        cf2 publiccf0  cf2 voidcf0  ReleaseResources()par ??        {par ??            imageInStream.Dispose();par ??            fullSizeLandscapeImage.Dispose();par ??        }par ??par ??        [cf10 Testcf0 ]par ??        cf2 publiccf0  cf2 voidcf0  ImageWriteWillWriteFullSizeLandscapeImages()par ??        {par ??            cf10 ImageWritercf0  writer = cf10 ImageWritercf0 .GetFullSizeWriter(imageInStream);par ??            writer.Write(fullSizeLandscapeImage);par ??par ??            cf10 Imagecf0  rereadImage = ResizeImageFromStream();par ??par ??            cf10 Assertcf0 .AreEqual(fullSizeLandscapeImage.Height, rereadImage.Height);par ??            cf10 Assertcf0 .AreEqual(fullSizeLandscapeImage.Width, rereadImage.Width);par ??        }par ??par ??        cf2 privatecf0  cf10 Imagecf0  ResizeImageFromStream()par ??        {par ??            imageInStream.Seek(0, cf10 SeekOrigincf0 .Begin);par ??            cf2 returncf0  cf10 Imagecf0 .FromStream(imageInStream);par ??        }par ??par ??        [cf10 Testcf0 ]par ??        cf2 publiccf0  cf2 voidcf0  ImageWriterWillWriteDetailsLandscapeImages()par ??        {par ??            cf10 ImageWritercf0  writer = cf10 ImageWritercf0 .GetDetailsSizeWriter(imageInStream);par ??            writer.Write(fullSizeLandscapeImage);par ??par ??            cf10 Imagecf0  rereadImage = ResizeImageFromStream();par ??par ??            cf10 Assertcf0 .AreEqual(306, rereadImage.Height);par ??            cf10 Assertcf0 .AreEqual(408, rereadImage.Width);par ??        }par ??par ??        [cf10 Testcf0 ]par ??        cf2 publiccf0  cf2 voidcf0  ImageWriterWillWriteThumbnailLandscapeImages()par ??        {par ??            cf10 ImageWritercf0  writer = cf10 ImageWritercf0 .GetThumbnailSizeWriter(imageInStream);par ??            writer.Write(fullSizeLandscapeImage);par ??par ??            cf10 Imagecf0  rereadImage = ResizeImageFromStream();par ??par ??            cf10 Assertcf0 .AreEqual(105, rereadImage.Height);par ??            cf10 Assertcf0 .AreEqual(140, rereadImage.Width);par ??        }par ??par ??        [cf10 Testcf0 ]par ??        cf2 publiccf0  cf2 voidcf0  ImageWriterWillWriteFullSizePortraitImages()par ??        {par ??            cf10 ImageWritercf0  writer = cf10 ImageWritercf0 .GetFullSizeWriter(imageInStream);par ??            writer.Write(fullSizePortraitImage);par ??par ??            cf10 Imagecf0  rereadImage = ResizeImageFromStream();par ??par ??            cf10 Assertcf0 .AreEqual(800, rereadImage.Height);par ??            cf10 Assertcf0 .AreEqual(600, rereadImage.Width);par ??        }par ??par ??        [cf10 Testcf0 ]par ??        cf2 publiccf0  cf2 voidcf0  ImageWriterWillWriteDetailsSizePortraitImages()par ??        {par ??            cf10 ImageWritercf0  writer = cf10 ImageWritercf0 .GetDetailsSizeWriter(imageInStream);par ??            writer.Write(fullSizePortraitImage);par ??par ??            cf10 Imagecf0  rereadImage = ResizeImageFromStream();par ??par ??            cf10 Assertcf0 .AreEqual(306, rereadImage.Height);par ??            cf10 Assertcf0 .AreEqual(230, rereadImage.Width);            par ??        }par ??par ??        [cf10 Testcf0 ]par ??        cf2 publiccf0  cf2 voidcf0  ImageWriterWillWriteThumbnailSizePortraitImages()par ??        {par ??            cf10 ImageWritercf0  writer = cf10 ImageWritercf0 .GetThumbnailSizeWriter(imageInStream);par ??            writer.Write(fullSizePortraitImage);par ??par ??            cf10 Imagecf0  rereadImage = ResizeImageFromStream();par ??par ??            cf10 Assertcf0 .AreEqual(105, rereadImage.Height);par ??            cf10 Assertcf0 .AreEqual(79, rereadImage.Width);par ??        }par ??par ??    }par ??}
-->I&#8217;m leading an agile team through developing a web site. This means that I spend most of my time managing, but on this one occasion I had the opportunity to write some code.

**The problem**

We had an image stored in a database that was always either 800&#215;600 (portrait) or 600&#215;800 (landscape). We had a need to render that image on the site either as-is or reduced to one of two other sizes. You can think of this as a thumbnail, a details image, and a full-size image. We were (of course) writing the code test first, and the tests were focusing on getting the sizes right and not so much on checking the generated images. We ended up getting it working, but we were thoroughly disgusted with the code that we produced 🙂 At least we _knew_ the code was bad, and resolved to fix it when we had a chance.

Before we get into the application code, let&#8217;s look at the tests we wrote, and I&#8217;ll explain the evolution of the code and what the classes involved are.

As you can see, the class under test is called ImageWriter. It came into being because we were being careful about resource management, so we didn&#8217;t want to resize an image and expose it to the world, where it might not get disposed. So, our concept was to create this class, whose purpose in life is to write a properly sized image to a Stream. It would ensure that the image was sized correctly, it was put into the stream properly, and the resources were reclaimed. Sounds pretty simple, and it was, other than some ugly switch logic.

We wrote the first three tests you see below first, starting with just taking in the full-sized landscape image and writing that to the stream. This wasn&#8217;t a hard test to get working, as you might expect. We followed that up with writing the detail-sized image, which forced us to write a conditional statement to choose between the two sizes. And then we wrote the third test, which caused us to write another else to allow us to choose thumbnail-sized images. At the fourth test, it started to get really ugly when we had to decide if the image was portrait or landscape, which added a totally different conditional statement. Very rapidly this code was becoming unwieldy. We quickly wrote the fifth and sixth tests, just to get the functionality working, since we were just following an already existing pattern, ugly though it was. Once we were finished, though, we knew we needed to refactor this beast before checking it in.

<div style="font-family: Courier New; font-size: 10pt; color: black; background: white;">
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 7</span> [<span style="color: teal;">TestFixture</span>]
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 8</span> <span style="color: blue;">public</span> <span style="color: blue;">class</span> <span style="color: teal;">ImageWriterFixture</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 9</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 10</span> <span style="color: blue;">private</span> <span style="color: teal;">Image</span> fullSizeLandscapeImage;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 11</span> <span style="color: blue;">private</span> <span style="color: teal;">Image</span> fullSizePortraitImage;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 12</span> <span style="color: blue;">private</span> <span style="color: teal;">MemoryStream</span> imageInStream;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 13</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 14</span> [<span style="color: teal;">SetUp</span>]
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 15</span> <span style="color: blue;">public</span> <span style="color: blue;">void</span> SetUp()
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 16</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 17</span> fullSizeLandscapeImage = <span style="color: blue;">new</span> <span style="color: teal;">Bitmap</span>(800, 600);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 18</span> fullSizePortraitImage = <span style="color: blue;">new</span> <span style="color: teal;">Bitmap</span>(600, 800);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 19</span> imageInStream = <span style="color: blue;">new</span> <span style="color: teal;">MemoryStream</span>();
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 20</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 21</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 22</span> [<span style="color: teal;">TearDown</span>]
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 23</span> <span style="color: blue;">public</span> <span style="color: blue;">void</span> ReleaseResources()
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 24</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 25</span> imageInStream.Dispose();
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 26</span> fullSizeLandscapeImage.Dispose();
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 27</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 28</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 29</span> [<span style="color: teal;">Test</span>]
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 30</span> <span style="color: blue;">public</span> <span style="color: blue;">void</span> ImageWriteWillWriteFullSizeLandscapeImages()
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 31</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 32</span> <span style="color: teal;">ImageWriter</span> writer = <span style="color: teal;">ImageWriter</span>.GetFullSizeWriter(imageInStream);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 33</span> writer.Write(fullSizeLandscapeImage);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 34</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 35</span> <span style="color: teal;">Image</span> rereadImage = ResizeImageFromStream();
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 36</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 37</span> <span style="color: teal;">Assert</span>.AreEqual(fullSizeLandscapeImage.Height, rereadImage.Height);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 38</span> <span style="color: teal;">Assert</span>.AreEqual(fullSizeLandscapeImage.Width, rereadImage.Width);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 39</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 40</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 41</span> <span style="color: blue;">private</span> <span style="color: teal;">Image</span> ResizeImageFromStream()
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 42</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 43</span> imageInStream.Seek(0, <span style="color: teal;">SeekOrigin</span>.Begin);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 44</span> <span style="color: blue;">return</span> <span style="color: teal;">Image</span>.FromStream(imageInStream);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 45</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 46</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 47</span> [<span style="color: teal;">Test</span>]
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 48</span> <span style="color: blue;">public</span> <span style="color: blue;">void</span> ImageWriterWillWriteDetailsLandscapeImages()
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 49</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 50</span> <span style="color: teal;">ImageWriter</span> writer = <span style="color: teal;">ImageWriter</span>.GetDetailsSizeWriter(imageInStream);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 51</span> writer.Write(fullSizeLandscapeImage);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 52</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 53</span> <span style="color: teal;">Image</span> rereadImage = ResizeImageFromStream();
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 54</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 55</span> <span style="color: teal;">Assert</span>.AreEqual(306, rereadImage.Height);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 56</span> <span style="color: teal;">Assert</span>.AreEqual(408, rereadImage.Width);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 57</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 58</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 59</span> [<span style="color: teal;">Test</span>]
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 60</span> <span style="color: blue;">public</span> <span style="color: blue;">void</span> ImageWriterWillWriteThumbnailLandscapeImages()
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 61</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 62</span> <span style="color: teal;">ImageWriter</span> writer = <span style="color: teal;">ImageWriter</span>.GetThumbnailSizeWriter(imageInStream);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 63</span> writer.Write(fullSizeLandscapeImage);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 64</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 65</span> <span style="color: teal;">Image</span> rereadImage = ResizeImageFromStream();
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 66</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 67</span> <span style="color: teal;">Assert</span>.AreEqual(105, rereadImage.Height);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 68</span> <span style="color: teal;">Assert</span>.AreEqual(140, rereadImage.Width);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 69</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 70</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 71</span> [<span style="color: teal;">Test</span>]
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 72</span> <span style="color: blue;">public</span> <span style="color: blue;">void</span> ImageWriterWillWriteFullSizePortraitImages()
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 73</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 74</span> <span style="color: teal;">ImageWriter</span> writer = <span style="color: teal;">ImageWriter</span>.GetFullSizeWriter(imageInStream);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 75</span> writer.Write(fullSizePortraitImage);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 76</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 77</span> <span style="color: teal;">Image</span> rereadImage = ResizeImageFromStream();
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 78</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 79</span> <span style="color: teal;">Assert</span>.AreEqual(800, rereadImage.Height);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 80</span> <span style="color: teal;">Assert</span>.AreEqual(600, rereadImage.Width);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 81</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 82</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 83</span> [<span style="color: teal;">Test</span>]
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 84</span> <span style="color: blue;">public</span> <span style="color: blue;">void</span> ImageWriterWillWriteDetailsSizePortraitImages()
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 85</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 86</span> <span style="color: teal;">ImageWriter</span> writer = <span style="color: teal;">ImageWriter</span>.GetDetailsSizeWriter(imageInStream);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 87</span> writer.Write(fullSizePortraitImage);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 88</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 89</span> <span style="color: teal;">Image</span> rereadImage = ResizeImageFromStream();
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 90</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 91</span> <span style="color: teal;">Assert</span>.AreEqual(306, rereadImage.Height);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 92</span> <span style="color: teal;">Assert</span>.AreEqual(230, rereadImage.Width);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 93</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 94</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 95</span> [<span style="color: teal;">Test</span>]
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 96</span> <span style="color: blue;">public</span> <span style="color: blue;">void</span> ImageWriterWillWriteThumbnailSizePortraitImages()
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 97</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 98</span> <span style="color: teal;">ImageWriter</span> writer = <span style="color: teal;">ImageWriter</span>.GetThumbnailSizeWriter(imageInStream);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 99</span> writer.Write(fullSizePortraitImage);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 100</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 101</span> <span style="color: teal;">Image</span> rereadImage = ResizeImageFromStream();
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 102</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 103</span> <span style="color: teal;">Assert</span>.AreEqual(105, rereadImage.Height);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 104</span> <span style="color: teal;">Assert</span>.AreEqual(79, rereadImage.Width);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 105</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 106</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 107</span> }
  </p>
</div>

Now here is the finished, but mostly unrefactored, source code. During the process of writing the tests, we did do some refactoring to clean up the code a bit, make things a bit more readable, etc, but we held off on the Replace Conditional with Polymorphism refactoring that we could both see coming. And that refactoring is what I want to eventually share here. So, here is our ugly code:

<div style="font-family: Courier New; font-size: 10pt; color: black; background: white;">
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 1</span> <span style="color: blue;">public</span> <span style="color: blue;">class</span> <span style="color: teal;">ImageWriter</span> : <span style="color: teal;">IImageWriter</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 2</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 3</span> <span style="color: blue;">private</span> <span style="color: teal;">Stream</span> stream;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 4</span> <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: teal;">ImageSize</span> desiredImageSize;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 5</span> <span style="color: blue;">private</span> <span style="color: blue;">int</span> desiredHeight;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 6</span> <span style="color: blue;">private</span> <span style="color: blue;">int</span> desiredWidth;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 7</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 8</span> <span style="color: blue;">private</span> <span style="color: blue;">enum</span> <span style="color: teal;">ImageSize</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 9</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 10</span> THUMBNAIL,
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 11</span> DETAILS,
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 12</span> FULLSIZE
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 13</span> } ;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 14</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 15</span> <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: teal;">Rectangle</span> LandscapeFullSize = <span style="color: blue;">new</span> <span style="color: teal;">Rectangle</span>(0, 0, 800, 600);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 16</span> <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: teal;">Rectangle</span> LandscapeDetailsSize = <span style="color: blue;">new</span> <span style="color: teal;">Rectangle</span>(0, 0, 408, 306);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 17</span> <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: teal;">Rectangle</span> LandscapeThumbnailSize = <span style="color: blue;">new</span> <span style="color: teal;">Rectangle</span>(0, 0, 140, 105);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 18</span> <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: teal;">Rectangle</span> PortraitFullSize = <span style="color: blue;">new</span> <span style="color: teal;">Rectangle</span>(0, 0, 600, 800);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 19</span> <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: teal;">Rectangle</span> PortraitDetailsSize = <span style="color: blue;">new</span> <span style="color: teal;">Rectangle</span>(0,0, 230, 306);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 20</span> <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: teal;">Rectangle</span> PortraitThumbnailSize = <span style="color: blue;">new</span> <span style="color: teal;">Rectangle</span>(0, 0, 79, 105);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 21</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 22</span> <span style="color: blue;">public</span> <span style="color: blue;">static</span> <span style="color: teal;">ImageWriter</span> GetFullSizeWriter(<span style="color: teal;">Stream</span> imageInStream)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 23</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 24</span> <span style="color: blue;">return</span> <span style="color: blue;">new</span> <span style="color: teal;">ImageWriter</span>(imageInStream, <span style="color: teal;">ImageSize</span>.FULLSIZE);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 25</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 26</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 27</span> <span style="color: blue;">public</span> <span style="color: blue;">static</span> <span style="color: teal;">ImageWriter</span> GetDetailsSizeWriter(<span style="color: teal;">Stream</span> imageInStream)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 28</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 29</span> <span style="color: blue;">return</span> <span style="color: blue;">new</span> <span style="color: teal;">ImageWriter</span>(imageInStream, <span style="color: teal;">ImageSize</span>.DETAILS);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 30</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 31</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 32</span> <span style="color: blue;">public</span> <span style="color: blue;">static</span> <span style="color: teal;">ImageWriter</span> GetThumbnailSizeWriter(<span style="color: teal;">Stream</span> imageInStream)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 33</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 34</span> <span style="color: blue;">return</span> <span style="color: blue;">new</span> <span style="color: teal;">ImageWriter</span>(imageInStream, <span style="color: teal;">ImageSize</span>.THUMBNAIL);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 35</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 36</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 37</span> <span style="color: blue;">private</span> ImageWriter(<span style="color: teal;">Stream</span> stream, <span style="color: teal;">ImageSize</span> imageSize)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 38</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 39</span> <span style="color: blue;">this</span>.stream = stream;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 40</span> desiredImageSize = imageSize;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 41</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 42</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 43</span> <span style="color: blue;">public</span> <span style="color: blue;">void</span> Write(<span style="color: teal;">Image</span> image)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 44</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 45</span> <span style="color: blue;">int</span> width = image.Width;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 46</span> <span style="color: blue;">int</span> height = image.Height;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 47</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 48</span> <span style="color: blue;">if</span> (width < height) <span style="color: green;">// isPortrait</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 49</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 50</span> <span style="color: blue;">switch</span>(desiredImageSize)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 51</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 52</span> <span style="color: blue;">case</span> <span style="color: teal;">ImageSize</span>.FULLSIZE:
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 53</span> desiredHeight = PortraitFullSize.Height;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 54</span> desiredWidth = PortraitFullSize.Width;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 55</span> <span style="color: blue;">break</span>;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 56</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 57</span> <span style="color: blue;">case</span> <span style="color: teal;">ImageSize</span>.DETAILS:
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 58</span> desiredHeight = PortraitDetailsSize.Height;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 59</span> desiredWidth = PortraitDetailsSize.Width;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 60</span> <span style="color: blue;">break</span>;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 61</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 62</span> <span style="color: blue;">case</span> <span style="color: teal;">ImageSize</span>.THUMBNAIL:
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 63</span> desiredHeight = PortraitThumbnailSize.Height;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 64</span> desiredWidth = PortraitThumbnailSize.Width;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 65</span> <span style="color: blue;">break</span>;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 66</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 67</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 68</span> <span style="color: blue;">else</span> <span style="color: green;">// isLandscape</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 69</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 70</span> <span style="color: blue;">switch</span>(desiredImageSize)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 71</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 72</span> <span style="color: blue;">case</span> <span style="color: teal;">ImageSize</span>.FULLSIZE:
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 73</span> desiredHeight = LandscapeFullSize.Height;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 74</span> desiredWidth = LandscapeFullSize.Width;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 75</span> <span style="color: blue;">break</span>;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 76</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 77</span> <span style="color: blue;">case</span> <span style="color: teal;">ImageSize</span>.DETAILS:
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 78</span> desiredHeight = LandscapeDetailsSize.Height;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 79</span> desiredWidth = LandscapeDetailsSize.Width;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 80</span> <span style="color: blue;">break</span>;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 81</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 82</span> <span style="color: blue;">case</span> <span style="color: teal;">ImageSize</span>.THUMBNAIL:
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 83</span> desiredHeight = LandscapeThumbnailSize.Height;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 84</span> desiredWidth = LandscapeThumbnailSize.Width;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 85</span> <span style="color: blue;">break</span>;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 86</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 87</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 88</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 89</span> <span style="color: blue;">using</span> (<span style="color: teal;">Image</span> resized = image.GetThumbnailImage(desiredWidth, desiredHeight, <span style="color: blue;">null</span>, <span style="color: teal;">IntPtr</span>.Zero))
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 90</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 91</span> resized.Save(stream, <span style="color: teal;">ImageFormat</span>.Jpeg);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 92</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 93</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 94</span> }
  </p>
</div>

The bright idea we had while we were writing it was that we would use the Rectangles to hold the dimensions of an image of the proper size, to make it easier to identify what the magic numbers for height and width meant. This also made it easier for us to write the body of each leg of the case statements. Clearly, however, this was only a short term workaround for a more proper solution later.

**Beginning the refactoring**

OK, so we&#8217;re about to start this. I truly have never attempted the refactoring that we&#8217;re going to try here on this code, so I&#8217;m going to be doing it essentially live for you. I&#8217;ll try to share with you any mistakes I make, what thoughts are going through my semi-sentient head, and what I&#8217;m feeling about the code as it progresses. Our goal is to end up in a situation where any conditional behavior is moved out of a procedural if/then/else block and into some sort of polymorphic dispatch, but to do that in small, orderly steps, such that we&#8217;re always pretty close to having working code.

To begin, I&#8217;m planning on opening up my refactoring book to the section on Replace Conditional with Polymorphism. As I tell my students in every TDD course I teach, _please_ open your Fowler Refactoring books and follow the steps, as Martin makes these things easy once you figure out which refactoring to use. So, to follow my own advice, I&#8217;m going to open the book and use it as I go.

**First step &#8212; Are the responsibilities in the right place?**

The first thing I notice when I look at the ImageWriter&#8217;s Write method is that I see policy and details happening in the same place. The policy in that class can be summed up as, "Determine the dimensions of the final image, resize the image, and then write the image to the stream", and the details in that method are concerned with how those dimensions are determined. In order for us to do anything at all to simplify this system, we&#8217;re going to have to pull the dimension calculations out into another method at least, and into another class possibly after that. So lets start with an ExtractMethod refactoring to get those dimension calculations out of there.

As my first step in doing this, I noticed that the member variables desiredHeight and desiredWidth weren&#8217;t really doing anything good for me, and I could get rid of them by using height and width, the local variables declared in the Write method, in their place, as such:

<div style="font-family: Courier New; font-size: 10pt; color: black; background: white;">
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 1</span> <span style="color: blue;">public</span> <span style="color: blue;">void</span> Write(<span style="color: teal;">Image</span> image)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 2</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 3</span> <span style="color: blue;">int</span> width = image.Width;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 4</span> <span style="color: blue;">int</span> height = image.Height;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 5</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 6</span> <span style="color: blue;">if</span> (width < height) <span style="color: green;">// isPortrait</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 7</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 8</span> <span style="color: blue;">switch</span>(desiredImageSize)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 9</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 10</span> <span style="color: blue;">case</span> <span style="color: teal;">ImageSize</span>.FULLSIZE:
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 11</span> height = PortraitFullSize.Height;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 12</span> width = PortraitFullSize.Width;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 13</span> <span style="color: blue;">break</span>;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 14</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 15</span> <span style="color: blue;">case</span> <span style="color: teal;">ImageSize</span>.DETAILS:
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 16</span> height = PortraitDetailsSize.Height;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 17</span> width = PortraitDetailsSize.Width;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 18</span> <span style="color: blue;">break</span>;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 19</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 20</span> <span style="color: blue;">case</span> <span style="color: teal;">ImageSize</span>.THUMBNAIL:
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 21</span> height = PortraitThumbnailSize.Height;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 22</span> width = PortraitThumbnailSize.Width;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 23</span> <span style="color: blue;">break</span>;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 24</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 25</span> }
  </p>
</div>

and so on. I think this sets me up very nicely to get rid of the individual width and height variables and replacing them with a Rectangle object. I&#8217;m going to try that in the code and see where that takes me. I&#8217;m not going to make this whole change all at once, because that&#8217;s too large of a change. Instead, I&#8217;m going to find a way to refactor each leg of the switch to contain the assignment to the desiredRectangle reference and then take advantage of that rectangle to set the height and width repeatedly.

<div style="font-family: Courier New; font-size: 10pt; color: black; background: white;">
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 48</span> <span style="color: blue;">public</span> <span style="color: blue;">void</span> Write(<span style="color: teal;">Image</span> image)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 49</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 50</span> <span style="color: teal;">Rectangle</span> desiredRectangle;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 51</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 52</span> <span style="color: blue;">int</span> width = image.Width;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 53</span> <span style="color: blue;">int</span> height = image.Height;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 54</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 55</span> <span style="color: blue;">if</span> (width < height) <span style="color: green;">// isPortrait</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 56</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 57</span> <span style="color: blue;">switch</span>(desiredImageSize)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 58</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 59</span> <span style="color: blue;">case</span> <span style="color: teal;">ImageSize</span>.FULLSIZE:
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 60</span> desiredRectangle = PortraitFullSize;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 61</span> height = desiredRectangle.Height;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 62</span> width = desiredRectangle.Width;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 63</span> <span style="color: blue;">break</span>;
  </p>
</div>

As you can see, I added a new Rectangle reference on line 50 which is going to hold the rectangle with the desired dimensions. And the smallest change I could make to start making use of this was to rewrite the body of the case statement starting on line 60 as you can see. For those of you new to refactoring, this is one of the most important pieces of the process &#8212; take steps that are as small as possible. By doing this, you keep your risk down as low as possible while you&#8217;re changing your code. If you take big steps and mess something up, it could take you a lot of time to get back to having something working. If you take a small step and mess something up, you can just back up a bit to where things worked. I&#8217;m taking a small step here, and just changing this leg of the switch. And after doing this, I ran my tests, and they worked. I&#8217;m going to change the rest of the legs now, running my tests between each change. I&#8217;ll do this privately, as it doesn&#8217;t seem very interesting to show you each step along this way.

<time passes>

OK, I did that, and all my tests worked, and each of the legs of the switches looks just like the sample code above, except for a different equivalent of line 60 for each case. Now that I&#8217;ve done this, I believe I can factor out the setting of the height and width in each leg and do that at the bottom of the method, right before actually doing the resizing. That will leave the code looking like this:

<div style="font-family: Courier New; font-size: 10pt; color: black; background: white;">
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 48</span> <span style="color: blue;">public</span> <span style="color: blue;">void</span> Write(<span style="color: teal;">Image</span> image)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 49</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 50</span> <span style="color: teal;">Rectangle</span> desiredRectangle = <span style="color: blue;">new</span> <span style="color: teal;">Rectangle</span>();
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 51</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 52</span> <span style="color: blue;">if</span> (image.Width < image.Height) <span style="color: green;">// isPortrait</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 53</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 54</span> <span style="color: blue;">switch</span>(desiredImageSize)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 55</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 56</span> <span style="color: blue;">case</span> <span style="color: teal;">ImageSize</span>.FULLSIZE:
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 57</span> desiredRectangle = PortraitFullSize;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 58</span> <span style="color: blue;">break</span>;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 59</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 60</span> <span style="color: blue;">case</span> <span style="color: teal;">ImageSize</span>.DETAILS:
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 61</span> desiredRectangle = PortraitDetailsSize;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 62</span> <span style="color: blue;">break</span>;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 63</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 64</span> <span style="color: blue;">case</span> <span style="color: teal;">ImageSize</span>.THUMBNAIL:
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 65</span> desiredRectangle = PortraitThumbnailSize;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 66</span> <span style="color: blue;">break</span>;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 67</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 68</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 69</span> <span style="color: blue;">else</span> <span style="color: green;">// isLandscape</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 70</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 71 // extra stuff elided</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 85</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 86</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 87</span> <span style="color: blue;">int</span> height = desiredRectangle.Height;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 88</span> <span style="color: blue;">int</span> width = desiredRectangle.Width;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 89</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 90</span> <span style="color: blue;">using</span> (<span style="color: teal;">Image</span> resized = image.GetThumbnailImage(width, height, <span style="color: blue;">null</span>, <span style="color: teal;">IntPtr</span>.Zero))
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 91</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 92</span> resized.Save(stream, <span style="color: teal;">ImageFormat</span>.Jpeg);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 93</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 94</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 95</span> }
  </p>
</div>

So each leg of the switches has become more simple and we&#8217;re breaking out the height and width individually now only at the end. During the next refactoring, I&#8217;ll probably do an Inline refactoring on height and width, as they&#8217;re really not helping much, which would shrink this method down even more.

Now that we&#8217;re at this point, I think I can do the ExtractMethod I talked about previously on the switch stuff and move that out into another method, so we can make the Write method only concerned with the higher level, more abstract steps of how this process works, and get the details of how the dimensions are calculated into its own method. After this refactoring, another ExtractMethod to take the mechanics of the writing to the stream out, and a couple of renamings to clarify what the rectangle dimension calculations actually _mean_, Write looks like this, which is just about right 🙂

<div style="font-family: Courier New; font-size: 10pt; color: black; background: white;">
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 48</span> <span style="color: blue;">public</span> <span style="color: blue;">void</span> Write(<span style="color: teal;">Image</span> image)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 49</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 50</span> <span style="color: teal;">Rectangle</span> imageDimensions = CalculateScaledImageDimensions(image);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 51</span> WriteScaledImage(image, imageDimensions);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 52</span> }
  </p>
</div>

**A decision needs to be made**

I&#8217;m at somewhat of a crossroads here. In looking back at the Write method, I&#8217;ve decided I really don&#8217;t like it. Something just seems strange to me about it. I know I need to do something with scaled images, but instead I&#8217;m working with the dimensions of that scaled image. To me, the calculations of the dimensions of the scaled images and storing those dimensions into a rectangle seems like an implementation detail of _how_ I did this. What the code really needs to be using, and written in terms of, are the scaled images themselves. In doing this, I think the method will now read better, since both lines of code in it will be using the same abstraction. Instead of using a Rectangle to represent something _about_ the scaled image, now I can deal with the scaled image throughout the method. I like this better. This leads us to this code:

<div style="font-family: Courier New; font-size: 10pt; color: black; background: white;">
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 48</span> <span style="color: blue;">public</span> <span style="color: blue;">void</span> Write(<span style="color: teal;">Image</span> image)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 49</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 50</span> <span style="color: blue;">using</span> (<span style="color: teal;">Image</span> scaledImage = GenerateScaledImage(image))
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 51</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 52</span> WriteScaledImage(scaledImage);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 53</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 54</span> }
  </p>
</div>

I like this a lot better, as it seems like both of the lines of this method are dealing with the same abstraction now, a ScaledImage. This leads me to think that there is a ScaledImage class or hierarchy of classes trying to find its way out, which was our goal when we started this &#8212; we were looking for the right place to put our polymorphic logic, and this ScaledImage class seems like the right place. The final code for this class looks like this:

<!--
{rtf1ansiansicpglang1024noproof1252uc1 deff0{fonttbl{f0fnilfcharset0fprq1 Courier New;}}{colortbl;red0green0blue0;red0green0blue255;red0green255blue255;red0green255blue0??;red255green0blue255;red255green0blue0;red255green255blue0;red255green255blue255;??red0green0blue128;red0green128blue128;red0green128blue0;??red128green0blue128;red128green0blue0;red128green128blue0;red128green128blue128;??red192green192blue192;}??fs20     cf2 publiccf0  cf2 classcf0  cf10 ImageWritercf0  : cf10 IImageWriterpar ??cf0     {par ??        cf2 privatecf0  cf10 Streamcf0  stream;par ??        cf2 privatecf0  cf2 readonlycf0  cf10 ImageSizecf0  desiredImageSize;par ??par ??        cf2 privatecf0  cf2 enumcf0  cf10 ImageSizepar ??cf0         {par ??            THUMBNAIL,par ??            DETAILS,par ??            FULLSIZEpar ??        } ;par ??par ??        cf2 privatecf0  cf2 readonlycf0  cf10 Rectanglecf0  LandscapeFullSize = cf2 newcf0  cf10 Rectanglecf0 (0, 0, 800, 600);par ??        cf2 privatecf0  cf2 readonlycf0  cf10 Rectanglecf0  LandscapeDetailsSize = cf2 newcf0  cf10 Rectanglecf0 (0, 0, 408, 306);par ??        cf2 privatecf0  cf2 readonlycf0  cf10 Rectanglecf0  LandscapeThumbnailSize = cf2 newcf0  cf10 Rectanglecf0 (0, 0, 140, 105);par ??        cf2 privatecf0  cf2 readonlycf0  cf10 Rectanglecf0  PortraitFullSize = cf2 newcf0  cf10 Rectanglecf0 (0, 0, 600, 800);par ??        cf2 privatecf0  cf2 readonlycf0  cf10 Rectanglecf0  PortraitDetailsSize = cf2 newcf0  cf10 Rectanglecf0 (0,0, 230, 306);par ??        cf2 privatecf0  cf2 readonlycf0  cf10 Rectanglecf0  PortraitThumbnailSize = cf2 newcf0  cf10 Rectanglecf0 (0, 0, 79, 105);par ??par ??        cf2 publiccf0  cf2 staticcf0  cf10 ImageWritercf0  GetFullSizeWriter(cf10 Streamcf0  imageInStream)par ??        {par ??            cf2 returncf0  cf2 newcf0  cf10 ImageWritercf0 (imageInStream, cf10 ImageSizecf0 .FULLSIZE);par ??        }par ??par ??        cf2 publiccf0  cf2 staticcf0  cf10 ImageWritercf0  GetDetailsSizeWriter(cf10 Streamcf0  imageInStream)par ??        {par ??            cf2 returncf0  cf2 newcf0  cf10 ImageWritercf0 (imageInStream, cf10 ImageSizecf0 .DETAILS);par ??        }par ??par ??        cf2 publiccf0  cf2 staticcf0  cf10 ImageWritercf0  GetThumbnailSizeWriter(cf10 Streamcf0  imageInStream)par ??        {par ??            cf2 returncf0  cf2 newcf0  cf10 ImageWritercf0 (imageInStream, cf10 ImageSizecf0 .THUMBNAIL);par ??        }par ??par ??        cf2 privatecf0  ImageWriter(cf10 Streamcf0  stream, cf10 ImageSizecf0  imageSize)par ??        {par ??            cf2 thiscf0 .stream = stream;par ??            desiredImageSize = imageSize;par ??        }par ??par ??        cf2 publiccf0  cf2 voidcf0  Write(cf10 Imagecf0  image)par ??        {par ??            cf2 usingcf0  (cf10 Imagecf0  scaledImage = GenerateScaledImage(image))par ??            {par ??                WriteScaledImage(scaledImage);par ??            }par ??        }par ??par ??        cf2 privatecf0  cf2 voidcf0  WriteScaledImage(cf10 Imagecf0  scaledImage)par ??        {par ??            scaledImage.Save(stream, cf10 ImageFormatcf0 .Jpeg);par ??        }par ??par ??        cf2 privatecf0  cf10 Imagecf0  GenerateScaledImage(cf10 Imagecf0  image)par ??        {par ??            cf10 Rectanglecf0  imageDimensions = cf2 newcf0  cf10 Rectanglecf0 ();par ??par ??            cf2 ifcf0  (image.Width < image.Height) cf11 // isPortraitpar ??cf0             {par ??                cf2 switchcf0 (desiredImageSize)par ??                {par ??                    cf2 casecf0  cf10 ImageSizecf0 .FULLSIZE:par ??                        imageDimensions = PortraitFullSize;par ??                        cf2 breakcf0 ;par ??                        par ??                    cf2 casecf0  cf10 ImageSizecf0 .DETAILS:par ??                        imageDimensions = PortraitDetailsSize;par ??                        cf2 breakcf0 ;par ??par ??                    cf2 casecf0  cf10 ImageSizecf0 .THUMBNAIL:par ??                        imageDimensions = PortraitThumbnailSize;par ??                        cf2 breakcf0 ;par ??                }par ??            }par ??            cf2 elsecf0  cf11 // isLandscapepar ??cf0             {par ??                cf2 switchcf0 (desiredImageSize)par ??                {par ??                    cf2 casecf0  cf10 ImageSizecf0 .FULLSIZE:par ??                        imageDimensions = LandscapeFullSize;par ??                        cf2 breakcf0 ;par ??par ??                    cf2 casecf0  cf10 ImageSizecf0 .DETAILS:par ??                        imageDimensions = LandscapeDetailsSize;par ??                        cf2 breakcf0 ;par ??par ??                    cf2 casecf0  cf10 ImageSizecf0 .THUMBNAIL:par ??                        imageDimensions = LandscapeThumbnailSize;par ??                        cf2 breakcf0 ;par ??                }par ??            }par ??par ??            cf2 returncf0  image.GetThumbnailImage(imageDimensions.Width, imageDimensions.Height, cf2 nullcf0 , cf10 IntPtrcf0 .Zero);;par ??        }par ??    }par ??}
-->

<div style="font-family: Courier New; font-size: 10pt; color: black; background: white;">
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 8</span> <span style="color: blue;">public</span> <span style="color: blue;">class</span> <span style="color: teal;">ImageWriter</span> : <span style="color: teal;">IImageWriter</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 9</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 10</span> <span style="color: blue;">private</span> <span style="color: teal;">Stream</span> stream;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 11</span> <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: teal;">ImageSize</span> desiredImageSize;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 12</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 13</span> <span style="color: blue;">private</span> <span style="color: blue;">enum</span> <span style="color: teal;">ImageSize</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 14</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 15</span> THUMBNAIL,
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 16</span> DETAILS,
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 17</span> FULLSIZE
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 18</span> } ;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 19</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 20</span> <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: teal;">Rectangle</span> LandscapeFullSize = <span style="color: blue;">new</span> <span style="color: teal;">Rectangle</span>(0, 0, 800, 600);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 21</span> <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: teal;">Rectangle</span> LandscapeDetailsSize = <span style="color: blue;">new</span> <span style="color: teal;">Rectangle</span>(0, 0, 408, 306);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 22</span> <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: teal;">Rectangle</span> LandscapeThumbnailSize = <span style="color: blue;">new</span> <span style="color: teal;">Rectangle</span>(0, 0, 140, 105);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 23</span> <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: teal;">Rectangle</span> PortraitFullSize = <span style="color: blue;">new</span> <span style="color: teal;">Rectangle</span>(0, 0, 600, 800);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 24</span> <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: teal;">Rectangle</span> PortraitDetailsSize = <span style="color: blue;">new</span> <span style="color: teal;">Rectangle</span>(0,0, 230, 306);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 25</span> <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: teal;">Rectangle</span> PortraitThumbnailSize = <span style="color: blue;">new</span> <span style="color: teal;">Rectangle</span>(0, 0, 79, 105);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 26</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 27</span> <span style="color: blue;">public</span> <span style="color: blue;">static</span> <span style="color: teal;">ImageWriter</span> GetFullSizeWriter(<span style="color: teal;">Stream</span> imageInStream)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 28</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 29</span> <span style="color: blue;">return</span> <span style="color: blue;">new</span> <span style="color: teal;">ImageWriter</span>(imageInStream, <span style="color: teal;">ImageSize</span>.FULLSIZE);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 30</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 31</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 32</span> <span style="color: blue;">public</span> <span style="color: blue;">static</span> <span style="color: teal;">ImageWriter</span> GetDetailsSizeWriter(<span style="color: teal;">Stream</span> imageInStream)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 33</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 34</span> <span style="color: blue;">return</span> <span style="color: blue;">new</span> <span style="color: teal;">ImageWriter</span>(imageInStream, <span style="color: teal;">ImageSize</span>.DETAILS);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 35</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 36</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 37</span> <span style="color: blue;">public</span> <span style="color: blue;">static</span> <span style="color: teal;">ImageWriter</span> GetThumbnailSizeWriter(<span style="color: teal;">Stream</span> imageInStream)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 38</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 39</span> <span style="color: blue;">return</span> <span style="color: blue;">new</span> <span style="color: teal;">ImageWriter</span>(imageInStream, <span style="color: teal;">ImageSize</span>.THUMBNAIL);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 40</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 41</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 42</span> <span style="color: blue;">private</span> ImageWriter(<span style="color: teal;">Stream</span> stream, <span style="color: teal;">ImageSize</span> imageSize)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 43</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 44</span> <span style="color: blue;">this</span>.stream = stream;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 45</span> desiredImageSize = imageSize;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 46</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 47</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 48</span> <span style="color: blue;">public</span> <span style="color: blue;">void</span> Write(<span style="color: teal;">Image</span> image)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 49</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 50</span> <span style="color: blue;">using</span> (<span style="color: teal;">Image</span> scaledImage = GenerateScaledImage(image))
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 51</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 52</span> WriteScaledImage(scaledImage);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 53</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 54</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 55</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 56</span> <span style="color: blue;">private</span> <span style="color: blue;">void</span> WriteScaledImage(<span style="color: teal;">Image</span> scaledImage)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 57</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 58</span> scaledImage.Save(stream, <span style="color: teal;">ImageFormat</span>.Jpeg);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 59</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 60</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 61</span> <span style="color: blue;">private</span> <span style="color: teal;">Image</span> GenerateScaledImage(<span style="color: teal;">Image</span> image)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 62</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 63</span> <span style="color: teal;">Rectangle</span> imageDimensions = <span style="color: blue;">new</span> <span style="color: teal;">Rectangle</span>();
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 64</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 65</span> <span style="color: blue;">if</span> (image.Width < image.Height) <span style="color: green;">// isPortrait</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 66</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 67</span> <span style="color: blue;">switch</span>(desiredImageSize)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 68</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 69</span> <span style="color: blue;">case</span> <span style="color: teal;">ImageSize</span>.FULLSIZE:
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 70</span> imageDimensions = PortraitFullSize;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 71</span> <span style="color: blue;">break</span>;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 72</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 73</span> <span style="color: blue;">case</span> <span style="color: teal;">ImageSize</span>.DETAILS:
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 74</span> imageDimensions = PortraitDetailsSize;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 75</span> <span style="color: blue;">break</span>;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 76</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 77</span> <span style="color: blue;">case</span> <span style="color: teal;">ImageSize</span>.THUMBNAIL:
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 78</span> imageDimensions = PortraitThumbnailSize;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 79</span> <span style="color: blue;">break</span>;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 80</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 81</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 82</span> <span style="color: blue;">else</span> <span style="color: green;">// isLandscape</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 83</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 84</span> <span style="color: blue;">switch</span>(desiredImageSize)
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 85</span> {
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 86</span> <span style="color: blue;">case</span> <span style="color: teal;">ImageSize</span>.FULLSIZE:
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 87</span> imageDimensions = LandscapeFullSize;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 88</span> <span style="color: blue;">break</span>;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 89</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 90</span> <span style="color: blue;">case</span> <span style="color: teal;">ImageSize</span>.DETAILS:
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 91</span> imageDimensions = LandscapeDetailsSize;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 92</span> <span style="color: blue;">break</span>;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 93</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 94</span> <span style="color: blue;">case</span> <span style="color: teal;">ImageSize</span>.THUMBNAIL:
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 95</span> imageDimensions = LandscapeThumbnailSize;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 96</span> <span style="color: blue;">break</span>;
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 97</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 98</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 99</span>
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 100</span> <span style="color: blue;">return</span> image.GetThumbnailImage(imageDimensions.Width, imageDimensions.Height, <span style="color: blue;">null</span>, <span style="color: teal;">IntPtr</span>.Zero);
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 101</span> }
  </p>
  
  <p style="margin: 0px;">
    <span style="color: #2b91af;"> 102</span> }
  </p>
</div>

**Next time**

This entry is getting pretty long, so I&#8217;m going to end it here. When I pick it up again next time, I&#8217;ll do the refactoring to pull the conditional logic out into the ScaledImage hierarchy we&#8217;re going to create and see where the code takes us after that. I suspect that the WriteScaledImage method is going to find its way into there as well, given its name. One big hint that methods want to be grouped together is when you discover that they have a common abstraction as part of their name. Generate_ScaledImage_ and Write_ScaledImage_ seem to both be crying out to be in a ScaledImage class to me, but we&#8217;ll have to see.

I&#8217;m so sorry that I haven&#8217;t posted any worthwhile content in a long time, but I was tied up managing a huge waterfall-ish project all fall. That project is over, and I&#8217;m working with several different agile teams now with varying levels of involvement, which should give me more time to blog. I&#8217;m also working on 4 different proposals for Agile 2007 and one for the PMI National Congress. More on those as they get more fully formed.

As always, if you&#8217;ve made it this far, thanks for reading, and please let me know if you have any comments. I&#8217;ve had to disable comments on the blog as the spammers have taken over the comment logs, so send the emails to me directly. I&#8217;ll post a summary of the best questions and my answers in my next post.

&#8212; bab