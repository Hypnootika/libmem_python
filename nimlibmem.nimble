# Package

version       = "0.1.0"
author        = "Hypnootika"
description   = "unofficial Libmem bindings for Python, generated using nimpy"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]



# Dependencies

requires "nim >= 2.0.0"
requires "nimpy"

task(downloadlibmem, "Downloads latest libmem source code"):
  exec "nim c -r src/githandler/libmemgithandler.nim"

task(generatebindings, "Prepares the bindings"):
  exec "nim c src/nimlibmem.nim"

task(buildall, "Builds the package"):
  exec "nimble downloadlibmem"
  exec "nimble generatebindings"
