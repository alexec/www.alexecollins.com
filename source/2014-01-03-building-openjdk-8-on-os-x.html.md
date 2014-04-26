---
title: Building OpenJDK 8 on OS-X Mavericks
date: 2014-01-03 23:31 UTC
tags: java,java-8,os-x
---
**!!! Work in Progress !!!**

Prerequisites:

* hg 
* Both Xcode and Xcode Command Line Tools (for gcc etc). **MUST be <= v4.6, later versions do NOT work**. [Read this](http://comments.gmane.org/gmane.comp.java.openjdk.macosx-port.devel/6343) and [this](http://stackoverflow.com/questions/9353444/how-to-use-install-gcc-on-mac-os-x-10-8-xcode-4-4)  for more info: OpenJDK requires GCC, but Xcode installs clang.
* XQuartz (for freetype?)
* OpenJDK 7u7 (NOT OpenJDK 8)

~/.bash_profile:

    export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_45.jdk/
    export PATH=$JAVA_HOME/bin:$PATH



Other Things...
---

1. Apply [this patch to fix GCC set-up](http://mail.openjdk.java.net/pipermail/build-dev/2013-November/010936.html), (ignore error, only on a single generated file).
2. Install gcc (as Xcode >= 4.2 uses clang). [Read this](http://stackoverflow.com/questions/9353444/how-to-use-install-gcc-on-mac-os-x-10-8-xcode-4-4).
3. [Building-and-Packaging-OpenJDK8-for-OSX](https://github.com/hgomez/obuildfactory/wiki/Building-and-Packaging-OpenJDK8-for-OSX)
4. Maybe [this freetype patch](https://github.com/hgomez/obuildfactory/blob/master/openjdk8/macosx/patches/freetype-osx.patch)???

