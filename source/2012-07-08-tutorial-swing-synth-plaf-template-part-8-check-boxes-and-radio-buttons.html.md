---
title: "Tutorial: Swing Synth PLAF Template - Part 8: Check-boxes and Radio-buttons"
tags: swing,java,plaf
---
<p>These are quite similar, they both have a selectable icon on their left, and text describing it on the right. A custom painter can create the icon, but based on what? As components can grow, if we used the component size, we'd have a variety of different sizes on any form.</p>

<p>To create check-boxes we create a separate class that implements Icon:</p>

	public abstract class CheckBoxIcon implements Icon {
	
	    private final int size;
	
	    public CheckBoxIcon(int size) {
	        this.size = size;
	    }
	
	    @Override
	    public void paintIcon(Component c, Graphics g, int x, int y) {
	        CustomPainter.paintVerticalGradient(g, x, y, getIconWidth(), getIconHeight(),
			        CustomPainter.getArc(c),
			        c.getForeground(), c.getBackground());
	    }
	
	    @Override
	    public int getIconWidth() {
	        return size;
	    }
	
	    @Override
	    public int getIconHeight() {
	        return size;
	    }
	}

<p>We can then sub-class that for selected an unselected versions:</p>

	public class CheckBoxOffIcon extends CheckBoxIcon {
	    public CheckBoxOffIcon(int size) {
	        super(size);
	    }
	}

	public class CheckBoxOnIcon extends CheckBoxIcon {
	
	    public CheckBoxOnIcon(int size) {
	        super(size);
	    }
	
	    @Override
	    public void paintIcon(Component c, Graphics g, int x, int y) {
	        super.paintIcon(c, g, x, y);
	        Graphics2D g2 = (Graphics2D) g;
	        int a = CustomPainter.getArc(c);
	        g2.setStroke(CustomPainter.THIN_STROKE);
	        g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
	        g2.drawPolyline(new int[]{x + a, x + getIconWidth() / 2, x + getIconWidth()},
	                new int[]{y + getIconWidth() / 2, y + getIconHeight() - a, y}, 3);
	    }
	}

<p>Finally, we need to tell synth to use those two classes:</p>

	<style id="checkbox">
	    <object id="checkOff" class="com.alexecollins.swing.plaf.synth.template.CheckBoxOffIcon"><int>16</int></object>
	    <object id="checkOn" class="com.alexecollins.swing.plaf.synth.template.CheckBoxOnIcon"><int>16</int></object>
	    <property key="CheckBox.icon" type="idref" value="checkOff"/>
	    <state value="SELECTED"><property key="CheckBox.icon" type="idref" value="checkOn"/></state>
	</style>
	<bind style="checkbox" type="region" key="CheckBox"/>

<p>Code for radio button is very similar.</p>

<p><a href="/tutorial-swing-synth-plaf-template-part-7-scroll-bars">&larr; Back to part 7</a> ~ <a href="/tutorial-swing-synth-plaf-template-part-9-lists">On to part 9 &rarr;</a></p>
