---
title: Java Tuples
date: 2014-01-04 17:52 UTC
tags: java, tuples
---
Tuples are an [order sequences of elements](http://en.wikipedia.org/wiki/Tuple). They are not supported in Java, but are a couple of great reasons to support them:

* They provide a way, to group objects together that can greatly reduce the amount of boiler plate "value object" code needed.
* They *can* improve performance, by reducing the number of object dereferences when accessing arrays of objects. 

In peer languages of Java, both Scala and C# support tuples. E.g.

| Scala: |  `val x = (0, false)` |
| C#: | `var x = Tuple.Create(0, false);` |
| Haskel: | `let x = (0, false)` |
| Erlang: | `P = {0, false}` |

It's easy to think of a tuple as a type of collection, and some implementations of tuples for Java are collection like.

Homogeneous, Heterogeneous and Primitive Tuples
---
Java already supports a tidy kind of *homogeneous tuple*: the humble array.

~~~java
int[] tuple2 = {0,1};
~~~

*Heterogeneous tuples* (where types are mixed) can be put into an `Object[]', but require casting. 

~~~java
int[] intOnlyTuple = {0, 1};
Integer[] integerOnlyTuple = {0, 1};

Object[] heteroTuple = {"", Integer.class};

String _0 = (String)heteroTuple[0];
Class<Integer> _1 = (Class<Integer>)heteroTuple[0];
~~~

*Primitive tuples* are tuples that only contain primitive values. 

Note, that many of my examples will used boxed types (e.g. `Integer`) which also sub-class `Number`, or parameterised types (such as `Class<Integer>`).

Naive Tuples in Java
---
A simple example of a tuple is a parameterised class, e.g.:

~~~java
public class Tuple2<T0, T1> {
    public T0 _0;
    public T1 _1;
    
    pubilc Tuple2(T0 _0, T1 _1) {
        this._0 = _0;
        this._1 = _1;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Tuple2 tuple2 = (Tuple2) o;

        if (_0 != null ? !_0.equals(tuple2._0) : tuple2._0 != null) return false;
        if (_1 != null ? !_1.equals(tuple2._1) : tuple2._1 != null) return false;

        return true;
    }

    @Override
    public int hashCode() {
        int result = _0 != null ? _0.hashCode() : 0;
        result = 31 * result + (_1 != null ? _1.hashCode() : 0);
        return result;
    }

    @Override
    public String toString() {
        return "(" + _0 + ',' + _1 + ')';
    }
}
~~~

There's a few problems with this class, and we'll address each in turn.
 

Immutability
---
Tuples implementations are generally immutable. Immutable objects have a stable hash code and makes then more usable in common collectsions such as the `HashMap`, and better for caching. This requires each element to be immutable, but there's no way to enforce this. Instead, we can at most mark the fields as final.

~~~java
public final T0 _0;
public final T1 _1;
~~~

Type Inference
---
To create one of these, we need to provide the types:

~~~java
Tuple2<Integer,Boolean> x = new Tuple2<Integer,Boolean>(0, true);
~~~

By providing a static constructor, we can have the type implied, resulting in fewer character and more easy to read code.

~~~java
Tuple2<Integer,Boolean> x = Tuple2.valueOf(0, false);
~~~

Null Elements
---
Null in Java is a "bottom type", it can be cast to any type (like `Nothing` in Scala). We allow nulls here, but lets quickly consider the inferred type of a tuples with nulls.

~~~java
Tuple2<Object, Object> x = new Tuple2<Object,Object>(null, null);
~~~

Serializable, Cloneable & Comparable
---
Each of these are commonly implemented, and useful.

`List` is not serialisable, but `ArrayList` (and many other implementations of collections) are. Essentially we treat serialisability as a property of a class that must be determined at runtime. `Cloneable` is a marker interface, like `Serializable`, that implies runtime checking. There's no implementation code needed for either `Cloneable` or `Serializable`. For `Comparable`, the implementation is simple:

~~~java
@Override
@SuppressWarnings("unchecked")
public int compareTo(Tuple2<T0, T1> o) {
    int i = ((Comparable<T0>)_0).compareTo(o._0);
    if (i != 0) {return i;}
    return ((Comparable<T1>)_1).compareTo(o._1);
}
~~~

As a footnote, when we mark a class as `Serializable`, we might consider, for performance reasons, providing implementations of `writeObject` and `readObject`. This is also a consideration for whether or not we mark the class final.

Typing
---
When using tuples, you may might need to use bounded wildcards, this example wouldn't work if you used `Tuple<Number,Boolean>`:

~~~java
Tuple2<? extends Number,Boolean> x = Tuple2.valueOf(0f, false); // Tuple<Float,Boolean>
	
x = Tuple2.valueOf(0, false); // Tuple2<Integer,Boolean>
~~~


Tuples as Functions, Arity
---
Tuples, like maps, can be treated as functions, in Java 8 we can create an interface for Tuple, which extends `IntFunction` and provide a `size()` method (for consistency with `Collection`) to get it's arity:

~~~java
public interface Tuple<T extends Tuple> extends IntFunction, Serializable, Cloneable, Comparable<T> {

   	int size();
}
~~~

For `Tuple2` we have simple implementations of `apply(..)` and `size()`:

~~~java
@Override
public Object apply(int value) {
    switch (value) {
        case 0:
            return _0;
        case 1:
            return _1;
        default:
            throw new IndexOutOfBoundsException();
    }
}

@Override
public int size() {
    return 2;
}
~~~

In Java 8 we can have a very nice default implementation for `compareTo(..)` in `Tuple` that'll work for all sizes of tuples:

~~~java
@Override
default int compareTo(T o) {
    Objects.requireNonNull(o);
    if (!getClass().equals(o.getClass())) {
        throw new ClassCastException(o.getClass() + " must equal " + getClass());
    }

    for (int i = 0; i < size(); i++) {
        @SuppressWarnings("unchecked")
        Comparable<Object> l = (Comparable<Object>) apply(i);
        Object r = o.apply(i);
        int c = l.compareTo(r);
        if (c != 0) {
            return c;
        }
    }

    return 0;
}
~~~

And as Java 8 now supports static methods on interfaces, some nice factory methods:

~~~java
public static <T0> Tuple1<T0> valueOf(T0 _0) {
    return Tuple1.valueOf(_0);
}

public static <T0, T1> Tuple2<T0, T1> valueOf(T0 _0, T1 _1) {
    return Tuple2.valueOf(_0, _1);
}

public static <T0, T1, T2> Tuple3<T0, T1, T2> valueOf(T0 _0, T1 _1, T2 _2) {
    return Tuple3.valueOf(_0, _1, _2);
} 
~~~

Which mean you create all tuples using the same code and therefore don't have to consider "how big is my tuple?":

~~~java
Tuple2<Integer,Boolean> x = Tuple.valueOf(0, false);
Tuple3<Integer,Float,Boolean> y = Tuple.valueOf(0, 0f, false);
~~~

Sub-Classing Tuples
---
A good example of a simple tuple is `Point`:

~~~java
public class Point extends Tuple2<Integer,Integer> {
    public Point(Integer _0, Integer _1) {
        super(_0, _1);
    }
}
~~~

I now have to access x and y as `_0 `and `_1`. Not really very handy. What we want is tuples with *named elements*. Lombok provides a [nice `@Data` annotation](http://projectlombok.org/features/Data.html), that takes the skeleton of a value object and creates `equals`, `hashCode`, getters and setter when it is complied:

~~~java
@Data
public class Point {
	private final int x, y;
	// yes, it's an invalid java file, but will still compile
}
~~~

As we now don't plan to sub-class tuples, I'll make them final.

*Unpacking* Tuples
---
Currently tuples you have a packed into, by which I mean, you still have to deference each element as follows:

~~~java
Tuple2<Integer,Boolean> x = Tuple.valueOf(0, false);
int a = x._0;
boolean b = x._1;
~~~

Scala uses *pattern matching* to unpack the values, how can we do this in Java? We can't.

[Code on Github](https://github.com/alexec/tuples) as usual.

References
---
* [Adding tuples to Java: a study in lightweight data structures](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.96.6578&rep=rep1&type=pdf)
* [Compact Off-Heap Structures/Tuples In Java](http://mechanical-sympathy.blogspot.co.uk/2012/10/compact-off-heap-structurestuples-in.html)