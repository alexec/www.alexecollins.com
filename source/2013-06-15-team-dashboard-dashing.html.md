---
title: "Team Dashboard with Dashing"
---
<p>I've been setting up a dashboard for my team to display metrics. After looking around at the various options (and having an abortive stab at writing a framework myself) I found and OSS version called
<a href="http://shopify.github.io/dashing/">Dashing written by Shopify</a> that suited the needs.</p>

<p>There's a <a href="http://www.youtube.com/watch?v=TbGbm1cE6M0">nice example on YouTube</a> which I think gives a better feel than the built in samples.</p>

<p>I thought I'd put a few hints and tips after what I've learnt.</p>

<p>Why do you want a team dashboard? A dashboard can provide an overview of the team's status, and highlight actions that need to be taken. The ones we've got include:</p>

<p>Actionable tiles:</p>

<ul>
<li>Build status. Which builds (of the 41 builds) that are broken, and who the CI thinks broken them. This goes red if builds are broken and indicates who needs to fix the build.</li>
<li>Failing tests. Again, which tests are failing and who the CI thinks broke them. Since the test's package can indicate which feature needs fixing, this also indicates who might want to take a look.</li>
<li>Recorded time. Who has not recorded their time in the timesheet system.</span></li></li>
<li>New tickets. Untriaged tickets in the bug tracking system, that need to be triaged.</li>
<li>Overdue code reviews.</li>
</ul>

<p>Information tiles:</p>

<ul>
<li>Recent commits. This shows what we're working on.</li>
<li>Beer clock: On Fridays, how many hours to free beer.</li>
<li>Assigned tickets. Tickets we're working on.</li>
<li>Test coverage.</li>
</ul>

<p>What do you notice here? More tiles are actionable rather than informative, and therefore more useful. The current weather or the company stock prices do not feature. It's not an executive dashboard, it is a team dashboard.</p>

<p>What else do you notice? Each metrics comes from a different system. Build information might be from Jenkins or Bamboo, tickets from JIRA or RT, and the timesheet information might be <a href="http://www.youtube.com/watch?v=cJMRKB3RU_s">from a spreadsheet</a>. This means you'll need to write a script to periodically extract the data and post it to the dashboard - there's a good chance you won't find a built it one that fits your exact requirements. Assume you'll need to write some of you own, but do not fear - this is almost trivially easy!</p>

<h2>Creating a Widget</h2>

<p>This tutorial will create a dashboard with a single widget:</p>

<p><img src="https://raw.github.com/alexec/dashing-example/master/screenshot.png"/></p>

<p>To install Dashing you need Ruby 1.9 (I'd recommend <a href="https://rvm.io">RVM</a>), and then execute:</p>

	dashing new example-dashboard
	cd example-dashboard
	bundle install &amp;&amp; dashing start

<p>This creates a set of samples you can look at by navigating to <a href="http://localhost:3030/sample">http://localhost:3030/sample</a>.</p>

<p>Lets create a widget that shows informatain about failing builds. It'll be closely related to <a href="https://gist.github.com/EHadoux/5196209">a Sonar Gist</a>, and follows a common set-of steps:</p>

<ul>
<li>Get same data from a URL, possbily having to authenticate.</li>
<li>Parse that data (if it is HTML we can <a href="http://mechanize.rubyforge.org">use Mechianize</a>).</li>
<li>Loop though the data to find the interesting information.</li>
<li>Filter that information, e.g. based on status.</li>
<li>Post that information to one of more widgets.</li>
</ul>

	    SCHEDULER.every '15m', :first_in => 0 do |job|
	        builds=config[:builds].map{|repo|
	            status=JSON(get("https://api.travis-ci.org/repositories/#{config[:user]}//#{repo}/builds.json"))[0]['result']?'ok':'failing'
	            {:repo => repo, :status => status}
	        }
	        failing_builds=builds.find_all{|build| build[:status]!='ok'}
	            send_event('travis_builds', {
	            :items => builds.map{|build| {:label => "#{build[:repo]} #{build[:status]}"}},
	            :moreinfo => "#{failing_builds.length}/#{builds.length} failing",
	            :status => (failing_builds.length>0?'warning':'ok')
	        })
	    end

<p>To create the widget I've copied the widgets/list to widgets/travis_builds and added this to the code to change the colour of the widget based on status:</p>

	     if data.status
	       # clear existing "status-*" classes
	       $(@get('node')).attr 'class', (i,c) -&gt;
	         c.replace /status-\\S+/g, ''
	       # add new class
	       $(@get('node')).addClass "status-#{data.status}"

<h2>Installing as a On a PC</h2>

<p>You'll want to run this on a Linux computer with a monitor mounted in a suitable place.</p>

<p>I've <a href="https://raw.github.com/alexec/dashing-example/master/dashboard.sh">written a script to start this as service on Linux</a>. You'll need to add a cd to change to the correct directory.</p>

<p>If you want to be eco-friendly you can turn the screen on and off at suitable times using xset, put this in your crontab:</p>

	0 9 1-5 * * xset dpms force on
	# turn off at 6/7/8pm everyday (just in case it get knocked on by accident)
	0 18,19,20 * * * xset dpms force off

<p>Now you have a few options for the actual display.</p>

<p>A simple and fully featured, but insecure, option would be to use a browser fullscreen and disable the screensaver.</p>

<p>A more secure, but quite hacky option would be to <a href="http://forums.pcbsd.org/showthread.php?t=5878">set-up xscreensaver to rotate thought</a> a directory of <a href="https://github.com/ariya/phantomjs/wiki/Screen-Capture">screenshots taken by phantomjs</a>.</p>

<p>I'd love to hear from anyone with a better compromise!</p>

<h2>References</h2>

<p>Code for this post can be <a href="https://github.com/alexec/dashing-example">found on Github</a>. Another widgets can be <a href="https://github.com/Shopify/dashing/wiki/Additional-Widgets">found amongst the additional widgets page</a>. <a href="http://shopify.github.io/dashing/">The guide</a> gives an example of creating your own widget.</p>
