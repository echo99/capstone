class UserInterface
  constructor: () ->

  draw: (ctx) ->
    # Note: there are alot of things that need to check for hovering and many
    #       of which draw tool tips if they are
    # visited planets = set
    # for each planet
    #   draw planet
    SHEET.drawSprite(SpriteNames.PLANET_BLUE, 0, 0, ctx)
    SHEET.drawSprite(SpriteNames.PLANET_BLUE, 200, 0, ctx)
    SHEET.drawSprite(SpriteNames.PLANET_BLUE, -200, 0, ctx)
    SHEET.drawSprite(SpriteNames.PLANET_BLUE, 0, 200, ctx)
    #   if structure
    #     draw structure
    #   if units
    #     draw units
    #   for each control group
    #     if control group is hovered over
    #       draw expanded view
    #     else
    #       draw unexpanded view
    #   for each neighbor
    #     if neighbor is not in visited planets
    #       draw connection to the neighbor
    #   add this planet to visited planets
    #
    # If all planets are off screen
    #   draw text in middle of screen that says something like:
    #   "Pres HOME to return to map"
    #
    # draw HUD
    #
    # for each button
    #   if button is visible (certian buttons aren't always visible)
    #     if button is hovered over
    #       draw hover image
    #     else
    #       draw regular image

  onMouseMove: (x, y) ->
    # for each button
    #   set button to not hover
    #   if (x, y) on button
    #     set button to hover

  onMouseClick: (x, y) ->
    # for each button
    #   if button is hovered over
    #     perform button action