# The Mission class defines a guarenteed layout for each mission. It also
# defines behavior that is common between or frequently used by missions.
class Mission
  settings: window.config.Missions

  # Creates a new mission and sets it up. This should not need to be
  # overwitten.
  constructor: ->
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
      console.log('vis: ' + theMenu.visible)
      if theMenu.visible
        theMenu.close()
      else
        theMenu.open()
    )
    menuButton.setMouseUpHandler(() => menuButton.setDirty())
    menuButton.setMouseDownHandler(() => menuButton.setDirty())
    menuButton.setMouseOutHandler(() => menuButton.setDirty())
    menuButton.setDrawFunc((ctx) =>
      loc = {x: menuButton.x, y: menuButton.y}
      if menuButton.isPressed()
        SHEET.drawSprite(SpriteNames.MENU_BUTTON_HOVER, loc.x, loc.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.MENU_BUTTON_IDLE, loc.x, loc.y, ctx, false)
    )

    frameElement.addChild(menuButton)

    return menuButton