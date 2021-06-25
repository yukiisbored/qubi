import
  nimraylib_now,
  consts,
  screen

type
  HelloWorldScreen* = ref object of Screen
  HelloWorldTwoScreen* = ref object of Screen

proc newHelloWorldScreen*(): HelloWorldScreen = new result
proc newHelloWorldTwoScreen*(): HelloWorldTwoScreen = new result

method update*(s: HelloWorldScreen) =
  beginDrawing:
    clearBackground(White)

    drawFPS(10, 10)

    block:
      let
        word = "Hello, world!"
        width = measureText(word, 40) div 2
      drawText(word, Center - width, Center - 20, 40, Lightgray)

    block:
      if isKeyPressed(K):
        changeScreen(newHelloWorldTwoScreen())

method update*(s: HelloWorldTwoScreen) =
  beginDrawing:
    clearBackground(Black)

    drawFPS(10, 10)

    block:
      let
        word = "Hello, world!"
        width = measureText(word, 40) div 2
      drawText(word, Center - width, Center - 20, 40, White)

    block:
      if isKeyPressed(K):
        changeScreen(newHelloWorldScreen())
