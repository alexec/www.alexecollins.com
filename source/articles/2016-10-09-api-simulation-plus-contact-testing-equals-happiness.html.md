---
title: API Simulation + Contact Testing = Happiness
date: 2016-10-09 14:18 UTC
tags: api, contract-testing, testing
---

You're building a new micro-service. You've got a number of other services you depend on, both internal to your organisation and external. You've been ask to do end to end testing, but you're finding it very time-consuming. It's proving very costly, and it's gotten so bad your team is unable to release any new software.

Sound familiar?

Let's look at a quick example. Your team is developing service A. It's dependent on service B and external service D.

![End-to-end testing](images/api-simulation.png)

To do your end to end testing, You speak to the team responsible the service B, and they are happy to set up the service on your test environment, just create a ticket and get it added to the backlog. You call the company responsible for service C, they say it'll take two days to set up their test environment, and say they'll send the bill shortly!

**API simulation** and **contract testing** to the rescue!

You need four things:

* A clearly defined **API specification** for each API your service uses.
* An **API simulation tool** to simulate each of those APIs.
* A test suite to make sure:
	*  The **API simulation** meets the specification.
	*  The **API implementation** meets it too.
* The ability to **prime systems for test**.

# API Specification

A good specification is clear and unambiguous. Fortunately, we now have great tools with which to write API specifications. [Swagger](http://swagger.io) is the most popular API specification language.

# API Simulation Tool

To simulate the API, you can:

* Write the simulation yourself.
* Use an online service, such as [Sandbox](https://getsandbox.com) to host your simulation.
* Use a tool such as the fantastic [Hoverfly](https://github.com/SpectoLabs/hoverfly) to run it in house.

# API Contract Test Suite

You can use any testing tool you like. I've always used the brilliant [RestAssured](http://rest-assured.io) in the past. I like the excellent [Pact](https://docs.pact.io), it combines both API simulation and contract testing, as runs in about a dozen different languages.

You'll need to run this test suite against both of the API simulation and the API implementation.

![Ensuring API simulation meets contract](images/api-simulation_001.png)

You'll want to run this suite against your simulation each time the simulation changes.

![Ensuring API implementation meets contract](images/api-simulation_002.png)

You'll want to run this suite whenever the implement may have changed. If the API is written by an external company, then it might be wise to run it at least every day.

Running the same suite against both the API simulation and the API implementation makes sure that they don't deviate from one another, resulting in new testing against the simulation that actually isn't valid.

It's well worthwhile reading Martin Fowler's [article on the topic of Consumer Driven Contracts](http://martinfowler.com/articles/consumerDrivenContracts.html).

# Priming Systems For Testing

One thing I haven't talked about is **stateful test systems**. Stateful systems are often tougher to test than stateless test systems, because you need to prime them by setting them into an appropriate state before running your test.

We ❤︎ APIs: let have an API for test priming! For example, we could have a resource that create fresh new customer:

	curl -X POST https://.../test-priming-api/customers

This can return the new customer's details

	HTTP/1.1 201 Created
	Content-Type: application/json
	...
	{"customerId": 124135}

# Testing Your Service

You can now use the API simulations to test your service use a standard test suite, but now you don't need to phone up other teams to get them to set-up their services. Happiness!

![Testing your service](images/api-simulation_003.png)  

# Conclusion

In micro-service architectures, we are now seeing emergent best practices around testing. Gone are the days of expensive heavyweight manual end to end functional testing. In their place: cheap, lightweight, and fast automated testing gives us the confidence our systems work the way we expect.
