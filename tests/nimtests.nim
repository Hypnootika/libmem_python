import ../src/nimlibmem

var p : Process = findprocess("notepad.exe")
var pm: Module = findmoduleex(p.pid, "notepad.exe")

echo getthreadprocess(getthread())

echo writeMemory(findmodule(cast[string](stringtToCstring(getprocess().name))).base, "Hello, World!")
echo writememoryex(p.pid, pm.base, "Hello, World!")

echo allocmemory(0x1000, Protxrw)
echo allocmemoryex(p.pid, 0x1000, Protxrw)
echo setmemory(findmodule(cast[string](stringtToCstring(getprocess().name))).base, 0, 4)
echo setmemoryex(p.pid, pm.base, 0, 4)

echo assemble("mov eax, 0x12345678")