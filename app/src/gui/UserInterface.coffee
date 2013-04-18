class UserInterface
  constructor: () ->

  draw: (ctx) ->
    # Note: there are alot of things that need to check for hovering and many
    #       of which draw tool tips if they are
    # visited planets = set
    # for each planet
    for p in game._planets
    #   draw planet
      SHEET.drawSprite(SpriteNames.PLANET_BLUE, p._x, p._y, ctx)
      if p._probes > 0
        SHEET.drawSprite(SpriteNames.PROBE, p._x+100, p._y-50, ctx)
    ###
    SHEET.drawSprite(SpriteNames.PLANET_BLUE, 0, 0, ctx)
    SHEET.drawSprite(SpriteNames.WARP_GATE, 0, 0, ctx)
    SHEET.drawSprite(SpriteNames.PROBE, 100, -50, ctx)
    SHEET.drawSprite(SpriteNames.ATTACK_SHIP, 100, 0, ctx)

    SHEET.drawSprite(SpriteNames.PLANET_BLUE, 200, 300, ctx)
    SHEET.drawSprite(SpriteNames.OUTPOST_GATHERING, 200, 300, ctx)


    SHEET.drawSprite(SpriteNames.PLANET_BLUE, -200, 400, ctx)
    SHEET.drawSprite(SpriteNames.STATION_CONSTRUCTING, -200, 400, ctx)
    SHEET.drawSprite(SpriteNames.PROBE_CONSTRUCTION, -200, 400, ctx)
    SHEET.drawSprite(SpriteNames.STATION_BUILDINGS_GATHERING, -200, 400, ctx)

    SHEET.drawSprite(SpriteNames.PLANET_BLUE, 600, -200, ctx)
    ###
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