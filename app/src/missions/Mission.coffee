# The Mission class defines a guarenteed layout for each mission. It also
# defines behavior that is common between or frequently used by missions.
class Mission
  settings: window.config.Missions

  # Creates a new mission and sets it up. This should not need to be
  # overwitten.
  constructor: (@showDescription=false)->
    @reset()

  # Removes any Elements that were created and does any other cleanup that might
  # need to be done before the mission is left.
  destroy: ->

  # Does all the setup that the mission needs. Creating planets, placing
  # initial units and fungus, etc.
  reset: ->

  # Draws all the mission specfic things
  #
  # @param [CanvasRenderingContext2D] ctx The game context
  # @param [CanvasRenderingContext2D] hudCtx The hud context
  draw: (ctx, hudCtx) ->

  # The mission expects this to be called when the mouse moves
  #
  # @param [Number] x The x position of the mouse
  # @param [Number] y The y position of the mouse
  onMouseMove: (x, y) ->

  # The mission expects this to be called when the mouse clicks
  #
  # @param [Number] x The x position of the mouse
  # @param [Number] y The y position of the mouse
  onMouseClick: (x, y) ->

  # Returns whether or not the mission is disallowing things not on the
  # cameraHudFrame to respond to input
  #
  # @return [Boolean] true if only the cameraHudFrame is permited to process input
  #hasInput: -> false

  # Returns whether or not the user can interact with the game elements
  #
  # @return [Boolean] true if the user can interact with the game elements
  canPlay: -> true

  # Returns whether or not the user can end the turn
  #
  # @return [Boolean] true if the user can end the turn
  canEndTurn: -> true

  # Returns whether or not the user can move the camera
  #
  # #return [Boolean] true if the user can move the camera
  canMove: -> true

  # Returns the location where the camera should go when HOME is pushed.
  # This must return something.
  getHomeTarget: ->
    return {x: 0, y: 0}

  # The mission expects this to be called after the end of a turn
  onEndTurn: ->

  createOptionMenu: (onRestart) ->
    menuBox = @_getMenuBox("Menu", @settings.w, @settings.h,
                           @settings.textAlign, @settings.vAlign)
    @_attachRestartButton(menuBox, onRestart)
    @_attachQuitButton(menuBox)
    @_attachCloseButton(menuBox)

    cameraHudFrame.addChild(menuBox)

    return menuBox

  createVictoryMenu: (onRestart, onNextMission) ->
    menuBox = @_getMenuBox("Victory!", @settings.w, @settings.h,
                           @settings.textAlign, @settings.vAlign)

    @_attachRestartButton(menuBox, onRestart)
    @_attachQuitButton(menuBox)
    @_attachNextButton(menuBox, onNextMission)

    cameraHudFrame.addChild(menuBox)

    return menuBox

  createFailMenu: (onRestart) ->
    menuBox = @_getMenuBox("Mission Failed!", @settings.w, @settings.h,
                           @settings.textAlign, @settings.vAlign)

    @_attachRestartButton(menuBox, onRestart)
    @_attachQuitButton(menuBox)

    cameraHudFrame.addChild(menuBox)

    return menuBox

  _getMenuBox: (message, w, h, ta, va, close=null) ->
    return new Elements.MessageBox(0, 0, w, h, message,
                                   {
                                     closeBtn: close
                                     textAlign: ta,
                                     vAlign: va,
                                     visible: false
                                   })

  _attachRestartButton: (menu, onRestart) ->
    restart = @settings.restart
    restartButton = new Elements.Button(restart.x, restart.y, restart.w, restart.h)
    restartButton.setClickHandler(onRestart)
    restartButton.setDrawFunc((ctx) =>
      loc = menu.getActualLocation(restartButton.x, restartButton.y)
      if restartButton.isPressed()
        SHEET.drawSprite(SpriteNames.RESTART_BUTTON_HOVER,
                         loc.x, loc.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.RESTART_BUTTON_IDLE,
                         loc.x, loc.y, ctx, false)
    )

    menu.addChild(restartButton)

  _attachQuitButton: (menu) ->
    quit = @settings.quit
    quitButton = new Elements.Button(quit.x, quit.y, quit.w, quit.h)
    quitButton.setClickHandler(() => newMission(Menu))
    quitButton.setDrawFunc((ctx) =>
      loc = menu.getActualLocation(quitButton.x, quitButton.y)
      if quitButton.isPressed()
        SHEET.drawSprite(SpriteNames.QUIT_BUTTON_HOVER,
                         loc.x, loc.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.QUIT_BUTTON_IDLE,
                         loc.x, loc.y, ctx, false)
    )

    menu.addChild(quitButton)

  _attachNextButton: (menu, onNextMission) ->
    next = @settings.next
    nextButton = new Elements.Button(next.x, next.y, next.w, next.h)
    nextButton.setClickHandler(onNextMission)
    nextButton.setDrawFunc((ctx) =>
      loc = menu.getActualLocation(nextButton.x, nextButton.y)
      if nextButton.isPressed()
        SHEET.drawSprite(SpriteNames.NEXT_BUTTON_HOVER,
                         loc.x, loc.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.NEXT_BUTTON_IDLE,
                         loc.x, loc.y, ctx, false)
    )

    menu.addChild(nextButton)

  _attachCloseButton: (menu) ->
    close = @settings.close
    closeButton = new Elements.Button(close.x, close.y, close.w, close.h)
    closeButton.setClickHandler(() => menu.close())
    closeButton.setDrawFunc((ctx) =>
      loc = menu.getActualLocation(closeButton.x, closeButton.y)
      SHEET.drawSprite(SpriteNames.CLOSE, loc.x, loc.y, ctx, false)
    )

    menu.addChild(closeButton)
    return closeButton

  createMenuButton: (theMenu) ->
    menu = @settings.menu
    x = camera.width - menu.w / 2 - 5
    y = menu.h / 2 + 5
    menuButton = new Elements.Button(x, y, menu.w, menu.h)
    menuButton.setClearFunc((ctx) =>
      ctx.clearRect(menuButton.x - menuButton.w / 2,
                    menuButton.y - menuButton.h / 2,
                    menuButton.w, menuButton.h)
    )
    menuButton.setClickHandler(() =>
      if theMenu.visible
        theMenu.close()
      else
        theMenu.open()
    )
    menuButton.setMouseUpHandler(() => menuButton.setDirty())
    menuButton.setMouseDownHandler(() => menuButton.setDirty())
    menuButton.setMouseOutHandler(() => menuButton.setDirty())
    menuButton.setDrawFunc((ctx) =>
      menuButton.x = camera.width - menu.w / 2 - 5
      loc = {x: menuButton.x, y: menuButton.y}
      if menuButton.isPressed()
        SHEET.drawSprite(SpriteNames.MENU_BUTTON_HOVER, loc.x, loc.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.MENU_BUTTON_IDLE, loc.x, loc.y, ctx, false)
    )

    frameElement.addChild(menuButton)

    return menuButton

  _createMenu: (settings, onStart=null, start=false, restart=false, quit=false,
                cancel=false, close=false) ->
    cancelButton = null
    if cancel
      cancelButton = new Elements.Button(settings.w * 2/3, settings.h - 15,
                                         60, 20)
    else if close
      cancelButton = new Elements.Button(settings.w - 8 - 5, 8 + 5,
                                         16, 16)

    menuBox = new Elements.MessageBox(0, 0,
                                      settings.w, settings.h,
                                      settings.message,
                                      {
                                        closeBtn: cancelButton,
                                        textAlign: settings.textAlign,
                                        vAlign: settings.vAlign,
                                        font: settings.font
                                        lineHeight: settings.lineHeight,
                                        visible: false
                                      })
    if cancel
      cancelButton.setClickHandler(() =>
        menuBox.close()
      )
      cancelButton.setDrawFunc((ctx) =>
        loc = menuBox.getActualLocation(cancelButton.x, cancelButton.y)
        if cancelButton.isPressed()
          SHEET.drawSprite(SpriteNames.CANCEL_BUTTON_HOVER,
                           loc.x, loc.y, ctx, false)
        else
          SHEET.drawSprite(SpriteNames.CANCEL_BUTTON_IDLE,
                           loc.x, loc.y, ctx, false)
      )

    if close
      cancelButton.setClickHandler(() =>
        menuBox.close()
      )
      cancelButton.setDrawFunc((ctx) =>
        loc = menuBox.getActualLocation(cancelButton.x, cancelButton.y)
        SHEET.drawSprite(SpriteNames.CLOSE, loc.x, loc.y, ctx, false)
      )

    if start
      startButton = new Elements.Button(settings.w * 1/3, settings.h - 15,
                                        101, 20)
      startButton.setClickHandler(onStart)
      startButton.setDrawFunc((ctx) =>
        loc = menuBox.getActualLocation(startButton.x, startButton.y)
        if startButton.isPressed()
          SHEET.drawSprite(SpriteNames.START_MISSION_BUTTON_HOVER,
                           loc.x, loc.y, ctx, false)
        else
          SHEET.drawSprite(SpriteNames.START_MISSION_BUTTON_IDLE,
                           loc.x, loc.y, ctx, false)
      )

      menuBox.addChild(startButton)
    else if restart
      startButton = new Elements.Button(settings.w * 1/3, settings.h - 15,
                                        63, 20)
      startButton.setClickHandler(onStart)
      startButton.setDrawFunc((ctx) =>
        loc = menuBox.getActualLocation(startButton.x, startButton.y)
        if startButton.isPressed()
          SHEET.drawSprite(SpriteNames.RESTART_BUTTON_HOVER,
                           loc.x, loc.y, ctx, false)
        else
          SHEET.drawSprite(SpriteNames.RESTART_BUTTON_IDLE,
                           loc.x, loc.y, ctx, false)
      )

      menuBox.addChild(startButton)

    if quit
      quitButton = new Elements.Button(settings.w * 2/3, settings.h - 15,
                                       40, 20)
      quitButton.setClickHandler(() => newMission(Menu))
      quitButton.setDrawFunc((ctx) =>
        loc = menuBox.getActualLocation(quitButton.x, quitButton.y)
        if quitButton.isPressed()
          SHEET.drawSprite(SpriteNames.QUIT_BUTTON_HOVER,
                           loc.x, loc.y, ctx, false)
        else
          SHEET.drawSprite(SpriteNames.QUIT_BUTTON_IDLE,
                           loc.x, loc.y, ctx, false)
      )

      menuBox.addChild(quitButton)

    cameraHudFrame.addChild(menuBox)

    return menuBox

  # @param [String] message
  # @param [Function] onNext
  # @param [Number] w
  # @param [Number] h
  _getM: (message, onNext, w=250, h=50) ->
    m = new Elements.MessageBox(0, 200, w, h, message,
      {
        textAlign: 'left',
        vAlign: 'top',
        font: window.config.windowStyle.defaultText.font,
        lineHeight: 17
        visible: false
      })

    if onNext != null
      next = new Elements.Button(w - 12, h - 12, 16, 16, onNext)
      next.setDrawFunc(
        (ctx) =>
          loc = m.getActualLocation(next.x, next.y)
          SHEET.drawSprite(SpriteNames.NEXT, loc.x, loc.y, ctx, false)
      )
      m.addChild(next)
    cameraHudFrame.addChild(m)

    return m

  createCameraHUDMenuButton: (theMenu) ->
    menu = @settings.menu
    x = camera.width / 2 - menu.w / 2 - 5
    y = -camera.height / 2 + menu.h / 2 + 5
    menuButton = new Elements.Button(x, y, menu.w, menu.h)
    menuButton.setClearFunc((ctx) =>
      loc = {x: menuButton.x+camera.width / 2, y: menuButton.y + camera.height / 2}
      ctx.clearRect(loc.x - menuButton.w / 2,
                    loc.y - menuButton.h / 2,
                    menuButton.w, menuButton.h)
    )
    menuButton.setClickHandler(() =>
      if theMenu.visible
        theMenu.close()
      else
        theMenu.open()
    )
    menuButton.setMouseUpHandler(() => menuButton.setDirty())
    menuButton.setMouseDownHandler(() => menuButton.setDirty())
    menuButton.setMouseOutHandler(() => menuButton.setDirty())
    menuButton.setDrawFunc((ctx) =>
      menuButton.x = camera.width / 2 - menu.w / 2 - 5
      menuButton.y = -camera.height / 2 + menu.h / 2 + 5
      loc = {x: menuButton.x+camera.width / 2, y: menuButton.y+camera.height / 2}
      if menuButton.isPressed()
        SHEET.drawSprite(SpriteNames.MENU_BUTTON_HOVER, loc.x, loc.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.MENU_BUTTON_IDLE, loc.x, loc.y, ctx, false)
    )

    cameraHudFrame.addChild(menuButton)

    return menuButton

  createSkipButton: (onSkip) ->
    skip = @settings.skip
    y = camera.height / 2 - skip.h / 2 - 5
    button = new Elements.Button(0, y, skip.w, skip.h)
    button.setClearFunc((ctx) =>
      loc = {x: button.x+camera.width / 2, y: button.y + camera.height / 2}
      ctx.clearRect(loc.x - button.w / 2,
                    loc.y - button.h / 2,
                    button.w, button.h)
    )
    button.setClickHandler(onSkip)
    button.setMouseUpHandler(() => button.setDirty())
    button.setMouseDownHandler(() => button.setDirty())
    button.setMouseOutHandler(() => button.setDirty())
    button.setDrawFunc((ctx) =>
      button.y = camera.height / 2 - skip.h / 2 - 5
      loc = {x: button.x+camera.width / 2, y: button.y + camera.height / 2}
      if button.isPressed()
        SHEET.drawSprite(SpriteNames.SKIP_BUTTON_HOVER, loc.x, loc.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.SKIP_BUTTON_IDLE, loc.x, loc.y, ctx, false)
    )

    cameraHudFrame.addChild(button)

    return button

  createSkipButton: (onSkip) ->
    skip = @settings.skip
    y = camera.height / 2 - skip.h / 2 - 5
    button = new Elements.Button(0, y, skip.w, skip.h)
    button.setClearFunc((ctx) =>
      loc = {x: button.x+camera.width / 2, y: button.y + camera.height / 2}
      ctx.clearRect(loc.x - button.w / 2,
                    loc.y - button.h / 2,
                    button.w, button.h)
    )
    button.setClickHandler(onSkip)
    button.setMouseUpHandler(() => button.setDirty())
    button.setMouseDownHandler(() => button.setDirty())
    button.setMouseOutHandler(() => button.setDirty())
    button.setDrawFunc((ctx) =>
      button.y = camera.height / 2 - skip.h / 2 - 5
      loc = {x: button.x+camera.width / 2, y: button.y + camera.height / 2}
      if button.isPressed()
        SHEET.drawSprite(SpriteNames.SKIP_BUTTON_HOVER, loc.x, loc.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.SKIP_BUTTON_IDLE, loc.x, loc.y, ctx, false)
    )

    cameraHudFrame.addChild(button)

    return button

  _setupMissionMap: ->
    map = {}
    map.planets = []

    p0 = new Planet(0, 0, 10, 2)
    game.addPlanet(p0)

    p1 = new Planet(600, 10, 30, 2)
    game.addPlanet(p1)

    p2 = new Planet(300, 500, 30, 1)
    game.addPlanet(p2)

    p3 = new Planet(-200, 500, 11, 1)
    game.addPlanet(p3)

    p4 = new Planet(900, 500, 33, 1)
    game.addPlanet(p4)

    p5 = new Planet(50, 1000, 19, 1)
    game.addPlanet(p5)

    p6 = new Planet(-200, 1500, 17, 1)
    game.addPlanet(p6)

    p7 = new Planet(300, 1500, 34, 1)
    game.addPlanet(p7)

    p8 = new Planet(-200, 2000, 15, 1)
    game.addPlanet(p8)

    p9 = new Planet(300, 2200, 10, 1)
    game.addPlanet(p9)

    p10 = new Planet(-100, 2500, 20, 1)
    game.addPlanet(p10)

    p11 = new Planet(400, 2700, 16, 1)
    game.addPlanet(p11)

    p12 = new Planet(900, 3200, 42, 1)
    game.addPlanet(p12)

    p13 = new Planet(1300, 3700, 64, 1)
    game.addPlanet(p13)

    p14 = new Planet(1700, 4000, 1, 1)
    game.addPlanet(p14)

    game.setNeighbors(p0, p1)
    game.setNeighbors(p0, p2)
    game.setNeighbors(p0, p3)
    game.setNeighbors(p1, p2)
    game.setNeighbors(p1, p4)
    game.setNeighbors(p2, p3)
    game.setNeighbors(p2, p4)
    game.setNeighbors(p2, p5)
    game.setNeighbors(p3, p5)
    game.setNeighbors(p5, p6)
    game.setNeighbors(p5, p7)
    game.setNeighbors(p6, p7)
    game.setNeighbors(p6, p8)
    game.setNeighbors(p8, p9)
    game.setNeighbors(p8, p10)
    game.setNeighbors(p9, p11)
    game.setNeighbors(p9, p10)
    game.setNeighbors(p10, p11)
    game.setNeighbors(p11, p12)
    game.setNeighbors(p12, p13)
    game.setNeighbors(p13, p14)

    map.planets.push(p0)
    map.planets.push(p1)
    map.planets.push(p2)
    map.planets.push(p3)
    map.planets.push(p4)
    map.planets.push(p5)
    map.planets.push(p6)
    map.planets.push(p7)
    map.planets.push(p8)
    map.planets.push(p9)
    map.planets.push(p10)
    map.planets.push(p11)
    map.planets.push(p12)
    map.planets.push(p13)
    map.planets.push(p14)

    map.home = p0
    map.home2 = p1
    map.station = p9
    map.outpost = p10
    map.probe = p11
    map.fungus_start = p14

    return map
