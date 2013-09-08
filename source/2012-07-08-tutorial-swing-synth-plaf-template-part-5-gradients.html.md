---
title: "Tutorial: Swing Synth PLAF Template - Part 5: Gradients"
tags: swing,java,plaf
---
<p>I wanted a vertical gradient <a href="http://docs.oracle.com/javafx/2/get_started/css.htm">similar to that in the JavaFX tutorial</a>. This uses the foreground of the component to choose the colours, something you cannot do with images. I wanted a smooth, anti-aliased, border.</p>

		/** Paint the component using a gradient based on the two provided colors. */
	    public static void paintVerticalGradient(Graphics g, int x, int y, int w, int h, int arc, Color fg, Color bg) {
	        Graphics2D g2 = (Graphics2D)g;
	        g2.setPaint(getGradient(x, y, h, fg, bg));
	        g2.fillRoundRect(x, y, w - 1, h - 1, arc, arc);
	        g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
	        g2.setColor(fg);
	        g2.setStroke(THIN_STROKE);
	        g2.drawRoundRect(x, y, w - 1, h - 1, arc, arc);
	    }
	
	    public static GradientPaint getGradient(int x, int y, int h, Color fg, Color bg) {
	        return new GradientPaint(x, y, bg, x, y + h, fg);
	    }
	
		private GradientPaint getGradient(SynthContext context, int x, int y, int h) {
			// For simplicity this always recreates the GradientPaint. In a
			// real app you should cache this to avoid garbage.
			return new GradientPaint(x, y, context.getStyle().getColor(context, ColorType.BACKGROUND), 
					x, y + h, context.getStyle().getColor(context, ColorType.FOREGROUND));
		}
	
		private void paintVerticalGradient(SynthContext context, Graphics g, int x, int y, int w, int h) {
	        final int arc = getArc(context);
	        Graphics2D g2 = (Graphics2D)g;
	        g2.setPaint(getGradient(context, x, y, h));
	        g2.fillRoundRect(x, y, w - 1, h - 1, arc, arc);
	        g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
	        g2.setColor(context.getStyle().getColor(context, ColorType.FOREGROUND));
	        g2.setStroke(THIN_STROKE);
	        g2.drawRoundRect(x, y, w - 1, h - 1, arc, arc);
	    }
	    @Override
	    public void paintButtonBackground(SynthContext context,Graphics g, int x, int y,int w, int h) {
	        paintVerticalGradient(context, g, x, y, w, h);
	    }
	

<p>Note that I don't hard code the colours, I get them from the XML.</p>

<p>You'll need the XML to apply the painter:<p>

	<style id="button"><painter method="buttonBackground" idref="painter"/></style>
	<bind style="button" type="region" key="Button"/>

<p>We can get components to change colour when the mouse is over:</p>

	<style id="hover">
		<state value="MOUSE_OVER">
			<color idref="focus" type="FOREGROUND"/>
		</state>
	</style>
	<bind style="hover" type="region" key="Button"/>

<p><a href="/content/tutorial-swing-synth-plaf-template-part-4-tiling-images">&larr; Back to part 4</a> ~ <a href="/content/tutorial-swing-synth-plaf-template-part-6-text-fields">On to part 6 &rarr;</a></p>
