---
title: "Tutorial: Swing Synth PLAF Template - Part 10: Progress Bars"
---
<p>These are tougher - they come in determinate and indeterminate flavours. We're only going to support the indeterminate version for now, reusing components.</p>

	@Override
	public void paintProgressBarBackground(SynthContext context, Graphics graphics, int x, int y, int w, int h) {
		paintBorder(context, graphics, x, y, w, h);
	    paintVerticalGradient(context, graphics, x, y, (int)(w * ((JProgressBar) context.getComponent()).getPercentComplete()), h);
	}

<p><a href="/content/tutorial-swing-synth-plaf-template-part-9-lists">&larr; Back to part 9</a> ~ <a href="/content/tutorial-swing-synth-plaf-template-part-11-targeting-styles">On to part 11 &rarr;</a></p>
