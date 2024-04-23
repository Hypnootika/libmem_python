import array

# noinspection PyUnresolvedReferences
from . import _libmem as libmem

PROTNONE = 0
PROTR = 1
PROTW = 2
PROTX = 4
PROTXR = 5
PROTXW = 6
PROTRW = 3
PROTXRW = 7
ARCHARM = 0
ARCHARM64 = 1
ARCHMIPS = 2
ARCHX86 = 3
ARCHPPC = 4
ARCHSPARC = 5
ARCHSYSZ = 6
ARCHEVM = 7
ARCHMAX = 8


class Process:
    def __init__(self, process):
        self._pid = process["pid"]
        self._ppid = process["ppid"]
        self._bits = process["bits"]
        self._start_time = process["startime"]
        self._path = process["path"]
        self._name = process["name"]

    def __repr__(self):
        return (f"Name: {self._name}, ppid: {self._ppid}, pid: {self._pid}, "
                f"bits: {self._bits}, starttime: {self._start_time}, path: {self._path}")

    @property
    def name(self):
        return self._name

    @property
    def pid(self):
        return self._pid

    @property
    def ppid(self):
        return self.ppid

    @property
    def bits(self):
        return self._bits

    @property
    def start_time(self):
        return self._start_time

    @property
    def path(self):
        return self._path


class Thread:
    def __init__(self, thread):
        self._tid = thread["tid"]
        self._owner_pid = thread["ownerpid"]

    def __repr__(self):
        return f"Thread: (Tid {self._tid} Pid: {self._owner_pid})"

    @property
    def tid(self):
        return self._tid

    @property
    def pid(self):
        return self._owner_pid


class Module:
    def __init__(self, module):
        self._base = module["base"]
        self._size = module["size"]
        self._path = module["path"]
        self._name = module["name"]

    def __repr__(self):
        return f"Name: {self.name} Path: {self.path} Base: {self.base} Size: {self.size}"

    @property
    def base(self):
        return self._base

    @property
    def size(self):
        return self._size

    @property
    def path(self):
        return self._path

    @property
    def name(self):
        return self._name


class Symbol:
    def __init__(self, symbol):
        self._address = symbol["memoryaddress"]
        self._name = symbol["name"]

    def __repr__(self):
        return f"Name: {self.name} Address: {self.address}"

    @property
    def address(self):
        return self._address

    @property
    def name(self):
        return self._name


class Segment:
    def __init__(self, segment):
        self._base = segment["base"]
        self._size = segment["size"]
        self._prot = segment["prot"]

    def __repr__(self):
        return f"Base: {self.base} Size: {self.size} Prot: {self.prot}"

    @property
    def base(self):
        return self._base

    @property
    def size(self):
        return self._size

    @property
    def prot(self):
        return self._prot


class Instruction:
    def __init__(self, instruction):
        self._address: int = instruction["memoryaddress"]
        self._size: int = instruction["size"]
        self._bytes: list[bytes] = instruction["bytes"]
        self._mnemonic: list[str] = instruction["mnemonic"]
        self._op_str = instruction["opstr"]

    def __repr__(self):
        return f"Address: {self.address} Size: {self.size} Mnemonic: {self.mnemonic} op_str: {self.op_str} Bytes: {self.bytes}"

    @property
    def address(self):
        return self._address

    @property
    def size(self):
        return self._size

    @property
    def mnemonic(self):
        s = ""
        return s.join([chr(e) for e in self._mnemonic]).split("\x00")[0]

    @property
    def op_str(self):
        st = ""
        return st.join([chr(e) for e in self._op_str]).strip("\x00")

    @property
    def bytes(self):
        return self._bytes


class Vmt:
    def __init__(self, vmt):
        self._vtable = vmt["vtable"]
        self._hkentries = vmt["hkentries"]

    def __repr__(self):
        return f"Vtable: {self.vtable} Hooked Entries: {self.hkentries}"

    @property
    def vtable(self):
        return self._vtable

    @property
    def hkentries(self):
        return self._hkentries


def enumprocesses() -> list[Process]:
    return [Process(e) for e in libmem.enumprocesses()]


def getprocess() -> Process:
    return Process(libmem.getprocess())


def getprocessex(pid: int) -> Process:
    return Process(libmem.getprocessex(pid))


def findprocess(processname: str) -> Process:
    return Process(libmem.findprocess(processname))


def isprocessalive(pid: int) -> bool:
    return libmem.isprocessalive(pid)


def getbits() -> int:
    return libmem.getbits()


def getsystembits() -> int:
    return libmem.getsystembits()


def enumthreads() -> list[Thread]:
    return [Thread(e) for e in libmem.enumthreads()]


def enumthreadsex(pid: int) -> list[Thread]:
    return [Thread(e) for e in libmem.enumthreadsex(pid)]


def getthread() -> Thread:
    return Thread(libmem.getthread())


def getthreadex(pid: int) -> Thread:
    return Thread(libmem.getthreadex(pid))


def getthreadprocess(thread: Thread) -> Process:
    return Process(libmem.getthreadprocess(thread))


def enummodules() -> list[Module]:
    return [Module(e) for e in libmem.enummodules()]


def enummodulesex(pid: int) -> list[Module]:
    return [Module(e) for e in libmem.enummodulesex(pid)]


def findmodule(name: str) -> Module:
    return Module(libmem.findmodule(name))


def findmoduleex(pid: int, name: str) -> Module:
    return Module(libmem.findmoduleex(pid, name))


def loadmodule(path: str) -> Module:
    return Module(libmem.loadmodule(path))


def loadmoduleex(pid: int, path: array) -> Module:
    return Module(libmem.loadmoduleex(pid, path))


def unloadmodule(modulename: str) -> bool:
    return libmem.unloadmodule(modulename)


def unloadmoduleex(pid: int, modulename: str) -> bool:
    return libmem.unloadmoduleex(pid, modulename)


def enumsymbols(modulename: str) -> list[Symbol]:
    return [Symbol(e) for e in libmem.enumsymbols(modulename)]


def findsymboladdress(modulename: str, symbolname: str) -> int:
    return libmem.findsymboladdress(modulename, symbolname)


def enumsegments() -> list[Segment]:
    return [Segment(e) for e in libmem.enumsegments()]


def enumsegmentsex(pid: int) -> list[Segment]:
    return [Segment(e) for e in libmem.enumsegmentsex(pid)]


def findsegment(address: int) -> Segment:
    return Segment(libmem.findsegment(address))


def findsegmentex(pid: int, address: int) -> Segment:
    return Segment(libmem.findsegmentex(pid, address))


def readmemory(source: int, size: int) -> list[bytes]:
    return libmem.readmemory(source, size)


def readmemoryex(pid: int, source: int, size: int) -> list[bytes]:
    return libmem.readmemoryex(pid, source, size)


def writedata(dest: int, data: array) -> int:
    return libmem.writedata(dest, data)


def writedataex(pid: int, dest: int, data: array) -> int:
    return libmem.writedataex(pid, dest, data)


def writememoryex(pid: int, dest: int, source: list[bytes]) -> int:
    return libmem.writememoryex(pid, dest, source)


def setmemory(dest: int, byte: int, size: int) -> int:
    return libmem.setmemory(dest, byte, size)


def setmemoryex(pid: int, dest: int, byte: bytes, size: int) -> int:
    return libmem.setmemoryex(pid, dest, byte, size)


def protmemory(address: int, size: int, prot: int) -> bool:
    return libmem.protmemory(address, size, prot)


def protmemoryex(pid: int, address: int, size: int, prot: int) -> bool:
    return libmem.protmemoryex(pid, address, size, prot)


def allocmemory(size: int, prot: int) -> int:
    return libmem.allocmemory(size, prot)


def allocmemoryex(pid: int, size: int, prot: int) -> int:
    return libmem.allocmemoryex(pid, size, prot)


def freememory(alloc: int, size: int) -> bool:
    return libmem.freememory(alloc, size)


def freememoryex(pid: int, alloc: int, size: int) -> bool:
    return libmem.freememoryex(pid, alloc, size)


def deeppointer(base: int, offsets: list[int]) -> int:
    return libmem.deeppointer(base, offsets)


def deeppointerex(pid: int, base: int, offsets: list[int]) -> int:
    return libmem.deeppointerex(pid, base, offsets)


def datascan(data: list[bytes], address: int, scansize: int) -> int:
    return libmem.datascan(data, address, scansize)


def datascanex(pid: int, data: list[bytes], address: int, scansize: int) -> int:
    return libmem.datascanex(pid, data, address, scansize)


def patternscan(pattern: list[bytes], mask: str, address: int, scansize: int) -> int:
    return libmem.patternscan(pattern, mask, address, scansize)


def patternscanex(pid: int, pattern: list[bytes], mask: str, address: int, scansize: int) -> int:
    return libmem.patternscanex(pid, pattern, mask, address, scansize)


def sigscan(signature: str, address: int, scansize: int) -> int:
    return libmem.sigscan(signature, address, scansize)


def sigscanex(pid: int, signature: str, address: int, scansize: int) -> int:
    return libmem.sigscanex(pid, signature, address, scansize)


def getarchitecture() -> int:
    return libmem.getarchitecture()


def assemble(code: array) -> Instruction:
    return Instruction(libmem.assemble(code))


def assembleex(code: str, arch: int, bits: int, runtimeaddress: int) -> Instruction:
    return Instruction(libmem.assembleex(code, arch, bits, runtimeaddress))


def freepayload(payload: int):
    return libmem.freepayload(payload)


def disassemble(machinecode: int) -> Instruction:
    return Instruction(libmem.disassemble(machinecode))


def disassembleex(machinecode: int, arch: int, bits: int, maxsize: int, instructioncount: int,
                  runtimeaddress: int) -> Instruction:
    return Instruction(libmem.disassembleex(machinecode, arch, bits, maxsize, instructioncount, runtimeaddress))


def freeinstructions(instructions: Instruction):
    return libmem.freeinstructions(instructions)


def codelength(machinecode: int, minlength: int) -> int:
    return libmem.codelength(machinecode, minlength)


def codelengthex(pid: int, machinecode: int, minlength: int) -> int:
    return libmem.codelengthex(pid, machinecode, minlength)


def hookcode(fromarg: int, to: int) -> int:
    return libmem.hookcode(fromarg, to)


def hookcodeex(pid: int, fromarg: int, to: int) -> int:
    return libmem.hookcodeex(pid, fromarg, to)


def unhookcode(fromarg: int, trampoline: int, size: int) -> bool:
    return libmem.unhookcode(fromarg, trampoline, size)


def unhookcodeex(pid: int, fromarg: int, trampoline: int, size: int) -> bool:
    return libmem.unhookcodeex(pid, fromarg, trampoline, size)
