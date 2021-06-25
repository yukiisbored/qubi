import
  sequtils,
  strutils,
  unicode,
  random,
  times,
  math,

  nimraylib_now,
  
  consts,
  screen

type
  GameScreen* = ref object of Screen
    words: seq[string]
    
    word: string
    input: string

    total: int
    bad: int

    overlayColor: Color
    overlayAlpha: float

    endTime: float

proc newGameScreen*(): GameScreen = new result

proc reset(s: GameScreen) = 
  s.input = ""
  s.word = sample(s.words).toLower

method init*(s: GameScreen) = 
  randomize()
  s.words = toSeq(lines "assets/words.txt")
  s.reset()
  s.endTime = times.getTime().toUnixFloat()

method update*(s: GameScreen) = 
  beginDrawing:
    clearBackground(White)

    block:
      let alpha = uint8(255 * s.overlayAlpha)

      s.overlayColor.a = alpha
      s.overlayAlpha = lerp(s.overlayAlpha, 0f, 1f - pow(0.33f, getFrameTime()))

      drawRectangle(0, 0, Size, Size, s.overlayColor)

    block:
      let width = measureText(s.word, 40) div 2 

      drawText(s.word, Center - width, Center - 20, 40, Lightgray)
      drawText(s.input, Center - width, Center - 20, 40, Black)

    block:
      var key = getKeyPressed()

      while key > 0:
        if (key >= 65 and key <= 90) or key == 39:
          s.input &= $key.char 
          key = getKeyPressed()
      
      s.input = s.input.toLower()

    block:
      if not s.word.startsWith(s.input):
        s.overlayColor = Red
        s.overlayAlpha = 1f
        s.bad.inc()
        s.reset()

      if s.word == s.input:
        s.overlayColor = Green
        s.overlayAlpha = 1f
        s.reset()
