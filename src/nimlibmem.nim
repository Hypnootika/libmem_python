import os, nimpy

pyExportModule("_libmem")

{.link: currentsourcepath().parentDir() / "lib/libmem.lib".}

const hdr = currentsourcepath().parentDir() / "libmem/libmem.h"


const
  protnone* = cint(0)
const
  protr* = cint(1)
const
  protw* = cint(2)
const
  protx* = cint(4)
const
  protxr* = cint(5)
const
  protxw* = cint(6)
const
  protrw* = cint(3)
const
  protxrw* = cint(7)
const
  archarm* = cint(0)
const
  archarm64* = cint(1)
const
  archmips* = cint(2)
const
  archx86* = cint(3)
const
  archppc* = cint(4)
const
  archsparc* = cint(5)
const
  archsysz* = cint(6)
const
  archevm* = cint(7)
const
  archmax* = cint(8)

type
  boolt*{.importc: "lm_bool_t".} = int
  bytet* = uint8
  addresst* = uintptr
  uintptr* = culonglong
  sizet* = csize_t
  chart* = cchar
  stringt* = cstring
  bytetarray* = ptr bytet
  pidt* = uint32
  idt* = uint32
  timet* = uint64
  prott* = uint32
  structlmprocess* {.header: hdr, importc: "lm_process_t", pure, inheritable, bycopy.} = object
    pid*: pidt
    ppid*: pidt
    bits*: sizet
    start_time*: timet
    path*{.importc: "path".}: cstring
    name*{.importc: "name".}: cstring
  Process* = structlmprocess
  structlmthread* {.header: hdr, importc: "lm_thread_t", pure, inheritable, bycopy.} = object
    tid*: idt
    owner_pid*: pidt
  Thread* = structlmthread
  structlmmodule* {.header: hdr, importc: "lm_module_t", pure, inheritable, bycopy.} = object
    base*: addresst
    `end`*: addresst
    size*: sizet
    path*{.importc: "path".}: cstring
    name*{.importc: "name".}: cstring
  Module* = structlmmodule
  structlmsegment* {.header: hdr, importc: "lm_segment_t", pure, inheritable, bycopy.} = object
    base*: addresst
    `end`*: addresst
    size*: sizet
    prot*: prott
  Segment* = structlmsegment
  structlmsymbol* {.header: hdr, importc: "lm_symbol_t", pure, inheritable, bycopy.} = object
    name*: stringt
    address*: addresst
  Symbol* = structlmsymbol
  structlminst* {.header: hdr, importc: "lm_inst_t", pure, inheritable, bycopy.} = object
    address*: addresst
    size*: sizet
    bytes*: array[16'i64, bytet]
    mnemonic*: array[32'i64, chart]
    op_str*: array[160'i64, chart]
  Instruction* = structlminst
  archt* = uint32
  structlmvmtentry* {.header: hdr, importc: "lm_vmtentry_t", pure, inheritable, bycopy.} = object
    origfunc*: addresst
    index*: sizet
    next*: ptr structlmvmtentry
  Vmtentry* = structlmvmtentry
  structlmvmt* {.header: hdr, importc: "lm_vmt_t", pure, inheritable, bycopy.} = object
    vtable*: ptr addresst
    hkentries*: ptr Vmtentry
  Vmt* = structlmvmt

proc cb[T](c: ptr T; arg: pointer): boolt {.cdecl.} =
  cast[ptr seq[T]](arg)[].add(c[])
  result = 1

proc enumprocessesoriginal(callback: proc (a0: ptr Process; a1: pointer): boolt {.cdecl.}; arg: pointer): boolt {.cdecl, importc: "LM_EnumProcesses".}
proc enumprocesses*(): seq[Process] {.exportpy: "enumprocesses".} = discard enumprocessesoriginal(cb, result.addr)

proc getprocessoriginal(processout: ptr Process): boolt {.cdecl, importc: "LM_GetProcess".}
proc getprocess*(): Process {.exportpy: "getprocess".} = discard getprocessoriginal(result.addr)

proc getprocessexoriginal(pid: pidt; processout: ptr Process): boolt {.cdecl, importc: "LM_GetProcessEx".}
proc getprocessex*(pid: pidt): Process {.exportpy: "getprocessex".} = discard getprocessexoriginal(pid, result.addr)

proc findprocessoriginal(processname: stringt; processout: ptr Process): boolt {.cdecl, importc: "LM_FindProcess".}
proc findprocess*(processname: string): Process {.exportpy.} = discard findprocessoriginal(processname, result.addr)

proc isprocessaliveorig(process: ptr Process): boolt {.cdecl, importc: "LM_IsProcessAlive".}
proc isprocessalive*(pid: uint32): bool {.exportpy.} = (var process = getprocessex(pid); return isprocessaliveorig(process.addr).bool)

proc getbitsoriginal(): sizet {.cdecl, importc: "LM_GetBits".}
proc getbits*(): uint64 {.exportpy.} = return cast[uint64](getbitsoriginal())

proc getsystembitsoriginal(): sizet {.cdecl, importc: "LM_GetSystemBits".}
proc getsystembits*(): uint64 {.exportpy.} = return cast[uint64](getsystembitsoriginal())

proc enumthreadsoriginal(callback: proc (a0: ptr Thread; a1: pointer): boolt {.cdecl.}; arg: pointer): boolt {.cdecl, importc: "LM_EnumThreads".}
proc enumthreads*(): seq[Thread] {.exportpy.} = discard enumthreadsoriginal(cb, result.addr)

proc enumthreadsexoriginal(process: ptr Process; callback: proc (a0: ptr Thread;a1: pointer): boolt {.cdecl.}; arg: pointer): boolt {.cdecl, importc: "LM_EnumThreadsEx".}
proc enumthreadsex*(pid: uint32): seq[Thread] {.exportpy.} = (var process = getprocessex(pid); discard enumthreadsexoriginal(process.addr, cb, result.addr))

proc getthreadoriginal(threadout: ptr Thread): boolt {.cdecl, importc: "LM_GetThread".}
proc getthread*(): Thread {.exportpy.} = discard getthreadoriginal(result.addr)

proc getthreadexoriginal(process: ptr Process; threadout: ptr Thread): boolt {.cdecl, importc: "LM_GetThreadEx".}
proc getthreadex*(pid: uint32): Thread {.exportpy.} = (var process = getprocessex(pid); discard getthreadexoriginal(process.addr, result.addr))

proc getthreadprocessoriginal(thread: ptr Thread; processout: ptr Process): boolt {.cdecl, importc: "LM_GetThreadProcess".}
proc getthreadprocess*(thread: Thread): Process {.exportpy.} = discard getthreadprocessoriginal(thread.addr, result.addr)

proc enummodulesoriginal(callback: proc (a0: ptr Module; a1: pointer): boolt {.cdecl.}; arg: pointer): boolt {.cdecl, importc: "LM_EnumModules".}
proc enummodules*(): seq[Module] {.exportpy.} = discard enummodulesoriginal(cb, result.addr)

proc enummodulesexoriginal(process: ptr Process; callback: proc (a0: ptr Module;a1: pointer): boolt {.cdecl.}; arg: pointer): boolt {.cdecl, importc: "LM_EnumModulesEx".}
proc enummodulesex*(pid: uint32): seq[Module] {.exportpy.} = (var process = getprocessex(pid); discard enummodulesexoriginal(process.addr, cb, result.addr))

proc findmoduleoriginal(name: stringt; moduleout: ptr Module): boolt {.cdecl, importc: "LM_FindModule".}
proc findmodule*(name: string): Module {.exportpy.} = discard findmoduleoriginal(name, result.addr)

proc findmoduleexoriginal(process: ptr Process; name: stringt;moduleout: ptr Module): boolt {.cdecl, importc: "LM_FindModuleEx".}
proc findmoduleex*(pid: uint32; name: string): Module {.exportpy.} = (var process = getprocessex(pid); discard findmoduleexoriginal(process.addr, name, result.addr))

proc loadmoduleoriginal(path: stringt; moduleout: ptr Module): boolt {.cdecl, importc: "LM_LoadModule".}
proc loadmodule*(path: string): Module {.exportpy.} = discard loadmoduleoriginal(path, result.addr)

proc loadmoduleexoriginal(process: ptr Process; path: stringt;moduleout: ptr Module): boolt {.cdecl, importc: "LM_LoadModuleEx".}
proc loadmoduleex*(pid: uint32; path: string): Module {.exportpy.} = (var process = getprocessex(pid); discard loadmoduleexoriginal(process.addr, path, result.addr))

proc unloadmoduleoriginal(module: ptr Module): boolt {.cdecl, importc: "LM_UnloadModule".}
proc unloadmodule*(modulename: string): boolt {.exportpy.} = (var module = findmodule(modulename); return unloadmoduleoriginal(module.addr))

proc unloadmoduleexoriginal(process: ptr Process; module: ptr Module): boolt {.cdecl, importc: "LM_UnloadModuleEx".}
proc unloadmoduleex*(pid: uint32; modulename: string): boolt {.exportpy.} = (var process: Process = getprocessex(pid); var module = findmoduleex(pid, modulename); return unloadmoduleexoriginal(process.addr, module.addr))

proc enumsymbolsoriginal(module: ptr Module; callback: proc (a0: ptr Symbol;a1: pointer): boolt {.cdecl.}; arg: pointer): boolt {.cdecl, importc: "LM_EnumSymbols".}
proc enumsymbols*(modulename: string): seq[Symbol] {.exportpy.} = (var module = findmodule(modulename); discard enumsymbolsoriginal(module.addr, cb, result.addr))

proc findsymboladdressoriginal(module: ptr Module; symbolname: stringt): addresst {.cdecl, importc: "LM_FindSymbolAddress".}
proc findsymboladdress*(modulename: string; symbolname: string): addresst {.exportpy.} = (var module = findmodule(modulename); return findsymboladdressoriginal(module.addr, symbolname))

proc enumsegmentsoriginal(callback: proc (a0: ptr Segment; a1: pointer): boolt {.cdecl.}; arg: pointer): boolt {.cdecl, importc: "LM_EnumSegments".}
proc enumsegments*(): seq[Segment] {.exportpy.} = discard enumsegmentsoriginal(cb, result.addr)

proc enumsegmentsexoriginal(process: ptr Process; callback: proc (a0: ptr Segment; a1: pointer): boolt {.cdecl.}; arg: pointer): boolt {.cdecl, importc: "LM_EnumSegmentsEx".}
proc enumsegmentsex*(pid: uint32): seq[Segment] {.exportpy.} = (var process = getprocessex(pid); discard enumsegmentsexoriginal(process.addr, cb, result.addr))

proc findsegmentoriginal(address: addresst; segmentout: ptr Segment): boolt {.cdecl, importc: "LM_FindSegment".}
proc findsegment*(address: addresst): Segment {.exportpy.} = discard findsegmentoriginal(address, result.addr)

proc findsegmentexoriginal(process: ptr Process; address: addresst;segmentout: ptr Segment): boolt {.cdecl, importc: "LM_FindSegmentEx".}
proc findsegmentex*(pid: uint32; address: addresst): Segment {.exportpy.} = (var process = getprocessex(pid); discard findsegmentexoriginal(process.addr, address, result.addr))

proc readmemoryoriginal(source: addresst; dest: ptr bytet; size: sizet): sizet {.cdecl, importc: "LM_ReadMemory".}
proc readmemory*(source: addresst; size: sizet): seq[byte] {.exportpy.} = (var dest = newSeq[byte](size); discard readmemoryoriginal(source, dest[0].addr, size); return dest)

proc readmemoryexoriginal(process: ptr Process; source: addresst;dest: ptr bytet; size: sizet): sizet {.cdecl, importc: "LM_ReadMemoryEx".}
proc readmemoryex*(pid: uint32; source: addresst; size: sizet): seq[byte] {.exportpy.} = (var process = getprocessex(pid); var dest = newSeq[byte](size); discard readmemoryexoriginal(process.addr, source, dest[0].addr, size); return dest)

proc writememoryoriginal(dest: addresst; source: bytetarray; size: sizet): sizet {.cdecl, importc: "LM_WriteMemory".}
proc writememory*(dest: addresst; source: seq[byte]): sizet {.exportpy.} = return writememoryoriginal(dest, source[0].addr, source.len.sizet)

proc writememoryexoriginal(process: ptr Process; dest: addresst;source: bytetarray; size: sizet): sizet {.cdecl, importc: "LM_WriteMemoryEx".}
proc writememoryex*(pid: uint32; dest: addresst; source: seq[byte]): sizet {.exportpy.} = (var process = getprocessex(pid); return writememoryexoriginal(process.addr, dest, source[0].addr, source.len.sizet))

proc setmemoryoriginal(dest: addresst; byte: bytet; size: sizet): sizet {.cdecl, importc: "LM_SetMemory".}
proc setmemory*(dest: addresst; byte: bytet; size: sizet): sizet {.exportpy.} = return setmemoryoriginal(dest, byte, size)

proc setmemoryexoriginal(process: ptr Process; dest: addresst; byte: bytet;size: sizet): sizet {.cdecl, importc: "LM_SetMemoryEx".}
proc setmemoryex*(pid: uint32; dest: addresst; byte: bytet; size: sizet): sizet {.exportpy.} = (var process = getprocessex(pid); return setmemoryexoriginal(process.addr, dest, byte, size))

proc protmemoryoriginal(address: addresst; size: sizet; prot: prott;oldprotout: ptr prott): boolt {.cdecl, importc: "LM_ProtMemory".}
proc protmemory*(address: addresst; size: sizet; prot: prott): boolt {.exportpy.} = return protmemoryoriginal(address, size, prot, nil)

proc protmemoryexoriginal(process: ptr Process; address: addresst; size: sizet;prot: prott; oldprotout: ptr prott): boolt {.cdecl, importc: "LM_ProtMemoryEx".}
proc protmemoryex*(pid: uint32; address: addresst; size: sizet; prot: prott): boolt {.exportpy.} = (var process = getprocessex(pid); return protmemoryexoriginal(process.addr, address, size, prot, nil))

proc allocmemoryoriginal(size: sizet; prot: prott): addresst {.cdecl, importc: "LM_AllocMemory".}
proc allocmemory*(size: sizet; prot: prott): addresst {.exportpy.} = return allocmemoryoriginal(size, prot)

proc allocmemoryexoriginal(process: ptr Process; size: sizet; prot: prott): addresst {.cdecl, importc: "LM_AllocMemoryEx".}
proc allocmemoryex*(pid: uint32; size: sizet; prot: prott): addresst {.exportpy.} = (var process = getprocessex(pid); return allocmemoryexoriginal(process.addr, size, prot))

proc freememoryoriginal(alloc: addresst; size: sizet): boolt {.cdecl, importc: "LM_FreeMemory".}
proc freememory*(alloc: addresst; size: sizet): boolt {.exportpy.} = return freememoryoriginal(alloc, size)

proc freememoryexoriginal(process: ptr Process; alloc: addresst; size: sizet): boolt {.cdecl, importc: "LM_FreeMemoryEx".}
proc freememoryex*(pid: uint32; alloc: addresst; size: sizet): boolt {.exportpy.} = (var process = getprocessex(pid); return freememoryexoriginal(process.addr, alloc, size))

proc deeppointeroriginal(base: addresst; offsets: ptr addresst; noffsets: csize_t): addresst {.cdecl, importc: "LM_DeepPointer".}
proc deeppointer*(base: addresst; offsets: seq[addresst]): addresst {.exportpy.} = return deeppointeroriginal(base, offsets[0].addr, offsets.len.csize_t)

proc deeppointerexoriginal(process: ptr Process; base: addresst;offsets: ptr addresst; noffsets: sizet): addresst {.cdecl, importc: "LM_DeepPointerEx".}
proc deeppointerex*(pid: uint32; base: addresst; offsets: seq[addresst]): addresst {.exportpy.} = (var process = getprocessex(pid); return deeppointerexoriginal(process.addr, base, offsets[0].addr, offsets.len.sizet))

proc datascanoriginal(data: bytetarray; datasize: sizet; address: addresst;scansize: sizet): addresst {.cdecl, importc: "LM_DataScan".}
proc datascan*(data: seq[byte]; address: addresst, scansize: sizet): addresst {.exportpy.} = return datascanoriginal(data[0].addr, data.len.sizet, address, scansize)

proc datascanexoriginal(process: ptr Process; data: bytetarray; datasize: sizet;address: addresst; scansize: sizet): addresst {.cdecl, importc: "LM_DataScanEx".}
proc datascanex*(pid: uint32; data: seq[byte]; address: addresst; scansize: sizet): addresst {.exportpy.} = (var process = getprocessex(pid); return datascanexoriginal(process.addr, data[0].addr, data.len.sizet, address, scansize))

proc patternscanoriginal(pattern: bytetarray; mask: stringt; address: addresst;scansize: sizet): addresst {.cdecl, importc: "LM_PatternScan".}
proc patternscan*(pattern: seq[byte]; mask: string; address: addresst; scansize: sizet): addresst {.exportpy.} = return patternscanoriginal(pattern[0].addr, mask, address, scansize)

proc patternscanexoriginal(process: ptr Process; pattern: bytetarray;mask: stringt; address: addresst; scansize: sizet): addresst {.cdecl, importc: "LM_PatternScanEx".}
proc patternscanex*(pid: uint32; pattern: seq[byte]; mask: string;address: addresst; scansize: sizet): addresst {.exportpy.} = (var process = getprocessex(pid); return patternscanexoriginal(process.addr, pattern[0].addr, mask, address, scansize))

proc sigscanoriginal(signature: stringt; address: addresst; scansize: sizet): addresst {.cdecl, importc: "LM_SigScan".}
proc sigscan*(signature: string; address: addresst; scansize: sizet): addresst {.exportpy.} = return sigscanoriginal(signature, address, scansize)

proc sigscanexoriginal(process: ptr Process; signature: stringt;address: addresst; scansize: sizet): addresst {.cdecl, importc: "LM_SigScanEx".}
proc sigscanex*(pid: uint32; signature: string; address: addresst;scansize: sizet): addresst {.exportpy.} = (var process = getprocessex(pid); return sigscanexoriginal(process.addr, signature, address, scansize))

proc getarchitectureoriginal(): archt {.cdecl, importc: "LM_GetArchitecture".}
proc getarchitecture*(): archt {.exportpy.} = return getarchitectureoriginal()

proc assembleoriginal(code: stringt; instructionout: ptr Instruction): boolt {.cdecl, importc: "LM_Assemble".}
proc assemble*(code: string): Instruction {.exportpy.} = (var inst: Instruction; discard assembleoriginal(code, inst.addr))

proc assembleexoriginal(code: stringt; arch: archt; bits: sizet;runtimeaddress: addresst; payloadout: ptr ptr bytet): sizet {.cdecl, importc: "LM_AssembleEx".}
proc assembleex*(code: string; arch: archt; bits: sizet;runtimeaddress: addresst): Instruction {.exportpy.} = (var payload: ptr bytet; discard assembleexoriginal(code, arch, bits, runtimeaddress, payload.addr); return cast[Instruction](payload[]))

proc freepayloadoriginal(payload: ptr bytet): void {.cdecl, importc: "LM_FreePayload".}
proc freepayload*(payload: addresst): void {.exportpy.} = freepayloadoriginal(cast[ptr bytet](payload))

proc disassembleoriginal(machinecode: addresst; instructionout: ptr Instruction): boolt {.cdecl, importc: "LM_Disassemble".}
proc disassemble*(machinecode: addresst): Instruction {.exportpy.} = (var inst: Instruction; discard disassembleoriginal(machinecode, inst.addr))

proc disassembleexoriginal(machinecode: addresst; arch: archt; bits: sizet;maxsize: sizet; instructioncount: sizet;runtimeaddress: addresst; instructionsout: ptr ptr Instruction): sizet {.cdecl, importc: "LM_DisassembleEx".}
proc disassembleex*(machinecode: addresst; arch: archt; bits: sizet;maxsize: sizet; instructioncount: sizet;runtimeaddress: addresst): Instruction {.exportpy.} = (var instructions: ptr Instruction; discard disassembleexoriginal(machinecode, arch, bits, maxsize, instructioncount, runtimeaddress, instructions.addr); return instructions[])

proc freeinstructionsoriginal(instructions: ptr Instruction): void {.cdecl, importc: "LM_FreeInstructions".}
proc freeinstructions*(instructions: Instruction): void {.exportpy.} = freeinstructionsoriginal(instructions.addr)

proc codelengthoriginal(machinecode: addresst; minlength: sizet): sizet {.cdecl, importc: "LM_CodeLength".}
proc codelength*(machinecode: addresst; minlength: sizet): sizet {.exportpy.} = return codelengthoriginal(machinecode, minlength)

proc codelengthexoriginal(process: ptr Process; machinecode: addresst;minlength: sizet): sizet {.cdecl, importc: "LM_CodeLengthEx".}
proc codelengthex*(pid: uint32; machinecode: addresst; minlength: sizet): sizet {.exportpy.} = (var process = getprocessex(pid); return codelengthexoriginal(process.addr, machinecode, minlength))

proc hookcodeoriginal(fromarg: addresst; to: addresst; trampolineout: ptr addresst): sizet {.cdecl, importc: "LM_HookCode".}
proc hookcode*(fromarg: addresst; to: addresst): addresst {.exportpy.} = (var trampoline: addresst; return hookcodeoriginal(fromarg, to, trampoline.addr))

proc hookcodeexoriginal(process: ptr Process; fromarg: addresst; to: addresst;trampolineout: ptr addresst): sizet {.cdecl, importc: "LM_HookCodeEx".}
proc hookcodeex*(pid: uint32; fromarg: addresst; to: addresst): addresst {.exportpy.} = (var process = getprocessex(pid); var trampoline: addresst; return hookcodeexoriginal(process.addr, fromarg, to, trampoline.addr))

proc unhookcodeoriginal(fromarg: addresst; trampoline: addresst; size: sizet): boolt {.cdecl, importc: "LM_UnhookCode".}
proc unhookcode*(fromarg: addresst; trampoline: addresst; size: sizet): boolt {.exportpy.} = return unhookcodeoriginal(fromarg, trampoline, size)

proc unhookcodeexoriginal(process: ptr Process; fromarg: addresst;trampoline: addresst; size: sizet): boolt {.cdecl, importc: "LM_UnhookCodeEx".}
proc unhookcodeex*(pid: uint32; fromarg: addresst; trampoline: addresst;size: sizet): boolt {.exportpy.} = (var process = getprocessex(pid); return unhookcodeexoriginal(process.addr, fromarg, trampoline, size))

