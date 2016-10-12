---
title: "Applet Model-View-Controller"
tags: java,applet
---
<applet code="com.alexecollins.appletmvc.core.DispatcherApplet.class" archive="/sites/default/files/example-1.0.0-SNAPSHOT-jar-with-dependencies.jar" width="400" height="300">
<param name="defaultController" value="com.alexecollins.appletmvc.example.DefaultController">
</applet>
<p>As Prince might say, I've been partying like it two thousand zero zero out of time. And by "partying" I mean "coding"; coding Java applets. The applets I've been working on don't use AWT components, treating the applet as a canvas, close in design to the applets in the documentation examples. The applets display quite different data in different states, and have started to become God objects. The applets have states that are somewhat like small web pages which you navigate between, and I thought that there must be a better way to encapsulate them.</p>

<p>As an experiment, I wanted to see if you could use the MVC pattern to solve this. I have written a small framework that allows you to create and switch between "views" an the applet to provide encapsulated components. The core class is DispatcherApplet, inspired by Spring's DispatcherServlet, that manages the components.</p>

<p>The code includes some examples, such as a menu, a photo carousel and a beeper. Typically you create a view for each "page" in your applet, and then navigate around by called DispatcherApplet.setView. When views are used, they are activated, and when no longer used (as another view is going to be used) passivated. The draw method is called when the applet needs painting, and the view can inform the applet that it has changed by emitted an event. The dispatcher resets the applet to a clean state between views.</p>

	public interface View extends Activatable {
	    /** Draw the view onto the graphics. */
	    void draw(Graphics graphics) throws Exception;
	    /** Add a listener for when the view changes. */
	    void addViewChangedListener(ViewChangedListener listener);
	    /** Remove a listener. */
	    void removeViewChangedListener(ViewChangedListener listener);
	}

<p>The starting view is determined by an applet parameter named "defaultController" (command pattern) which is executed when the applet starts to set the starting view, example:</p>

	public class DefaultController implements Controller {
	
	    private final DispatcherApplet applet;
	
	    public DefaultController(DispatcherApplet applet) {
	        this.applet = applet;
	    }
	
	    public void execute() throws Exception {
	        applet.setView(new MenuView(applet));
	    }
	}

<p>I've included a full MVC example in the form of CarouselView/CarouselModel. The model controls the animation by emitting events when the model of the image's position has changed, the view listens to the model and emits events to indicate the view has changed.</p>

<p>The code is <a href="https://github.com/alexec/applet-mvc">GitHub</a>.</p>
