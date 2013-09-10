---
title: "Tutorial: JUnit @Rule"
tags: testing,junit,java
---
<h2>Overview</h2>

<p>Recent versions of JUnit have added support for a concept called rules, a system similar to custom runners, but without some of the restrictions. This tutorial looks at creating custom rules, how this can simplify integration with Spring and Mockito, and how you can create simpler and more powerful tests using them.</p>

<h2>Rules as Runners</h2>

<p>You might be familiar with SpringJUnit4ClassRunner or MockitoJUnitRunner, both of which can be applied to a test class to inject dependencies - either from the application context into fields annotated with @Autowired the case of Spring, or mocks annotated with the @Mock annotation in the case of Mockito, for example:</p>

~~~java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = "classpath:testContext.xml")
public class FooTest {
	
@Autowired
private String foo;
...
~~~

<p>Or</p>

~~~java
@RunWith(MockitoJUnitRunner.class)
public class BarTest {
	
	@Mock
	private List<String> bar;
~~~

<p>What if you wanted both mocks and dependencies and injected? In recent JUnit versions (&gt;= 4.7), @RunsWith can be replaced with @Rule. @Rule can be used by a class in indicate that it requires work done before and after a test's execution. This can allow you to test standard parts of your application, while at the same time, creating the context that you need to run you tests in. For example, you could verify some test invariants, create an application context or set-up a JPA session/JDBC connection for integration tests.</p>

Lets start with a basic set of boiler-plate dependencies in our pom.xml:

~~~xml
<dependency>
	<groupId>org.springframework</groupId>
	<artifactId>spring-context</artifactId>
	<version>2.5.6</version>
</dependency>
<dependency>
	<groupId>org.springframework</groupId>
	<artifactId>spring-test</artifactId>
	<version>2.5.6</version>
	<scope>test</scope>
</dependency>
<dependency>
	<groupId>org.mockito</groupId>
	<artifactId>mockito-core</artifactId>
	<version>1.9.0</version>
	<scope>test</scope>
</dependency>
<dependency>
	<groupId>junit</groupId>
	<artifactId>junit</artifactId>
	<version>4.10</version>
	<scope>test</scope>
</dependency>
~~~

<p>Next we'll create a rule for injecting @Autowired dependencies. This rule wraps each execution of a test within the class by creating a context, injecting the beans into the classes fields, and managing the life-cyle of that context.</p>

~~~java
public class SpringContextRule implements TestRule {
	
    /** A list of class-path contexts. */
    private final String[] locations;
    
    /** The target test. */
    private final Object target;

    public SpringContextRule(String[] locations, Object target) {
        this.locations = locations;
        this.target = target;
    }

    public Statement apply(final Statement base, Description description) {
        return new Statement() {
            @Override
            public void evaluate() throws Throwable {
                ConfigurableApplicationContext context = new ClassPathXmlApplicationContext(
                        locations);
                context.getAutowireCapableBeanFactory().autowireBean(target);
                context.start();
                try {
                    base.evaluate();
                } finally {
                    context.close();
                }
            }
        };
    }
}
~~~

<p>We can test this works using a small context and test, that verifies that auto-wired fields are set as expected.</p>

~~~xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-2.5.xsd http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-2.5.xsd">

	<context:annotation-config/>

	<bean id="bar" class="java.lang.String">
		<constructor-arg value="bar"/>
	</bean>

</beans>
~~~

~~~java
public class FooTest {

	@Rule
	public TestRule contextRule = new SpringContextRule(
			new String[] { "testContext.xml" }, this);

	@Autowired
	public String bar;

	@Test
	public void testBaz() throws Exception {
		assertEquals("bar", bar);
	}
}
~~~

<p>Next we can extend this, by adding a mocking rule. This will simply populate the mocks before each test.</p>

~~~java
public class MockRule implements TestRule {

    private final Object target;

    public MockRule(Object target) {
        this.target = target;
    }

    public Statement apply(final Statement base, Description description) {
        return new Statement() {
            @Override
            public void evaluate() throws Throwable {
                MockitoAnnotations.initMocks(target);
                base.evaluate();
            }
        };
    }
}
~~~

<p>Finally, lets put it all together with a final test.</p>

~~~java
public class FooTest {

    @Rule
    public TestRule contextRule = new SpringContextRule(new String[]{"testContext.xml"}, this);

    @Rule
    public TestRule mockRule = new MockRule(this);

    @Autowired
    public String bar;

    @Mock
    public List baz;

    @Test
    public void testBar() throws Exception {
        assertEquals("bar", bar);
    }

    @Test
    public void testBaz() throws Exception {
        when(baz.size()).thenReturn(2);
        assertEquals(2, baz.size());
    }
}
~~~

<p>This test shows that you can mix two rules together, something that you cannot do with @RunWith. You could create you own custom runner, but that runner would have very poor <a href="http://en.wikipedia.org/wiki/Cohesion_(computer_science)">cohesion</a>.</p>

<h2>Rules as Invariants</h2>

<p>With @Rule, not only can you mix different rules, you can also enforce invariants. To do this, we'll create an marker annotation for fields that should not change, and a new rule to check the invariants.</p>

~~~java
@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
public @interface Invariant {
}
~~~

<p>The rule cheaply stores each field's hash-codes and then compares them before and after the test, throwing an error if the hash-code has changed.</p>

~~~java
public class InvariantRule implements TestRule {
	
    private final Object target;

    /**
     * It should be noted that, while cheap and safe, an object can 
     * change, but the hash code not. Bugs that result might be a tricky to diagnose.
     */
    private final Map<Field, Integer> fieldToHashCode = new HashMap<Field, Integer>();

    public InvariantRule(Object target) {
        this.target = target;
    }

    public Statement apply(final Statement base, Description description) {
        return new Statement() {
            @Override
            public void evaluate() throws Throwable {
                fieldToHashCode.clear();

                for (Field f : target.getClass().getFields()) {
                    if (f.isAnnotationPresent(Invariant.class)) {
                        fieldToHashCode.put(f, f.get(target).hashCode());
                    }
                }

                base.evaluate();

                for (Map.Entry<Field, Integer> e : fieldToHashCode.entrySet()) {
                    if (e.getKey().get(target).hashCode() != e.getValue()) {
                        throw new AssertionFailedError(e.getKey().getName() + " changed");
                    }
                }
            }
        };
    }
}
~~~

<p>Finally, a test.</p>

~~~java
public class BazTest {

    @Rule
    public TestRule invariantRule = RuleChain.outerRule(
            new TestRule() {
                @Override
                public Statement apply(final Statement base, Description description) {
                    return new Statement() {
                        @Override
                        public void evaluate() throws Throwable {
                            qux = 2;
                            base.evaluate();
                        }
                    };
                }
            }).around(new InvariantRule(this));

    @Invariant
    public int qux;

    @Test
    public void testListUnchanged() throws Exception {
        // nop
    }

    @Test // this will cause on exception
    public void testListChangedImpliesError() throws Exception {
        qux = 3;
    }
}
~~~

<h2>Conclusion</h2>

<p>You may have noted that @Before and @After have not featured in these tests. Rules are executed around @Before/@After and therefore it's not possible to set-up invariants in @Before. Instead we use a rule chain to create what is  effectively a @Before using an anonymous inner class. @Rule provides a more powerful and flexible way of reducing boilerplate code in your test.</p>

<p>This a href="https://github.com/alexec/test-support">code is on Github</a>.</p>
