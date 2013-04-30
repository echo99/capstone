#_require Mission
#_require ../backend/Planet

# This mission acts as our games main menu
class Menu extends Mission
  # @see Mission#reset
  reset: ->
    # Load user progress
    #   Add fungus to locked mission planets
    #
    # Create planets:
    #game.setup(10, null)
    #return
    @Names = ["Home", "Missions", "Mission1", "Mission2", "Mission3",
              "Extermination", "Credits"]
    @Planets =
      Home: new Planet(0, 0)
      Missions: new Planet(0, -400)
      Mission1: new Planet(-400, -750)
      Mission2: new Planet(0, -800)
      Mission3: new Planet(400, -750)
      Extermination: new Planet(400, 150)
      Credits: new Planet(-400, 150)

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
    @Planets.Home._probes = 1
    #@Planets.Missions._probes = 23
    @Planets.Mission1._fungusStrength = 1
    #@Planets.Home._defenseShips = 23

    @lastPlanet = @Planets.Home

    UI.initialize(true)
    camera.setZoom(0.5)

    # Note: The position currently doesn't update if the camera changes
    @mission1Menu = new Elements.MessageBox(camera.width/2, camera.height/2,
                                            300, 200,
                                            "This is the mission 1 message box")
    button = new Elements.Button(100, 170, 101, 20)
    button.setProperty("hover", false)
    button.setClickHandler(() =>
      console.log('clicked mission 1 button')
    )
    button.setHoverHandler(() =>
      button.setProperty("hover", true)
      button.setDirty()
    )
    button.setMouseOutHandler(() =>
      button.setProperty("hover", false)
      button.setDirty()
    )
    button.setDrawFunc((ctx) =>
      loc = @mission1Menu.getActualLocation(button.x, button.y)
      if button.getProperty("hover")
        SHEET.drawSprite(SpriteNames.START_MISSION_BUTTON_HOVER,
                         loc.x, loc.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.START_MISSION_BUTTON_IDLE,
                         loc.x, loc.y, ctx, false)
    )
    button.setZIndex(100)
    @mission1Menu.addChild(button)
    @mission1Menu.close()
    frameElement.addChild(@mission1Menu)

    @exterminationMenu = new Elements.MessageBox(camera.width/2, camera.height/2,
      400, 100, "Exterminate all fungus before it exterminates you.")
    button2 = new Elements.Button(345, 85, 101, 20)
    button2.setProperty("hover", false)
    button2.setClickHandler(() =>
      console.log('clicked extermination button')
    )
    button2.setHoverHandler(() =>
      button2.setProperty("hover", true)
      button2.setDirty()
    )
    button2.setMouseOutHandler(() =>
      button2.setProperty("hover", false)
      button2.setDirty()
    )
    button2.setDrawFunc((ctx) =>
      loc = @exterminationMenu.getActualLocation(button2.x, button2.y)
      if button2.getProperty("hover")
        SHEET.drawSprite(SpriteNames.START_MISSION_BUTTON_HOVER,
                         loc.x, loc.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.START_MISSION_BUTTON_IDLE,
                         loc.x, loc.y, ctx, false)
    )
    button2.setZIndex(100)
    @exterminationMenu.addChild(button2)
    @exterminationMenu.close()
    frameElement.addChild(@exterminationMenu)


  # @see Mission#draw
  draw: (ctx, hudCtx) ->
    SHEET.drawSprite(SpriteNames.TITLE, camera.width/2, 75, ctx, false)

    winStyle = window.config.windowStyle
    ctx.font = winStyle.defaultText.font
    ctx.fillStyle = winStyle.defaultText.color
    ctx.textAlign = 'center'
    for p in @Names
      planet = @Planets[p]
      if planet._probes == 0
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
    if @lastPlanet.numShips(window.config.units.probe) == 0
      game.endTurn()
      UI.endTurn()
      CurrentMission.onEndTurn()
      loc = @lastPlanet.location()
      camera.setTarget(loc.x, loc.y)

    # NOTE: this assumes that the game handle the mouse click first,
    #       if that's not the case this may have to be done differently
    # else if the prompt is being displayed and the mouse is on a button
    #   if cancel button
    #     close prompt
    #   else if play button
    #     CurrentMission = the mission that the planet goes to
    #   else
    #     (other buttons?)

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
      loc = @lastPlanet.location()
      camera.setTarget(loc.x, loc.y)
    #   for each planet that leaves the menu
    #     if the planet has a probe on it
    #       open prompt for the planet
    # Add the probe to the selected units
