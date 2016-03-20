---
title: Developing With Docker - Building Patterns
date: 2016-03-20 16:00 UTC
tags: docker, developing-with-docker
---
This is my 4th post on [developing with Docker](/tags/developing-with-docker)). In previous posts I've focussed on debugging applications. This post deals with some common ways you can build Docker images.

I'm going to assuming you've already packaged your application (e.g. into a JAR).

There are several choices: **scratch + binary**, <!-- **scratch + zip**,--> **language stack**, and **distro + package manager**.

## Scratch + Binary

Scratch is the most basic image, it does not contain any files at all. You must build a **standalone binary application** if you are going to use this. Lets seen an example.

Firstly, we'll build a standalone binary application using Docker.

Create an empty directory, and then create `main.go` with the following content:

~~~go
package main

import "fmt"

func main() {
    fmt.Println("Hello World")
}
~~~

Compile the application:

~~~shell
docker run --rm -ti -v $(pwd):/go/src/myapp google/golang go build myapp
~~~

Create a `Dockerfile` for the application:

~~~Dockerfile
FROM scratch
ADD myapp /
CMD ["myapp"]
~~~


Finally build and run the image:

~~~shell
docker build -t myapp:1 .
docker run --rm -ti myapp:1
~~~

You'll see "Hello World" printed in your terminal.

Advantages:

- As the image contains just one file it has a **very low attack surface**.
- Typically small images, and runtime memory usage.

Disadvantages

- Only suitable for applications that can be packaged as standalone binaries
- No language runtime, so larger applications will take more disk-space as they do not share image layers.
- No built in diagnostics tools, such as `curl`.

<!--
## Scratch + Zip

**Scratch + Zip** is similar to **scratch + binary**, in that you start with the `scratch` base image. You then un-zip into in any files you need. This essentially the same process similar to building a base image.

~~~shell
curl https://bitbucket.org/alexkasko/openjdk-unofficial-builds/downloads/openjdk-1.7.0-u80-unofficial-linux-i586-image.zip
~~~
-->

## Language Stack

Docker provide a number of pre-built base images for the runtime for common languages.

Lets look an example. Create a new empty directory and in it, `Main.java`:

~~~java
public class Main {
  public static void main(String[] args) {
    System.out.println("Hello World");
  }
}
~~~

Compile this application using the Java Development Kit:

~~~shell
docker run --rm -ti -v $(pwd):/myapp -w /myapp java:8-jdk javac Main.java
~~~

Create the following `Dockerfile`:

~~~Dockerfile
FROM java:8-jre
ADD Main.class /
CMD ["java", "-cp", "/", "Main"]
~~~

Finally, you can run this:

~~~shell
docker build -t myapp:1 .
docker run --rm -it myapp:1
~~~

Advantages

- Fast to deploy, once the base image is downloaded.
- If you use the same base image for many apps, the additional layer needed is tiny.

Disadvantages

- Base image must be downloaded.
- You'll need to consider how you re-build and re-deploy images if you find a security vulnerability in the base.

### Distro + Package Manager

If you want to build an image that is not on a supported language stack, then you'll need to roll your own, starting with a **distro**, and then using a **package manager** to add any dependencies you need.

Linux always contains a package manager, we can build a similar images to the Java image above using it by starting with Ubuntu:

~~~Dockerfile
FROM ubuntu:15.10

RUN apt-get update && apt-get install --no-install-recommends -y openjdk-8-jre

ADD Main.class /

CMD ["java", "-cp", "/", "Main"]
~~~

As per the last examples, build and run this base image:

~~~shell
docker build -t myapp:1 .
docker run --rm -it myapp:1
~~~

Advantages

- Flexible, can build any application.
- Can put multiple applications into a single image (using systemd).

Disadvantages

- Longer build time.
- You'll need to consider how you re-build and re-deploy images if you find a security vulnerability in the base.
