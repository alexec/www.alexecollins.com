---
title: ANTLR4 and Maven Tutorial
date: 2014-02-09 17:18 UTC
tags: java, antlr, maven, dsl
---
I've been working on a side project to write an external DSL. It's partly to get some more exposure to DSLs, and Java 8. ANTLR grammar is well documented, and has great tooling, but many tutorials stop at writing code exercises the new language, so I've added a my own example here.

This tutorial is in four simple parts, but you may wish to read up a little on DSLs and Java 8 first.

The grammar we're going to create is for a simple command line game similar to battleships. The user digs a field containing buried treasure, if they find treasure, they score points. The DSL will allow a game designer to create their own fields, decide what treasure is buried and how much it scores. 

~~~
You're playing "Example Field".
Where do you want to dig (enter x then y)?
3 1
You found "Golden Crown"! Your score is 50.
Where do you want to dig (enter x then y)?
4 2
Sorry, nothing there!
Where do you want to dig (enter x then y)?
3 2
You found "Broken Crockery"! Your score is 51.
~~~

As usual this will be [on Github](https://github.com/alexec/antlr-tutorial). 

The Grammar
---
We're going to use a Maven plugin to convert our grammar into a lexer and parser:

~~~xml
<plugin>
    <groupId>org.antlr</groupId>
    <artifactId>antlr4-maven-plugin</artifactId>
    <version>4.0</version>
    <executions>
        <execution>
            <goals>
                <goal>antlr4</goal>
            </goals>
        </execution>
    </executions>
</plugin>
~~~

This plugin will generate source code from the grammars `src/main/antl4/*.g4`. We also need a run time dependency:

~~~xml
 <dependency>
     <groupId>org.antlr</groupId>
     <artifactId>antlr4-runtime</artifactId>
     <version>4.0</version>
 </dependency>
~~~

Here's an example of our language:

~~~
"Example Field"
"Golden Crown" scores 50 points
"Iron Sword" scores 20 points
"Broken Crockery" scores 1 points
"Golden Sword" is buried at 3,1
"Iron Sword" is buried at 2,3
"Broken Crockery" is buried at 3,2
"Broken Crockery" is buried at 1,4
"Broken Crockery" is buried at 4,1
~~~

Add this example to `src/main/resources/example.field`, so we can use it for a test later on.

ANTLR grammars consist of a couple sections:

* A header, listing the grammar's name.
* Rules, which start with a lower-case letter, indicating how ANTLR should match text.
* Tokens, the basic tokens that make up the language (think of this as the actual words you use).

Create `src/main/antlr4/Field.g4`:

~~~antlr
grammar Field;

field:
    name=Name NL
    (points NL)+
    (burial NL)+
    EOF;

points: treasure=Name WS 'scores' WS value=Int WS 'points';
burial: treasure=Name WS 'is' WS 'buried' WS 'at' WS at=location ;
location: x=Int ',' y=Int;

Name: '"' ('A'..'Z' | 'a'..'z' | ' ')+ '"' ;
Int: ('0'..'9')+;

WS: (' ' | '\t')+;
NL:  '\r'? '\n';
~~~

Run `mvn generate-sources` to create the new sources, and have a look in `target/generate-sources/antlr4` to see what is created.

Now create a simple test:

~~~java
@Test
public void testExampleField() throws Exception {
    FieldLexer l = new FieldLexer(new ANTLRInputStream(getClass().getResourceAsStream("/example.field")));
    FieldParser p = new FieldParser(new CommonTokenStream(l));
    p.addErrorListener(new BaseErrorListener() {
        @Override
        public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine, String msg, RecognitionException e) {
            throw new IllegalStateException("failed to parse at line " + line + " due to " + msg, e);
        }
    });
    p.field();
}
~~~

You'll notice that there's a lot of boilerplate here, but note three things:

* Reading the file and "lexing" the text into tokens using `FieldLexer`.
* Creating a parser for the tokens `FieldParser`.
* Adding an error listener, that reports parsing errors.
* Parse using `.field()`;

Model
---
Any DSL needs a model, this is what we'll build from the files written in our new language. The model should be complete agnostic on the grammar. We'll create a factory to create instances of our model later on. The code is pretty basic, for example, it doesn't print out the field to show you where you've already dug, or know then the game is over. 

~~~java
public class Game {
    private String name;
    private Map<String,Integer> points;
    private String[][] grid;
    private int score = 0;

    public Game(String name, Map<String, Integer> points, String[][] grid) {
        this.name = name;
        this.points = points;
        this.grid = grid;
    }

    public void play() {
        Scanner in = new Scanner(System.in);

        System.out.println("You're playing " + name + ".") ;

        while (true) {
            System.out.println("Where do you want to dig (enter x then y)?");

            int x = in.nextInt();
            int y = in.nextInt();

            if (grid[x][y] != null) {
                String treasure = grid[x][y];
                score += points.get(treasure);
                grid[x][y] = null;
                System.out.println("You found " + treasure + "! Your score is " + score + ".");
            } else {
                System.out.println("Sorry, nothing there!");
            }
        }
    }
}
~~~

Factory
---
We need to build a model from the grammar. We'll use an observer to do this, create this class:

~~~java
public class GameFactory {
    public Game createGame(InputStream in) throws IOException {
        FieldLexer l = new FieldLexer(new ANTLRInputStream(in));
        FieldParser p = new FieldParser(new CommonTokenStream(l));
        p.addErrorListener(new BaseErrorListener() {
            @Override
            public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine, String msg, RecognitionException e) {
                throw new IllegalStateException("failed to parse at line " + line + " due to " + msg, e);
            }
        });

        final AtomicReference<String> name = new AtomicReference<>();
        final Map<String, Integer> points = new HashMap<>();
        final String[][] grid = new String[5][5];

        p.addParseListener(new FieldBaseListener() {
            int x;
            int y;

            @Override
            public void exitField(FieldParser.FieldContext ctx) {
                name.set(ctx.name.getText());
            }

            @Override
            public void exitLocation(FieldParser.LocationContext ctx) {
                x = Integer.parseInt(ctx.x.getText());
                y = Integer.parseInt(ctx.y.getText());
            }

            @Override
            public void exitBurial(FieldParser.BurialContext ctx) {
                grid[x][y] = ctx.treasure.getText();
            }

            @Override
            public void exitPoints(FieldParser.PointsContext ctx) {
                points.put(ctx.treasure.getText(), Integer.parseInt(ctx.value.getText()));
            }
        });
        p.field();

        return new Game(name.get(), points, grid);
    }
}
~~~

You'll notice that some code is copied from the test earlier on. We've added a listener that gets the data from the parser and builds up a game from it. This is a common pattern, but a listener is not the only approach. You can also use a visitor or a tree parser, but I won't talk about those here.

Application
---
Finally we can put it all together and play with a simple class:

~~~java
public class App {

    public static void main(String[] args) throws Exception {

        Game game = new GameFactory().createGame(App.class.getResourceAsStream("/example.field"));

        game.play();
    }
}
~~~

I hope this was useful to you. Have a play of the game, and try changing `example.field`. You might want to add some validation to the game to make sure you cannot add invalid treasures to the map.

Next time, I'll create a post about a simple editor for your new language.