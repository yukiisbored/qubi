import nimraylib_now

const
  Size = 512
  Center = Size div 2

proc update() {.cdecl.} =
  beginDrawing:
    clearBackground(White)

    drawFPS(10, 10)

    block:
      let
        word = "Hello, world!"
        width = measureText(word, 40) div 2
      drawText(word, Center - width, Center - 20, 40, Lightgray)

proc main() =
  initWindow(Size, Size, "OpenWorkstation Enterprise")

  when defined(emscripten):
    emscriptenSetMainLoop(update, 0, 1)
  else:
    setTargetFPS(60)

    while not windowShouldClose():
      update()

  closeWindow()

when isMainModule: main()
