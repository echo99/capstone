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

    @mission1Menu = {x: 200, y: 200, w: 200, h: 200,
    message: "This is the mission 1 message box"}
    @showMission1Menu = false

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
    if @showMission1Menu
      @showMission1Menu = false
      console.log('showMission1Menu')
      if @menu1
        console.log('menu1')
        @menu1.visible = true
      else
        console.log('not menu1')
        @menu1 = new Elements.MessageBox(@mission1Menu.x, @mission1Menu.y,
                                         @mission1Menu.w, @mission1Menu.y,
                                         @mission1Menu.message, ctx)
        @mission1Button = new Elements.Button(300, 300, 100, 50)
        @mission1Button.setProperty("hover", false)
        @mission1Button.setClickHandler(() =>
          console.log('clicked mission 1 button')
        )
        @mission1Button.setHoverHandler(() =>
          @mission1Button.setProperty("hover", true)
          @mission1Button.setDirty()
        )
        @mission1Button.setMouseOutHandler(() =>
          @mission1Button.setProperty("hover", false)
          @mission1Button.setDirty()
        )
        @mission1Button.setDrawFunc((ctx) =>
          x = @mission1Button.x
          y = @mission1Button.y
          if @mission1Button.getProperty("hover")
            SHEET.drawSprite(SpriteNames.END_TURN_BUTTON_HOVER, x, y, ctx, false)
          else
            SHEET.drawSprite(SpriteNames.END_TURN_BUTTON_IDLE, x, y, ctx, false)
        )
        @mission1Button.setZIndex(100)
        frameElement.addChild(@mission1Button)

        frameElement.addChild(@menu1)

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
      if @lastPlanet == @Planets.Mission1
        @showMission1Menu = true
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
      if p.numShips(window.config.units.probe) == 1
        found = true
        @lastPlanet = p
        break
    if not found
      @lastPlanet._probes = 1
    #   for each planet that leaves the menu
    #     if the planet has a probe on it
    #       open prompt for the planet
    # Add the probe to the selected units
