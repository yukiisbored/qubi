type
  Screen* = ref object of RootObj

var
  currentScreen: Screen

method update*(s: Screen) {.base.} =
  raise newException(CatchableError, "Method without implementation override")

method init*(s: Screen) {.base.} =
  discard

method deinit*(s: Screen) {.base.} =
  discard

proc changeScreen*(s: Screen) =
  if currentScreen != nil:
    currentScreen.deinit()

  s.init()
  currentScreen = s

proc updateScreen*() =
  if currentScreen != nil:
    currentScreen.update()
