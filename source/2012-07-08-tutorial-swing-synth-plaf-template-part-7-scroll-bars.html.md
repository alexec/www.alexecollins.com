---
title: "Tutorial: Swing Synth PLAF Template - Part 7: Scroll-bars"
tags: swing,java,plaf
---
<p>OK - I'm operating on an 80/20 rule here. Some components are simpler and easier to code, but some you really need. As scrollbar is one. It's more complex than other components, consisting of arrows, a thumb which you drag along, and a track that the thumb sits in.</p>

<p>To keep scrollbar simple, firstly I removed the arrows:</p>

	<style id="scrollBarArrowStyle"><property key="ArrowButton.size" type="integer" value="0" /></style>
	<bind style="scrollBarArrowStyle" type="REGION" key="ArrowButton" />

<p>Then, I made the track (the background) white with a small inset:</p>

	<style id="scrollbarTrackStyle">
	    <opaque value="true"/>
	    <state>
	        <insets top="1" right="1" bottom="1" left="1"/>
	        <color value="#ffffff" type="BACKGROUND"/>
	    </state>
	</style>
	<bind style="scrollbarTrackStyle" type="REGION" key="ScrollBarTrack" />

<p>Finally, I created a semi-transparent thumb:</p>

	@Override
	public void paintScrollBarThumbBackground(SynthContext context, Graphics g, int x, int y, int w, int h, int i4) {
	    Graphics2D g2 = (Graphics2D)g;
	    int arc = getArc(context);
	
	    g2.setColor(createTransparentColor(context.getStyle().getColor(context, ColorType.BACKGROUND).darker().darker()));
	    g2.fillRoundRect(x + 1, y + 1, w - 2, h - 2, arc, arc);
	}
	
	/** Make an existing colour transparent. */
	private static Color createTransparentColor(Color color) {
	    return new Color(color.getRed(), color.getGreen(), color.getBlue(), 0x88);
	}

<p><a href="/content/tutorial-swing-synth-plaf-template-part-6-text-fields">&larr; Back to part 6</a> ~ <a href="/content/tutorial-swing-synth-plaf-template-part-8-check-boxes-and-radio-buttons">On to part 8 &rarr;</a></p>
