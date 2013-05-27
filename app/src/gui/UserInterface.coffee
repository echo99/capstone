#_require UnitSelection

# This class is resposible for drawing the game state and handling user
# input related to the game directly.
# TODO:
#   - Deselect all units button (this might not be needed actually
class UserInterface
  planetButtons: []
  hoveredPlanet: null
  selectedPlanet: null
  lastMousePos: {x: 0, y: 0}
  unitSelection: null
  switchedMenus: false
  hoveredGroup: null
  turns: 0
  lookingToSendResources: false
  lookingToSetRally: false
  carrierCount: 0
  movingElements: []
  showAll: false

  # Creates a new UserInterface
  constructor: () ->
    @unitSelection = new UnitSelection()
    b = new Elements.Button(5 + 133/2, camera.height + 5 - 20/2, 133, 20)
    b.setClickHandler(() =>
      endTurn()
    )
    b.setClearFunc((ctx) => ctx.clearRect(b.x - b.w/2, b.y - b.h/2, b.w, b.h))
    b.setMouseUpHandler(() => b.setDirty())
    b.setMouseDownHandler(() => b.setDirty())
    b.setMouseOutHandler(() => b.setDirty())
    b.setHoverHandler(() => b.setDirty())
    b.setDrawFunc((ctx) =>
      b.y = camera.height-5-10
      if b.isPressed()
        SHEET.drawSprite(SpriteNames.END_TURN_BUTTON_HOVER, b.x, b.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.END_TURN_BUTTON_IDLE, b.x, b.y, ctx, false)

      if not CurrentMission.canEndTurn()
        ctx.strokeStyle = "rgb(255, 0, 0)"
        ctx.lineWidth = 2
        ctx.beginPath()
        ctx.moveTo(b.x - 50, b.y - 9)
        ctx.lineTo(b.x + 50, b.y + 9)

        ctx.moveTo(b.x - 50, b.y + 9)
        ctx.lineTo(b.x + 50, b.y - 9)
        ctx.stroke()
    )
    b.setZIndex(100)
    frameElement.addChild(b)
    @endTurnButton = b

    @nextStationButton = new Elements.Button(5 + 150/2, 230, 150, 20)
    @nextStationButton.setClearFunc((ctx) =>
      ctx.clearRect(5, 230 - 10, 150, 20)
    )
    @nextStationButton.setClickHandler(() => @gotoNextStation())
    @nextStationButton.setMouseUpHandler(() => @nextStationButton.setDirty())
    @nextStationButton.setMouseDownHandler(() => @nextStationButton.setDirty())
    @nextStationButton.setMouseOutHandler(() => @nextStationButton.setDirty())
    @nextStationButton.setHoverHandler(() => @nextStationButton.setDirty())
    @nextStationButton.setDrawFunc((ctx) =>
      if @nextStationButton.isPressed()
        SHEET.drawSprite(SpriteNames.NEXT_STATION_BUTTON_HOVER,
                         @nextStationButton.x, @nextStationButton.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.NEXT_STATION_BUTTON_IDLE,
                         @nextStationButton.x, @nextStationButton.y, ctx, false)
    )
    @nextStationButton.setZIndex(100)
    @nextStationButton.visible = false
    frameElement.addChild(@nextStationButton)

    @help = new Elements.MessageBox(0, 0, 300, 50,
      "Press HOME to return", {zIndex: 10})
    @help.visible = false
    cameraHudFrame.addChild(@help)

    winStyle = window.config.windowStyle
    stationStyle = window.config.stationMenuStyle
    loc = stationStyle.location
    w = stationStyle.width
    h = stationStyle.height
    @stationMenu = new Elements.BoxElement(loc.x+w/2, loc.y+h/2, w, h)
    @stationMenu.setDrawFunc(@_drawStationMenu)
    @stationMenu.setClearFunc(@_clearMenu(stationStyle))

    stationStyle = window.config.stationMenuStyle
    x = stationStyle.vert1x + winStyle.lineWidth
    y = winStyle.lineWidth / 2
    w = (stationStyle.vert2x - winStyle.lineWidth / 2) - x
    h = (stationStyle.height / 2 - winStyle.lineWidth / 2) - y
    probeButton = @_getStationButton(x, y, w, h, window.config.units.probe)

    x = stationStyle.vert1x + winStyle.lineWidth
    y = stationStyle.height / 2 + winStyle.lineWidth / 2
    w = (stationStyle.vert2x - winStyle.lineWidth / 2) - x
    h = (stationStyle.height - winStyle.lineWidth / 2) - y
    colonyButton = @_getStationButton(x, y, w, h, window.config.units.colonyShip)

    x = stationStyle.vert2x + winStyle.lineWidth / 2
    y = winStyle.lineWidth / 2
    w = (stationStyle.vert3x - winStyle.lineWidth / 2) - x
    h = (stationStyle.height / 2 - winStyle.lineWidth / 2) - y
    attackButton = @_getStationButton(x, y, w, h, window.config.units.attackShip)

    x = stationStyle.vert2x + winStyle.lineWidth / 2
    y = stationStyle.height / 2 + winStyle.lineWidth / 2
    w = (stationStyle.vert3x - winStyle.lineWidth / 2) - x
    h = (stationStyle.height - winStyle.lineWidth / 2) - y
    defenseButton = @_getStationButton(x, y, w, h, window.config.units.defenseShip)

    x = stationStyle.rallyLoc.x
    y = stationStyle.rallyLoc.y
    w = stationStyle.rallySize.w
    h = stationStyle.rallySize.h
    stationRally = new Elements.Button(x, y, w, h)
    stationRally.setProperty("location",
      @stationMenu.getActualLocation(stationRally.x, stationRally.y))
    stationRally.setClickHandler(() =>
      @lookingToSetRally = true
    )
    stationRally.setDrawFunc((ctx) =>
      loc = stationRally.getProperty("location")
      if stationRally.isPressed()
        SHEET.drawSprite(SpriteNames.RALLY_BUTTON_HOVER,
                         loc.x, loc.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.RALLY_BUTTON_IDLE,
                         loc.x, loc.y, ctx, false)
    )
    stationRally.visible = true

    x = stationStyle.cancelRallyLoc.x
    y = stationStyle.cancelRallyLoc.y
    w = stationStyle.cancelRallySize.w
    h = stationStyle.cancelRallySize.h
    stationCancelRally = new Elements.Button(x, y, w, h)
    stationCancelRally.setProperty("location",
      @stationMenu.getActualLocation(stationCancelRally.x, stationCancelRally.y))
    stationCancelRally.setClickHandler(() =>
      @lookingToSetRally = false
    )
    stationCancelRally.setDrawFunc((ctx) =>
      loc = stationCancelRally.getProperty("location")
      if stationCancelRally.isPressed()
        SHEET.drawSprite(SpriteNames.CANCEL_BUTTON_HOVER,
                         loc.x, loc.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.CANCEL_BUTTON_IDLE,
                         loc.x, loc.y, ctx, false)
    )
    stationCancelRally.visible = false

    x = stationStyle.cancelLoc.x
    y = stationStyle.cancelLoc.y
    w = stationStyle.cancelSize.w
    h = stationStyle.cancelSize.h
    cancelBuild = new Elements.Button(x, y, w, h)
    cancelBuild.setProperty("location",
      @stationMenu.getActualLocation(cancelBuild.x, cancelBuild.y))
    cancelBuild.setClickHandler(() =>
      @selectedPlanet.cancelConstruction()
    )
    cancelBuild.setDrawFunc((ctx) =>
      loc = cancelBuild.getProperty("location")
      if cancelBuild.isPressed()
        SHEET.drawSprite(SpriteNames.CANCEL_BUTTON_HOVER,
                         loc.x, loc.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.CANCEL_BUTTON_IDLE,
                         loc.x, loc.y, ctx, false)
    )
    cancelBuild.visible = false
    @stationMenu.addChild(probeButton)
    @stationMenu.addChild(colonyButton)
    @stationMenu.addChild(attackButton)
    @stationMenu.addChild(defenseButton)
    @stationMenu.addChild(cancelBuild)
    @stationMenu.addChild(stationRally)
    @stationMenu.addChild(stationCancelRally)
    @stationMenu.setProperty("cancelButton", cancelBuild)
    @stationMenu.setProperty("cancelOpen", false)
    @stationMenu.setProperty("rallyButton", stationRally)
    @stationMenu.setProperty("rallyOpen", true)
    @stationMenu.setProperty("cancelRallyButton", stationCancelRally)
    @stationMenu.setProperty("cancelRallyOpen", false)
    @stationMenu.visible = false
    frameElement.addChild(@stationMenu)

    outpostStyle = window.config.outpostMenuStyle
    loc = outpostStyle.location
    w = outpostStyle.width
    h = outpostStyle.height
    @outpostMenu = new Elements.BoxElement(loc.x+w/2, loc.y+h/2, w, h)
    @outpostMenu.setDrawFunc(@_drawOutpostMenu)
    @outpostMenu.setClearFunc(@_clearMenu(outpostStyle))

    x = winStyle.lineWidth / 2
    y = outpostStyle.horiz1y + winStyle.lineWidth / 2
    w = (outpostStyle.width - winStyle.lineWidth / 2) - x
    h = (outpostStyle.height - winStyle.lineWidth / 2) - y
    @stationButton = @_getStationButton(x, y, w, h,
                                        window.config.structures.station)
    x = outpostStyle.cancelLoc.x
    y = outpostStyle.cancelLoc.y
    w = outpostStyle.cancelSize.w
    h = outpostStyle.cancelSize.h
    cancelConstS = new Elements.Button(x, y, w, h)
    cancelConstS.setProperty("location",
      @outpostMenu.getActualLocation(cancelConstS.x, cancelConstS.y))
    cancelConstS.setClickHandler(() =>
      @selectedPlanet.cancelConstruction()
    )
    cancelConstS.setDrawFunc((ctx) =>
      loc = cancelConstS.getProperty("location")
      if cancelConstS.isPressed()
        SHEET.drawSprite(SpriteNames.CANCEL_BUTTON_HOVER,
                         loc.x, loc.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.CANCEL_BUTTON_IDLE,
                         loc.x, loc.y, ctx, false)
    )
    cancelConstS.visible = false

    x = outpostStyle.sendLoc.x
    y = outpostStyle.sendLoc.y
    w = outpostStyle.sendSize.w
    h = outpostStyle.sendSize.h
    outpostSend = new Elements.Button(x, y, w, h)
    outpostSend.setProperty("location",
      @outpostMenu.getActualLocation(outpostSend.x, outpostSend.y))
    outpostSend.setClickHandler(() =>
      @selectedPlanet.sending = true
      @lookingToSendResources = true
    )
    outpostSend.setDrawFunc((ctx) =>
      loc = outpostSend.getProperty("location")
      if outpostSend.isPressed()
        SHEET.drawSprite(SpriteNames.SEND_RESOURCES_BUTTON_HOVER,
                         loc.x, loc.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.SEND_RESOURCES_BUTTON_IDLE,
                         loc.x, loc.y, ctx, false)
    )
    outpostSend.visible = true

    x = outpostStyle.stopLoc.x
    y = outpostStyle.stopLoc.y
    w = outpostStyle.stopSize.w
    h = outpostStyle.stopSize.h
    outpostStop = new Elements.Button(x, y, w, h)
    outpostStop.setProperty("location",
      @outpostMenu.getActualLocation(outpostStop.x, outpostStop.y))
    outpostStop.setClickHandler(() =>
      @selectedPlanet.sending = false
      if not @lookingToSendResources
        @selectedPlanet.stopSendingResources()
      @lookingToSendResources = false
    )
    outpostStop.setDrawFunc((ctx) =>
      loc = outpostStop.getProperty("location")
      if outpostStop.isPressed()
        SHEET.drawSprite(SpriteNames.STOP_SENDING_BUTTON_HOVER,
                         loc.x, loc.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.STOP_SENDING_BUTTON_IDLE,
                         loc.x, loc.y, ctx, false)
    )
    outpostStop.visible = false
    @outpostMenu.addChild(@stationButton)
    @outpostMenu.addChild(cancelConstS)
    @outpostMenu.addChild(outpostSend)
    @outpostMenu.addChild(outpostStop)
    @outpostMenu.setProperty("cancelButton", cancelConstS)
    @outpostMenu.setProperty("cancelOpen", false)
    @outpostMenu.setProperty("sendButton", outpostSend)
    @outpostMenu.setProperty("sendOpen", true)
    @outpostMenu.setProperty("stopButton", outpostStop)
    @outpostMenu.setProperty("stopOpen", true)
    @outpostMenu.visible = false
    frameElement.addChild(@outpostMenu)

    colonyStyle = window.config.colonyMenuStyle
    loc = colonyStyle.location
    w = colonyStyle.width
    h = colonyStyle.height
    @colonyMenu = new Elements.BoxElement(loc.x+w/2, loc.y+h/2, w, h)
    @colonyMenu.setDrawFunc(@_drawColonyMenu)
    @colonyMenu.setClearFunc(@_clearMenu(colonyStyle))

    x = winStyle.lineWidth / 2
    y = colonyStyle.horiz1y + winStyle.lineWidth / 2
    w = (colonyStyle.width - winStyle.lineWidth / 2) - x
    h = (colonyStyle.height - winStyle.lineWidth / 2) - y
    @outpostButton = @_getStationButton(x, y, w, h,
                                       window.config.structures.outpost, true)
    x = colonyStyle.cancelLoc.x
    y = colonyStyle.cancelLoc.y
    w = colonyStyle.cancelSize.w
    h = colonyStyle.cancelSize.h
    cancelConstO = new Elements.Button(x, y, w, h)
    cancelConstO.setProperty("location",
      @colonyMenu.getActualLocation(cancelConstO.x, cancelConstO.y))
    cancelConstO.setClickHandler(() =>
      @selectedPlanet.cancelConstruction()
      @endTurn()
      @turns--
    )
    cancelConstO.setDrawFunc((ctx) =>
      loc = cancelConstO.getProperty("location")
      if cancelConstO.isPressed()
        SHEET.drawSprite(SpriteNames.CANCEL_BUTTON_HOVER,
                         loc.x, loc.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.CANCEL_BUTTON_IDLE,
                         loc.x, loc.y, ctx, false)
    )
    cancelConstO.visible = false

    @colonyMenu.addChild(@outpostButton)
    @colonyMenu.addChild(cancelConstO)
    @colonyMenu.setProperty("cancelButton", cancelConstO)
    @colonyMenu.setProperty("cancelOpen", false)
    @colonyMenu.visible = false
    frameElement.addChild(@colonyMenu)

    @turnCounter = new Elements.BoxElement(155, camera.height + 5 - 20/2, 30, 20)
    clear = (ctx) =>
      w = @turnCounter.w
      h = @turnCounter.h
      x = @turnCounter.x - w / 2
      y = @turnCounter.y - h / 2
      ctx.clearRect(x, y, w, h)

    @turnCounter.setClearFunc(clear)
    @turnCounter.setDrawFunc((ctx) =>
      clear(ctx)
      @turnCounter.y = camera.height-5-10
      ctx.textAlign = 'center'
      ctx.textBaseline = 'middle'
      ctx.font = window.config.windowStyle.defaultText.font
      ctx.fillStyle = window.config.windowStyle.defaultText.color
      ctx.fillText(@turns, @turnCounter.x, @turnCounter.y)
    )
    frameElement.addChild(@turnCounter)

    # TODO: remove when done with beta
    @beta = new Elements.BoxElement(camera.width - 5, 25, 0, 20)
    clearBeta = (ctx) =>
      w = ctx.measureText("Beta").width + 5
      h = @beta.h
      x = @beta.x - w
      y = @beta.y
      ctx.clearRect(x, y, w, h)
    @beta.setClearFunc(clearBeta)
    @beta.setDrawFunc((ctx) =>
      clearBeta(ctx)
      @beta.x = camera.width - 5
      ctx.textAlign = 'right'
      ctx.textBaseline = 'top'
      ctx.font = window.config.windowStyle.titleText.font
      ctx.fillStyle = window.config.windowStyle.titleText.color
      ctx.fillText("Beta", @beta.x, @beta.y)
    )
    frameElement.addChild(@beta)

  _getStationButton: (x, y, w, h, unit, probes=false) ->
    button = new Elements.Button(x+w/2, y+h/2, w, h)
    button.setProperty("location",
      @stationMenu.getActualLocation(button.x, button.y))
    button.setClickHandler(() =>
      if (probes and
          @selectedPlanet.numShips(window.config.units.probe) < unit.cost) or
          (not probes and @selectedPlanet.availableResources() < unit.cost)
      else if @selectedPlanet.buildUnit() != null
      else
        if unit == window.config.structures.station
          @selectedPlanet.scheduleStation()
        else if unit == window.config.structures.outpost
          @selectedPlanet.scheduleOutpost()
          if probes
            @unitSelection.updateSelection(@selectedPlanet)
        else
          @selectedPlanet.build(unit)
    )
    button.setDrawFunc((ctx) =>
      loc = button.getProperty("location")
      if (probes and
          @selectedPlanet.numShips(window.config.units.probe) < unit.cost) or
          (not probes and @selectedPlanet.availableResources() < unit.cost)
        ctx.strokeStyle = window.config.unitDisplay.red
      else if @selectedPlanet.buildUnit() != null
        ctx.strokeStyle = window.config.unitDisplay.orange
      else
        ctx.strokeStyle = window.config.unitDisplay.stroke
      ctx.lineWidth = window.config.unitDisplay.lineWidth
      ctx.lineJoin = window.config.unitDisplay.lineJoin
      x = loc.x
      y = loc.y
      w = button.w
      h = button.h
      if button.isHovered()
        ctx.strokeRect(x - w/2, y - h /2, w, h)
    )
    return button

  _clearMenu: (style) =>
    (ctx) =>
      winStyle = window.config.windowStyle
      w = style.width
      h = style.height
      ctx.clearRect(style.location.x - winStyle.lineWidth / 2 - 1,
                    style.location.y - winStyle.lineWidth / 2 - 1,
                    w + winStyle.lineWidth + 2,
                    h + winStyle.lineWidth + 2)

  _drawStationMenu: (ctx) =>
    winStyle = window.config.windowStyle
    stationStyle = window.config.stationMenuStyle
    w = stationStyle.width
    h = stationStyle.height
    loc = stationStyle.location
    @_clearMenu(stationStyle)(ctx)

    ctx.fillStyle = winStyle.fill
    ctx.strokeStyle = winStyle.stroke
    ctx.lineJoin = winStyle.lineJoin
    ctx.lineWidth = winStyle.lineWidth

    # Draw background
    ctx.fillRect(loc.x, loc.y, w, h)

    # Draw frame
    ctx.strokeRect(loc.x, loc.y, w, h)

    # Draw dividers
    ctx.beginPath()
    ctx.moveTo(loc.x, loc.y+h/2)
    ctx.lineTo(loc.x+stationStyle.horizLength, loc.y+h/2)

    ctx.moveTo(loc.x+stationStyle.vert2x, loc.y)
    ctx.lineTo(loc.x+stationStyle.vert2x, loc.y+h)

    ctx.moveTo(loc.x+stationStyle.vert3x, loc.y)
    ctx.lineTo(loc.x+stationStyle.vert3x, loc.y+h)
    ctx.stroke()

    ctx.lineWidth = winStyle.lineWidth * 2
    ctx.beginPath()
    ctx.moveTo(loc.x+stationStyle.vert1x, loc.y)
    ctx.lineTo(loc.x+stationStyle.vert1x, loc.y+h)
    ctx.stroke()

    # Draw title block
    ctx.font = winStyle.titleText.font
    ctx.fillStyle = winStyle.titleText.color
    ctx.textAlign = 'left'
    ctx.textBaseline = 'top'
    x = loc.x+stationStyle.titleLoc.x
    y = loc.y+stationStyle.titleLoc.y
    ctx.fillText("Station", x, y)

    ctx.strokeStyle = winStyle.titleText.color
    ctx.lineWidth = winStyle.titleText.underlineWidth
    ctx.beginPath()
    ctx.moveTo(x, y + winStyle.titleText.height)
    ctx.lineTo(x + ctx.measureText("Station").width, y + winStyle.titleText.height)
    ctx.stroke()

    ctx.font = winStyle.defaultText.font
    ctx.fillStyle = winStyle.defaultText.color
    ctx.textAlign = 'left'
    ctx.textBaseline = 'top'
    x = loc.x+stationStyle.availableLoc.x
    y = loc.y+stationStyle.availableLoc.y
    ctx.fillText("Resources avaliable:", x, y)

    # Draw currently buiding block
    x = loc.x+stationStyle.buildingLoc.x
    y = loc.y+stationStyle.buildingLoc.y
    ctx.fillText("Currently building:", x, y)

    # Draw unit blocks
    @_drawUnitBlock(ctx, "Probe", loc, window.config.units.probe,
                    stationStyle.probe, SpriteNames.PROBE)

    @_drawUnitBlock(ctx, "Colony Ship", loc, window.config.units.colonyShip,
                    stationStyle.colony, SpriteNames.COLONY_SHIP)

    @_drawUnitBlock(ctx, "Attack Ship", loc, window.config.units.attackShip,
                    stationStyle.attack, SpriteNames.ATTACK_SHIP)

    @_drawUnitBlock(ctx, "Defense Ship", loc, window.config.units.defenseShip,
                    stationStyle.defense, SpriteNames.DEFENSE_SHIP)

    # Draw variables
    ctx.fillStyle = winStyle.defaultText.value
    resources = @selectedPlanet.availableResources()
    x = loc.x+stationStyle.availableLoc.x +
        ctx.measureText("Resources avaliable:").width + 5
    y = loc.y+stationStyle.availableLoc.y
    ctx.fillText(resources, x, y)

    x = loc.x+stationStyle.buildingLoc.x
    y = loc.y+stationStyle.buildingLoc.y
    switch @selectedPlanet.buildUnit()
      when window.config.units.probe
        text = "Probe"
        sprite = SpriteNames.PROBE
      when window.config.units.colonyShip
        text = "Colony Ship"
        sprite = SpriteNames.COLONY_SHIP
      when window.config.units.attackShip
        text = "Attack Ship"
        sprite = SpriteNames.ATTACK_SHIP
      when window.config.units.defenseShip
        text = "Defense Ship"
        sprite = SpriteNames.DEFENSE_SHIP
      else
        text = ""
    w = ctx.measureText("Currently building:").width + 5
    ctx.fillText(text, x + w, y)
    if text != ""
      SHEET.drawSprite(sprite, x+w+40, y+35, ctx, false)
      turns = @selectedPlanet.buildStatus()
      text = turns + " turn"
      if turns > 1
        text += "s"
      text += " remaining"
      ctx.fillText(text, x, y+20)

    if @selectedPlanet.buildUnit()
      if not @stationMenu.getProperty("cancelOpen")
        @stationMenu.getProperty("cancelButton").open()
        @stationMenu.setProperty("cancelOpen", true)
    else
      if @stationMenu.getProperty("cancelOpen")
        @stationMenu.getProperty("cancelButton").close()
        @stationMenu.setProperty("cancelOpen", false)

    if @lookingToSetRally
      if @stationMenu.getProperty("rallyOpen")
        @stationMenu.getProperty("rallyButton").close()
        @stationMenu.setProperty("rallyOpen", false)
      if not @stationMenu.getProperty("cancelRallyOpen")
        @stationMenu.getProperty("cancelRallyButton").open()
        @stationMenu.setProperty("cancelRallyOpen", true)
    else
      if @stationMenu.getProperty("cancelRallyOpen")
        @stationMenu.getProperty("cancelRallyButton").close()
        @stationMenu.setProperty("cancelRallyOpen", false)
      if not @stationMenu.getProperty("rallyOpen")
        @stationMenu.getProperty("rallyButton").open()
        @stationMenu.setProperty("rallyOpen", true)

  _drawUnitBlock: (ctx, title, loc, unit, unitConfig, sprite) =>
    x = loc.x + unitConfig.labelLoc.x
    y = loc.y + unitConfig.labelLoc.y
    ctx.fillText(title, x, y)
    if @selectedPlanet.availableResources() < unit.cost
      ctx.fillStyle = window.config.windowStyle.defaultText.red
    x = loc.x + unitConfig.costLoc.x
    y = loc.y + unitConfig.costLoc.y
    ctx.fillText("Cost: " + unit.cost, x, y)
    if @selectedPlanet.availableResources() < unit.cost
      ctx.fillStyle = window.config.windowStyle.defaultText.color
    x = loc.x + unitConfig.turnsLoc.x
    y = loc.y + unitConfig.turnsLoc.y
    ctx.fillText("Turns: " + unit.turns, x, y)
    x = loc.x + unitConfig.imgLoc.x
    y = loc.y + unitConfig.imgLoc.y
    SHEET.drawSprite(sprite, x, y, ctx, false)

  _drawOutpostMenu: (ctx) =>
    winStyle = window.config.windowStyle
    outpostStyle = window.config.outpostMenuStyle
    w = outpostStyle.width
    h = outpostStyle.height
    loc = outpostStyle.location
    @_clearMenu(outpostStyle)(ctx)

    ctx.fillStyle = winStyle.fill
    ctx.strokeStyle = winStyle.stroke
    ctx.lineJoin = winStyle.lineJoin
    ctx.lineWidth = winStyle.lineWidth

    # Draw background
    ctx.fillRect(loc.x, loc.y, w, h)

    # Draw frame
    ctx.strokeRect(loc.x, loc.y, w, h)

    # Draw dividers
    ctx.beginPath()
    ctx.moveTo(loc.x, loc.y + outpostStyle.horiz1y)
    ctx.lineTo(loc.x + w, loc.y + outpostStyle.horiz1y)
    ctx.stroke()

    # Draw title block
    ctx.font = winStyle.titleText.font
    ctx.fillStyle = winStyle.titleText.color
    ctx.textAlign = 'left'
    ctx.textBaseline = 'top'
    x = loc.x+outpostStyle.titleLoc.x
    y = loc.y+outpostStyle.titleLoc.y
    ctx.fillText("Outpost", x, y)

    ctx.strokeStyle = winStyle.titleText.color
    ctx.lineWidth = winStyle.titleText.underlineWidth
    ctx.beginPath()
    ctx.moveTo(x, y + winStyle.titleText.height)
    ctx.lineTo(x + ctx.measureText("Outpost").width, y + winStyle.titleText.height)
    ctx.stroke()

    ctx.font = winStyle.defaultText.font
    ctx.fillStyle = winStyle.defaultText.color
    ctx.textAlign = 'left'
    ctx.textBaseline = 'top'
    x = loc.x + outpostStyle.availableLoc.x
    y = loc.y + outpostStyle.availableLoc.y
    ctx.fillText("Resources avaliable:", x, y)

    x = loc.x + outpostStyle.upgrade.labelLoc.x
    y = loc.y + outpostStyle.upgrade.labelLoc.y

    # Draw upgrade button
    if @selectedPlanet.isBuilding() and
       @selectedPlanet.buildUnit() == window.config.structures.station
      if @stationButton.visible
        @stationButton.close()
      ctx.fillStyle = winStyle.defaultText.value
      turns = @selectedPlanet.buildStatus()
      ctx.fillText("Turns remaining until station: " + turns, x, y+20)
    else
      if not @stationButton.visible
        @stationButton.open()
      station = window.config.structures.station
      ctx.fillText("Upgrade to Station", x, y)
      if @selectedPlanet.availableResources() < station.cost
        ctx.fillStyle = window.config.windowStyle.defaultText.red
      x = loc.x + outpostStyle.upgrade.costLoc.x
      y = loc.y + outpostStyle.upgrade.costLoc.y
      ctx.fillText("Cost: " + station.cost, x, y)
      if @selectedPlanet.availableResources() < station.cost
        ctx.fillStyle = window.config.windowStyle.defaultText.color
      x = loc.x + outpostStyle.upgrade.turnsLoc.x
      y = loc.y + outpostStyle.upgrade.turnsLoc.y
      ctx.fillText("Turns: " + station.turns, x, y)
      x = loc.x + outpostStyle.upgrade.imgLoc.x
      y = loc.y + outpostStyle.upgrade.imgLoc.y
      SHEET.drawSprite(window.config.spriteNames.STATION_NOT_CONSTRUCTING, x, y,
                       ctx, false, 0.38)

    # Draw variables
    ctx.fillStyle = winStyle.defaultText.value
    resources = @selectedPlanet.availableResources()
    x = loc.x + outpostStyle.availableLoc.x +
        ctx.measureText("Resources avaliable:").width + 5
    y = loc.y + outpostStyle.availableLoc.y
    ctx.fillText(resources, x, y)

    if @selectedPlanet.buildUnit()
      if not @outpostMenu.getProperty("cancelOpen")
        @outpostMenu.getProperty("cancelButton").open()
        @outpostMenu.setProperty("cancelOpen", true)
    else
      if @outpostMenu.getProperty("cancelOpen")
        @outpostMenu.getProperty("cancelButton").close()
        @outpostMenu.setProperty("cancelOpen", false)

    if not @selectedPlanet.buildUnit() and
       (@selectedPlanet.availableResources() > 0 or
       @selectedPlanet.resources() > 0)
      if @selectedPlanet.sending
        if @outpostMenu.getProperty("sendOpen")
          @outpostMenu.getProperty("sendButton").close()
          @outpostMenu.setProperty("sendOpen", false)
        if not @outpostMenu.getProperty("stopOpen")
          @outpostMenu.getProperty("stopButton").open()
          @outpostMenu.setProperty("stopOpen", true)
      else
        if @outpostMenu.getProperty("stopOpen")
          @outpostMenu.getProperty("stopButton").close()
          @outpostMenu.setProperty("stopOpen", false)
        if not @outpostMenu.getProperty("sendOpen")
          @outpostMenu.getProperty("sendButton").open()
          @outpostMenu.setProperty("sendOpen", true)
    else
      @selectedPlanet.sending = false
      if @outpostMenu.getProperty("stopOpen")
        @outpostMenu.getProperty("stopButton").close()
        @outpostMenu.setProperty("stopOpen", false)
      if @outpostMenu.getProperty("sendOpen")
        @outpostMenu.getProperty("sendButton").close()
        @outpostMenu.setProperty("sendOpen", false)

  _drawColonyMenu: (ctx) =>
    winStyle = window.config.windowStyle
    colonyStyle = window.config.colonyMenuStyle
    w = colonyStyle.width
    h = colonyStyle.height
    loc = colonyStyle.location
    @_clearMenu(colonyStyle)(ctx)

    ctx.fillStyle = winStyle.fill
    ctx.strokeStyle = winStyle.stroke
    ctx.lineJoin = winStyle.lineJoin
    ctx.lineWidth = winStyle.lineWidth

    # Draw background
    ctx.fillRect(loc.x, loc.y, w, h)

    # Draw frame
    ctx.strokeRect(loc.x, loc.y, w, h)

    # Draw dividers
    ctx.beginPath()
    ctx.moveTo(loc.x, loc.y + colonyStyle.horiz1y)
    ctx.lineTo(loc.x + w, loc.y + colonyStyle.horiz1y)
    ctx.stroke()

    # Draw title block
    ctx.font = winStyle.titleText.font
    ctx.fillStyle = winStyle.titleText.color
    ctx.textAlign = 'left'
    ctx.textBaseline = 'top'
    x = loc.x + colonyStyle.titleLoc.x
    y = loc.y + colonyStyle.titleLoc.y
    ctx.fillText("Colony Ship", x, y)

    ctx.strokeStyle = winStyle.titleText.color
    ctx.lineWidth = winStyle.titleText.underlineWidth
    ctx.beginPath()
    ctx.moveTo(x, y + winStyle.titleText.height)
    ctx.lineTo(x + ctx.measureText("Colony Ship").width,
               y + winStyle.titleText.height)
    ctx.stroke()

    ctx.font = winStyle.defaultText.font
    ctx.fillStyle = winStyle.defaultText.color
    ctx.textAlign = 'left'
    ctx.textBaseline = 'top'
    x = loc.x + colonyStyle.availableLoc.x
    y = loc.y + colonyStyle.availableLoc.y
    ctx.fillText("Probes avaliable:", x, y)

    probes = @selectedPlanet.numShips(window.config.units.probe)

    x = loc.x + colonyStyle.upgrade.labelLoc.x
    y = loc.y + colonyStyle.upgrade.labelLoc.y

    # Draw upgrade button
    if @selectedPlanet.isBuilding() and
       @selectedPlanet.buildUnit() == window.config.structures.outpost
      if @outpostButton.visible
        @outpostButton.close()
      ctx.fillStyle = winStyle.defaultText.value
      turns = @selectedPlanet.buildStatus()
      ctx.fillText("Turns remaining until outpost: " + turns, x, y+20)
    else
      if not @outpostButton.visible
        @outpostButton.open()
      outpost = window.config.structures.outpost
      ctx.fillText("Convert to outpost", x, y)
      if probes < outpost.cost
        ctx.fillStyle = window.config.windowStyle.defaultText.red
      x = loc.x + colonyStyle.upgrade.costLoc.x
      y = loc.y + colonyStyle.upgrade.costLoc.y
      cost = "Cost: " + outpost.cost + " probe"
      if outpost.cost > 1
        cost += "s"
      ctx.fillText(cost, x, y)

      ctx.fillStyle = window.config.windowStyle.defaultText.color
      x = loc.x + colonyStyle.upgrade.turnsLoc.x
      y = loc.y + colonyStyle.upgrade.turnsLoc.y
      ctx.fillText("Turns: " + outpost.turns, x, y)
      x = loc.x + colonyStyle.upgrade.imgLoc.x
      y = loc.y + colonyStyle.upgrade.imgLoc.y
      SHEET.drawSprite(window.config.spriteNames.OUTPOST_NOT_GATHERING, x, y,
                       ctx, false, 0.5)

    # Draw variables
    ctx.fillStyle = winStyle.defaultText.value
    x = loc.x + colonyStyle.availableLoc.x +
        ctx.measureText("Probes avaliable:").width + 5
    y = loc.y + colonyStyle.availableLoc.y
    ctx.fillText(probes, x, y)

    if @selectedPlanet.buildUnit()
      if not @colonyMenu.getProperty("cancelOpen")
        @colonyMenu.getProperty("cancelButton").open()
        @colonyMenu.setProperty("cancelOpen", true)
    else
      if @colonyMenu.getProperty("cancelOpen")
        @colonyMenu.getProperty("cancelButton").close()
        @colonyMenu.setProperty("cancelOpen", false)

  # Must be called after newGame(...) or game.endTurn() for settings to be
  # correct on first turn.
  initialize: (onlyProbe=false, @moveToDiscovered=true, @showResources=true) ->
    @turns = 0
    @planetButtons = []
    for p in game.getPlanets()
      pos = p.location()
      r = window.config.planetRadius
      b = new Elements.RadialButton(pos.x, pos.y, r, @planetButtonCallback(p))
      b.setHoverHandler(@planetButtonHoverCallback(p))
      b.setMouseOutHandler(@planetButtonOutCallback)
      b.setProperty("planet", p)
      vis = p.visibility()
      if vis == window.config.visibility.undiscovered or
         (vis == window.config.visibility.discovered and
         not @moveToDiscovered)
        b.visible = false
      else
        b.visible = true
      gameFrame.addChild(b)
      @planetButtons.push(b)
    @unitSelection.initialize(onlyProbe)
    @controlGroups = []
    @_groupDisplays = []
    @showAll = false

  destroy: () ->
    @selectedPlanet = null
    @endTurn()

    for b in @planetButtons
      gameFrame.removeChild(b)
    @planetButtons = []
    @unitSelection.destroy()
    for c in @controlGroups
      c.destroy()
    for g in @_groupDisplays
      g.destroy()
    for e in @movingElements
      e.destroy()

  planetButtonCallback: (planet) =>
    return () =>
      if @unitSelection.total > 0
        for p in @unitSelection.planetsWithSelectedUnits
          attack = @unitSelection.getNumberOfAttacks(p)
          defense = @unitSelection.getNumberOfDefenses(p)
          probe = @unitSelection.getNumberOfProbes(p)
          colony = @unitSelection.getNumberOfColonies(p)
          p.moveShips(attack, defense, probe, colony, planet)
          @unitSelection.updateSelection(p)
          @updateControlGroups()
        @unitSelection.deselectAllUnits()
      else if @lookingToSendResources
        if planet.hasStation() and @selectedPlanet != planet
          @selectedPlanet.sendResources(planet)
          @lookingToSendResources = false
      else if @lookingToSetRally
        @selectedPlanet.sendUnits(planet)
        @lookingToSetRally = false
      else
        if @selectedPlanet == planet
          @stationMenu.close()
          @outpostMenu.close()
          @colonyMenu.close()
          @selectedPlanet = null
        else if planet.hasStation()
          @selectedPlanet = planet
          @stationMenu.open()
          @outpostMenu.close()
          @colonyMenu.close()
        else if planet.hasOutpost() or
                planet.buildUnit() == window.config.structures.station
          @selectedPlanet = planet
          @outpostMenu.open()
          @stationMenu.close()
          @colonyMenu.close()
        else if planet.numShips(window.config.units.colonyShip) > 0 or
                planet.buildUnit() == window.config.structures.outpost
          @selectedPlanet = planet
          @colonyMenu.open()
          @stationMenu.close()
          @outpostMenu.close()
        else
          @stationMenu.close()
          @outpostMenu.close()
          @colonyMenu.close()
          @selectedPlanet = null
        @switchedMenus = true

  planetButtonHoverCallback: (planet) =>
    return () =>
      @hoveredPlanet = planet

  planetButtonOutCallback: () =>
    @hoveredPlanet = null

  _isIdle: (p) ->
    return p.hasStation() and not p.isBuilding() and p.availableResources() > 0

  gotoNextStation: () ->
    foundCurrent = false
    findFirst = @selectedPlanet == null or not @selectedPlanet.hasStation()
    first = null
    target = null
    for p in game.getPlanets()
      if first == null and @_isIdle(p)
        first = p
      if @_isIdle(p) and (findFirst or foundCurrent)
        @selectedPlanet = p
        @outpostMenu.close()
        @colonyMenu.close()
        @stationMenu.open()
        @stationMenu.setDirty()
        @switchedMenus = true
        camera.setTarget(p.location())
        target = p
        break
      if p == @selectedPlanet
        foundCurrent = true

    if target == null and first
      @selectedPlanet = first
      @outpostMenu.close()
      @colonyMenu.close()
      @stationMenu.open()
      @stationMenu.setDirty()
      @switchedMenus = true
      camera.setTarget(first.location())

  # Draws the game and HUD
  #
  # @param [CanvasRenderingContext2D] ctx The game context
  # @param [CanvasRenderingContext2D] hudCtx The hud context
  draw: (ctx, hudCtx) ->
    visited = []
    #ctx.strokeStyle = window.config.connectionStyle.normal.stroke
    ctx.lineWidth = window.config.connectionStyle.normal.lineWidth
    for p in game.getPlanets()
      pos = camera.getScreenCoordinates(p.location())
      visited.push(p)
      for neighbor in p.getAdjacentPlanets()
        if neighbor in visited
          ctx.strokeStyle = window.config.connectionStyle.normal.undiscovered
        else if cheat or @showAll
          ctx.strokeStyle = window.config.connectionStyle.normal.discovered
        else if p.visibility() == window.config.visibility.visible and
                neighbor.visibility() == window.config.visibility.visible
          ctx.strokeStyle = window.config.connectionStyle.normal.visible
        else if p.visibility() == window.config.visibility.undiscovered or
                neighbor.visibility() == window.config.visibility.undiscovered
          ctx.strokeStyle = window.config.connectionStyle.normal.undiscovered
        else
          ctx.strokeStyle = window.config.connectionStyle.normal.discovered
        #if cheat or @showAll or (neighbor not in visited and
        #   p.visibility() != window.config.visibility.undiscovered and
        #   neighbor.visibility() != window.config.visibility.undiscovered)
        # draw connection to the neighbor
        nPos = camera.getScreenCoordinates(neighbor.location())
        ctx.beginPath()
        ctx.moveTo(pos.x, pos.y)
        ctx.lineTo(nPos.x, nPos.y)
        ctx.stroke()

    if @hoveredGroup != null
      tooltipCtx.textAlign = "left"
      tooltipCtx.font = window.config.toolTipStyle.font
      tooltipCtx.fillStyle = window.config.toolTipStyle.color
      x = @lastMousePos.x + window.config.toolTipStyle.xOffset
      y = @lastMousePos.y + window.config.toolTipStyle.yOffset
      tooltipCtx.fillText("Cancel fleet", x, y)
      @_drawRoute(ctx, @hoveredGroup)

    lost = true
    for p in game.getPlanets()
      loc = p.location()
      pos = camera.getScreenCoordinates(loc)
      # Draw planet
      vis = p.visibility()
      if vis == window.config.visibility.discovered and not @showAll
        if p._lastSeenFungus
          SHEET.drawSprite(SpriteNames.PLANET_INVISIBLE_FUNGUS, loc.x, loc.y, ctx)
        else
          SHEET.drawSprite(SpriteNames.PLANET_INVISIBLE, loc.x, loc.y, ctx)
      else if vis == window.config.visibility.visible or @showAll
        if p.sprite()
          SHEET.drawSprite(p.sprite(), loc.x, loc.y, ctx)
        else if (@showAll and p.fungusStrength() > 0) or
           (p._lastSeenFungus and not @showAll)
          if (p.fungusStrength() == p._fungusMaximumStrength)
            SHEET.drawSprite(SpriteNames.PLANET_BLUE_FUNGUS_MAX, loc.x, loc.y, ctx)
          else
            SHEET.drawSprite(SpriteNames.PLANET_BLUE_FUNGUS, loc.x, loc.y, ctx)
        else
          SHEET.drawSprite(SpriteNames.PLANET_BLUE, loc.x, loc.y, ctx)
      else if cheat
        if p.fungusStrength() > 0
          SHEET.drawSprite(SpriteNames.PLANET_INVISIBLE_FUNGUS, loc.x, loc.y, ctx)
        else
          SHEET.drawSprite(SpriteNames.PLANET_INVISIBLE, loc.x, loc.y, ctx)
      if camera.onScreen(pos) and vis != window.config.visibility.undiscovered
        lost = false
        @help.close()

      # Draw resources
      if @showResources
        if vis != window.config.visibility.undiscovered
          yellow = window.config.windowStyle.defaultText.value
          white = window.config.windowStyle.defaultText.color
          red = window.config.windowStyle.defaultText.red
          green = window.config.windowStyle.defaultText.green
          a = p.availableResources()
          r = p.resources()
          rate = p.rate()
          if r == null
            r = "?"
            rate = "?"
          ctx.font = window.config.windowStyle.smallText.font
          if p.numShips(window.config.units.probe) > 0 or
             p.hasStation() or p.hasOutpost()
            ctx.fillStyle = yellow
          else
            ctx.fillStyle = white
          ctx.textAlign = 'left'
          ctx.textBaseline = 'middle'
          offset = 60 * camera.getZoom()
          tAvb = "#{a}"
          tRes = "#{r}"
          tRat = "#{rate}"
          if camera.getZoom() > window.config.displayCutoff
            tAvb = "Resrouces Collected: " + tAvb
            tRes = "Resources remaining: " + tRes
            tRat = "Collection rate: " + tRat
          if p.hasOutpost() or p.hasStation()
            if a > 0
              ctx.fillStyle = green
            else
              ctx.fillStyle = red
            ctx.fillText(tAvb, pos.x+offset, pos.y)
          if r == 0
            ctx.fillStyle = red
          else if p.numShips(window.config.units.probe) > 0 or
                  p.hasStation() or p.hasOutpost()
            ctx.fillStyle = yellow
          else
            ctx.fillStyle = white
          ctx.fillText(tRes, pos.x+offset, pos.y+10)

          if p.numShips(window.config.units.probe) > 0 or
             p.hasStation() or p.hasOutpost()
            ctx.fillStyle = yellow
          else
            ctx.fillStyle = white
          ctx.fillText(tRat, pos.x+offset, pos.y+20)

      if (@showAll and p.fungusStrength() > 0) or
         (p._lastSeenFungus and not @showAll)
        ctx.font = window.config.windowStyle.titleText.font
        ctx.textAlign = 'left'
        ctx.textBaseline = 'middle'
        ctx.fillStyle = window.config.windowStyle.defaultText.red
        offset = 60 * camera.getZoom()
        if vis == window.config.visibility.visible or @showAll
          ctx.fillText(p.fungusStrength(), pos.x+offset, pos.y-offset)
        else
          ctx.fillText("?", pos.x+offset, pos.y-offset)

      # Draw structure
      if p.hasOutpost()
        if p.resources() > 0
          SHEET.drawSprite(SpriteNames.OUTPOST_GATHERING, loc.x, loc.y, ctx)
        else
          SHEET.drawSprite(SpriteNames.OUTPOST_NOT_GATHERING, loc.x, loc.y, ctx)
      else if p.hasStation()
        if p.isBuilding()
          switch p.buildUnit()
            when window.config.units.probe
              SHEET.drawSprite(SpriteNames.PROBE_CONSTRUCTION, loc.x, loc.y, ctx)
            when window.config.units.colonyShip
              SHEET.drawSprite(SpriteNames.COLONY_SHIP_CONSTRUCTION,
                               loc.x, loc.y, ctx)
            when window.config.units.attackShip
              SHEET.drawSprite(SpriteNames.ATTACK_SHIP_CONSTRUCTION,
                               loc.x, loc.y, ctx)
            when window.config.units.defenseShip
              SHEET.drawSprite(SpriteNames.DEFENSE_SHIP_CONSTRUCTION,
                               loc.x, loc.y, ctx)
          SHEET.drawSprite(SpriteNames.STATION_CONSTRUCTING, loc.x, loc.y, ctx)
        else
          SHEET.drawSprite(SpriteNames.STATION_NOT_CONSTRUCTING, loc.x, loc.y, ctx)

        if p.resources() > 0
          SHEET.drawSprite(SpriteNames.STATION_GATHERING, loc.x, loc.y, ctx)
        else
          SHEET.drawSprite(SpriteNames.STATION_NOT_GATHERING, loc.x, loc.y, ctx)

      if p.isBuilding()
        if p.buildUnit() == window.config.structures.station
          SHEET.drawSprite(SpriteNames.STATION_CONSTRUCTION, loc.x, loc.y, ctx)
          SHEET.drawSprite(SpriteNames.STATION_NOT_GATHERING, loc.x, loc.y, ctx)
        else if p.buildUnit() == window.config.structures.outpost
          SHEET.drawSprite(SpriteNames.OUTPOST_CONSTRUCTION, loc.x, loc.y, ctx)

      next = p.nextSend()
      if next and @carrierCount == 0
        s = p.location()
        e = next.location()
        @movingElements.push(new MovingElement(s, e,
          window.config.carrierStyle.speed,
          (ctx, loc) =>
            ctx.fillStyle = window.config.carrierStyle.color
            ctx.beginPath()
            r = window.config.carrierStyle.radius * camera.getZoom()
            ctx.arc(loc.x, loc.y, r, 0, 2*Math.PI)
            ctx.fill()
        ))

      for c in p._resourceCarriers
        if @carrierCount == 0
          s = p.location()
          e = c.next().location()
          @movingElements.push(new MovingElement(s, e,
            window.config.carrierStyle.speed,
            (ctx, loc) =>
              ctx.fillStyle = window.config.carrierStyle.color
              ctx.beginPath()
              r = window.config.carrierStyle.radius * camera.getZoom()
              ctx.arc(loc.x, loc.y, r, 0, 2*Math.PI)
              ctx.fill()
          ))

    @carrierCount = (@carrierCount + 1) % window.config.carrierStyle.delay

    @unitSelection.draw(ctx, hudCtx)

    if lost
      @help.open()

    x = @lastMousePos.x + window.config.toolTipStyle.xOffset
    y = @lastMousePos.y + window.config.toolTipStyle.yOffset
    tooltipCtx.textAlign = "left"
    tooltipCtx.font = window.config.toolTipStyle.font
    tooltipCtx.fillStyle = window.config.toolTipStyle.color
    if @hoveredPlanet
      if @hoveredPlanet.hasStation() and @hoveredPlanet.isBuilding()
        switch @hoveredPlanet.buildUnit()
          when window.config.units.probe
            sprite = SpriteNames.PROBE
          when window.config.units.colonyShip
            sprite = SpriteNames.COLONY_SHIP
          when window.config.units.attackShip
            sprite = SpriteNames.ATTACK_SHIP
          when window.config.units.defenseShip
            sprite = SpriteNames.DEFENSE_SHIP
        SHEET.drawSprite(sprite, x + 16, y + 24, ctx, false)
        turns = @hoveredPlanet.buildStatus()
        text = turns + " turn"
        if turns > 1
          text += "s"
        text += " remaining"
        ctx.font = window.config.windowStyle.defaultText.font
        ctx.fillStyle = window.config.windowStyle.defaultText.value
        ctx.fillText(text, x + 35, y + 24)
      else if @hoveredPlanet.hasOutpost() and @hoveredPlanet.sendingResourcesTo()
        # Outline planet that hovered planet with outpost is sending resources to
        # @NOTE Not sure if this is a good place to put this
        ctx.strokeStyle = window.config.resourceTarget.color
        ctx.lineWidth = window.config.resourceTarget.lineWidth
        resourceTarget = @hoveredPlanet.sendingResourcesTo()
        loc = resourceTarget.location()
        pos = camera.getScreenCoordinates(loc)
        r = (window.config.planetRadius + window.config.resourceTarget.radius) *
           camera.getZoom()
        ctx.beginPath()
        ctx.arc(pos.x, pos.y, r, 0, 2*Math.PI, false)
        ctx.stroke()

      hasAction = true
      if @lookingToSendResources
        if @hoveredPlanet.hasStation() and @hoveredPlanet != @selectedPlanet
          tooltipCtx.fillText("Valid destination", x, y)
        else
          tooltipCtx.fillText("Invalid destination", x, y)
      else if @lookingToSetRally
        tooltipCtx.fillText("Set planet as unit rally point", x, y)
      else if @unitSelection.total > 0
        tooltipCtx.fillText("Move selected units", x, y)
      else if @hoveredPlanet.hasOutpost() or
              @hoveredPlanet.buildUnit() == window.config.structures.station
        if @outpostMenu.visible and @hoveredPlanet == @selectedPlanet
          tooltipCtx.fillText("Close outpost menu", x, y)
        else
          tooltipCtx.fillText("Open outpost menu", x, y)
      else if @hoveredPlanet.hasStation()
        if @stationMenu.visible and @hoveredPlanet == @selectedPlanet
          tooltipCtx.fillText("Close station menu", x, y)
        else
          tooltipCtx.fillText("Open station menu", x, y)
      else if @hoveredPlanet.numShips(window.config.units.colonyShip) > 0 or
              @hoveredPlanet.buildUnit() == window.config.structures.outpost
        if @colonyMenu.visible and @hoveredPlanet == @selectedPlanet
          tooltipCtx.fillText("Close colony ship menu", x, y)
        else
          tooltipCtx.fillText("Open colony ship menu", x, y)
      else
        tooltipCtx.fillText("No action available", x, y)
        hasAction = false

      if hasAction
        ctx.strokeStyle = window.config.selectionStyle.stroke
        ctx.lineWidth = window.config.selectionStyle.lineWidth
        loc = @hoveredPlanet.location()
        pos = camera.getScreenCoordinates(loc)
        r = (window.config.planetRadius + window.config.selectionStyle.radius) *
             camera.getZoom()
        ctx.beginPath()
        ctx.arc(pos.x, pos.y, r, 0, 2*Math.PI)
        ctx.stroke()
    else if @lookingToSendResources
      tooltipCtx.fillText("Select planet with station", x, y)

    if @selectedPlanet
      ctx.strokeStyle = window.config.selectionStyle.stroke
      ctx.lineWidth = window.config.selectionStyle.lineWidth
      loc = @selectedPlanet.location()
      pos = camera.getScreenCoordinates(loc)
      r = (window.config.planetRadius + window.config.selectionStyle.radius) *
           camera.getZoom()
      ctx.beginPath()
      ctx.arc(pos.x, pos.y, r, 0, 2*Math.PI)
      ctx.stroke()
      # Outline planet that outpost is sending resources to
      if @selectedPlanet.hasOutpost() and @selectedPlanet.sendingResourcesTo()
        ctx.strokeStyle = window.config.resourceTarget.color
        ctx.lineWidth = window.config.resourceTarget.lineWidth
        resourceTarget = @selectedPlanet.sendingResourcesTo()
        loc = resourceTarget.location()
        pos = camera.getScreenCoordinates(loc)
        r = (window.config.planetRadius + window.config.resourceTarget.radius) *
           camera.getZoom()
        ctx.beginPath()
        ctx.arc(pos.x, pos.y, r, 0, 2*Math.PI, false)
        ctx.stroke()

    use = null
    if @hoveredPlanet and @hoveredPlanet.hasStation()
      use = @hoveredPlanet
    else if @selectedPlanet and @selectedPlanet.hasStation()
      use = @selectedPlanet
    if use
      if use._sendingUnitsTo
        loc = use._sendingUnitsTo.location()
      else
        loc = use.location()
      pos = camera.getScreenCoordinates(loc)

      ctx.strokeStyle = window.config.rallyPoint.color
      ctx.lineWidth = window.config.rallyPoint.width
      r = (window.config.planetRadius + window.config.rallyPoint.radius) *
        camera.getZoom()
      ctx.beginPath()
      ctx.arc(pos.x, pos.y, r, 0, 2*Math.PI)
      ctx.stroke()

      ctx.font = window.config.windowStyle.defaultText.font
      ctx.fillStyle = window.config.rallyPoint.color
      ctx.textAlign = 'center'
      ctx.textBaseline = 'bottom'
      ctx.fillText("Rally Point", pos.x, pos.y - r)

    if @switchedMenus
      @stationMenu.setDirty()
      @outpostMenu.setDirty()
      @colonyMenu.setDirty()

    if drag and not @hoveredPlanet and not @lookingToSendResources and
       not @lookingToSetRally
      @stationMenu.close()
      @outpostMenu.close()
      @colonyMenu.close()
      @selectedPlanet = null

    hasIdle = false
    for p in game.getPlanets()
      if @_isIdle(p)
        hasIdle = true

    if hasIdle
      @nextStationButton.open()
    else
      @nextStationButton.close()

  _drawRoute: (ctx, route) ->
    start = camera.getScreenCoordinates(route[0].location())
    finish = camera.getScreenCoordinates(route[route.length - 1].location())
    ctx.strokeStyle = window.config.controlGroup.pathColor
    ctx.lineWidth = window.config.controlGroup.pathWidth
    ctx.beginPath()
    ctx.moveTo(start.x, start.y)
    for p in route
      pos = camera.getScreenCoordinates(p.location())
      ctx.lineTo(pos.x, pos.y)
    ctx.stroke()

    r = (window.config.planetRadius + window.config.controlGroup.finishRadius) *
        camera.getZoom()
    ctx.beginPath()
    ctx.arc(finish.x, finish.y, r, 0, 2*Math.PI)
    ctx.stroke()

    ctx.font = window.config.windowStyle.defaultText.font
    ctx.fillStyle = "rgb(0, 100, 255)"
    ctx.textAlign = 'center'
    ctx.textBaseline = 'bottom'
    ctx.fillText("Destination", pos.x, pos.y - r)

  # The UI expects this to be called when the mouse moves
  #
  # @param [Number] x The x position of the mouse
  # @param [Number] y The y position of the mouse
  onMouseMove: (x, y) ->
    @lastMousePos = {x: x, y: y}
    @unitSelection.onMouseMove(x, y)

  # The UI expects this to be called when the mouse clicks
  #
  # @param [Number] x The x position of the mouse
  # @param [Number] y The y position of the mouse
  onMouseClick: (x, y) ->
    @unitSelection.onMouseClick(x, y)

  updateControlGroups: () ->
    for c in @controlGroups
      gameFrame.removeChild(c)
    @controlGroups = []
    for g in @_groupDisplays
      frameElement.removeChild(g)
    @_groupDisplays = []
    for p in game.getPlanets()
      gs = {}
      for g in p.getControlGroups()
        next = g.next()
        if not gs[next]
          gs[next] = {}
          gs[next].groups = []
          gs[next].location = next.location()
          gs[next].prev = p
        gs[next].groups.push(g)
      for g of gs
        nextLoc = gs[g].location
        groups = gs[g].groups
        previous = gs[g].prev
        planetGameLoc = previous.location()
        vec = {x: nextLoc.x - planetGameLoc.x, y: nextLoc.y - planetGameLoc.y}
        length = Math.sqrt(vec.x*vec.x + vec.y*vec.y)
        dir = {x: vec.x / length, y: vec.y / length}
        d = window.config.controlGroup.distance
        controlGameLoc =
          x: Math.floor(dir.x * d + planetGameLoc.x)
          y: Math.floor(dir.y * d + planetGameLoc.y)
        controlHudLoc = camera.getScreenCoordinates(controlGameLoc)

        groupDisplay = @_getExpandedDisplay(controlGameLoc, groups, previous)

        controlGroup = @_getCollapsedDisplay(controlGameLoc, groupDisplay)
        @_setHandler(groupDisplay, controlGroup, controlGameLoc, groups)

        @controlGroups.push(controlGroup)
        controlGroup.setZIndex(100)
        gameFrame.addChild(controlGroup)
        @_groupDisplays.push(groupDisplay)
        frameElement.addChild(groupDisplay)
        groupDisplay.visible = false

  _getExpandedDisplay: (controlGameLoc, groups, planet) ->
    winStyle = window.config.windowStyle
    w = window.config.controlGroup.expandedWidth
    h = window.config.controlGroup.expandedHeight * groups.length
    groupDisplay = new Elements.BoxElement(-1000, -1000, w, h)

    height = window.config.controlGroup.expandedHeight
    y = height/2
    for g in groups
      button = @_getControlButton(w/2, y,
                                  w-winStyle.lineWidth, height - winStyle.lineWidth,
                                  groupDisplay, g, planet)
      y += height
      groupDisplay.addChild(button)
    return groupDisplay

  _getControlButton: (x, y, w, h, groupDisplay, group, planet) ->
    winStyle = window.config.windowStyle
    settings = window.config.controlGroup.button
    button = new Elements.Button(x, y, w, h)
    button.setClickHandler(() =>
      planet.cancelControlGroup(group)
      @updateControlGroups()
      @unitSelection.updateSelection(planet)
      @hoveredGroup = null
    )
    button.setHoverHandler(() => @hoveredGroup = group.route())
    button.setMouseOutHandler(() => @hoveredGroup = null)
    button.setDrawFunc((ctx) =>
      center =
        x: groupDisplay.x - groupDisplay.w / 2 + button.x
        y: groupDisplay.y - groupDisplay.h / 2 + button.y
      topleft =
        x: center.x - button.w / 2
        y: center.y - button.h / 2

      SHEET.drawSprite(SpriteNames.PROBE,
                       topleft.x + settings.probe.imgloc.x,
                       topleft.y + settings.probe.imgloc.y,
                       ctx, false, settings.probe.scale)
      SHEET.drawSprite(SpriteNames.COLONY_SHIP,
                       topleft.x + settings.colony.imgloc.x,
                       topleft.y + settings.colony.imgloc.y,
                       ctx, false, settings.colony.scale)
      SHEET.drawSprite(SpriteNames.ATTACK_SHIP,
                       topleft.x + settings.attack.imgloc.x,
                       topleft.y + settings.attack.imgloc.y,
                       ctx, false, settings.attack.scale)
      SHEET.drawSprite(SpriteNames.DEFENSE_SHIP,
                       topleft.x + settings.defense.imgloc.x,
                       topleft.y + settings.defense.imgloc.y,
                       ctx, false, settings.defense.scale)

      ctx.font = winStyle.defaultText.font
      ctx.fillStyle = winStyle.defaultText.value
      ctx.textAlign = 'left'
      ctx.textBaseline = 'middle'
      ctx.fillText(group.probes(),
                   topleft.x + settings.probe.txtloc.x,
                   topleft.y + settings.probe.txtloc.y)
      ctx.fillText(group.colonies(),
                   topleft.x + settings.colony.txtloc.x,
                   topleft.y + settings.colony.txtloc.y)
      ctx.fillText(group.attackShips(),
                   topleft.x + settings.attack.txtloc.x,
                   topleft.y + settings.attack.txtloc.y)
      ctx.fillText(group.defenseShips(),
                   topleft.x + settings.defense.txtloc.x,
                   topleft.y + settings.defense.txtloc.y)
      ctx.strokeStyle = window.config.unitDisplay.stroke
      ctx.lineWidth = window.config.unitDisplay.lineWidth
      ctx.lineJoin = window.config.unitDisplay.lineJoin
      if button.isHovered()
        ctx.strokeRect(topleft.x, topleft.y, button.w, button.h)
    )
    return button

  _setHandler: (groupDisplay, controlGroup, controlGameLoc, groups) ->
    winStyle = window.config.windowStyle
    h = groupDisplay.h
    w = groupDisplay.w
    clear = (ctx) =>
      ctx.fillStyle = winStyle.fill
      ctx.strokeStyle = winStyle.stroke
      ctx.lineJoin = winStyle.lineJoin
      ctx.lineWidth = winStyle.lineWidth

      loc = {x: groupDisplay.x-w/2, y: groupDisplay.y-h/2}
      ctx.clearRect(loc.x - winStyle.lineWidth/2 - 1,
                    loc.y - winStyle.lineWidth/2 - 1,
                    w + winStyle.lineWidth + 2,
                    h + winStyle.lineWidth + 2,)

    groupDisplay.setClearFunc(clear)
    groupDisplay.setDrawFunc(
      (ctx) =>
        clear(ctx)
        winStyle = window.config.windowStyle
        ctx.fillStyle = winStyle.fill
        ctx.strokeStyle = winStyle.stroke
        ctx.lineJoin = winStyle.lineJoin
        ctx.lineWidth = winStyle.lineWidth

        loc = camera.getScreenCoordinates(controlGameLoc)
        groupDisplay.moveTo(loc.x + w/2, loc.y + h/2)

        ctx.fillRect(loc.x, loc.y, w, h)
        ctx.strokeRect(loc.x, loc.y, w, h)

        offset = 0
        height = window.config.controlGroup.expandedHeight
        for g in groups
          # Draw divider
          ctx.beginPath()
          ctx.moveTo(loc.x, loc.y + offset)
          ctx.lineTo(loc.x + w, loc.y + offset)
          ctx.stroke()
          offset += height
        if not groupDisplay.isHovered() and
           groupDisplay.visible and not controlGroup.visible
          controlGroup.open()
          groupDisplay.close()
    )

    groupDisplay.setMouseOutHandler(
      () =>
        if groupDisplay.visible and not controlGroup.visible
          controlGroup.open()
          groupDisplay.close()
    )

  _getCollapsedDisplay: (controlGameLoc, groupDisplay) ->
    w = window.config.controlGroup.collapsedWidth
    h = window.config.controlGroup.collapsedHeight
    controlGroup = new Elements.BoxElement(controlGameLoc.x+w/2,
                                           controlGameLoc.y+h/2, w, h)
    controlGroup.setDrawFunc(
      (ctx) =>
        winStyle = window.config.windowStyle
        ctx.fillStyle = winStyle.fill
        ctx.strokeStyle = winStyle.stroke
        ctx.lineJoin = winStyle.lineJoin
        ctx.lineWidth = winStyle.lineWidth * camera.getZoom()

        w = window.config.controlGroup.collapsedWidth * camera.getZoom()
        h = window.config.controlGroup.collapsedHeight * camera.getZoom()

        loc = camera.getScreenCoordinates(controlGameLoc)

        ctx.fillRect(loc.x, loc.y, w, h)
        ctx.strokeRect(loc.x, loc.y, w, h)

        ctx.setFont(window.config.windowStyle.defaultText.fontObj)
        ctx.fillStyle = window.config.windowStyle.defaultText.color
        ctx.textAlign = 'left'
        ctx.textBaseline = 'middle'
        size = ctx.getFontSizeVal()
        ctx.setFontSizeVal(Math.floor(size * camera.getZoom()))
        ctx.fillText("Fleets", loc.x + 10 * camera.getZoom(), loc.y + h/2)
    )
    controlGroup.setHoverHandler(
      () =>
        if not drag
          if controlGroup.visible and not groupDisplay.visible
            controlGroup.close()
            groupDisplay.open()
        )

    return controlGroup

  endTurn: () ->
    @updateControlGroups()

    for p in game.getPlanets()
      @unitSelection.updateSelection(p)

    # Reset planet button visibility
    for b in @planetButtons
      p = b.getProperty("planet")
      vis = p.visibility()
      if vis == window.config.visibility.undiscovered or
         (vis == window.config.visibility.discovered and
         not @moveToDiscovered)
        b.close()
      else
        b.open()

    if @selectedPlanet
      if not @selectedPlanet.hasStation() and @stationMenu.visible
        @stationMenu.close()
        @selectedPlanet = null
      else if not @selectedPlanet.hasOutpost() and @outpostMenu.visible
        @outpostMenu.close()
        if @selectedPlanet.hasStation()
          @stationMenu.open()
        else
          @selectedPlanet = null
      else if (@selectedPlanet.numShips(window.config.units.colonyShip) == 0 and
              @colonyMenu.visible) or @selectedPlanet.hasOutpost()
        @colonyMenu.close()
        if @selectedPlanet.hasOutpost()
          @outpostMenu.open()
        else
          @selectedPlanet = null
      else if @stationMenu.visisble
        @stationMenu.setDirty()
      else if @outpostMenu.visible
        @outpostMenu.setDirty()
      else if @colonyMenu.visible
        @colonyMenu.setDirty()
    else
      if @stationMenu.visible
        @stationMenu.close()
      else if @outpostMenu.visible
        @outpostMenu.close()
      else if @colonyMenu.visible
        @colonyMenu.close()

    @hoveredGroup = null

    @unitSelection.endTurn()

    @turns++
    @turnCounter.setDirty()

    @lookingToSendResources = false

    combatStyle = window.config.combatStyle
    for p in game.getPlanets()
      report = p.getCombatReport()
      #vis = p.visibility()
      if (p.fungusOnPlanet() or report.fungusLost) and
         (p.humansOnPlanet() or report.probesLost or
                                report.coloniesLost or
                                report.attackShipsLost or
                                report.defenseShipsLost)
         #vis == window.config.visibility.visible
        pLoc = p.location()

        s = {x: pLoc.x + combatStyle.fungusLoc.x,
        y: pLoc.y + combatStyle.fungusLoc.y}
        e = {x: s.x, y: s.y + combatStyle.good.distance}
        @movingElements.push(new MovingElement(s, e, combatStyle.good.speed,
          @_getDrawDamage(-report.fungusLost, combatStyle.good)))

        if p.numShips(window.config.units.probe) > 0 or report.probesLost > 0
          s = {x: pLoc.x + combatStyle.probeLoc.x,
          y: pLoc.y + combatStyle.probeLoc.y}
          e = {x: s.x + combatStyle.bad.distance, y: s.y}
          @movingElements.push(new MovingElement(s, e, combatStyle.bad.speed,
            @_getDrawDamage(-report.probesLost, combatStyle.bad)))

        if p.numShips(window.config.units.colonyShip) > 0 or report.coloniesLost > 0
          s = {x: pLoc.x + combatStyle.colonyLoc.x,
          y: pLoc.y + combatStyle.colonyLoc.y}
          e = {x: s.x + combatStyle.bad.distance, y: s.y}
          @movingElements.push(new MovingElement(s, e, combatStyle.bad.speed,
            @_getDrawDamage(-report.coloniesLost, combatStyle.bad)))

        if p.numShips(window.config.units.attackShip) > 0 or
           report.attackShipsLost > 0
          s = {x: pLoc.x + combatStyle.attackLoc.x,
          y: pLoc.y + combatStyle.attackLoc.y}
          e = {x: s.x + combatStyle.bad.distance, y: s.y}
          @movingElements.push(new MovingElement(s, e, combatStyle.bad.speed,
            @_getDrawDamage(-report.attackShipsLost, combatStyle.bad)))

        if p.numShips(window.config.units.defenseShip) > 0 or
           report.defenseShipsLost > 0
          s = {x: pLoc.x + combatStyle.defenseLoc.x,
          y: pLoc.y + combatStyle.defenseLoc.y}
          e = {x: s.x + combatStyle.bad.distance, y: s.y}
          @movingElements.push(new MovingElement(s, e, combatStyle.bad.speed,
            @_getDrawDamage(-report.defenseShipsLost, combatStyle.bad)))

  refreshEndTurnButton: ->
    @endTurnButton.setDirty()

  _getDrawDamage: (damage, style) ->
    text = ""
    if damage > 0
      text += "+" + damage
    else
      text += damage
    return (ctx, loc) =>
      ctx.setFont(style.fontObj)
      ctx.textAlign = 'center'
      ctx.textBaseline = 'middle'
      ctx.fillStyle = style.color
      ctx.fillText(text, loc.x, loc.y)

  endGame: () ->
    @stationMenu.close()
    @outpostMenu.close()
    @colonyMenu.close()
    @selectedPlanet = null
    @lookingToSendResources = false
    @showAll = true

class MovingElement
  constructor: (start, @end, @speed, @drawFunc) ->
    @distanceMoved = 0
    @current = start
    vec = {x: @end.x - start.x, y: @end.y - start.y}
    @length = Math.sqrt(vec.x*vec.x + vec.y*vec.y)
    @dir = {x: vec.x / @length * @speed, y: vec.y / @length * @speed}
    @element = new Elements.BoxElement(@current.x, @current.y, 0, 0)
    @element.setDrawFunc(@draw)
    @element.setClearFunc(@clear)
    @element.visible = true
    gameFrame.addChild(@element)

  draw: (ctx) =>
    loc =
      x: Math.floor(@current.x)
      y: Math.floor(@current.y)
    @drawFunc(ctx, camera.getScreenCoordinates(loc))

    @current.x += @dir.x
    @current.y += @dir.y

    @element.moveTo(@current.x, @current.y)

    @distanceMoved += @speed
    if @distanceMoved > @length
      @destroy()

  destroy: ->
    @element.destroy()
    UI.movingElements = UI.movingElements.filter((e) => e != @)
