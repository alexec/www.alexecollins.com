---
title: "Tutorial: Swing Synth PLAF Template - Part 11: Targeting Styles"
---
<p>Is CSS, you can target elements and style them specially, e.g. as a title, or important button. You can do the same in Swing by setting their name:</p>

	new JButton("Button named 'primary'") {{setName("primary");}}

<p>In the XML you can set-up colours for this name and they’ll be applied.</p>

	<object class="javax.swing.plaf.ColorUIResource" id="primaryfg"><int>255</int><int>0</int><int>0</int></object>
	<object class="javax.swing.plaf.ColorUIResource" id="primarybg"><int>50</int><int>50</int><int>50</int></object>
	
	<style id="primary">
	    <state><color type="FOREGROUND" idref="primaryfg"/>
	        <color type="BACKGROUND" idref="primarybg"/> </state>
	</style>
	<bind style="primary" type="name" key="primary"/>

<p><a href="/content/tutorial-swing-synth-plaf-template-part-10-progress-bars">&larr; Back to part 10</a> ~ <a href="/content/tutorial-swing-synth-plaf-template-part-12-conclusion">On to part 12 &rarr;</a></p>
