---
title: "Opinion: Terse Coding Naming Conventions"
---
When writing code, you might experience the feeling that you should make all your names very descriptive, and long. But is this necessary? 

<em>"A name is too long when a shorter name exists that equally conveys the name's meaning and implication."</em> 

Long names take up screen real-estate, meaning that less code appears on screen, making it slower to work with and people more prone to mistakes, esp. in dynamic languages. Ultimately, long names create additional cost, and additional bugs.

<em>1. Use common abbreviations.</em>

This pretty much covers all common abbreviations in the English dictionary, e.g.:

* abbreviation &rarr; abbr
* page &rarr; pg

Common programming terms, e.g.:

* directory &rarr; dir
* configuration &rarr; config &rarr; conf &rarr; cfg
* automatic &rarr; auto
* error &rarr; err
* exception &rarr; ex
* event &rarr; evt
* list &rarr; ls
* copy &rarr; cp
* x-axis &rarr; x
* amount &rarr; amt (other transactional ones include, transaction &rarr; tx, debit &rarr; dbt)
* synchronous &rarr; sync
* customer &rarr; cust (there's many customer related ones, e.g. uname, passwd, fname, addr)
* context &rarr; ctx

<em>2. Don't use a common prefix</em>

Have you ever seen classes where all fields start with "my" or all private fields with "_"?

<ol>
<li>Every reference to these fields takes maybe 20% longer to type.</li>
<li>IDE auto-completion is hobbled, making typing those field much, much slower.</li>
</ol>

<em>3. Consider using the shortest sane abbreviation within the scope</em>

Think of this as the flip-side of the "long-lived variable should have descriptive names". Short-lived variable's meaning can be taken from their context and therefore don't need long names. You might even wish to just use single letters.

<em>4. Consider using domain specific abbrs.</em>

In e-gaming this might include:

* account &rarr; acct
* report &rarr; rpt
* event selection &rarr; seln
* table &rarr; tbl

Consider having an easy to find list of common ones (e.g. in your new starter welcome pack).

<em>5. But... don't make them up.</em>

If you start inventing abbreviations, then that means that other people will either have to ask you what they mean, or invent their own interpretations and usually misunderstand your names. If a name means different things to people in the same content, you can expect it to cause problems - by which I mean bugs.
