---
title: Continuous Delivery With Kubernetes, Docker, and CircleCI
date: 2017-03-06 22:10 UTC
tags: kubernetes, docker
---

In this article I'll walk you through my experience setting up a Continuous Delivery pipeline using (mostly) open and free tools.

I've spent a lot less time writing code over the last year, and decided to create a small side-project to keep my [Kubernetes](https://kubernetes.io) skills fresh. Oh, and to use absolutely ever technology I've ever used (Deployment, Kubernetes, Nginx, Docker, CircleCI, Mongo,  Postgres, Java 8, Scala 2.11, Node, HTML, CSS, JavaScript, Ruby, Spring Boot, Playframework 2, jQuery, Phaser (PIXIJS), JUnit, ScalaTest, WDIO,  Selenium WebDriver, RestAssured, Gatling, Git/GitHub, Middleman, Jekyll, Swagger 2, urm Lisp? Cobol? Prolog? TCL?).

The project in a system for writing games, and has six main components:

![Architecture](https://raw.githubusercontent.com/phoebus-games/phoebus-games/master/arch.png)

Each component has a role to play:

* Nginx does TLS termination and serves the web content (HTML/CSS/JS)
* The router does authentication, message enrichment/routing
* The wallet backs onto a Postgres database and allows money to be added and removed from wallets
* A game that backs onto a Mongo database, and models games

I wanted to deliver this onto a server automatically, so I created this pipeline:

![CI](https://raw.githubusercontent.com/phoebus-games/phoebus-games/master/ci.png)

This means that every commit is built, tested, packaged, deployed, smoke and load tested.

I said this is nearly free, the one thing I paid for was some cloud hosted servers. I used [Digital Ocean](https://www.digitalocean.com), as they have a fantastically easy to use interface, and a variety of data centres. Kubernetes needed 3x 2CPU/2GB machines, which set me back $60 a month. You can power them down when you're not using them (using the Digital Ocean API and a curl script).

Getting Kubernetes set up from scratch (the "hard way") takes a long time and requires a lot of technical expertise and patience. Instead, I used [Stackpoint](https://stackpoint.io) to do this for me. To do this I had  to create an API token for Digital Ocean, sign-up to Stack Point, tell it the token is and it span up a Kubernetes cluster in about 15 mins.

Once it's started up, you're emailed an `kubeconfig` file to use with `kubectl`.

I build my applications and deploy them to [Docker Hub](https://hub.docker.com). I don't use any specialist tools to do this, just Maven, SBT, and the core Docker tools. You need to have `DOCKER_USER`, `DOCKER_EMAIL`, `DOCKER_PASS` - your Docker Hub username, email, and password. Here's a build script for a standalone JAR Maven project:

~~~bash
mvn package -DskipTests
docker build --rm=false -t alexec/wallet:$CIRCLE_BUILD_NUM -t alexec/wallet:latest .
docker login -e $DOCKER_EMAIL -u $DOCKER_USER -p $DOCKER_PASS
docker push alexec/wallet
~~~

For speed, I used the Alpine base images. The `Dockerfile` for the Java apps is:

~~~bash
FROM openjdk:8-jre-alpine
ADD target/wallet.jar /
ENV JAVA_OPTS=""
ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -jar /wallet.jar" ]
~~~

[Open on Github](https://github.com/phoebus-games/wallet)

The process for building standalone Playframework is a bit more complex, as Playframework does not produce a standalone JAR normally:

~~~bash
sbt dist
unzip -d target/universal target/universal/router-1.0.0-SNAPSHOT.zip
docker build --rm=false -t alexec/router:$CIRCLE_BUILD_NUM -t alexec/router:latest .
docker login -e $DOCKER_EMAIL -u $DOCKER_USER -p $DOCKER_PASS
docker push alexec/router
~~~

~~~bash
FROM openjdk:8-jre-alpine
ADD target/universal/router-1.0.0-SNAPSHOT/ /
RUN rm -f RUNNING_PID
ENV JAVA_OPTS=""
ENV APPLICATION_SECRET=changeme
ENTRYPOINT [ "sh", "-c", "java -cp 'conf:lib/*' play.core.server.ProdServerStart"]
~~~

[Open on Github](https://github.com/phoebus-games/router)

These build each commit on CircleCI. I particularly like CircleCI's clean user interface and its "insights" features, amongst I choose it in preference to the popular TravisCI.

I need to chain my builds into a pipeline, but CircleCI doesn't provide that out of the box. It has something better (IMHO), an API you can call to start a build. Each build ends up invoking this command:

~~~bash
curl -fv -u $CIRCLE_TOKEN: -X POST -d '{\"build_parameters\": {\"COMPONENT\": \"router\"}}' -H 'Content-Type: application/json' https://circleci.com/api/v1.1/project/github/phoebus-games/deploy/tree/master
~~~

`CIRCLE_TOKEN` is a CircleCI API token (you can create this using [Personal API Tokens](https://circleci.com/account/api)). This starts the `deploy` build add passes the name of the component to build. This build does some clever stuff, which I'm going to include in ill is gory glory:

~~~yaml
dependencies:
  override:
  - curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
  - chmod +x kubectl
  - sudo apt-get -y install gnupg
compile:
  override:
  - echo $GPG_KEY | gpg -d --passphrase-fd 0  --batch --yes kubeconfig.gpg > kubeconfig
test:
  override:
    - "true"
deployment:
  prod:
    branch: master
    commands:
      - env KUBECONFIG=kubeconfig PATH=$PATH:. kubectl replace --force -f $COMPONENT.yml
      - env KUBECONFIG=kubeconfig PATH=$PATH:. kubectl get pods -o name|grep "$COMPONENT\|web"|env KUBECONFIG=kubeconfig PATH=$PATH:. xargs kubectl delete
      - "curl -f -u $CIRCLE_TOKEN: -X POST https://circleci.com/api/v1.1/project/github/phoebus-games/smoke/tree/master"
~~~

Phew! Ok, so what does this do?

* Installs `kubectl` so that I can deploy Kubernetes workloads, and `gnupg` to decrypt the `kubeconfig` file.
* Decrypts the `kubeconfig` file by passing the password in via stdin.
* Skips tests!
* Deploys the component.
* Re-deploys Nginx (this is so that it can get the updated IP of the service).
* Kicks of the smoke test.

`GPG_KEY` is a random string. I used this to encrypt `kubeconfig`, as there are no "secrets" in CircleCI.

[Open on Github](https://github.com/phoebus-games/router)

Finally, a successful smoke test kicks of a load test.

## Tips

* Integration test with a real database running locally. This is super easy with Homebrew on the Mac.
* Separate the building of your component from the building of the Docker image. Use different tools.
* Separate deployment from build, and then take advantage of the Docker packaging to reuse the same deployment script.
* Don't bother trying to run it all locally. Use Wiremock to simulate your dependencies when doing integration testing.
