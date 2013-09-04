---
title: "Swing Utils"
---
<p>
    I've been doing a lot of Swing lately (don't laugh, it's still a <a href="http://zeroturnaround.com/labs/developer-productivity-report-2012-java-tools-tech-devs-and-data/">big deal</a>). There one or two basic things that are missing, so I've knocked together some lightweight implementations with no licensing.
</p>
<ul>
    <li><b>FormLayout</b> lays out components in the same fashion as a web-form.</li>
    <li><b>FormPanel</b> is a panel that lays out its contents like a web-form.</li>
    <li><b>ProgressPanel</b> is a panel version of ProgressMonitor, so you can embed it somewhere else.</li>
    <li><b>WizardPanel</b> is a basic version of a wizard that allows you to add multiple pages and deals with navigation.</li>
</ul>
<p>They're usable but a bit primitive. For example, you can't change the order of pages in the wizard, and the form layout doesn't do any wrapping components. The class ExampleWizardPanel showcases them. You may wish to consider JGoodies FormLayout in preference to this.</p>
<p>The code is <a href="https://github.com/alexec/swing-utils">on Github</a>.</p>
