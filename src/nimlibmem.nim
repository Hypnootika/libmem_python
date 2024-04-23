import os, nimpy, typetraits

pyExportModule("_libmem")

type
  cstr* = distinct array[4096, char]

converter stringtToCstring*(x: cstr): cstring = cast[cstring]((distinctBase(cstr)x)[0].addr)

proc cb[T](c: ptr T; arg: pointer): bool {.cdecl.} =
  cast[ptr seq[T]](arg)[].add(c[])
  result = true

const
  Protnone* = uint32(0)
  Protr* = uint32(1)
  Protw* = uint32(2)
  Protx* = uint32(4)
  Protxr* = uint32(5)
  Protxw* = uint32(6)
  Protrw* = uint32(3)
  Protxrw* = uint32(7)
  Archarm* = uint32(0)
  Archarm64* = uint32(1)
  Archmips* = uint32(2)
  Archx86* = uint32(3)
  Archppc* = uint32(4)
  Archsparc* = uint32(5)
  Archsysz* = uint32(6)
  Archevm* = uint32(7)
  Archmax* = uint32(8)



type
  memoryaddress* = uintptr
  uintptr* = culonglong
  size* = csize_t
  char* = cchar
  str* = cstring
  bytearray* = ptr byte
  pid* = uint32
  tid* = uint32
  time* = uint64
  prot* = uint32
  structprocess* {.pure, inheritable, bycopy.} = object
    pid*: uint32
    ppid*: uint32
    bits*: csize_t
    startime*: uint64
    path*: cstr
    name*: cstr
  Process* = structprocess
  structhread* {.pure, inheritable, bycopy.} = object
    tid*: uint32
    ownerpid*: uint32
  Thread* = structhread
  structmodule* {.pure, inheritable, bycopy.} = object
    base*: memoryaddress
    endfield*: memoryaddress
    size*: csize_t
    path*: cstr
    name*: cstr
  Module* = structmodule
  structsegment* {.pure, inheritable, bycopy.} = object
    base*: memoryaddress
    endfield*: memoryaddress
    size*: csize_t
    prot*: prot
  Segment* = structsegment
  structsymbol* {.pure, inheritable, bycopy.} = object
    name*: str
    memoryaddress*: memoryaddress
  Symbol* = structsymbol
  structinst* {.pure, inheritable, bycopy.} = object
    memoryaddress*: memoryaddress
    size*: csize_t
    bytes*: array[16'i64, byte]
    mnemonic*: array[32'i64, char]
    opstr*: array[160'i64, char]
  Instruction* = structinst
  archt* = uint32
  structvmtentry* {.pure, inheritable, bycopy.} = object
    origfunc*: memoryaddress
    index*: csize_t
    next*: ptr structvmtentry
  vmtentry* = structvmtentry
  structvmt* {.pure, inheritable, bycopy.} = object
    vtable*: ptr memoryaddress
    hkentries*: ptr vmtentry
  Vmt* = structvmt    



proc enumprocessesoriginal(callback: proc (a0: ptr Process; a1: pointer): bool {.cdecl.}; arg: pointer): bool {.cdecl, importc: "LM_EnumProcesses".}
proc enumprocesses*(): seq[Process] {.exportpy: "enumprocesses".} = discard enumprocessesoriginal(cb, result.addr)

proc getprocessoriginal(processout: ptr Process): bool {.cdecl, importc: "LM_GetProcess".}
proc getprocess*(): Process {.exportpy: "getprocess".} = discard getprocessoriginal(result.addr)

proc getprocessexoriginal(pid: uint32; processout: ptr Process): bool {.cdecl, importc: "LM_GetProcessEx".}
proc getprocessex*(pid: uint32): Process {.exportpy: "getprocessex".} = discard getprocessexoriginal(pid, result.addr)

proc findprocessoriginal(processname: cstring; processout: ptr Process): bool {.cdecl, importc: "LM_FindProcess".}
proc findprocess*(processname: string): Process {.exportpy.} = discard findprocessoriginal(processname, result.addr)

proc isprocessaliveorig(process: ptr Process): bool {.cdecl, importc: "LM_IsProcessAlive".}
proc isprocessalive*(pid: uint32): bool {.exportpy.} = (var process = getprocessex(pid); return isprocessaliveorig(process.addr).bool)

proc getbitsoriginal(): csize_t {.cdecl, importc: "LM_GetBits".}
proc getbits*(): uint64 {.exportpy.} = return cast[uint64](getbitsoriginal())

proc getsystembitsoriginal(): csize_t {.cdecl, importc: "LM_GetSystemBits".}
proc getsystembits*(): uint64 {.exportpy.} = return cast[uint64](getsystembitsoriginal())

proc enumthreadsoriginal(callback: proc (a0: ptr Thread; a1: pointer): bool {.cdecl.}; arg: pointer): bool {.cdecl, importc: "LM_EnumThreads".}
proc enumthreads*(): seq[Thread] {.exportpy.} = discard enumthreadsoriginal(cb, result.addr)

proc enumthreadsexoriginal(process: ptr Process; callback: proc (a0: ptr Thread;a1: pointer): bool {.cdecl.}; arg: pointer): bool {.cdecl, importc: "LM_EnumThreadsEx".}
proc enumthreadsex*(pid: uint32): seq[Thread] {.exportpy.} = (var process = getprocessex(pid); discard enumthreadsexoriginal(process.addr, cb, result.addr))

proc getthreadoriginal(threadout: ptr Thread): bool {.cdecl, importc: "LM_GetThread".}
proc getthread*(): Thread {.exportpy.} = discard getthreadoriginal(result.addr)

proc getthreadexoriginal(process: ptr Process; threadout: ptr Thread): bool {.cdecl, importc: "LM_GetThreadEx".}
proc getthreadex*(pid: uint32): Thread {.exportpy.} = (var process = getprocessex(pid); discard getthreadexoriginal(process.addr, result.addr))

proc getthreadprocessoriginal(thread: ptr Thread; processout: ptr Process): bool {.cdecl, importc: "LM_GetThreadProcess".}
proc getthreadprocess*(thread: Thread): Process {.exportpy.} = discard getthreadprocessoriginal(thread.addr, result.addr)

proc enummodulesoriginal(callback: proc (a0: ptr Module; a1: pointer): bool {.cdecl.}; arg: pointer): bool {.cdecl, importc: "LM_EnumModules".}
proc enummodules*(): seq[Module] {.exportpy.} = discard enummodulesoriginal(cb, result.addr)

proc enummodulesexoriginal(process: ptr Process; callback: proc (a0: ptr Module;a1: pointer): bool {.cdecl.}; arg: pointer): bool {.cdecl, importc: "LM_EnumModulesEx".}
proc enummodulesex*(pid: uint32): seq[Module] {.exportpy.} = (var process = getprocessex(pid); discard enummodulesexoriginal(process.addr, cb, result.addr))

proc findmoduleoriginal(name: cstring; moduleout: ptr Module): bool {.cdecl, importc: "LM_FindModule".}
proc findmodule*(name: string): Module {.exportpy.} = discard findmoduleoriginal(name, result.addr)

proc findmoduleexoriginal(process: ptr Process; name: cstring;moduleout: ptr Module): bool {.cdecl, importc: "LM_FindModuleEx".}
proc findmoduleex*(pid: uint32; name: string): Module {.exportpy.} = (var process = getprocessex(pid); discard findmoduleexoriginal(process.addr, name, result.addr))

proc loadmoduleoriginal(path: cstring; moduleout: ptr Module): bool {.cdecl, importc: "LM_LoadModule".}
proc loadmodule*(path: string): Module {.exportpy.} = (var m: Module; discard loadmoduleoriginal(path.cstring, m.addr); return m)

proc loadmoduleexoriginal(process: ptr Process; path:cstring;moduleout: ptr Module): bool {.cdecl, importc: "LM_LoadModuleEx".}
proc loadmoduleex*(pid: uint32; path: string): Module {.exportpy.} = (var p: Process = getprocessex(pid); discard loadmoduleexoriginal(p.addr, cast[cstring](path), result.addr))

proc unloadmoduleoriginal(module: ptr Module): bool {.cdecl, importc: "LM_UnloadModule".}
proc unloadmodule*(modulename: string): bool {.exportpy.} = (var module = findmodule(modulename); return unloadmoduleoriginal(module.addr))

proc unloadmoduleexoriginal(process: ptr Process; module: ptr Module): bool {.cdecl, importc: "LM_UnloadModuleEx".}
proc unloadmoduleex*(pid: uint32; modulename: string): bool {.exportpy.} = (var process: Process = getprocessex(pid); var module = findmoduleex(pid, modulename); return unloadmoduleexoriginal(process.addr, module.addr))

proc enumsymbolsoriginal(module: ptr Module; callback: proc (a0: ptr Symbol;a1: pointer): bool {.cdecl.}; arg: pointer): bool {.cdecl, importc: "LM_EnumSymbols".}
proc enumsymbols*(modulename: string): seq[Symbol] {.exportpy.} = (var module = findmodule(modulename); discard enumsymbolsoriginal(module.addr, cb, result.addr))

proc findsymboladdressoriginal(module: ptr Module; symbolname: cstring): memoryaddress {.cdecl, importc: "LM_FindSymbolAddress".}
proc findsymboladdress*(modulename: string; symbolname: string): memoryaddress {.exportpy.} = (var module = findmodule(modulename); return findsymboladdressoriginal(module.addr, symbolname))

proc enumsegmentsoriginal(callback: proc (a0: ptr Segment; a1: pointer): bool {.cdecl.}; arg: pointer): bool {.cdecl, importc: "LM_EnumSegments".}
proc enumsegments*(): seq[Segment] {.exportpy.} = discard enumsegmentsoriginal(cb, result.addr)

proc enumsegmentsexoriginal(process: ptr Process; callback: proc (a0: ptr Segment; a1: pointer): bool {.cdecl.}; arg: pointer): bool {.cdecl, importc: "LM_EnumSegmentsEx".}
proc enumsegmentsex*(pid: uint32): seq[Segment] {.exportpy.} = (var process = getprocessex(pid); discard enumsegmentsexoriginal(process.addr, cb, result.addr))

proc findsegmentoriginal(address: memoryaddress; segmentout: ptr Segment): bool {.cdecl, importc: "LM_FindSegment".}
proc findsegment*(address: memoryaddress): Segment {.exportpy.} = discard findsegmentoriginal(address, result.addr)

proc findsegmentexoriginal(process: ptr Process; address: memoryaddress;segmentout: ptr Segment): bool {.cdecl, importc: "LM_FindSegmentEx".}
proc findsegmentex*(pid: uint32; address: memoryaddress): Segment {.exportpy.} = (var process = getprocessex(pid); discard findsegmentexoriginal(process.addr, address, result.addr))

proc protmemoryoriginal(address: memoryaddress; size: csize_t; prot: prot;oldprotout: ptr prot): bool {.cdecl, importc: "LM_ProtMemory".}
proc protmemory*(address: memoryaddress; size: csize_t; prot: prot): bool {.exportpy.} = return protmemoryoriginal(address, size, prot, nil)

proc protmemoryexoriginal(process: ptr Process; address: memoryaddress; size: csize_t;prot: prot; oldprotout: ptr prot): bool {.cdecl, importc: "LM_ProtMemoryEx".}
proc protmemoryex*(pid: uint32; address: memoryaddress; size: csize_t; prot: prot): bool {.exportpy.} = (var process = getprocessex(pid); return protmemoryexoriginal(process.addr, address, size, prot, nil))

proc readmemoryoriginal(source: memoryaddress; dest: ptr byte; size: csize_t): csize_t {.cdecl, importc: "LM_ReadMemory".}
proc readmemory*(source: memoryaddress; size: csize_t): seq[byte] {.exportpy.} = (var dest = newSeq[byte](size); discard readmemoryoriginal(source, dest[0].addr, size); return dest)

proc readmemoryexoriginal(process: ptr Process; source: memoryaddress;dest: ptr byte; size: csize_t): csize_t {.cdecl, importc: "LM_ReadMemoryEx".}
proc readmemoryex*(pid: uint32; source: memoryaddress; size: csize_t): seq[byte] {.exportpy.} = (var process = getprocessex(pid); var dest = newSeq[byte](size); discard readmemoryexoriginal(process.addr, source, dest[0].addr, size); return dest)

proc writememoryoriginal(dest: memoryaddress; source: bytearray; size: csize_t): csize_t {.cdecl, importc: "LM_WriteMemory".}
proc writeMemory*[T](dest: memoryaddress; data: T): bool =
  ## Writes memory safely and reports errors distinctly.
  try:
    if not protmemory(dest, sizeof(T).csize_t, ProtXRW):
      raise newException(Exception, "Memory protection setting failed.")
    var bytesWritten: csize_t
    when T is typeof(SomeInteger):
      bytesWritten = writememoryoriginal(dest, cast[ptr byte](addr data), sizeof(T).csize_t)
    else:
      bytesWritten = writememoryoriginal(dest, cast[ptr byte](addr data[0]), sizeof(T).csize_t)
    if bytesWritten != sizeof(T).csize_t:
      raise newException(Exception, "Incomplete write operation.")
    true
  except Exception as e:
    echo "Failed to write memory: ", e.msg
    false

proc writememoryexoriginal(process: ptr Process; dest: memoryaddress;source: bytearray; size: csize_t): csize_t {.cdecl, importc: "LM_WriteMemoryEx".}
#proc writememoryex*(pid: uint32; dest: memoryaddress; source: seq[byte]): csize_t {.exportpy.} = (var process = getprocessex(pid); return writememoryexoriginal(process.addr, dest, source[0].addr, source.len.csize_t))
proc writememoryex*[T](pid: uint32; dest: memoryaddress; data: T): bool {.discardable.} =
  var process = getprocessex(pid)
  ## Writes memory to another process with detailed error handling.
  try:
    if not protmemoryexoriginal(process.addr, dest, sizeof(T).csize_t, Protxrw, nil):
      return false  # Avoiding exception for external process operations to allow graceful degradation
    var bytesWritten: csize_t
    when T is typeof(SomeInteger):
      bytesWritten = writememoryexoriginal(process, dest, cast[ptr byte](addr data), sizeof(T).csize_t)
    else:
      bytesWritten = writememoryexoriginal(process.addr, dest, cast[ptr byte](addr data[0]), sizeof(T).csize_t)
    if bytesWritten != sizeof(T).csize_t:
      echo "Incomplete write operation in external process."
      false
    else:
      true
  except:
    echo "Error occurred during external process memory write."
    false

proc writedata(address: memoryaddress; data: openArray[byte]): bool {.exportpy.} = writememory(address, data)
proc writedata(address: memoryaddress; data: openArray[char]): bool {.exportpy.} = writememory(address, data)
proc writedata(address: memoryaddress; data: openArray[int]): bool {.exportpy.} = writememory(address, data)
proc writedataex(pid: uint32; address: memoryaddress; data: openArray[byte]): bool {.exportpy.} = (var process = getprocessex(pid); return writememoryex(process.pid, address, data))
proc writedataex(pid: uint32; address: memoryaddress; data: openArray[char]): bool {.exportpy.} = (var process = getprocessex(pid); return writememoryex(process.pid, address, data))
proc writedataex(pid: uint32; address: memoryaddress; data: openArray[int]): bool {.exportpy.} = (var process = getprocessex(pid); return writememoryex(process.pid, address, data))

proc setmemoryoriginal(dest: memoryaddress; byte: byte; size: csize_t): csize_t {.cdecl, importc: "LM_SetMemory".}
proc setmemory*(dest: memoryaddress; byte: byte; size: csize_t): csize_t {.exportpy.} = return setmemoryoriginal(dest, byte, size)

proc setmemoryexoriginal(process: ptr Process; dest: memoryaddress; byte: byte;size: csize_t): csize_t {.cdecl, importc: "LM_SetMemoryEx".}
proc setmemoryex*(pid: uint32; dest: memoryaddress; byte: byte; size: csize_t): csize_t {.exportpy.} = (var process = getprocessex(pid); return setmemoryexoriginal(process.addr, dest, byte, size))

proc allocmemoryoriginal(size: csize_t; prot: prot): memoryaddress {.cdecl, importc: "LM_AllocMemory".}
proc allocmemory*(size: csize_t; prot: prot): memoryaddress {.exportpy.} = return allocmemoryoriginal(size, prot)

proc allocmemoryexoriginal(process: ptr Process; size: csize_t; prot: prot): memoryaddress {.cdecl, importc: "LM_AllocMemoryEx".}
proc allocmemoryex*(pid: uint32; size: csize_t; prot: prot): memoryaddress {.exportpy.} = (var process = getprocessex(pid); return allocmemoryexoriginal(process.addr, size, prot))

proc freememoryoriginal(alloc: memoryaddress; size: csize_t): bool {.cdecl, importc: "LM_FreeMemory".}
proc freememory*(alloc: memoryaddress; size: csize_t): bool {.exportpy.} = return freememoryoriginal(alloc, size)

proc freememoryexoriginal(process: ptr Process; alloc: memoryaddress; size: csize_t): bool {.cdecl, importc: "LM_FreeMemoryEx".}
proc freememoryex*(pid: uint32; alloc: memoryaddress; size: csize_t): bool {.exportpy.} = (var process = getprocessex(pid); return freememoryexoriginal(process.addr, alloc, size))

proc deeppointeroriginal(base: memoryaddress; offsets: ptr memoryaddress; noffsets: csize_t): memoryaddress {.cdecl, importc: "LM_DeepPointer".}
proc deeppointer*(base: memoryaddress; offsets: seq[memoryaddress]): memoryaddress {.exportpy.} = return deeppointeroriginal(base, offsets[0].addr, offsets.len.csize_t)

proc deeppointerexoriginal(process: ptr Process; base: memoryaddress;offsets: ptr memoryaddress; noffsets: csize_t): memoryaddress {.cdecl, importc: "LM_DeepPointerEx".}
proc deeppointerex*(pid: uint32; base: memoryaddress; offsets: seq[memoryaddress]): memoryaddress {.exportpy.} = (var process = getprocessex(pid); return deeppointerexoriginal(process.addr, base, offsets[0].addr, offsets.len.csize_t))

proc datascanoriginal(data: bytearray; datasize: csize_t; address: memoryaddress;scansize: csize_t): memoryaddress {.cdecl, importc: "LM_DataScan".}
proc datascan*(data: seq[byte]; address: memoryaddress, scansize: csize_t): memoryaddress {.exportpy.} = return datascanoriginal(data[0].addr, data.len.csize_t, address, scansize)

proc datascanexoriginal(process: ptr Process; data: bytearray; datasize: csize_t;address: memoryaddress; scansize: csize_t): memoryaddress {.cdecl, importc: "LM_DataScanEx".}
proc datascanex*(pid: uint32; data: seq[byte]; address: memoryaddress; scansize: csize_t): memoryaddress {.exportpy.} = (var process = getprocessex(pid); return datascanexoriginal(process.addr, data[0].addr, data.len.csize_t, address, scansize))

proc patternscanoriginal(pattern: bytearray; mask: cstring; address: memoryaddress;scansize: csize_t): memoryaddress {.cdecl, importc: "LM_PatternScan".}
proc patternscan*(pattern: seq[byte]; mask: string; address: memoryaddress; scansize: csize_t): memoryaddress {.exportpy.} = return patternscanoriginal(pattern[0].addr, mask, address, scansize)

proc patternscanexoriginal(process: ptr Process; pattern: bytearray;mask: cstring; address: memoryaddress; scansize: csize_t): memoryaddress {.cdecl, importc: "LM_PatternScanEx".}
proc patternscanex*(pid: uint32; pattern: seq[byte]; mask: string;address: memoryaddress; scansize: csize_t): memoryaddress {.exportpy.} = (var process = getprocessex(pid); return patternscanexoriginal(process.addr, pattern[0].addr, mask, address, scansize))

proc sigscanoriginal(signature: cstring; address: memoryaddress; scansize: csize_t): memoryaddress {.cdecl, importc: "LM_SigScan".}
proc sigscan*(signature: string; address: memoryaddress; scansize: csize_t): memoryaddress {.exportpy.} = return sigscanoriginal(signature, address, scansize)

proc sigscanexoriginal(process: ptr Process; signature: cstring;address: memoryaddress; scansize: csize_t): memoryaddress {.cdecl, importc: "LM_SigScanEx".}
proc sigscanex*(pid: uint32; signature: string; address: memoryaddress;scansize: csize_t): memoryaddress {.exportpy.} = (var process = getprocessex(pid); return sigscanexoriginal(process.addr, signature, address, scansize))

proc getarchitectureoriginal(): archt {.cdecl, importc: "LM_GetArchitecture".}
proc getarchitecture*(): archt {.exportpy.} = return getarchitectureoriginal()

proc assembleoriginal(code: cstring; instructionout: ptr Instruction): bool {.cdecl, importc: "LM_Assemble".}
proc assemble*(code: openArray[char]): Instruction {.exportpy.} = discard assembleoriginal(cast[cstring](code), result.addr)

proc assembleexoriginal(code: openArray[char]; arch: archt; bits: csize_t;runtimeaddress: memoryaddress; payloadout: ptr ptr byte): csize_t {.cdecl, importc: "LM_AssembleEx".}
proc assembleex*(code: openArray[char]; arch: archt; bits: csize_t;runtimeaddress: memoryaddress): Instruction {.exportpy.} = (var payload: ptr byte; discard assembleexoriginal(code, arch, bits, runtimeaddress, payload.addr); return cast[Instruction](payload[]))

proc freepayloadoriginal(payload: ptr byte): void {.cdecl, importc: "LM_FreePayload".}
proc freepayload*(payload: memoryaddress): void {.exportpy.} = freepayloadoriginal(cast[ptr byte](payload))

proc disassembleoriginal(machinecode: memoryaddress; instructionout: ptr Instruction): bool {.cdecl, importc: "LM_Disassemble".}
proc disassemble*(machinecode: memoryaddress): Instruction {.exportpy.} = (var inst: Instruction; discard disassembleoriginal(machinecode, inst.addr))

proc disassembleexoriginal(machinecode: memoryaddress; arch: archt; bits: csize_t;maxsize: csize_t; instructioncount: csize_t;runtimeaddress: memoryaddress; instructionsout: ptr ptr Instruction): csize_t {.cdecl, importc: "LM_DisassembleEx".}
proc disassembleex*(machinecode: memoryaddress; arch: archt; bits: csize_t;maxsize: csize_t; instructioncount: csize_t;runtimeaddress: memoryaddress): Instruction {.exportpy.} = (var instructions: ptr Instruction; discard disassembleexoriginal(machinecode, arch, bits, maxsize, instructioncount, runtimeaddress, instructions.addr); return instructions[])

proc freeinstructionsoriginal(instructions: ptr Instruction): void {.cdecl, importc: "LM_FreeInstructions".}
proc freeinstructions*(instructions: Instruction): void {.exportpy.} = freeinstructionsoriginal(instructions.addr)

proc codelengthoriginal(machinecode: memoryaddress; minlength: csize_t): csize_t {.cdecl, importc: "LM_CodeLength".}
proc codelength*(machinecode: memoryaddress; minlength: csize_t): csize_t {.exportpy.} = return codelengthoriginal(machinecode, minlength)

proc codelengthexoriginal(process: ptr Process; machinecode: memoryaddress;minlength: csize_t): csize_t {.cdecl, importc: "LM_CodeLengthEx".}
proc codelengthex*(pid: uint32; machinecode: memoryaddress; minlength: csize_t): csize_t {.exportpy.} = (var process = getprocessex(pid); return codelengthexoriginal(process.addr, machinecode, minlength))

proc hookcodeoriginal(fromarg: memoryaddress; to: memoryaddress; trampolineout: ptr memoryaddress): csize_t {.cdecl, importc: "LM_HookCode".}
proc hookcode*(fromarg: memoryaddress; to: memoryaddress): memoryaddress {.exportpy.} = (var trampoline: memoryaddress; return hookcodeoriginal(fromarg, to, trampoline.addr))

proc hookcodeexoriginal(process: ptr Process; fromarg: memoryaddress; to: memoryaddress;trampolineout: ptr memoryaddress): csize_t {.cdecl, importc: "LM_HookCodeEx".}
proc hookcodeex*(pid: uint32; fromarg: memoryaddress; to: memoryaddress): memoryaddress {.exportpy.} = (var process = getprocessex(pid); discard  hookcodeexoriginal(process.addr, fromarg, to, result.addr))

proc unhookcodeoriginal(fromarg: memoryaddress; trampoline: memoryaddress; size: csize_t): bool {.cdecl, importc: "LM_UnhookCode".}
proc unhookcode*(fromarg: memoryaddress; trampoline: memoryaddress; size: csize_t): bool {.exportpy.} = return unhookcodeoriginal(fromarg, trampoline, size)

proc unhookcodeexoriginal(process: ptr Process; fromarg: memoryaddress;trampoline: memoryaddress; size: csize_t): bool {.cdecl, importc: "LM_UnhookCodeEx".}
proc unhookcodeex*(pid: uint32; fromarg: memoryaddress; trampoline: memoryaddress;size: csize_t): bool {.exportpy.} = (var process = getprocessex(pid); return unhookcodeexoriginal(process.addr, fromarg, trampoline, size))

