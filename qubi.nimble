version       = "0.0.0"
author        = "Yuki"
description   = "Game"
license       = "ISC"
srcDir        = "src"
bin           = @["qubi"]

requires "nim >= 1.4"
requires "nimraylib_now >= 0.13.1"

task web, "Build WebAssembly version":
  exec "rm -rf public"
  exec "mkdir public"
  exec "nim c -d:emscripten src/qubi.nim"
