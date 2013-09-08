---
title: "Tutorial: Swing Synth PLAF Template - Part 6: Text Fields"
tags: swing,java,plaf
---
<p>For text fields, and the like I wanted a similar area to that in the JavaFX tutorial too. I also wanted the edge to change colour when focussed, using the colour from the XML.  You can see in this sample that we're reusing colours again, and anti-aliasing.</p>

	private void paintBorder(SynthContext context, Graphics g, int x, int y, int w, int h) {
	    Graphics2D g2 = (Graphics2D)g;
	
	    final int arc = getArc(context);
	    final boolean isFocused = (context.getComponentState() & SynthConstants.FOCUSED) > 0;
	
	    g2.setColor(context.getStyle().getColor(context, ColorType.BACKGROUND));
	    g2.fillRoundRect(x + 1, y + 1, w - 3, h - 3, arc, arc);
	    g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
	    g2.setColor(isFocused ? getHighlight(context) : context.getStyle().getColor(context, ColorType.FOREGROUND));
	    g2.setStroke(thin);
	    g2.drawRoundRect(x, y, w - 1, h - 1, arc, arc);
	}

<p><a href="/content/tutorial-swing-synth-plaf-template-part-5-gradients">&larr; Back to part 5</a> ~ <a href="/content/tutorial-swing-synth-plaf-template-part-7-scroll-bars">On to part 7 &rarr;</a></p>
