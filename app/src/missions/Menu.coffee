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
      Mission2: new Planet(0, -800)
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
    @Planets.Mission1._fungusStrength = 1
    #@Planets.Home._defenseShips = 23

    @lastPlanet = @Planets.Home
    UI.initialize(true, false)
    camera.setZoom(0.5)
    camera.setTarget(@Planets.Home.location())

    @_initMenus()
    game.setup(0, null)

  destroy: ->
    cameraHudFrame.removeChild(@mission1Menu)
    cameraHudFrame.removeChild(@exterminationMenu)

  _initMenus: ->
    @mission1Menu = @_createMenu(@settings.mission1.menu, () =>
      console.log('clicked mission 1 button'))
    @exterminationMenu = @_createMenu(@settings.extermination.menu, () =>
      console.log('clicked extermination button')
      newMission(Extermination))

  _createMenu: (settings, onStart) ->
    cancel = settings.cancel
    start = settings.start
    cancelButton = new Elements.Button(cancel.x, cancel.y, cancel.w, cancel.h)
    menuBox = new Elements.MessageBox(0, 0,
                                      settings.w, settings.h,
                                      settings.message,
                                      cancelButton,
                                      settings.textAlign,
                                      settings.vAlign)
    cancelButton.setClickHandler(() =>
      menuBox.close()
    )
    cancelButton.setMouseUpHandler(() =>
      cancelButton.setDirty()
    )
    cancelButton.setMouseDownHandler(() =>
      cancelButton.setDirty()
    )
    cancelButton.setMouseOutHandler(() =>
      cancelButton.setDirty()
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
    startButton.setMouseUpHandler(() =>
      startButton.setDirty()
    )
    startButton.setMouseDownHandler(() =>
      startButton.setDirty()
    )
    startButton.setMouseOutHandler(() =>
      startButton.setDirty()
    )
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
    menuBox.close()
    cameraHudFrame.addChild(menuBox)

    return menuBox

  # @see Mission#draw
  draw: (ctx, hudCtx) ->
    SHEET.drawSprite(SpriteNames.TITLE, camera.width/2, 75, ctx, false)

    winStyle = window.config.windowStyle
    ctx.font = winStyle.defaultText.font
    ctx.fillStyle = winStyle.defaultText.color
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

    # if the probe is on a planet of interest
    #   draw prompt to make sure the player wants to play the mission

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
      camera.setTarget(@lastPlanet.location())
      inGroup = false
      for c in @lastPlanet.getControlGroups()
        if c.probes() == 1
          inGroup = true
          break

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
        @lastPlanet = p
        if @lastPlanet == @Planets.Mission1
          @mission1Menu.visible = true
        else
          @mission1Menu.close()
        if @lastPlanet == @Planets.Extermination
          @exterminationMenu.visible = true
        else
          @exterminationMenu.close()
        break
    if not found
      @lastPlanet._probes = 1
      camera.setTarget(@lastPlanet.location)
    #   for each planet that leaves the menu
    #     if the planet has a probe on it
    #       open prompt for the planet
    # Add the probe to the selected units
