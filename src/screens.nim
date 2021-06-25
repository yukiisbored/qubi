import
  sequtils,
  strutils,
  unicode,
  random,
  math,

  nimraylib_now,
  
  consts,
  screen

const
  Wait = 1f
  Duration = 30f
  
  ConfidentialNotice = "Qubi Research Confidential - Experimental Software - Do Not Distribute"

  DaysPerWeek = 3

  DailyGoal = int(Duration * 80 / 100)
  
  BaseRent = int(DailyGoal * DaysPerWeek * 60 / 100)
  
  CompensationPerWord = 1
  CostPerBadWord = -2

  OverdraftLimit = 100

  RentIncreaseFactor = 10 / 100

  InitialBalance = 100

var
  day = 0
  balance = InitialBalance
  rent = BaseRent

type
  KernelBootScreen = ref object of Screen
    lines: seq[string]
    bootDuration: float
    endTime: float

  LoginScreen = ref object of Screen
    iden: int 

  TransitionScreen = ref object of Screen
    duration: float
    gameDuration: float
    endTime: float

  GameScreen* = ref object of Screen
    duration: float

    words: seq[string]
    
    word: string
    input: string

    total: int
    bad: int

    overlayColor: Color
    overlayAlpha: float

    endTime: float

  EndScreen* = ref object of Screen 
    total_words: int
    bad: int

    items: seq[(string, int)]
    total: int

    messages: seq[string]

  GameOverScreen* = ref object of Screen
    messages: seq[string]

proc drawConfidentialNotice() =
  let width = measureText(ConfidentialNotice, 10) div 2
  drawText(ConfidentialNotice, Center - width, 10, 10, Lightgray)

proc newKernelBootScreen*(duration: float): KernelBootScreen = 
  new result
  result.bootDuration = duration

proc newLoginScreen*(): LoginScreen = new result

proc newTransitionScreen*(duration: float): TransitionScreen = 
  new result
  result.duration = duration

proc newTransitionScreen*(): TransitionScreen = newTransitionScreen(Wait)

proc newGameScreen*(duration: float): GameScreen = 
  new result
  result.duration = duration

proc newEndScreen*(total, bad: int): EndScreen =
  new result 
  result.total_words = total 
  result.bad = bad

proc newGameOverScreen(): GameOverScreen = new result

method init*(s: KernelBootScreen) =
  s.lines = toSeq(lines "assets/dmesg.txt")
  s.endTime = getTime() + s.bootDuration

method update*(s: KernelBootScreen) =
  beginDrawing:
    clearBackground(Black)

    block:
      let 
        delta = s.endTime - getTime()
        progress = 1 - (delta / 3f)
        maxLine = int(progress * s.lines.len.float)

      for i in 0..<maxLine:
        let y = 12 * (i+1)
        drawText(s.lines[i], 10, y, 10, White)

    block:
      if getTime() > s.endTime:
        changeScreen(newLoginScreen())

method init*(s: LoginScreen) =
  s.iden = rand(1024..8192)

method update*(s: LoginScreen) =
  beginDrawing:
    clearBackground(White)
    drawConfidentialNotice()

    block:
      let
        text = "Thank you for participating in Qubi Research"
        width = measureText(text, 20) div 2 

      drawText(text, Center - width, Center - 40, 20, Black)

    block:
      let
        text = "Press any key to start"
        width = measureText(text, 20) div 2

      drawText(text, Center - width, Center + 40, 20, Darkgray)
    

    block:
      let
        text = "Authenticated as Research Participant #" & $s.iden
        width = measureText(text, 10) div 2
        
      drawText(text, Center - width, Size - 20, 10, Lightgray)

    block:
      if getKeyPressed() > 0:
        changeScreen(newTransitionScreen(5f))
      

method init*(s: TransitionScreen) =
  s.gameDuration = Duration
  s.endTime = getTime() + s.duration

  if day >= 6:
    s.gameDuration = rand(5..30).float

method update*(s: TransitionScreen) =
  beginDrawing:
    clearBackground(White)

    drawConfidentialNotice()

    block:
      let 
        delta = s.endTime - getTime()
        progress = delta / s.duration

      drawRectangle(0, Size - 10, int(progress * Size.float), 10, Lightgray)
    
    block:
      let
        text = $s.gameDuration & " seconds"
        width = measureText(text, 40) div 2

      drawText(text, Center - width, Center - 20, 40, Lightgray)

    block:
      if getTime() >= s.endTime:
        changeScreen(newGameScreen(s.gameDuration))

proc reset(s: GameScreen) = 
  s.input = ""
  s.word = sample(s.words).toLower
  s.total.inc()

  if day >= 15 and rand(1..100) mod 3 == 0 and s.word.len >= 4:
      let 
        first = s.word[0]
        last = s.word[^1]
      
      var middle = s.word[1..^2]

      shuffle(middle)

      s.word = $first & middle & $last


method init*(s: GameScreen) = 
  s.words = toSeq(lines "assets/words.txt")
  s.reset()
  s.endTime = getTime() + s.duration

method update*(s: GameScreen) = 
  beginDrawing:
    clearBackground(White)
    
    drawConfidentialNotice()

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
      let 
        delta = s.endTime - getTime()
        progress = delta / s.duration

      drawRectangle(0, Size - 10, int(progress * Size.float), 10, Lightgray)

    block:
      var key = getKeyPressed()

      while key > 0:
        if key >= 65 and key <= 90:
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

    block:
      if getTime() >= s.endTime:
        changeScreen(newEndScreen(s.total, s.bad))

method init*(s: EndScreen) =
  day.inc()

  s.items.add(("Balance", balance))
  s.items.add(("Compensation", CompensationPerWord * s.total_words))

  if s.bad != 0:
    s.items.add(($s.bad & " incorrect entries", CostPerBadWord * s.bad))

  if day mod DaysPerWeek == 0:
    s.items.add(("Rent", rent * -1))
    rent += int(rent.float * RentIncreaseFactor)
    s.messages.add("--- Your landlord has increased rent: " & $rent)

  if day == 6:
    s.messages.add("--- To meet high demand, allocated session time")
    s.messages.add("--- are now randomized.")

  s.total = if s.items.len != 0: foldr(s.items.mapIt(it[1]), a + b)
            else: 0

  balance = s.total

  if balance <= 0:
    s.messages.add("--- Account overdraft limit: " & $OverdraftLimit)

method update*(s: EndScreen) = 
  beginDrawing:
    clearBackground(White)

    drawConfidentialNotice()

    block:
      let 
        text = "Day " & $day & " Progress"
        width = measureText(text, 20) div 2 

      drawText(text, Center - width, 25, 20, Black) 

    block:
      for i, item in s.items.pairs:
        let 
          width = measureText($item[1], 20)
          y = 25 * (i + 2)
          color = if item[1] < 0: Red
                  else: Green

        drawText($item[0], 10, y, 20, Darkgray)
        drawText($item[1], Size - width - 20, y, 20, color)

    block:
      let y = 25 * (s.items.len + 2) + 5
      drawLine(10, y, Size - 10, y, Black)

    block:
      let 
        width = measureText($s.total, 20)
        y = 25 * (s.items.len + 2) + 10
        color = if s.total < 0: Red
                else: Darkgray

      drawText($s.total, Size - width - 20, y, 20, color)

    block:
      for i, msg in s.messages:
        let 
          y = 25 * (s.items.len + 3 + i) + 10
   
        drawText(msg, 10, y, 20, Violet)

    block:
      const text = "Press ENTER to continue ..." 
      let width = measureText(text, 20) div 2 
      drawText(text, Center - width, Size - 30, 20, Black)

    block:
      if isKeyPressed(Enter):
        if balance < -OverdraftLimit:
          changeScreen(newGameOverScreen())
        else:
          changeScreen(newTransitionScreen())

method init*(s: GameOverScreen) =
  s.messages = @[
    "You have surpassed the overdraft limit of",
    "your account.",
    "",
    "Your position is now immediately dismissed.",
    "",
    "Thank you for participating in our research.",
    "",
    "Qubi Solutions, LLC",
    "Always Leaping Boundaries",
    "",
    "You have completed " & $day & " days.",
    "",
    "If you wish to create a new account, press ENTER."
  ]


method update*(s: GameOverScreen) =
  beginDrawing:
    block:
      let 
        text = "Account terminated"
        width = measureText(text, 20) div 2 

      drawText(text, Center - width, 10, 20, Red)
 
    block:
      for i, msg in s.messages:
        let y = 25 * (i + 2)
        drawText(msg, 10, y, 20, Black)

    block:
      if isKeyPressed(Enter):
        changeScreen(newLoginScreen())