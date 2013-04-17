#_require Mission

class Menu extends Mission
  reset: ->
    # Load user progress
    #   Add fungus to locked mission planets
    #
    # Create planets:
    #   Home -> Missions, Open, Credits
    #   Missions -> Mission 1, etc.
    #   Open -> Small, Medium, Large
    #   Credits -> ??
    #
    # Planets that leave the menu:
    #   Mission 1, etc
    #   Small, Medium, Large
    #
    # Add probe to Home planet

  draw: (ctx) ->
    # Draw title
    # for each planet
    #   if the planet is visible and the probe is not on it
    #     draw the planet's label
    # if the probe is on a planet of interest
    #   draw prompt to make sure the player wants to play the mission

  onMouseMove: (x, y) ->
    # if drawing a prompt
    #   check mouse position against the button positions

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

  onEndTurn: ->
    # if there is no probe
    #   create one on the last planet it was on
    # else
    #   set the last planet it was on to the current one
    #   for each planet that leaves the menu
    #     if the planet has a probe on it
    #       open prompt for the planet
    # Add the probe to the selected units
