#_require Mission
#_require ../backend/Planet

# This mission acts as our games main menu
class Menu extends Mission
  settings: window.config.MainMenu
  # @see Mission#reset
  reset: ->
    # Load user progress
    #   Add fungus to locked mission planets
    #
    # Create planets:
    #game.setup(10, null)
    #return
    newGame(10000, 10000)
    @Names = ["Home", "Missions", "Mission1", "Mission2", "Mission3",
              "Extermination", "Credits"]
    @Planets =
      Home: new Planet(@settings.home.x, @settings.home.y)
      Missions: new Planet(@settings.missions.x, @settings.missions.y)
      Mission1: new Planet(@settings.mission1.x, @settings.mission1.y)
      Mission2: new Planet(@settings.mission2.x, @settings.mission2.y)
      Mission3: new Planet(400, -750)
      Extermination: new Planet(@settings.extermination.x,
                                @settings.extermination.y)
      Credits: new Planet(-400, 150)

    # Set visibilities
    @Planets.Home.setVisibility(window.config.visibility.discovered)
    @Planets.Missions.setVisibility(window.config.visibility.discovered)
    @Planets.Mission1.setVisibility(window.config.visibility.discovered)
    @Planets.Mission2.setVisibility(window.config.visibility.discovered)
    @Planets.Mission3.setVisibility(window.config.visibility.discovered)
    @Planets.Extermination.setVisibility(window.config.visibility.discovered)
    @Planets.Credits.setVisibility(window.config.visibility.discovered)

    # Add planets to game
    game.addPlanet(@Planets.Home)
    game.addPlanet(@Planets.Missions)
    game.addPlanet(@Planets.Mission1)
    game.addPlanet(@Planets.Mission2)
    game.addPlanet(@Planets.Mission3)
    game.addPlanet(@Planets.Extermination)
    game.addPlanet(@Planets.Credits)

    # Add connections to game
    game.setNeighbors(@Planets.Home, @Planets.Missions)
    game.setNeighbors(@Planets.Home, @Planets.Extermination)
    game.setNeighbors(@Planets.Home, @Planets.Credits)
    game.setNeighbors(@Planets.Missions, @Planets.Mission1)
    game.setNeighbors(@Planets.Missions, @Planets.Mission2)
    game.setNeighbors(@Planets.Missions, @Planets.Mission3)

    # Planets that leave the menu:
    #   Mission 1, etc
    #   Small, Medium, Large

    # Add probe to Home planet
    @Planets.Home.addShips(window.config.units.probe, 1)
    #@Planets.Missions._attackShips = 23
    @Planets.Mission2._fungusStrength = 1
    @Planets.Mission3._fungusStrength = 1
    #@Planets.Home._defenseShips = 23

    @lastPlanet = @Planets.Home
    UI.initialize(true, false, false)
    camera.setZoom(0.5)
    camera.setTarget(@Planets.Home.location())

    @_initMenus()
    game.endTurn()

  destroy: ->
    cameraHudFrame.removeChild(@mission1Menu)
    cameraHudFrame.removeChild(@mission2Menu)
    cameraHudFrame.removeChild(@exterminationMenu)
    cameraHudFrame.removeChild(@gameCompleteMenu)

  _initMenus: ->
    @mission1Menu = @_createMenu(@settings.mission1.menu, () =>
      console.log('clicked mission 1 button'))
    @mission2Menu = @_createMenu(@settings.mission2.menu, () =>
      console.log('clicked mission 2 button'))
    @mission3Menu = @_createMenu(@settings.mission3.menu, () =>
      console.log('clicked mission 3 button'))
    @exterminationMenu = @_createMenu(@settings.extermination.menu, () =>
      newMission(Extermination))
    # if they have never seen this menu before:
    close = new Elements.Button(500 - 10, 10, 16, 16,
      () =>
        @gameCompleteMenu.close()
        # TODO: and never open again
    )
    close.setDrawFunc(
      (ctx) =>
        loc = @gameCompleteMenu.getActualLocation(close.x, close.y)
        SHEET.drawSprite(SpriteNames.CLOSE, loc.x, loc.y, ctx, false)
    )
    @gameCompleteMenu = new Elements.MessageBox(0, 0, 500, 100,
      "Congratulations!\n
       You've completed all the missions. If you haven't had enough yet be sure to
       check out Extermination mode. Also, we would love to hear any feedback you
       might have, let us know by clicking the feedback icon in the lower right.",
      {
        closeBtn: close,
        textAlign: 'left',
        vAlign: 'top',
        font: window.config.windowStyle.defaultText.font,
        visible: false
      })
    cameraHudFrame.addChild(@gameCompleteMenu)

  _createMenu: (settings, onStart) ->
    cancel = settings.cancel
    start = settings.start
    cancelButton = new Elements.Button(cancel.x, cancel.y, cancel.w, cancel.h)
    menuBox = new Elements.MessageBox(0, 0,
                                      settings.w, settings.h,
                                      settings.message,
                                      {
                                        closeBtn: cancelButton,
                                        textAlign: settings.textAlign,
                                        vAlign: settings.vAlign,
                                        visible: false
                                      })
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

  # @see Mission#draw
  draw: (ctx, hudCtx) ->
    winStyle = window.config.windowStyle
    ctx.font = winStyle.labelText.font
    ctx.fillStyle = winStyle.labelText.color
    ctx.textAlign = 'center'
    for p in @Names
      planet = @Planets[p]
      if planet.numShips(window.config.units.probe) == 0 and
         planet.visibility() == window.config.visibility.visible
        loc = planet.location()
        coords = {x: loc.x, y: loc.y - 100}
        coords = camera.getScreenCoordinates(coords)
        if camera.onScreen(coords)
          ctx.fillText(p, coords.x, coords.y)
    SHEET.drawSprite(SpriteNames.TITLE, camera.width/2, 30, ctx, false)

  # @see Mission#onMouseMove
  onMouseMove: (x, y) ->
    # if drawing a prompt
    #   check mouse position against the button positions

  # @see Mission#onMouseClick
  onMouseClick: (x, y) ->
    # if the probe has been set to move to a new planet
    #   advance the turn
    inGroup = false
    for c in @lastPlanet.getControlGroups()
      if c.probes() == 1
        inGroup = true
        break
    while inGroup#@lastPlanet.numShips(window.config.units.probe) == 0 or inGroup
      game.endTurn()
      UI.endTurn()
      CurrentMission.onEndTurn()
      inGroup = false
      for c in @lastPlanet.getControlGroups()
        if c.probes() == 1
          inGroup = true
          break
      camera.setTarget(@lastPlanet.location())

    # NOTE: this assumes that the game handle the mouse click first,
    #       if that's not the case this may have to be done differently
    # else if the prompt is being displayed and the mouse is on a button
    #   if cancel button
    #     close prompt
    #   else if play button
    #     CurrentMission = the mission that the planet goes to
    #   else
    #     (other buttons?)

  getHomeTarget: ->
    return @lastPlanet.location()

  # @see Mission#onEndTurn
  onEndTurn: ->
    found = false
    for p in game.getPlanets()
      inGroup = false
      for c in p.getControlGroups()
        if c.probes() == 1
          inGroup = true
          break
      if p.numShips(window.config.units.probe) == 1 or inGroup
        found = true
        @_checkMissions(p)
        break
    if not found
      @lastPlanet._probes = 1
      camera.setTarget(@lastPlanet.location())
      game.endTurn()
      UI.endTurn()
      CurrentMission.onEndTurn()
    #   for each planet that leaves the menu
    #     if the planet has a probe on it
    #       open prompt for the planet
    # Add the probe to the selected units

  _checkMissions: (p) ->
    if p.fungusStrength() == 0
      @lastPlanet = p
      if @lastPlanet == @Planets.Mission1
        @mission1Menu.open()
      else
        @mission1Menu.close()
      if @lastPlanet == @Planets.Mission2
        @mission2Menu.open()
      else
        @mission2Menu.close()
      if @lastPlanet == @Planets.Mission3
        @mission3Menu.open()
      else
        @mission3Menu.close()
      if @lastPlanet == @Planets.Extermination
        @exterminationMenu.open()
      else
        @exterminationMenu.close()