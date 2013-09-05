---
title: "Thread Jiggling"
---
<h2>Overview</h2>

<p>Thread jiggler is a simple testing framework for exercising code to find threading problems. It works by modifying classes bytecode at runtime to insert Thread.yield() calls between instructions - "jiggling" the threads. This greatly increases the likelihood of discovering threading issues, and does it without you needing to change your production code.</p>

<h2>Background</h2>

<p>I was recently researching how to test multithreaded code for threading issues, and found out about a tool from IBM called <a href="http://www.almaden.ibm.com/laborday/haifa/projects/verification/contest/index.html">ConTest</a>, but couldn't find any code I could use myself. So naturally, I thought I'd spike my own.</p>

<p>Consider this canonical simple, but thread unsafe class:</p>

~~~java
    private int count = 0 ;

    public void count() {
        count++;
    }
~~~

<p>The count method's byte code is:</p>

	DUP
	GETFIELD asm/Foo.counter : I
	ICONST_1
	IADD
	PUTFIELD asm/Foo.counter : I

<p>This provides several places where there could be a context switch, which means that count my be increased, but not stored as expected. Let consider a quick unit test:</p>

~~~java
    Counter counter = new BadCounter();
    int n = 1000;

    @Test
    public void singleThreadedTest() throws Exception {

        for (int i = 0; i < n; i++) {
            counter.count();
        }

        assertEquals(n, counter.getCount());
    }
    ...
~~~
<p>This test runs in a single thread, and passes. Lets try and run this on two threads and see if it fails.</p>

~~~java
    public void threadedTest() throws Exception {
	
        final CompletionService<Void> service = new ExecutorCompletionService<Void>(Executors.newFixedThreadPool(2));

        for (int i = 0; i < n; i++) {
            service.submit(new Callable<Void>() {
                @Override
                public Void call() {
                    counter.count();
                    return null;
                }
            });
        }

        for (int i = 0; i < n; ++i) {
            service.take().get();
        }

        assertEquals(n, counter.getCount());
     }
~~~

<p>This also passes. On my computer I can increase <em>n</em> to 100,000 before it starts to fail consistently.</p>

	Expected :1000000
	Actual   :999661

<p>Just 0.04% of the tests had a problem. What have we learned? We've learned a simple way to run a multithreaded test, but we've learned that, because we can't control when threads do their work, it's a bit trial and error.</p>

<h2>Thread Jiggling</h2>

<p>So one problem exercising code to find threading defects is that you can't control when threads will yield. However, we can re-write the bytecode to insert Thread.yield() into the bytecode between instructions. In the above example we can get the code to produce more issues by changing the bytecode:</p>

	DUP
	GETFIELD asm/Foo.counter : I
	INVOKESTATIC java/lang/Thread.yield ()V
	ICONST_1
	IADD
	PUTFIELD asm/Foo.counter : I

<p>Using ASM, we can create a rewriter to insert these invocations. The JigglingClassLoader re-writes classes on the fly, adding these calls. From this we can create a JUnit runner to run use the new class loader for the test.</p>

~~~java
@Jiggle("threadjiggler.test.*")
public class BadCounterTest {
    ...
}
~~~

<p>Now running the test:</p>

	Expected :1000000
	Actual   :836403

<p>The number of test where we see the threading problem jump to 16%. We've done this with out any recompilation of the code, or impacting on other unit tests running in the same JVM.</p>

<h2>Exercise for the Reader</h2>

<p>SimpleDateFormat is a well know, non-thread safe class in Java. Write a test that jiggles the class. Why is it not thread-safe? How would you rewrite it so that it was thread safe? How can you do so without using a ThreadLocal, locks or synchronisation?</p>

<h2>Source Code</h2>

<p>The code for this can be <a href="https://github.com/alexec/thread-jiggler">found on Github</a>.</p>

<h2>Further Reading</h2>

<p>I've written <a href="/content/5-tips-unit-testing-threaded-code">a post on testing threaded code for correctnes</a>. You may also wish to read more generally:</p>

<ul>
<li><a href="ftp://ftp.cs.umanitoba.ca/pub/IPDPS03/DATA/W20_PADTD_02.PDF">Concurrent Bug Patterns and How to Test Them - Eitan Farchi, Yarden Nir, Shmuel Ur IBM Haifa Research Labs</a></li>
<li><a href="http://www.almaden.ibm.com/laborday/haifa/projects/verification/contest/papers/testingConcurrentJune2008ForMS.pdf">A presentation describing the difficulty of testing and debugging concurrent software - Shmuel Ur</a></li>
<li><a href="http://www.ibm.com/developerworks/java/library/j-jtp09263/index.html">Java theory and practice: Characterizing thread safety</a></li>
</ul>
