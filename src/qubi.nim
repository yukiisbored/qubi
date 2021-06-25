import
  nimraylib_now,
  consts,
  screen,
  screens

proc update() {.cdecl.} = updateScreen()

proc main() =
  initWindow(Size, Size, "OpenWorkstation Enterprise - Licensed for Qubi Innovative Solutions, LLC")

  changeScreen(newGameScreen())

  when defined(emscripten):
    emscriptenSetMainLoop(update, 0, 1)
  else:
    setTargetFPS(60)
    while not windowShouldClose(): update()

  closeWindow()

when isMainModule: main()
