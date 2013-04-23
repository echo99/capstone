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
    @Names = ["Home", "Missions", "Extermination", "Credits"]
    @Planets =
      Home: new Planet(0, 0)
      Missions: new Planet(0, -500)
      Extermination: new Planet(500, 0)
      Credits: new Planet(0, 500)

    # Add planets to game
    game.addPlanet(@Planets.Home)
    game.addPlanet(@Planets.Missions)
    game.addPlanet(@Planets.Extermination)
    game.addPlanet(@Planets.Credits)

    # Add connections to game
    game.setNeighbors(@Planets.Home, @Planets.Missions)
    game.setNeighbors(@Planets.Home, @Planets.Extermination)
    game.setNeighbors(@Planets.Home, @Planets.Credits)

    # Planets that leave the menu:
    #   Mission 1, etc
    #   Small, Medium, Large

    # Add probe to Home planet
    @Planets.Home._probes = 1

    UI.initialize(true)

  # @see Mission#draw
  draw: (ctx, hudCtx) ->
    # Draw title
    SHEET.drawSprite(SpriteNames.TITLE, camera.width/2, 75, ctx, false)
    # for each planet
    winStyle = window.config.windowStyle
    ctx.font = winStyle.defaultText.font
    ctx.fillStyle = winStyle.defaultText.color
    ctx.textAlign = 'center'
    for p in @Names
    #   if the planet is visible and the probe is not on it
      planet = @Planets[p]
      if planet._probes == 0
        loc = planet.location()
        coords = {x: loc.x, y: loc.y - 100}
        coords = camera.getScreenCoordinates(coords)
        if camera.onScreen(coords)
          ctx.fillText(p, coords.x, coords.y)
    #     draw the planet's label
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
    # if there is no probe
    #   create one on the last planet it was on
    # else
    #   set the last planet it was on to the current one
    #   for each planet that leaves the menu
    #     if the planet has a probe on it
    #       open prompt for the planet
    # Add the probe to the selected units
