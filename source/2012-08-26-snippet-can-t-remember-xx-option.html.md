---
title: "Snippet: Can't Remember That -XX Option?"
---
<p>A handy recent find:</p>

	% java -XX:+UnlockDiagnosticVMOptions -XX:+PrintFlagsFinal -version
	...
	    uintx MinPermHeapExpansion                      = 327680          {product}           
	    uintx PermGenPadding                            = 3               {product}           
	    uintx PermMarkSweepDeadRatio                    = 20              {product}  
	...
