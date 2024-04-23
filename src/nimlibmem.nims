const libmemlib = getCurrentDir() & "/src/lib/libmem.lib"

--cc:vcc
--passC:"/MD"
--passL:"ntdll.lib shell32.lib src/lib/libmem.lib"
--app:lib
--cpu:amd64
switch("define", "useMalloc")
--gc:refc
--out:"libmem/_libmem.pyd"
--tlsEmulation:off
--passC:"-w"
