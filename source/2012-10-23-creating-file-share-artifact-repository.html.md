---
title: "Creating a File Share Artifact Repository "
tags: maven
---
When you need to have file kept on file share used in your build, but they're not suitable to deploy into your repo, you can get some of the benefits of having artifacts in a repo (e.g. sharing and versions) by creating a disk based repo on an office file share. This is handy for some edge cases, for example when you might have very large artifacts (e.g. CD images) that are too large for your artifactory, but could be stored on a file share disk.

Firstly, create somewhere shared for the repo it to live:

<pre>\\\\fileshare\\my-repo</pre>

You need to create the artifact, e.g. a zip file. I'm using the dependency plugin to get artifacts for my build. I haven't released the artifact yet, but I've chosen a group ID etc and put it in a place ready for the assembly plugin to, well, assemble it:

	<plugin>                        
		<artifactId>maven-dependency-plugin</artifactId>
		<version>2.5.1</version>                        
		<executions>                           
			<execution>
				<phase>package</phase>
				<goals><goal>unpack</goal></goals>
				<configuration>
					<artifactItems>
						<artifactItem>
							<groupId>com.alexecollins</groupId>                      
							<artifactId>big-zip-file</artifactId>
							<version>1</version>
							<type>zip</type>
							<outputDirectory>${project.build.directory}/assembly/default</outputDirectory>    
						</artifactItem>
						...

And to indicate where to get this from, I've added the disk repo to my POM:

	    <repositories>
	        <repository>
	            <id>my-repo</id>
	            <url>file://fileshare/my-repo</url>
	        </repository>
	    </repositories>

When you now do a "mvn package" it'll complain:

<pre>
[ERROR] Try downloading the file manually from the project website.
[ERROR]
[ERROR] Then, install it using the command:
[ERROR] mvn install:install-file -DgroupId=com.alexecollins -DartifactId=my-big-file -Dversion=1 -Dpackaging=zip -Dfile=/path/to/file
[ERROR]
[ERROR] Alternatively, if you host your own repository you can deploy the file there:
[ERROR] mvn deploy:deploy-file -DgroupId=com.alexecollins -DartifactId=my-big-file -Dversion=1 -Dpackaging=zip -Dfile=/path/to/file -Durl=[url] -DrepositoryId=[id]
</pre>

You'd think you could then do this:

<pre>
mvn deploy:deploy-file -DgroupId=com.alexecollins -DartifactId=my-big-file -Dversion=1 -Dpackaging=zip -Dfile=my-big-file.zip -Durl=file://fileshare/my-repo
</pre>

But this doesn't work, and fails silently. Instead, we can get Maven to create the directory structure and meta-data (i.e. POM) by first locally installing it:

<pre>
mvn install:install-file -DgroupId=com.alexecollins -DartifactId=my-big-file -Dversion=1 -Dpackaging=zip -Dfile=my-big-file.zip
</pre>

Move the directory it creates in your local repository  (i.e. in ~/.m2/repository/com/alexecollis/my-big-file/1/my-big-file-1.zip)to your new file share repo (you'll need the keep the full path, e.g. //fileshare/my-repo/com/alexecollins/my-big-file/1/my-big-file-1.zip), delete any file that's not a *.pom or an artifact. 

Finally, you'll need a checksum (I'm using Cygwin):

<pre>
md5sum my-big-file-1.zip | awk '{print $1}' > my-big-file-1.zip.iso.md5
</pre>

You will now be able to use that directory as a repo. Try running "mvn package" again - and see it download the artifact.

If you're using a mirror, and you've stated that it mirrors everything by having <mirrorOf>*</mirrorOf> in your Maven settings.xml, then Maven will assume it can also mirror your file share repo. You'll have to change your settings to state that this repo is not included.

Finally, you might want to consider:-

<ol>
<li>How it the repository is backed up?</li>
<li>How secure is it?</li>
<li>How easy would it be to corrupt it?</li>
</ol>

You'll probably only want to use this when you'd have previously kept the files on a file share and used Ant to copy them over.
