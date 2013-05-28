#_require Mission
#_require ../backend/Planet

# This mission acts as our games main menu
class Menu extends Mission
  settings: window.config.MainMenu
  # @see Mission#reset
  reset: ->
    Logger.logEvent("Starting the Menu")
    # Load user progress
    @progress = localStorage["mission_complete"]
    if not @progress
      @progress = false
      localStorage["mission_complete"] = false
    @seenGameComplete = localStorage["seen_complete"]
    if not @seenGameComplete
      @seenGameComplete = false
      localStorage["seen_complete"] = false

    # Create planets:
    newGame(10000, 10000, true)
    @Names = ["Home", "Tutorial", "Extermination",
              "Small", "Medium", "Large", "Credits"]
    @Planets =
      Home: new Planet(@settings.home.x, @settings.home.y)
      Tutorial: new Planet(@settings.mission.x, @settings.mission.y)
      Extermination: new Planet(@settings.extermination.x,
                                @settings.extermination.y)
      Small: new Planet(@settings.small.x, @settings.small.y)
      Medium: new Planet(@settings.medium.x, @settings.medium.y)
      Large: new Planet(@settings.large.x, @settings.large.y)
      Credits: new Planet(-400, 150)

    # Add planets to game
    game.addPlanet(@Planets.Home)
    game.addPlanet(@Planets.Tutorial)
    game.addPlanet(@Planets.Extermination)
    game.addPlanet(@Planets.Small)
    game.addPlanet(@Planets.Medium)
    game.addPlanet(@Planets.Large)
    game.addPlanet(@Planets.Credits)

    # Add connections to game
    #game.setNeighbors(@Planets.Home, @Planets.Missions)
    game.setNeighbors(@Planets.Home, @Planets.Tutorial)
    game.setNeighbors(@Planets.Home, @Planets.Extermination)
    game.setNeighbors(@Planets.Home, @Planets.Credits)
    game.setNeighbors(@Planets.Extermination, @Planets.Small)
    game.setNeighbors(@Planets.Extermination, @Planets.Medium)
    game.setNeighbors(@Planets.Extermination, @Planets.Large)

    # Add probe to Home planet
    @Planets.Home.addShips(window.config.units.probe, 1)

    @lastPlanet = @Planets.Home
    camera.setZoom(0.1)
    camera.setZoomTarget(0.5)
    camera.setTarget(@Planets.Home.location())

    @_initMenus()
    game.endTurn()
    UI.initialize(true, false, false)

    # Set visibilities
    @Planets.Small.setVisibility(window.config.visibility.discovered)
    @Planets.Medium.setVisibility(window.config.visibility.discovered)
    @Planets.Large.setVisibility(window.config.visibility.discovered)

    @_selectProbe()

  destroy: ->
    cameraHudFrame.removeChild(@missionMenu)
    cameraHudFrame.removeChild(@smallMenu)
    cameraHudFrame.removeChild(@mediumMenu)
    cameraHudFrame.removeChild(@largeMenu)
    cameraHudFrame.removeChild(@creditsMenu)
    if @gameCompleteMenu
      cameraHudFrame.removeChild(@gameCompleteMenu)

    Logger.logEvent("Leaving Main Menu")
    Logger.send()

  _initMenus: ->
    @missionMenu = @_createMenu(@settings.mission.menu,
      () =>
        newMission(Cutscene)
      start=true, restart=false, quit=false, cancel=true, close=false)
    @smallMenu = @_createMenu(@settings.small.menu,
      () =>
        newMission(ExterminationSmall)
      start=true, restart=false, quit=false, cancel=true, close=false)
    @mediumMenu = @_createMenu(@settings.medium.menu,
      () =>
        newMission(ExterminationMedium)
      start=true, restart=false, quit=false, cancel=true, close=false)
    @largeMenu = @_createMenu(@settings.large.menu,
      () =>
        camera.setZoom(0.1)
        newMission(ExterminationLarge)
      start=true, restart=false, quit=false, cancel=true, close=false)
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

    if @progress == 'true' and @seenGameComplete == 'false'
      Logger.logEvent("Showing mission complete menu")
      close = new Elements.Button(500 - 10, 10, 16, 16,
        () =>
          @gameCompleteMenu.close()
          @seenGameComplete = true
          localStorage["seen_complete"] = true
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

    if inGroup
      endTurn()
      camera.setTarget(@lastPlanet.location())
      Logger.logEvent("Moving Main Menu probe to " + @lastPlanet.toString())

  getHomeTarget: ->
    return @lastPlanet.location()

  # @see Mission#onEndTurn
  onEndTurn: ->
    for p in game.getPlanets()
      if p.numShips(window.config.units.probe) == 1
        @_checkMissions(p)
        break

    @_selectProbe()

  _selectProbe: ->
    for p in game.getPlanets()
      units = p.unitSelection
      for row in units.probes
        for stack in row
          if not stack.isSelected() and stack.getCount() > 0
            stack.toggleSelection()

  _checkMissions: (p) ->
    @lastPlanet = p
    if p.sprite() != SpriteNames.PLANET_BLUE_FUNGUS
      if @lastPlanet == @Planets.Tutorial
        Logger.logEvent("Showing mission menu")
        @missionMenu.open()
      else
        @missionMenu.close()
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
