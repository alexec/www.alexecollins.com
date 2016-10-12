---
title: Try-Fail-Catch-Assert JUnit Patttern
date: 2014-11-15 18:57 UTC
tags: junit, testing
---
There's a pattern I like to use when testing for exceptions in JUnit. I call it the "Try-Fail-Catch-Assert Pattern".

Why would I want to use this pattern when I can just use `@Test(expected = "…")`?

~~~java
public class AppTest {

    private App app;

    @Before
    public void setUp() throws Exception {
        app = new App();
    }

    @Test(expected = IllegalStateException.class)
    public void shutdownWithOutStartThrowsIllegalStateException() throws Exception {
        app.configure();
        app.shutdown();
    }
}
~~~

The goal of this test is to make sure that if I try to shutdown the app without starting it up, then I get an exception. Let's look at the code of `App`:

~~~java
public class App {
    private State state;
    private String name;
    public void configure() {
        if (name == null) {
            throw new IllegalStateException("name is null");
        }
    }

    public void start() {
        // some code
    }

    public void shutdown() {
        // some code
    }

    public void setName(String name) {
        this.name = name;
    }
}
~~~

My test is going to be green, but for the wrong reason, not due to the state, rather due to the incorrect configuration of the app's name.

The problem is that using `expected` is too coarse. It catches my exception from `configure`, but not from `shutdown`. We can address this using try-fail-catch.

~~~java
@Test
public void shutdownWithOutStartThrowsException() throws Exception {
    app.configure();
    try {
        app.shutdown();
        fail();
    } catch (IllegalStateException e) {
        // nop
    }
}
~~~

We no longer catch the erroneous exception from the `configure`. The `fail` makes sure the test fails if we do not get any exception at all. The `catch` targets the `IllegalStateException` we expect. When I run it, it's red, as the name is not set; but that's easy to change:

~~~java
public void shutdownWithOutStartThrowsIllegalStateException() throws Exception {
    app.setName("");
~~~

Now it's green, great! But should it be??? Lets look further at the code of `App`:

~~~java
public void shutdown() {
    if (name.isEmpty()) {
        throw new IllegalStateException("name is empty");
    }
    // some more code
}
~~~

Oh no! It's green, but for the wrong reason. There's another check in the `shutdown` method for `name`. More generally, I can get an `IllegalStateException` for any reason. I need a more refined test on the exception, and here is where the `asset` comes in:

~~~java
} catch (IllegalStateException e) {
    assertEquals("state is not STARTED", e.getMessage());
}
~~~

When I run it, I get this output:

~~~
Expected :state is not STARTED
Actual   :name is empty
~~~

I hope you can see the benefit for targeted exception verification using the try-fail-catch-assert pattern. As usual, the code can be found [on Github](https://github.com/alexec/try-fail-catch-assert).