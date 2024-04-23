from array import array

import libmem
import os
import unittest

if not libmem.findprocess("notepad.exe"):
    os.system("notepad.exe")


class TestLibmem(unittest.TestCase):
    def test_enumprocesses(self):
        self.assertIsInstance(libmem.enumprocesses(), list)
        self.assertIsInstance(libmem.enumprocesses()[0], libmem.Process)
        self.assertGreater(len(libmem.enumprocesses()), 0)

    def test_getprocess(self):
        self.assertIsInstance(libmem.getprocess(), libmem.Process)
        self.assertGreater(libmem.getprocess().pid, 0)

    def test_getprocessex(self):
        self.assertIsInstance(libmem.getprocessex(0), libmem.Process)
        self.assertEqual(libmem.getprocessex(0).pid, 0)

    def test_findprocess(self):
        self.assertIsInstance(libmem.findprocess("python.exe"), libmem.Process)
        self.assertEqual(libmem.findprocess("python.exe").name, "python.exe")

    def test_isprocessalive(self):
        self.assertTrue(libmem.isprocessalive(libmem.findprocess("notepad.exe").pid))

    def test_getbits(self):
        self.assertIsInstance(libmem.getbits(), int)
        self.assertIn(libmem.getbits(), [32, 64])

    def test_getsystembits(self):
        self.assertIsInstance(libmem.getsystembits(), int)
        self.assertIn(libmem.getsystembits(), [32, 64])

    def test_enumthreads(self):
        self.assertIsInstance(libmem.enumthreads(), list)
        self.assertIsInstance(libmem.enumthreads()[0], libmem.Thread)
        self.assertGreater(len(libmem.enumthreads()), 0)

    def test_enumthreadsex(self):
        self.assertIsInstance(libmem.enumthreadsex(libmem.findprocess("notepad.exe").pid), list)
        self.assertIsInstance(libmem.enumthreadsex(libmem.findprocess("notepad.exe").pid)[0], libmem.Thread)
        self.assertGreater(len(libmem.enumthreadsex(libmem.findprocess("notepad.exe").pid)), 0)

    def test_getthread(self):
        self.assertIsInstance(libmem.getthread(), libmem.Thread)
        self.assertGreater(libmem.getthread().tid, 0)

    def test_getthreadex(self):
        self.assertIsInstance(libmem.getthreadex(libmem.findprocess("notepad.exe").pid), libmem.Thread)
        self.assertGreater(libmem.getthreadex(libmem.findprocess("notepad.exe").pid).tid, 0)

    def test_getthreadprocess(self):
        self.assertIsInstance(libmem.getthreadprocess(libmem.getthread()), libmem.Process)

    def test_enummodules(self):
        self.assertIsInstance(libmem.enummodules(), list)
        self.assertIsInstance(libmem.enummodules()[0], libmem.Module)
        self.assertGreater(len(libmem.enummodules()), 0)

    def test_enummodulesex(self):
        self.assertIsInstance(libmem.enummodulesex(libmem.findprocess("notepad.exe").pid), list)
        self.assertIsInstance(libmem.enummodulesex(libmem.findprocess("notepad.exe").pid)[0], libmem.Module)
        self.assertGreater(len(libmem.enummodulesex(libmem.findprocess("notepad.exe").pid)), 0)

    def test_findmodule(self):
        self.assertIsInstance(libmem.findmodule("ntdll.dll"), libmem.Module)
        self.assertEqual(libmem.findmodule("ntdll.dll").name, "ntdll.dll")

    def test_hookcode(self):
        self.assertTrue(
            libmem.hookcode(libmem.findmodule("ntdll.dll").base + 0x50, libmem.findmodule("ntdll.dll").base + 0x60))

    def test_hookcodeex(self):
        proc = libmem.findprocess("notepad.exe")
        procmod = libmem.findmoduleex(proc.pid, "notepad.exe")
        self.assertGreater(libmem.hookcodeex(proc.pid, procmod.base + 0x0000A70A, procmod.base + 0x0000A70C), 0)

    def test_unhookcode(self):
        self.assertTrue(
            libmem.unhookcode(libmem.findmodule("ntdll.dll").base + 0x50, libmem.findmodule("ntdll.dll").base + 0x60,
                              5))

    def test_unhookcodeex(self):
        self.assertTrue(
            libmem.unhookcodeex(libmem.findprocess("notepad.exe").pid, libmem.findmodule("ntdll.dll").base + 0x50,
                                libmem.findmodule("ntdll.dll").base + 0x60, 5))

    def test_loadmodule(self):
        self.assertIsInstance(libmem.loadmodule("ntdll.dll"), libmem.Module)

    # def test_loadmoduleex(self):
    #     self.assertIsInstance(libmem.loadmoduleex(libmem.findprocess("notepad.exe").pid, "ntdll.dll"), libmem.Module)
    #     self.assertEqual(libmem.loadmoduleex(libmem.findprocess("notepad.exe").pid, "ntdll.dll").name, "ntdll.dll")

    #
    def test_unloadmodule(self):
        self.assertTrue(libmem.unloadmodule("ntdll.dll"))

    #
    # def test_unloadmoduleex(self):
    # self.assertTrue(libmem.unloadmoduleex(libmem.findprocess("notepad.exe").pid, "notepad.exe"))

    def test_getarchitecture(self):
        self.assertIsInstance(libmem.getarchitecture(), int)
        self.assertIn(libmem.getarchitecture(), [0, 1, 2, 3])

    def test_assemble(self):
        self.assertIsInstance(libmem.assemble(list("mov eax, 0x40".encode())), libmem.Instruction)
        print(libmem.assemble(list("mov eax, 0x40".encode())).mnemonic)

    def test_enumsymbols(self):
        self.assertIsInstance(libmem.enumsymbols("ntdll.dll"), list)
        self.assertIsInstance(libmem.enumsymbols("ntdll.dll")[0], libmem.Symbol)
        self.assertGreater(len(libmem.enumsymbols("ntdll.dll")), 0)

    def test_findsymboladdress(self):
        self.assertIsInstance(libmem.findsymboladdress("ntdll.dll", "NtClose"), int)
        self.assertGreater(libmem.findsymboladdress("ntdll.dll", "NtClose"), 0)

    def test_enumsegments(self):
        self.assertIsInstance(libmem.enumsegments(), list)
        self.assertIsInstance(libmem.enumsegments()[0], libmem.Segment)
        self.assertGreater(len(libmem.enumsegments()), 0)

    def test_enumsegmentsex(self):
        self.assertIsInstance(libmem.enumsegmentsex(libmem.findprocess("notepad.exe").pid), list)
        self.assertIsInstance(libmem.enumsegmentsex(libmem.findprocess("notepad.exe").pid)[0], libmem.Segment)
        self.assertGreater(len(libmem.enumsegmentsex(libmem.findprocess("notepad.exe").pid)), 0)

    def test_readmemory(self):
        self.assertEqual(libmem.readmemory(libmem.findmodule("ntdll.dll").base, 4), b'MZ\x90\x00')

    def test_readmemoryex(self):
        try:
            self.assertEqual(
                libmem.readmemoryex(libmem.findprocess("notepad.exe").pid, libmem.findmodule("ntdll.dll").base, 4),
                b'MZ\x90\x00')
        except:
            self.assertEqual(
                libmem.readmemoryex(libmem.findprocess("notepad.exe").pid, libmem.findmodule("ntdll.dll").base, 4),
                b'@\x00\x00\x00')

    def test_writememory(self):
        self.assertTrue(libmem.writedata(libmem.findmodule("ntdll.dll").base, [0x40, 0x40, 0x40, 0x40]))

    def test_writememoryex(self):
        self.assertTrue(libmem.writedataex(libmem.findprocess("notepad.exe").pid, libmem.findmodule("ntdll.dll").base,
                                           [0x40, 0x40, 0x40, 0x40]))

    def test_setmemory(self):
        self.assertGreater(libmem.setmemory(libmem.findmodule("ntdll.dll").base, 4, 4), 0)

    def test_setmemoryex(self):
        self.assertGreater(
            libmem.setmemoryex(libmem.findprocess("notepad.exe").pid, libmem.findmodule("ntdll.dll").base, 4, 4), 0)

    def test_protmemory(self):
        self.assertTrue(libmem.protmemory(libmem.findmodule("ntdll.dll").base, 4, 6))

    def test_protmemoryex(self):
        self.assertTrue(
            libmem.protmemoryex(libmem.findprocess("notepad.exe").pid, libmem.findmodule("ntdll.dll").base, 4, 6))

    def test_allocmemory(self):
        self.assertIsInstance(libmem.allocmemory(4, 6), int)

    def test_allocmemoryex(self):
        self.assertIsInstance(libmem.allocmemoryex(libmem.findprocess("notepad.exe").pid, 4, 6), int)

    def test_freememory(self):
        alloc = libmem.allocmemory(100, libmem.PROTXRW)
        self.assertTrue(libmem.freememory(alloc, 4))

    def test_freememoryex(self):
        alloc = libmem.allocmemoryex(libmem.findprocess("notepad.exe").pid, 100, libmem.PROTXRW)
        self.assertTrue(libmem.freememoryex(libmem.findprocess("notepad.exe").pid, alloc, 4))

    def test_deeppointer(self):
        self.assertIsInstance(libmem.deeppointer(libmem.findmodule("ntdll.dll").base, [0x3C, 0x50]), int)

    def test_deeppointerex(self):
        self.assertIsInstance(
            libmem.deeppointerex(libmem.findprocess("notepad.exe").pid, libmem.findmodule("ntdll.dll").base,
                                 [0x3C, 0x50]), int)

    def test_datascan(self):
        self.assertIsInstance(libmem.datascan(b'MZ', libmem.findmodule("ntdll.dll").base, 4), int)

    def test_datascanex(self):
        self.assertIsInstance(
            libmem.datascanex(libmem.findprocess("notepad.exe").pid, b'MZ', libmem.findmodule("ntdll.dll").base, 4),
            int)

    def test_patternscan(self):
        self.assertIsInstance(libmem.patternscan(b'MZ', 'x', libmem.findmodule("ntdll.dll").base, 4), int)
        self.assertGreater(libmem.patternscan(b'MZ', 'x', libmem.findmodule("ntdll.dll").base, 4), 0)

    def test_patternscanex(self):
        self.assertIsInstance(
            libmem.patternscanex(libmem.findprocess("notepad.exe").pid, b'MZ', 'x', libmem.findmodule("ntdll.dll").base,
                                 4), int)
        self.assertGreater(
            libmem.patternscanex(libmem.findprocess("notepad.exe").pid, b'MZ', 'x', libmem.findmodule("ntdll.dll").base,
                                 4), 0)

    def test_sigscan(self):
        self.assertIsInstance(libmem.sigscan("4D5A", libmem.findmodule("ntdll.dll").base, 4), int)
        self.assertGreater(libmem.sigscan("4D5A", libmem.findmodule("ntdll.dll").base, 4), 0)

    def test_sigscanex(self):
        self.assertIsInstance(
            libmem.sigscanex(libmem.findprocess("notepad.exe").pid, "4D5A", libmem.findmodule("ntdll.dll").base, 4),
            int)
        self.assertGreater(
            libmem.sigscanex(libmem.findprocess("notepad.exe").pid, "4D5A", libmem.findmodule("ntdll.dll").base, 4), 0)
