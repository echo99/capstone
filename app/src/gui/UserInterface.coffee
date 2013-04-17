class UserInterface
  constructor: () ->

  draw: (ctx) ->
    # Note: there are alot of things that need to check for hovering and many
    #       of which draw tool tips if they are
    # visited planets = set
    # for each planet
    #   draw planet
    cPos = camera.getPosition()
    cZ = camera.getZoom()
    transX = 100+cPos.x
    transY = 100+cPos.y
    if 0 < transX < camera.width and 0 < transY < camera.height
      SHEET.drawSprite(SpriteNames.PLANET_BLUE, transX, transY, ctx, cZ)
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