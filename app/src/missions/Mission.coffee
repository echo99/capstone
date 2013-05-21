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

  ###
  _createMenu: (settings, onStart, showCancel=true) ->
    cancel = settings.cancel
    start = settings.start
    cancelButton = if showCancel
      new Elements.Button(cancel.x, cancel.y, cancel.w, cancel.h)
    else
      null
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
    if showCancel
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

    startButton = new Elements.Button(start.x, start.y, start.w, start.h)
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
    cameraHudFrame.addChild(menuBox)

    return menuBox
  ###