---
title: "Reverse a Java ZIP into Maven Project"
tags: maven,java
---
1. Unzip the jars 

~~~sh
unzip app.zip -d dist
mkdir classes
find dist -name '*.jar' -exec unzip -B {} -d classes ';'
~~~

2. Download JAD and add to you PATH.
3. Decompile classes

~~~sh
mkdir -p src/main/java
cd classes
find . -name '*.class' | while read F ; do D=../src/main/java/$(dirname $F); mkdir -p $D ; jad -o -s java -d $D $F ; done
cd ..
~~~

4. Get resources:

~~~sh
mkdir -p src/main/resources
cd classes
find . -type f ! -name '*.class' | while read F ; do D=../src/main/resources/$(dirname $F); mkdir -p $D ; cp -v $F $D ; done
cd ..
~~~

5. Create a nominal POM:

~~~sh
echo '<project><modelVersion>4.0.0</modelVersion><groupId>com</groupId><artifactId>app</artifactId> <version>1</version></project>' > pom.xml
~~~

6. Compile!

~~~sh
mvn compile
~~~

Notes:

- If you multiple files with the same name, you'll get multiple copies with a number suffix, e.g. MANIFEST.MF~1.
- JAD can't always decompile files.
