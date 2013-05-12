#_require Mission
#_require ../backend/Planet

# This mission acts as our games main menu
class Menu extends Mission
  settings: window.config.MainMenu
  numMissions: 3
  # @see Mission#reset
  reset: ->
    Logger.logEvent("Starting the Menu")
    # Load user progress
    @progress = localStorage["progress"]
    if not @progress
      @progress = 1
      localStorage["progress"] = 1
    @seenGameComplete = localStorage["complete"]
    if not @seenGameComplete
      @seenGameComplete = false
      localStorage["complete"] = false

    # Create planets:
    newGame(10000, 10000, true)
    @Names = ["Home", "Missions", "Mission 1", "Mission 2", "Mission 3",
              "Extermination", "Small", "Medium", "Large", "Credits"]
    @Planets =
      Home: new Planet(@settings.home.x, @settings.home.y)
      Missions: new Planet(@settings.missions.x, @settings.missions.y)
      Mission1: new Planet(@settings.mission1.x, @settings.mission1.y)
      Mission2: new Planet(@settings.mission2.x, @settings.mission2.y)
      Mission3: new Planet(@settings.mission3.x, @settings.mission3.y)
      Extermination: new Planet(@settings.extermination.x,
                                @settings.extermination.y)
      Small: new Planet(@settings.small.x, @settings.small.y)
      Medium: new Planet(@settings.medium.x, @settings.medium.y)
      Large: new Planet(@settings.large.x, @settings.large.y)
      Credits: new Planet(-400, 150)

    # Set visibilities
    @Planets.Home.setVisibility(window.config.visibility.discovered)
    @Planets.Missions.setVisibility(window.config.visibility.discovered)
    @Planets.Mission1.setVisibility(window.config.visibility.discovered)
    @Planets.Mission2.setVisibility(window.config.visibility.discovered)
    @Planets.Mission3.setVisibility(window.config.visibility.discovered)
    @Planets.Extermination.setVisibility(window.config.visibility.discovered)
    @Planets.Small.setVisibility(window.config.visibility.discovered)
    @Planets.Medium.setVisibility(window.config.visibility.discovered)
    @Planets.Large.setVisibility(window.config.visibility.discovered)
    @Planets.Credits.setVisibility(window.config.visibility.discovered)

    if @progress < 2
      @Planets.Mission2.setSprite(SpriteNames.PLANET_BLUE_FUNGUS)
    if @progress < 3
      @Planets.Mission3.setSprite(SpriteNames.PLANET_BLUE_FUNGUS)
    # TODO: other missions

    # Add planets to game
    game.addPlanet(@Planets.Home)
    game.addPlanet(@Planets.Missions)
    game.addPlanet(@Planets.Mission1)
    game.addPlanet(@Planets.Mission2)
    game.addPlanet(@Planets.Mission3)
    game.addPlanet(@Planets.Extermination)
    game.addPlanet(@Planets.Small)
    game.addPlanet(@Planets.Medium)
    game.addPlanet(@Planets.Large)
    game.addPlanet(@Planets.Credits)

    # Add connections to game
    game.setNeighbors(@Planets.Home, @Planets.Missions)
    game.setNeighbors(@Planets.Home, @Planets.Extermination)
    game.setNeighbors(@Planets.Home, @Planets.Credits)
    game.setNeighbors(@Planets.Missions, @Planets.Mission1)
    game.setNeighbors(@Planets.Missions, @Planets.Mission2)
    game.setNeighbors(@Planets.Missions, @Planets.Mission3)
    game.setNeighbors(@Planets.Extermination, @Planets.Small)
    game.setNeighbors(@Planets.Extermination, @Planets.Medium)
    game.setNeighbors(@Planets.Extermination, @Planets.Large)

    # Add probe to Home planet
    @Planets.Home.addShips(window.config.units.probe, 1)

    @lastPlanet = @Planets.Home
    camera.setZoom(0.5)
    camera.setTarget(@Planets.Home.location())

    @_initMenus()
    game.endTurn()
    UI.initialize(true, false, false)

  destroy: ->
    cameraHudFrame.removeChild(@mission1Menu)
    cameraHudFrame.removeChild(@mission2Menu)
    cameraHudFrame.removeChild(@mission3Menu)
    cameraHudFrame.removeChild(@smallMenu)
    cameraHudFrame.removeChild(@mediumMenu)
    cameraHudFrame.removeChild(@largeMenu)
    cameraHudFrame.removeChild(@creditsMenu)
    if @gameCompleteMenu
      cameraHudFrame.removeChild(@gameCompleteMenu)

    Logger.logEvent("Leaving Main Menu")
    Logger.send()

  _initMenus: ->
    @mission1Menu = @_createMenu(@settings.mission1.menu, () =>
      newMission(Mission1))
    @mission2Menu = @_createMenu(@settings.mission2.menu, () =>
      newMission(Mission2))
    @mission3Menu = @_createMenu(@settings.mission3.menu, () =>
      newMission(Mission3))
    @smallMenu = @_createMenu(@settings.small.menu, () =>
      newMission(ExterminationSmall))
    @mediumMenu = @_createMenu(@settings.medium.menu, () =>
      newMission(ExterminationMedium))
    @largeMenu = @_createMenu(@settings.large.menu, () =>
      newMission(ExterminationLarge))

    c = new Elements.Button(200 - 10, 10, 16, 16,
      () =>
        @creditsMenu.close()
    )
    c.setDrawFunc(
      (ctx) =>
        loc = @creditsMenu.getActualLocation(c.x, c.y)
        SHEET.drawSprite(SpriteNames.CLOSE, loc.x, loc.y, ctx, false)
    )
    message = "Credits\n\n" +
              "Design and Programming:\n" +
              "    Erik Chou\n" +
              "    Brandon Edgren\n" +
              "    Ian Johnson\n" +
              "    Raymond Zhang\n\n" +
              "Art:\n" +
              "    Brandon Edgren\n\n" +
              "Sound:\n" +
              "    Erik Chou"
    @creditsMenu = new Elements.MessageBox(0, 0, 200, 250, message,
      {
        closeBtn: c,
        textAlign: 'left',
        vAlign: 'top',
        font: window.config.windowStyle.defaultText.font,
        lineHeight: 17
        visible: false
      })
    cameraHudFrame.addChild(@creditsMenu)

    if @progress > @numMissions and @seenGameComplete == 'false'
      Logger.logEvent("Showing mission complete menu")
      close = new Elements.Button(500 - 10, 10, 16, 16,
        () =>
          @gameCompleteMenu.close()
          @seenGameComplete = true
          localStorage["complete"] = true
      )
      close.setDrawFunc(
        (ctx) =>
          loc = @gameCompleteMenu.getActualLocation(close.x, close.y)
          SHEET.drawSprite(SpriteNames.CLOSE, loc.x, loc.y, ctx, false)
      )
      message = "Congratulations!\n\nYou've completed all the missions. If you " +
                "haven't had enough yet be sure to check out Extermination mode. " +
                "Also, we would love to hear any feedback you might have, let us " +
                "know by clicking the feedback icon in the lower right."
      @gameCompleteMenu = new Elements.MessageBox(0, 0, 500, 100, message,
        {
          closeBtn: close,
          textAlign: 'left',
          vAlign: 'top',
          font: window.config.windowStyle.defaultText.font,
          lineHeight: 17
          visible: false
        })
      cameraHudFrame.addChild(@gameCompleteMenu)
      @gameCompleteMenu.open()

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
                                        font: settings.font
                                        lineHeight: settings.lineHeight,
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
      if p == "Mission 1"
        planet = @Planets["Mission1"]
      else if p == "Mission 2"
        planet = @Planets["Mission2"]
      else if p == "Mission 3"
        planet = @Planets["Mission3"]
      else
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

    if inGroup
      endTurn()
      camera.setTarget(@lastPlanet.location())
      Logger.logEvent("Moving Main Menu probe to " + @lastPlanet.toString())

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
      @Planets.Missions.addShips(window.config.units.probe, 1)
      @lastPlanet = @Planets.Missions
      camera.setTarget(@lastPlanet.location())
      endTurn()

  _checkMissions: (p) ->
    @lastPlanet = p
    if p.sprite() != SpriteNames.PLANET_BLUE_FUNGUS #p.fungusStrength() == 0
      if @lastPlanet == @Planets.Mission1
        Logger.logEvent("Showing mission 1 menu")
        @mission1Menu.open()
      else
        @mission1Menu.close()
      if @lastPlanet == @Planets.Mission2
        Logger.logEvent("Showing mission 2 menu")
        @mission2Menu.open()
      else
        @mission2Menu.close()
      if @lastPlanet == @Planets.Mission3
        Logger.logEvent("Showing mission 3 menu")
        @mission3Menu.open()
      else
        @mission3Menu.close()
      if @lastPlanet == @Planets.Small
        Logger.logEvent("Showing extermination small menu")
        @smallMenu.open()
      else
        @smallMenu.close()
      if @lastPlanet == @Planets.Medium
        Logger.logEvent("Showing extermination medium menu")
        @mediumMenu.open()
      else
        @mediumMenu.close()
      if @lastPlanet == @Planets.Large
        Logger.logEvent("Showing extermination large menu")
        @largeMenu.open()
      else
        @largeMenu.close()
      if @lastPlanet == @Planets.Credits
        Logger.logEvent("Showing credits")
        @creditsMenu.open()
      else
        @creditsMenu.close()
