---
title: Spring Transactional Gotchas
date: 2014-11-06 21:30 UTC	
tags: spring
---
What is @Transactional and how can it catch me out?
---
The @Transactional annotation is used by Spring to wrap a method call in a transaction, committing if successful, and rolling back if unsuccessful.

It has a couple of quite nasty gotchas. 

Today we'll create a very simple app with one class, a H2 database and use Spring to wire it together. It'll have one test, which will make sure `@Transactional` is working and demonstrate some gotchas.

You can find all the following code on [Github](https://github.com/alexec/spring-tx-gotchas).

Create the following `pom.xml`:

~~~xml
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>spring-tx-gotchas</groupId>
    <artifactId>spring-tx-gotchas</artifactId>
    <version>1.0.0-SNAPSHOT</version>

    <properties>
        <spring.version>3.2.11.RELEASE</spring.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
            <version>${spring.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-jdbc</artifactId>
            <version>${spring.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-tx</artifactId>
            <version>${spring.version}</version>
        </dependency>
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <version>1.4.182</version>
        </dependency>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.11</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-test</artifactId>
            <version>${spring.version}</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

</project>
~~~

OK, it's quite involved, but we're not done yet. Create this class:

~~~java
public class App {
    @Autowired
    private JdbcTemplate db;

    @PostConstruct
    public void createTable() {
        db.execute("create table test (id int)");
    }

    @PreDestroy
    public void dropTable() {
        db.execute("drop table test");
    }

    @Transactional
    public void insertOneRecordAndThenThrowException() {
        db.execute("insert into test values(1)");
        throw new RuntimeException("boom!");
    }

    public int countRecords() {
        return db.queryForObject("select count(*) from test", Integer.class);
    }
}
~~~

An Spring XML configuration file named `AppTest-context.xml` in the root of your class path:

~~~xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:p="http://www.springframework.org/schema/p"
       xmlns:tx="http://www.springframework.org/schema/tx" xmlns="http://www.springframework.org/schema/beans"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx.xsd">

    <tx:annotation-driven/>

    <bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource"
          p:driverClassName="org.h2.Driver" p:url="jdbc:h2:/tmp/test" p:username="sa"/>

    <bean class="org.springframework.jdbc.core.JdbcTemplate" p:dataSource-ref="dataSource"/>

    <bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager" p:dataSource-ref="dataSource"/>

    <bean class="App"/>

</beans>
~~~

And finally, this test:

~~~java
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration
public class AppTest {

    @Autowired
    private App app;

    @Test
    public void test() throws Exception {
        try {
            app.insertOneRecordAndThenThrowException();
            fail();
        } catch (RuntimeException e) {
            assertEquals("boom!", e.getMessage());
        }

        assertEquals(0, app.countRecords());
    }
}
~~~

Run the test, you'll find it's green. It tells us that even though we had an exception in the method, we rolled back our changes.

Now, lets experiment. Comment out `@Transactional` and re-run the test. It'll be red. Uncomment it again before you continue.

Constructors Gotcha
---

Change `App` to use constructor injection:

~~~java
public class App {
    
    private final JdbcTemplate db;

    @Autowired
    public App(JdbcTemplate db) {
        this.db = db;
    }
~~~

Run the test. You'll see this exception:

~~~
IllegalArgumentException: Superclass has no null constructors but no arguments were given
~~~

You can't use `@Transactional` on a class without a no-args constructor. Revert this change.

You may need to delete the database now if you see `Table "TEST" already exists`:

~~~shell
rm -R /tmp/test.*
~~~

Non-Public Method Gotcha
---
Now lets look a more insidious error, change `App` so that the insert method is protected like this:

~~~
protected void insertOneRecordAndThenThrowException() {
~~~

The test will fail. `@Transactional` only works on public methods, but you get no error or warning about it.

Conclusion
---
Watch out for these problems! In [my next post](http://www.alexecollins.com/java-annotation-processor-tutorial/index.html) I'll show how to prevent these errors at compile time. 
