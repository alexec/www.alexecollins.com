---
title: "Tutorial: Swing Synth PLAF Template - Part 3: Custom Painter"
tags: swing,java,plaf
---
<p>A custom painter is key to creating attractive backgrounds. A custom painter can be specified in the XML using a simple tag:</p>

	<object id="painter" class="com.alexecollins.swing.plaf.synth.template.CustomPainter"/>

<p>And chosen for a component:</p>

	<style id="panel">
	    <painter method="panelBackground" idref="painter"/>
	</style>
	<bind style="panel" type="region" key="Panel"/>

<p>The name of the method to use must have the correct name for the component; panel must called paintPanelBackground.</p>

<p>I want some supporting method for getting style etc:</p>

	public class CustomPainter extends SynthPainter {
	
	/** Background image for panels. */
		private final Image background;
		static final Stroke THIN_STROKE = new BasicStroke(2);
		
		public CustomPainter() throws IOException {
		    this.background = ImageIO.read(getClass().getResource("images/background.png"));
		}
	
	...
	
		private int getArc(SynthContext context) {
		    return getArc(context.getComponent());
		}
		
		public static int getArc(Component component) {
		    // lists appear to mess up arcs
		    return component instanceof  JList ? 0 : component.getFont().getSize() / 2;
		}

<p><a href="/content/tutorial-swing-synth-plaf-template-part-2-style-defaults">&larr; Back to part 2</a> ~ <a href="/content/tutorial-swing-synth-plaf-template-part-4-tiling-images">On to part 4 &rarr;</a></p>
