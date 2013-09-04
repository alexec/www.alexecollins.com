---
title: "ORM an anti-pattern Lets examine this."
---
I recently read an article via DZone, and was immediately drawn to the title.

I'd like to ignore the "anti-pattern" discussion, focus on the specific problems, and look at the root cause of those problems, and see what positives can we come up with.

<h2>"ORM writes some SQL for you, but you always ending up doing some SQL anyway, why not write all the boiler plate yourself?"</h2>

Fair comment. Why use two tools for a job, when just one will do? Are the two tools the same? While you can hand-roll all your SQL, there are benefits you don't get, which are expensive to add. For example. Caching. This can be as simple a few lines of configuration and some tuning. If you hand roll, hours of work. 

<em>Edit:</em> All the feedback I've had points to connection pooling being actually pretty easy to do in natively. So I've removed this section.

<h2>"SQL gives you control, why risk your ORM screwing that up?"</h2>

Did you know that you can get the ORM to log the SQL it runs? I'd say that you need to make sure any SQL that is executed is verified as sensible and performant, regardless of whether it is hand rolled, or generated. Would not doing this be a failure of due diligence?

<h2>"Why risk the performance with all this additional code?"</h2>

In my experience, performance issues have rarely had their root cause in code. It's been the network or the database. The former if often out of your control, the latter exists in both native SQL and ORM based solutions. 

Perhaps what were really talking about is pre-emptive optimisation? Would Knuth would have a thing or two to say about this?

Conversely, I'd recently discussed the benefit of both solution with the wallet tech lead at a games company. I was interested to find out they were replacing their ORM with JDBC code. "What was the reason" I asked? "Performance" was the reply. The right tool for the right job. If part of your application has high transactional throughput, then you are going to need a high performing solution. ORM does not solve this problem - it is not for you.

<h2>"ORM bring backs the whole record from the database, it's inefficient"</h2>

This is true. And in fact, there are plenty of situations that you won't want query in an OO fashion. For example - aggregation queries. Consider a simple example where ORM brings back too much data is when you've added a large varchar to a table that you don't need very often. But hang on - was it a design error to add the column to the table in the first place? Either way, in real life, you might find a large varchar column attached to a table that isn't going to move, that you don't want to bring back. Solutions? There's a couple. 

1) Not using it? Remove it from the object. In fact,  don't add columns etc until you need them. Keep your objects lean and save yourself time.
2) Add it. Is it really a problem? Might be a high read/write table, but then, does a large varchar belong on that table?
3) Is this a suitable time to use ORM? Might be time to revert to SQL.

<h2>Summary</h2>
The ORM debate is hardly over. There will always be people wanting to use it when it's not appropriate, and those not using it when it might be, and on a case by case basis, they may turn out to be right or wrong.

Interestingly, I wonder if it's a stepping stone to something else? Relational databases are going to be around for sometime yet, but is ORM the only solution to reducing boiler plate code?

Have I missed something? Let me know. I'd love to expand this out.
