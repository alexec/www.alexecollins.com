---
title: Type Aliasing in Java
date: 2013-11-09 10:01 UTC
tags: java
---
Type aliasing allow you to use a named type in place of another without writing code for the alias. Unlike C or Scala, Java provides no system for doing type aliasing. In C this is:

	typedef int myint;
	
In Scala:

	type MyInt = Int
	
The benefits of type aliasing can be easily seen by looking at this method signature:

	void save(long customerId, long referenceId, long statementId);
	
It would be easy to mix up these arguments! It would be preferable to use typed arguments:

	void save(CustId customerId, RefId referenceId, StmtId statementId);

Here CustId is a concrete class which we'd like to be an alias for Long, but as Long is a final class, we cannot sub-class it. This can be done using a simple class:

	public class CustId {
		private final long value;
		public CustId(long value) {this.value=value;}
		public CustId valueOf(long value) {return new CustId(value);}
		public long longValue() {return value;}
		@Override public String toString() {return value;}
	}
	
What else can we do? Long implements Number. This will allow us to have flexibility in target methods, which might wish to accept both boxed longs and CustId.

	@Deprecated
	void save(Number customerId, RefId referenceId, CustId statementId);
		save(CustId.valueOf(customerId.longValue()), referenceId, statementId);
	}

This isn't without draw-backs. The lack of implict conversion (I'd almost argue to T.valueOf() is Java's implict conversion function) makes this code verbose, and the type of bug we're trying to resolve could be sorted out using static analysis.