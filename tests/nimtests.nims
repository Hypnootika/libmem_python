const libmemlib = getCurrentDir() & "/src/lib/libmem.lib"

--cc:vcc
--passC:"/MD"
--passL:"ntdll.lib shell32.lib src/lib/libmem.lib"
--app:console
--cpu:amd64
switch("define", "useMalloc")
--gc:refc

