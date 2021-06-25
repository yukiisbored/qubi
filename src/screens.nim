import
  sequtils,
  strutils,
  unicode,
  random,
  nimraylib_now,
  consts,
  screen,
  utils

type
  GameScreen* = ref object of Screen
    words: seq[string]
    word: string
    input: string
    total: int
    success: int

proc newGameScreen*(): GameScreen = new result

proc reset(s: GameScreen) = 
  s.input = ""
  s.word = sample(s.words).toLower

method init*(s: GameScreen) = 
  randomize()
  s.words = toSeq(lines "assets/words.txt")
  s.reset()

method update*(s: GameScreen) = 
  beginDrawing:
    clearBackground(White)

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
        s.reset()

      if s.word == s.input:
        s.success.inc
        s.reset()
