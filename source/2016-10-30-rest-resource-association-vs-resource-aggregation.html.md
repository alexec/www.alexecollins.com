---
title: REST - Resource Association vs Resource Aggregation
date: 2016-10-30 13:00 UTC
tags: api, rest
---
Imagine you're creating an API for ordering meals in restaurant. You have an API that allows to you create a meal, and then add starters to it:

~~~
POST /meals
{}
	
HTTP/1.1 201 Created
Location: /meals/1
~~~

~~~
POST /meals/1/starters
{"option": "soup"}
	
HTTP/1.1 201 Created
Location: /meals/1/starters/1
~~~

~~~	
POST /meals/1/starters
{"option": "salad"}
	
HTTP/1.1 201 Created
Location: /meals/1/starters/2
~~~

This API shows a pretty standard example of creating resources which are associated in a one-to-many relationship. Consider the URL `/meals/1/starters/2` the first half of the path (i.e. `/meals/1`) indicates the entity that is the "one" side, and the second half (i.e. `/starters/2`) indicates an entity on the "many" side. 
	 
This works well, until you realise that you need to send a number of messages order a whole meal. Lets change the API to allow you to order the meal in one go:

~~~
POST /meals
{
	"starters": [
		{"option": "soup"}, 
		{"option": "salad"}
	]
}
	
HTTP1.1 201 Created
Location /meals/1
~~~

Brilliant - we've reduced the number of messages to order a email. But, now the client want to change their starter, they want to remove the salad. How can we do this?

Interestingly, we changed our model when we changed the API. Previously we had two resources: `meal` and `starter`. 

Originally the starters were entities (they had identity) and were **associated** with the meal. Now the starters are just a part of the meal: the meal is a domain **aggregate**.

We've fundamental changed our model, but we need to answer a key question: are starters entities (the first API) or part of the aggregate?

Contrast the mean to an API to collect data about who lives in what property:

Say it already has a database of people:

~~~
GET /people/2

HTTP/1.1 201 Created
{"name": "John Smith"}
~~~

So to say that John live at a property we need to do two requests:

~~~
POST /properties
{"address": "..."}

HTTP/1.1 201 Created
Location: /properties/1
~~~

~~~
POST /properties/1/people/2
{}

HTTP/1.1 201 Created
~~~

Seems straight-forward, but we find out our common use case is to create a property with all the people at the same time, so we want a way to do that:

~~~
POST /properties
{
	"address": "...",
	"people": [{"id": 2}]
}

HTTP/1.1 201 Created
Location: /properties/1
~~~

So far, so good. But what's wrong with this? What happens when I get the property:

~~~
GET /properties/1

HTTP/1.1 200 OK
{
	"address": "..."
}
~~~

I don't know who lives there, but my common use case is that I always want to list the people living there! The HAL specification provides the `_embedded` keyword for this:

~~~
GET /properties/1

HTTP/1.1 200 OK
{
	"address": "...",
	"_embedded": {
		"people": [{"id": 2, "name": "John Smith"}]
	}
}
~~~

This makes it clear that the people aren't part of the resource. In this case we want symmetry in the API, so we can use the `_embedded` keyword in the creation: 

~~~
POST /properties
{
	"address": "...",
	"_embedded": {
		"people": [{"id": 2, "name": "John Smith"}]
	}
}

HTTP/1.1 201 Created
Location: /properties/1
~~~

# Conclusion

It's important when consider your API to determine if something in your model is an entity or not. In the meal example, the starters turned out not to be entities, so having an API to create them separately would be odd. Unlike the property API, when the identity of the people was key to the API.