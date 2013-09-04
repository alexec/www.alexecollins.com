---
title: "Tutorial: Swing Synth PLAF Template - Part 1"
---
<p>I've been working on a GUI app written is Swing recently, and there's been a request to make it look more modern and attractive. When people are asked to do this, they often start sub-classing components, or calling setters directly. This is the Swing equivalent of HTML inline styles, with a similar set of problems. In HTML you’d use CSS to solve this problem. There are two good methods of styling in Swing. The first is to sub-class an existing pluggable-look-and-feel (PLAF), or to use Synth PLAF and write matching code.</p>

<p>In <a href="/content/swing-plaf-example"> a previous post </a> I talked about sub-classing a Swing PLAF to get a modified theme.</p>

<p>The Synth PLAF provides a framework for creating your own. You do this by create two things: an XML file that defines coarse grained options such as colours, sizes, insets, and images; and a "painter" that provides a higher degree of control of the rendering of each component.</p>

<p>The code <a href="https://github.com/alexec/swing-synth-plaf-template">is on Github</a>. You can see a demo using SynthDemoApp.</p> 

<p>You specify the XML file programmatically when you choose the PLAF:</p>

	SynthLookAndFeel synth = new SynthLookAndFeel();
	synth.load(CustomPainter.class.getResourceAsStream("synth.xml"), CustomPainter.class);
	UIManager.setLookAndFeel(synth);

<p>There are two routes you can take when creating a theme, you can use images, or a custom painter. The advantage of using images is that it is quick and easy, but you cannot do more complex things, like changing the image based on arbitrary options. The advantage of a custom painter is versatility, but they are technically more difficult. As the former is <a href="http://docs.oracle.com/javase/tutorial/uiswing/lookandfeel/synth.html">well documented at Oracle</a> I'm going to talk about custom painters.<p>

<p><a href="/content/tutorial-swing-synth-plaf-template-part-2-style-defaults">On to part 2 &rarr; </a></p>
