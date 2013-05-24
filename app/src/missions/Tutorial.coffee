#_require Mission

class Tutorial extends Mission
  # @see Mission#reset
  reset: ->
    @attempts = localStorage["mission_attempts"]
    if not @attempts
      @attempts = 0
    @attempts++
    localStorage["mission_attempts"] = Number(@attempts)
    Logger.logEvent("Starting The Mission", {attempt: @attempts})

    randSave = Math.random
    Math.seedrandom()
    @gameEnded = false
    ga('send', {
      'hitType': 'event',
      'eventCategory': 'The Mission',
      'eventAction': 'Start'
      'dimension1': 'The Mission',
      'metric1': 1
    })
    Math.random = randSave

    # Create planets:
    newGame(10000, 10000)

    @map = @_setupMissionMap()
    @home = @map.home

    #camera.setZoom(0.1)
    #camera.setZoomTarget(0.5)
    #camera.setTarget(@home.location())

    @_initMenus()

    game.endTurn()
    UI.initialize(false, true, false)

    @startTime = currentTime()

  destroy: ->
    cameraHudFrame.removeChild(@foundA1Message)

    Logger.logEvent("Leaving The Mission from cutscene")
    Logger.send()

  _initMenus: ->
    closeA1 = new Elements.Button(250 - 10, 10, 16, 16,
      () =>
        @foundA1Message.close()
    )
    closeA1.setDrawFunc(
      (ctx) =>
        loc = @foundA1Message.getActualLocation(closeA1.x, closeA1.y)
        SHEET.drawSprite(SpriteNames.CLOSE, loc.x, loc.y, ctx, false)
    )
    message = "Man am I glad to see you, I wasn't going to last much longer out " +
              "here. What? You say the fungus is still around? Just point me at " +
              "it and I'll take it from there."
    @foundA1Message = new Elements.MessageBox(0, 0, 250, 100, message,
      {
        closeBtn: closeA1,
        textAlign: 'left',
        vAlign: 'middle',
        font: window.config.windowStyle.defaultText.font,
        lineHeight: 17
        visible: false
      })
    cameraHudFrame.addChild(@foundA1Message)

  # @see Mission#draw
  draw: (ctx, hudCtx) ->

  # @see Mission#onMouseMove
  onMouseMove: (x, y) ->

  # @see Mission#onMouseClick
  onMouseClick: (x, y) ->

  # @see Mission#canEndTurn
  canEndTurn: ->
    true

  getHomeTarget: ->
    return @home.location()

  # @see Mission#onEndTurn
  onEndTurn: ->
