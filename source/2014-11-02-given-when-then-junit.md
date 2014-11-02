---
title: Given When Then JUnit
date: 2014-11-02 19:00 UTC
tags: testing, junit
---
I was introduced to a way to take some of the benefits of using the given/when/then style of specification based testing.

If you don't want to start using a system like Cucumber JVM with your existing codebase, you can still get a lot of the benefit from applying the mindset.

The code is on [Github](https://github.com/alexec/givenwhenthenjunit).

Let consider the Gherkin from [Wikipedia's page on BDD](http://en.wikipedia.org/wiki/Behavior-driven_development).

~~~gherkin
Feature: Returns go to stock

	In order to keep track of stock
	As a store owner
	I want to add items back to stock when they're returned

	Scenario: Refunded items should be returned to stock
		Given a customer previously bought a black sweater from me
		And I currently have three black sweaters left in stock
		When he returns the sweater for a refund
		Then I should have four black sweaters in stock

	Scenario: Replaced items should be returned to stock
		Given that a customer buys a blue garment
		And I have two blue garments in stock
		And three black garments in stock.
		When he returns the garment for a replacement in black,
		Then I should have three blue garments in stock
		And two black garments in stock
~~~

We can code this into JUnit test ([commit](https://github.com/alexec/givenwhenthenjunit/commit/2f5527ce11869bfae86a84428183e395cf1425d5). The class represents the story, and each scenario is a method.

~~~java
/**
 * In order to keep track of stock
 * As a store owner
 * I want to add items back to stock when they're returned
 */
public class ReturnsGoToStockStoryTest {

    @Test
    public void refundedItemsShouldBeReturnedToStock() {
        // Given a customer previously bought a black sweater from me
        // And I currently have three black sweaters left in stock
        // When he returns the sweater for a refund
        // Then I should have four black sweaters in stock
        fail();
    }

    @Test
    public void replacedItemsShouldBeReturnedToStock() {
        // Given that a customer buys a blue garment
        // And I have two blue garments in stock
        // And three black garments in stock.
        // When he returns the garment for a replacement in black,
        // Then I should have three blue garments in stock
        // And two black garments in stock
        fail();
    }
}
~~~

There's a couple of things to note here:

* None of the comments will appear on  display in the CI.
* I've added a `fail()` at the end of each test to make sure I complete it.
* I'm sticking with Java and JUnit naming conventions.

Now we can implment the tests ([commit](https://github.com/alexec/givenwhenthenjunit/commit/7c964872a44056f374faee97ae2d28ee2b1c40eb)):

~~~java
    @Test
    public void refundedItemsShouldBeReturnedToStock() {

        Inventory inventory = new Inventory();

        // Given a customer previously bought a black sweater from me
        BlackSweater blackSweater = new BlackSweater();
        inventory.sellItem(blackSweater, new Customer());
        
        // And I currently have three black sweaters left in stock
        inventory.addItem(new BlackSweater());
        inventory.addItem(new BlackSweater());
        inventory.addItem(new BlackSweater());

        // When he returns the sweater for a refund
        inventory.returnItem(blackSweater);

        // Then I should have four black sweaters in stock
        assertEquals(4, inventory.countStock(BlackSweater.class));
    }
~~~

Go ahead and implement the logic if you like. I've implement hard-coded returns in my code. Lets complete the second test ([commit](https://github.com/alexec/givenwhenthenjunit/commit/8a4ddf75e06148a13674417032d4988898ec93ba)).

~~~java
    @Test
    public void replacedItemsShouldBeReturnedToStock() {

        Inventory inventory = new Inventory();

        // Given that a customer buys a blue garment
        BlueGarment blueGarment = new BlueGarment();
        inventory.sellItem(blueGarment, new Customer());

        // And I have two blue garments in stock
        inventory.addItem(new BlueGarment());
        inventory.addItem(new BlueGarment());

        // And three black garments in stock.
        inventory.addItem(new BlackGarment());
        inventory.addItem(new BlackGarment());
        inventory.addItem(new BlackGarment());

        // When he returns the garment for a replacement in black,
        inventory.replaceItem(blueGarment, inventory.get(BlackGarment.class));

        // Then I should have three blue garments in stock
        assertEquals(3, inventory.countStock(BlueGarment.class));

        // And two black garments in stock
        assertEquals(2, inventory.countStock(BlueGarment.class));
    }
~~~
These test share both customer and inventory. We can refactor this out.

~~~java
    private Inventory inventory;
    private Customer customer;

    @Before
    public void setUp() throws Exception {
        inventory = new Inventory();
        customer = new Customer();
    }
~~~

Finally, we can implement the main code ([commit](https://github.com/alexec/givenwhenthenjunit/commit/83409db87271dffb9b634819e1afb9e2937173fd)). Note that I've still got TODOs in the code, as I can clearly see some other scenarios that we'll want to write.

I hope this shows you one interesting way to write your tests and bring some new ideas to your code with having to take on a new technology to do so.

Read [more about unit testing](http://www.alexecollins.com/tags/testing/).
