---
title: "Dagger DI for Spring Refuges: 10 Tips"
---
  <p class="c0"><span>I've been experimenting with</span>
  <span class="c2"><a class="c3" href=
  "http://square.github.io/dagger/">Dagger</a></span><span>, a
  dependency inject systems. I was drawn to it probably for the
  same reasons as others:</span></p>

  <p class="c1 c0"></p>

  <ul class="c6 lst-kix_e8imrt6jtb8v-0 start">
    <li class="c5 c0"><span>Compile time checking.</span></li>

    <li class="c5 c0"><span>Very small (&lt;100kb), vs Guice
    (~500kb) and Spring (~800kb).</span></li>

    <li class="c5 c0"><span>Fast.</span></li>
  </ul>

  <p class="c0 c1"></p>

  <p class="c0"><span>I've been migrating a</span> <span class=
  "c2"><a class="c3" href=
  "https://github.com/alexec/openbookmaker">toy
  app</a></span><span>&nbsp;</span><span>from Spring, an app which
  uses Spring to create a context which internally sends JMS
  messages around. The app is a bit JEE, whereas I think Dagger is
  aimed at Android.</span></p>

  <p class="c1 c0"></p>

  <p class="c0"><span>What I found:</span></p>

  <p class="c1 c0"></p>

  <ol class="c6 lst-kix_6ljgxlwtxehi-0 start" start="1">
    <li class="c5 c0"><span>Dagger doesn't really like exceptions,
    either thrown from a module method, or from an constructor. I
    ended up creating a fair amount of code to wrap them in
    RTEs.</span></li>

    <li class="c5 c0"><span>Dagger doesn't provide support for bean
    life-cycle management, or hooks e.g. @PostConstruct. I ended up
    writing</span> <span class="c2"><a class="c3" href=
    "https://github.com/alexec/openbookmaker/blob/14af37a9e9a89094fcefd92a2f43393894835f2c/src/main/java/com/alexecollins/openbookmaker/LifeCycleManager.java">
    a solution to this</a></span><span>, but it's poorly designed
    and doesn't have the compile time benefits.</span></li>

    <li class="c5 c0"><span>Like Spring et al, it can't detect
    parameterized classes, e.g. Set&lt;Service&gt;. You'll need to
    use @Named on these.</span></li>

    <li class="c0 c5"><span>There's no in-built support for JNDI,
    but you can</span> <span class="c2"><a class="c3" href=
    "https://github.com/alexec/openbookmaker/blob/14af37a9e9a89094fcefd92a2f43393894835f2c/src/main/java/com/alexecollins/openbookmaker/sports/OpenbookmakerModule.java">
    easily make some</a></span><span>.</span></li>

    <li class="c5 c0"><span>You must either annotate the
    constructor with @Inject, or add the object to your module. If
    you have a no-args constructor, and you don't build it in the
    module, you'll need to create one.</span></li>

    <li class="c5 c0"><span>@Singleton on a class will be ignored
    if the object is specified by the module, you need to
    &nbsp;annotate in the module too.</span></li>

    <li class="c5 c0"><span>Use @Singleton by default, then remove
    if not necessary.</span></li>

    <li class="c5 c0"><span>Dagger only has two scopes: singleton
    and non-singleton. Request and session are not supported. Using
    Provider&lt;MyClass&gt; gives the same effect as
    prototype.</span></li>

    <li class="c5 c0"><span>If need to add any "dangling"
    dependencies to your root (you get a "unused @Provider"
    error).</span></li>

    <li class="c5 c0"><span>When debugging the graph, you can
    visualise the graph by looking at the ${moduleName}.dot
    files.</span></li>
  </ol>

  <p class="c1 c0"></p>

  <p class="c0"><span>Further reading:</span></p>

  <p class="c1 c0"></p>

  <ul class="c6 lst-kix_hjo5a5798cw9-0 start">
    <li class="c5 c0">
    <a href="http://blog.freeside.co/post/41774730401/is-this-a-dagger-i-see-before-me">Is this a dagger is see before me?</a></li>

    <li class="c5 c0">
    <a href="http://dig.floatingsun.net/dagger-vs-guice/">Dagger vs Guice</a></li>
  </ul>
