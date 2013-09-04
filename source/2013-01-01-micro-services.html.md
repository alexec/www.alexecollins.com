---
title: "Micro Services"
---
I've just watch <a href="http://www.infoq.com/presentations/Micro-Services">a really good InfoQ video from James Lewis at Thoughtworks</a>. As you might expect from Thoughtworks, it has some stuff about CD, but also some great ideas an building large systems from small, somewhat independent components.

As a brain dump:

- Break complex systems into manageable, independent parts.
- Use HTTP and REST for services (no ESB). 
- Don't worry too much about reuse. It's a double-edged sword. 
- Standard media types, ones that can be consumed both by machines and peoples are great for testing.
- Conway's Law: arrange your teams to reflect your system's topology.
- Each team can use the best tech is best suited to their system.
- Not for the first time I've heard someone say, use lightweight embedded HTTP server rather than a heavy weight container.
