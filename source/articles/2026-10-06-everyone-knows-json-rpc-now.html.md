---
title: Everyone knows JSON-RPC now
date: 2026-10-06 12:00 UTC
tags: oped, mcp
published: true
---
MCP has won. If you want an agent to use your product, you ship an MCP server, and most teams I talk to have already done it. MCP runs on JSON-RPC. So in the last year a very large number of developers have written a JSON-RPC API, many of them for the first time.

I think that changes what they'll build next. Once you've written one JSON-RPC API, REST and GraphQL start to look like a lot of work.

## What JSON-RPC asks of you

A JSON-RPC call has a method name, some parameters and a result. That's it. You write a function, give it a name, and it's on the API.

There's nothing to design around it. You don't argue about whether cancelling an order is a `DELETE`, a `PATCH` to a status field, or a `POST` to `/orders/{id}/cancellations`. You don't pick status codes or decide where the version number goes. You write `cancelOrder`.

## What REST and GraphQL ask of you

REST makes you model everything as resources and verbs, and a lot of real operations don't fit. Every team I've worked with has a style guide for it, and an argument about it in review.

GraphQL asks for more. You write a schema and resolvers, then add data loaders so a nested query doesn't fire hundreds of database calls. Then you add query depth and cost limits so a client can't take your service down. That's a lot of machinery, and most teams only use a fraction of what it gives them.

Both made sense when there was nothing simpler that everyone already knew. Now there is.

## The next API will be JSON-RPC too

A team with an MCP server already has the handlers, the auth and the error handling for JSON-RPC. When the web app needs an endpoint, the cheapest thing to do is add a method to what they've got. One set of handlers serves the agent and the app.

I expect most new internal and product APIs to go that way. Teams will stop writing a REST API and then wrapping it in MCP, and do it the other way round.

## Where REST holds on

REST still gets things from HTTP that JSON-RPC gives up. Every JSON-RPC call is a POST to one endpoint, so there's no GET caching and no CDN in front of your reads. If you run a public, read-heavy API, REST is still the right choice.

That's a smaller share of APIs than it sounds. Most APIs sit behind a login and serve data nobody caches anyway.

GraphQL has less to fall back on. Its best argument was letting a client fetch exactly the fields it needs in one request. A team that already speaks JSON-RPC can write a method that returns exactly what the screen needs, without the schema and the resolvers.

## What I'd watch for

Over the next year, watch what new products ship besides their MCP server. If it's a JSON-RPC API for their own app, with REST only where caching matters, I'm right. If they keep building REST first and wrapping it, I'm wrong.

My bet is on JSON-RPC.
