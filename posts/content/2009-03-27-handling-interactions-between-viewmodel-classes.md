---
title: Handling interactions between ViewModel classes
author: Brian Button
type: post
date: 2009-03-27T05:59:00+00:00
url: /index.php/2009/03/27/handling-interactions-between-viewmodel-classes/
sfw_comment_form_password:
  - kgQarRcKsed7
sfw_pwd:
  - 17msuqTMXTuk
categories:
  - Uncategorized

---
I’ve been puzzling over what seemed to be an insurmountable problem lately. It seemed that the guys who came up with the MVVM design pattern totally missed the boat on anything more than a simple, single-page app. It couldn’t be me, since I’m a SuperGenius (TM).

Well, OK, it did turn out to be me. Once I stopped flailing about in WPF-land and actually _thought_ about the problem, it became easy. 

**The Problem**

What I was trying to do seemed pretty simple, and I couldn’t figure out how to make it work, which is why I was sure _it was them and not me –_ how wrong I would be…

Basically, I had an app with multiple views. In one view, I was doing something that caused some data to be updated. I wanted to show the updated data in another view. Since the two views were using two different ViewModels, I couldn’t figure out how data binding by itself could solve the problem. Then it came to me – the two different ViewModels were sharing the idea of the data they were both showing, and **_data is supposed to live in the Model layer_**. Duh!

Once this epiphany drilled its way through my head, I figured out how to solve the problem (Note – I’m 100% new to WPF, so there is every chance there is an easier way to do this. If you know it, please let me know!)

**The Solution**

The key to this was to make both my ViewModels implement INotifyPropertyChanged to hook them up to propagate changes to and from their Views. Then I created an event in the Model that would be raised whenever the underlying data they were sharing was changed. My model looked like this:

<div class="csharpcode">
  <pre class="alt"><span class="lnum">   1:  </span>&nbsp;&nbsp; <span class="kwrd">public</span> <span class="kwrd">class</span> Model</pre>
  
  <pre><span class="lnum">   2:  </span>    {</pre>
  
  <pre class="alt"><span class="lnum">   3:  </span>        <span class="kwrd">private</span> String modelValue;</pre>
  
  <pre><span class="lnum">   4:  </span>&nbsp;</pre>
  
  <pre class="alt"><span class="lnum">   5:  </span>        <span class="kwrd">public</span> <span class="kwrd">delegate</span> <span class="kwrd">void</span> ModelChangedEvent(<span class="kwrd">object</span> sender, ModelChangedEventArgs e);</pre>
  
  <pre><span class="lnum">   6:  </span>        <span class="kwrd">public</span> <span class="kwrd">event</span> ModelChangedEvent ModelChanged;</pre>
  
  <pre class="alt"><span class="lnum">   7:  </span>        <span class="kwrd">public</span> <span class="kwrd">void</span> SetValue(<span class="kwrd">string</span> newValue)</pre>
  
  <pre><span class="lnum">   8:  </span>        {</pre>
  
  <pre class="alt"><span class="lnum">   9:  </span>            modelValue = newValue;</pre>
  
  <pre><span class="lnum">  10:  </span>            <span class="kwrd">if</span>(ModelChanged != <span class="kwrd">null</span>)</pre>
  
  <pre class="alt"><span class="lnum">  11:  </span>            {</pre>
  
  <pre><span class="lnum">  12:  </span>                ModelChanged(<span class="kwrd">this</span>, <span class="kwrd">new</span> ModelChangedEventArgs {OldValue = modelValue, NewValue = newValue});</pre>
  
  <pre class="alt"><span class="lnum">  13:  </span>            }</pre>
  
  <pre><span class="lnum">  14:  </span>        }</pre>
  
  <pre class="alt"><span class="lnum">  15:  </span>    }</pre>
</div>

And I had my target ViewModel listen for this event. In the event handler for the ModelChangedEvent, the ViewModel used the newValue to set the value it needed to show on the View, which caused the PropertyChanged event to be raised, and everything worked like a champ. Here is the target ViewModel:

<div class="csharpcode">
  <pre class="alt"><span class="lnum">   1:  </span>    <span class="kwrd">public</span> <span class="kwrd">class</span> ReflectedViewModel : INotifyPropertyChanged</pre>
  
  <pre><span class="lnum">   2:  </span>    {</pre>
  
  <pre class="alt"><span class="lnum">   3:  </span>        <span class="kwrd">private</span> <span class="kwrd">string</span> reflectedValue;</pre>
  
  <pre><span class="lnum">   4:  </span>        <span class="kwrd">private</span> Model model;</pre>
  
  <pre class="alt"><span class="lnum">   5:  </span>        <span class="kwrd">public</span> <span class="kwrd">event</span> PropertyChangedEventHandler PropertyChanged;</pre>
  
  <pre><span class="lnum">   6:  </span>&nbsp;</pre>
  
  <pre class="alt"><span class="lnum">   7:  </span>        <span class="kwrd">public</span> Model Model</pre>
  
  <pre><span class="lnum">   8:  </span>        {</pre>
  
  <pre class="alt"><span class="lnum">   9:  </span>            get { <span class="kwrd">return</span> model; }</pre>
  
  <pre><span class="lnum">  10:  </span>            set</pre>
  
  <pre class="alt"><span class="lnum">  11:  </span>            {</pre>
  
  <pre><span class="lnum">  12:  </span>                <span class="kwrd">if</span>(model != <span class="kwrd">null</span>) <span class="kwrd">throw</span> <span class="kwrd">new</span> InvalidOperationException(<span class="str">"Attempted to set model more than once."</span>);</pre>
  
  <pre class="alt"><span class="lnum">  13:  </span>                model = <span class="kwrd">value</span>;</pre>
  
  <pre><span class="lnum">  14:  </span>                model.ModelChanged += model_ModelChanged;</pre>
  
  <pre class="alt"><span class="lnum">  15:  </span>            }</pre>
  
  <pre><span class="lnum">  16:  </span>        }</pre>
  
  <pre class="alt"><span class="lnum">  17:  </span>&nbsp;</pre>
  
  <pre><span class="lnum">  18:  </span>        <span class="kwrd">void</span> model_ModelChanged(<span class="kwrd">object</span> sender, ModelChangedEventArgs e)</pre>
  
  <pre class="alt"><span class="lnum">  19:  </span>        {</pre>
  
  <pre><span class="lnum">  20:  </span>            ReflectedValue = e.NewValue;</pre>
  
  <pre class="alt"><span class="lnum">  21:  </span>        }</pre>
  
  <pre><span class="lnum">  22:  </span>&nbsp;</pre>
  
  <pre class="alt"><span class="lnum">  23:  </span>        <span class="kwrd">public</span> String ReflectedValue</pre>
  
  <pre><span class="lnum">  24:  </span>        {</pre>
  
  <pre class="alt"><span class="lnum">  25:  </span>            get { <span class="kwrd">return</span> reflectedValue; }</pre>
  
  <pre><span class="lnum">  26:  </span>            set</pre>
  
  <pre class="alt"><span class="lnum">  27:  </span>            {</pre>
  
  <pre><span class="lnum">  28:  </span>                <span class="kwrd">if</span>(<span class="kwrd">value</span>.Equals(reflectedValue) == <span class="kwrd">false</span>)</pre>
  
  <pre class="alt"><span class="lnum">  29:  </span>                {</pre>
  
  <pre><span class="lnum">  30:  </span>                    reflectedValue = <span class="kwrd">value</span>;</pre>
  
  <pre class="alt"><span class="lnum">  31:  </span>                    <span class="kwrd">if</span>(PropertyChanged != <span class="kwrd">null</span>)</pre>
  
  <pre><span class="lnum">  32:  </span>                    {</pre>
  
  <pre class="alt"><span class="lnum">  33:  </span>                        PropertyChanged(<span class="kwrd">this</span>, <span class="kwrd">new</span> PropertyChangedEventArgs(<span class="str">"ReflectedValue"</span>));</pre>
  
  <pre><span class="lnum">  34:  </span>                    }</pre>
  
  <pre class="alt"><span class="lnum">  35:  </span>                }</pre>
  
  <pre><span class="lnum">  36:  </span>            }</pre>
  
  <pre class="alt"><span class="lnum">  37:  </span>        }</pre>
  
  <pre><span class="lnum">  38:  </span>    }</pre>
</div>

You can download the entire example from [here][1].

**Conclusion**

This was not a hard problem to solve, once I stopped and actually thought about it. I got so wrapped up in the new framework and toys (WPF/XAML) that I forgot about everything else I knew for a bit 🙂

As usual, any and all comments appreciated. Comments telling me about easier and more idiomatically correct ways of writing this are 100% welcomed!

&#8212; bab

 [1]: http://www.agilestl.com/downloads/InteractingViewModels.zip