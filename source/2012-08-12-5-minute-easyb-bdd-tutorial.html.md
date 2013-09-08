---
title: "5 Minute EasyB BDD Tutorial"
tags: groovy,bdd
---
<p>This is a 5 minute tutorial on how to write a test story using <a href="http://www.easyb.org">EasyB</a>, a Groovy based behaviour driven development system for Java.</p> 

<p>You'll need Maven installed and you may want to have an IDE with Maven and Groovy integration. Additionally, both IntelliJ and Eclipse also provide EasyB plugins that allow you to run individual stories.</p>

<p>Firstly create a skeleton project, and add these plugins to your POM:</p>

	<!-- needed for Groovy 1.7.10 -->
	<plugin>
	    <artifactId>maven-compiler-plugin</artifactId>
	    <version>2.5.1</version>
	    <configuration>
	        <source>1.5</source>
	        <target>1.5</target>
	    </configuration>
	</plugin>
	<plugin>
	    <groupId>org.easyb</groupId>
	    <artifactId>maven-easyb-plugin</artifactId>
	    <version>1.2</version>
	    <executions>
	        <execution>
	            <goals>
	                <goal>test</goal>
	            </goals>
	        </execution>
	    </executions>
	</plugin>

<p>If, like me, you want to run them in your IDE you may want to add a Groovy runtime:</p>

	<!-- needed to run tests from within IntelliJ -->
	<dependency>
	    <groupId>org.codehaus.groovy</groupId>
	    <artifactId>groovy</artifactId>
	    <version>1.7.10</version>
	    <scope>test</scope>
	</dependency>

<p>We need a test subject, in this tutorial account, implementation to be filled in later:</p>

	public class Account {
		public void add(BigDecimal amount) {
			// nop
		}
		
		public BigDecimal getBalance() {
			return BigDecimal.ZERO;
		}
	}

<p>Finally a test for it. The Maven plugin in expects tests to be in "src/test/easyb" and named either "*Story.groovy" or "*.story":</p>

	description "account semantics"
	
	scenario "increasing an empty account", {
	
	    given "an empty account",{
	        sut = new Account()
	    }
	
	    when "1 is added", {
	        sut.add(BigDecimal.ONE)
	    }
	
	    then "the balance should be 1", {
	        sut.getBalance().shouldBe BigDecimal.ONE
	    }
	}

<p>Runs this test, either by executing "mvn test" or using your IDE. You should see:</p>

	FAILURE Scenarios run: 1, Failures: 1, Pending: 0, Time elapsed: 1.05 sec
	
		scenario "empty account"
		step THEN "the balance should be 1" -- expected 1 but was 0

<p>The test failed. Append another scenario to the file:</p>

	scenario "decreasing an empty account", {
	
	    given "an empty account",{
	        sut = new Account()
	    }
	
	    when "1 is subtracted", {
	        subtract = {sut.add(BigDecimal.ZERO.subtract(BigDecimal.ONE))}
	    }
	
	    then "an exception occurs", {
	        ensureThrows(Exception) { subtract() }
	    }
	}

<p>Note that we have to use a closure to capture the failure (not ideal). Run the test story again:</p>

	FAILURE Scenarios run: 2, Failures: 2, Pending: 0, Time elapsed: 1.409 sec
	
		scenario "increasing an empty account"
		step THEN "the balance should be 1" -- expected 1 but was 0
		scenario "decreasing an empty account"
		step THEN "an exception occur" -- expected exception of type [class java.lang.Exception] was not thrown

<p>Finally, make the test subject work:</p>

	public class Account {
		private BigDecimal balance = BigDecimal.ZERO;
	
		public void add(BigDecimal amount) {
			if (balance.add(amount).compareTo(BigDecimal.ZERO) < 0) {
				throw new IllegalArgumentException("cannot have < 0 balance");
			}
			balance = balance.add(amount);
		}
	
		public BigDecimal getBalance() {
			return balance;
		}
	}

<p>Finally, you can run this and see all your tests pass.</p>

<p>The code for this is <a href="https://github.com/alexec/easyb-tutorial">Github</a>.</p>
