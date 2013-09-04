---
title: "Tutorial: Swing Synth PLAF Template - Part 4: Tiling Images"
---
<p>I wanted to display a tiling image as the background of panels, but I found that synth would stretch images, even when requested not to. I created a short piece of code to tile the image:</p>

	@Override
	public void paintPanelBackground(SynthContext context, Graphics graphics, int x, int y, int w, int h) {
	    Graphics2D g2 = (Graphics2D)graphics;
	    // tile the image
	    int x1 = x;
	    while (y < h) {
	        x = x1;
	        while (x < w) {
	            g2.drawImage(background, x,y, null);
	            x+=background.getWidth(null);
	        }
	        y+=background.getHeight(null);
	    }
	}

<p><a href="/content/tutorial-swing-synth-plaf-template-part-3-custom-painter">&larr; Back to part 3</a> ~ <a href="/content/tutorial-swing-synth-plaf-template-part-5-gradients">On to part 5 &rarr;</a></p>
