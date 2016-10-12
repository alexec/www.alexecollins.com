---
title: "VirtualBox Java API v1 Released, v2 Roadmap "
tags: software
---
<p>I've decided today that I'm not going to pack any more features into v1. It's got everything I want at the moment and I'm not finding any more bugs.</p>

<p>Just a quick overview of the features of v1:</p>

<ul>
<li>The ability to create VirtualBoxes from templates.</li>
<li>Provision those boxes with software.</li>
<li>Integration with Ant and Maven.</li>
</ul>

<p>Version 1 can be <a href="https://github.com/alexec/maven-vbox-plugin/tree/1.0.0">found on GitHub</a> as can <a href="http://alexec.github.com/maven-vbox-plugin">the documentation</a>.</p>

<h2>V2 Roadmap</h2>

<p>In v2 I'm planning on two neat new features, patches and estates. You can <a href="https://github.com/alexec/maven-vbox-plugin/issues?milestone=2">track the tickets on GitHub</a>. As this is version 2, you can expect some API breaking changes :)</p>

<h3>Patches</h3>

<p>The ability to take a template and apply parameterised patches to it to produce a box, or several similar boxes Potentially this will make it much easier to create boxes from templates and greatly simplify the process. For example:</p>

	<Profile template="CentOS_6_3">
	<Patch name="Hostname" args="hostname=app1"/>
	<Patch name="Tomcat6"/>
	</Profile>

Or

	<Profile template="CentOS_6_3">
	<Patch name="Hostname" args="hostname=app1"/>
	<Patch>
	--- a/floppy0/post-install.sh
	+++ b/floppy0/post-install.sh
	@@ -7,8 +7,4 @@ mount /dev/sr0 /media/cdrom
	 /media/cdrom/VBoxLinuxAdditions.run
	 umount /dev/sr0
	 rm -R /media/cdrom
	-
	-yum -y install tomcat6
	-chkconfig tomcat6 on
	-
	 poweroff now
	</Patch>
	</Profile>

<p>This will allow you to upgrade your OS, and potentially use the same patches (at least by name) to get the same outcome.</p>

<h3>Estates</h3>

<p>Currently you can only create single box at a time, or a several, effectively independent boxes. This change will create a group of machines into a single environment (or estate) and a single click, and low configuring and management of boxes as a group.<p>
