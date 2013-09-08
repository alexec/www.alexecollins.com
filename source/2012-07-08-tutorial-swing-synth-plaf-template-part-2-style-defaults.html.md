---
title: "Tutorial: Swing Synth PLAF Template - Part 2: Style Defaults"
tags: swing,java,plaf
---
<p>Firstly, we'll want to and some common values in one place accessible to all.</p>

	<synth>
	    <object class="javax.swing.plaf.ColorUIResource" id="fg"><int>0</int><int>0</int><int>0</int></object>
	    <object class="javax.swing.plaf.ColorUIResource" id="bg"><int>255</int><int>255</int><int>255</int></object>
	    <object class="javax.swing.plaf.ColorUIResource" id="focus"><int>50</int><int>50</int><int>127</int></object>

<p>We use colour objects, so we can use the same colours later on without breaking the DRY principle. Also you can make components transparent; adding opacity as necessary.</p>

<p>By default some components will throw exceptions unless you make some basic settings that apply to all components.</p>

	
	<style id="default">
	    <opaque value="false"/>
	    <font name="Lucida Sans Unicode" size="12"/>
	    <state>
	        <color type="FOREGROUND" idref="fg"/>
	        <color type="TEXT_BACKGROUND" idref="bg"/>
	        <!-- The color used in highlighting components. -->
	        <color type="FOCUS" idref="focus"/>
	    </state>
	</style>
	<bind style="default" type="region" key=".*"/>

<p>A word of warning, synth tends to fail quietly, so you want to be careful to make small changes, and test them incrementally.</p>

<p>There's a handy <a href="http://www.ampsoft.net/webdesign-l/WindowsMacFonts.html">list of common fonts</a>.</p>

<p>You might also want consistent insets on certain components:</p>

	<style id="padding">
	    <insets top="5" right="5" bottom="5" left="5"/>
	</style>
	<bind style="padding" type="region" key="Button"/>
	<bind style="padding" type="region" key="ComboBox"/>
	<bind style="padding" type="region" key="PasswordField"/>
	<bind style="padding" type="region" key="TextField"/>
	<bind style="padding" type="region" key="TextArea"/>
	<bind style="padding" type="region" key="EditorPane"/>
	<bind style="padding" type="region" key="List"/>
	<bind style="padding" type="region" key="Tree"/>

<p><a href="/content/tutorial-swing-synth-plaf-template-part-1">&larr; Back to part 1</a> ~ <a href="/content/tutorial-swing-synth-plaf-template-part-3-custom-painter">On to part 3 &rarr;</a></p>
