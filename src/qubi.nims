if defined(emscripten):
  --define:release

  --os:linux
  --cpu:wasm32
  --cc:clang

  when defined(windows):
    --clang.exe:emcc.bat
    --clang.linkerexe:emcc.bat
    --clang.cpp.exe:emcc.bat
    --clang.cpp.linkerexe:emcc.bat
  else:
    --clang.exe:emcc
    --clang.linkerexe:emcc
    --clang.cpp.exe:emcc
    --clang.cpp.linkerexe:emcc

  --listCmd
  --gc:orc
  --exceptions:goto
  --define:noSignalHandler

  switch("passL", "-s ASYNCIFY -o public/index.html --shell-file src/shell.html --embed-file assets")
