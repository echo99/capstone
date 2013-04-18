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
    #   Home -> Missions, Open, Credits
    p = [new Planet(0, 0), new Planet(0, -500), new Planet(500, 0),
         new Planet(0, 500)]
    p[0]._probes = 1
    @Planets =
      Home: p[0]
      Missions: p[1]
      Open: p[2]
      Credits: p[3]
    @Ps = [[[p[0]._x, p[0]._y], "Home"], [[p[1]._x, p[1]._y], "Missions"],
           [[p[2]._x, p[2]._y], "Open"], [[p[3]._x, p[3]._y], "Credits"]]
    game.setGraph(p)
    connections = [
      [@Planets.Home, @Planets.Missons],
      [@Planets.Home, @Planets.Open],
      [@Planets.Home, @Planets.Credits]
    ]
    #   Missions -> Mission 1, etc.
    #   Open -> Small, Medium, Large
    #   Credits -> ??
    #
    # Add planets and connections to game
    # Planets that leave the menu:
    #   Mission 1, etc
    #   Small, Medium, Large
    #
    # Add probe to Home planet

  # @see Mission#draw
  draw: (ctx) ->
    # Draw title
    SHEET.drawSprite(SpriteNames.TITLE, camera.width/2, 75, ctx, false)
    # for each planet
    winStyle = window.config.windowStyle
    ctx.font = winStyle.defaultText.font
    ctx.fillStyle = winStyle.defaultText.color
    ctx.textAlign = 'center'
    for p in @Ps
    #   if the planet is visible and the probe is not on it
      if @Planets[p[1]]._probes == 0
        coords = {x: p[0][0], y: p[0][1] - 100}
        coords = camera.getScreenCoordinates(coords)
        ctx.fillText(p[1], coords.x, coords.y)
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
