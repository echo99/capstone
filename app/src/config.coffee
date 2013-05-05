#_require util/Sprite

if not root?
  root = exports ? window

if exports?
  {Sprite, AnimatedSprite} = require './util/Sprite'

DRAG_TYPES = ['DEFAULT', 'ONE_TO_ONE']

root.config =
  ZOOM_SPEED: 0.02
  PAN_SPEED_FACTOR: 3
  BG_PAN_SPEED_FACTOR: 50
  DRAG_TYPE: DRAG_TYPES[1]
  displayCutoff: 0.4
  windowStyle:
    fill: "rgba(0, 37, 255, 0.5)"
    stroke: "rgba(0, 37, 255, 1)"
    lineJoin: "bevel"
    lineWidth: 5
    defaultText:
      font: "13px Arial"
      fontObj: {sizeVal: 13, unit: "px", family: "Arial"}
      color: "rgba(255, 255, 255, 1)"
      red: "rgba(255, 0, 0, 1)"
      value: "rgba(255, 255, 0, 1)"
    titleText:
      height: 15
      font: "15px Arial"
      color: "rgba(255, 255, 255, 1)"
      underlineWidth: 2
    labelText:
      font: "17pt Arial"
      color: "rgba(255, 255, 255, 1)"
    valueText:
      font: "15px Arial"
      color: "rgba(255, 255, 0, 1)"
    msgBoxText:
      font: "18pt Arial"
      color: "rgb(255, 255, 255)"
      lineWidth: 28
  toolTipStyle:
    font: "15px Arial"
    color: "rgba(255, 255, 255, 1)"
    xOffset: 15
    yOffset: 30
  connectionStyle:
    normal:
      stroke: "rgba(128, 128, 128, 0.5)"
      lineWidth: 2
    path:
      stroke: "rgba(255, 255, 0, 0.8)"
      lineWidth: 2
    resourcePath:
      stroke: "rgba(0, 255, 255, 0.5)"
      lineWidth: 2
    unit:
      stroke: "rgba(255, 255, 0, 0.3)"
      lineWidth: 1
  controlGroup:
    distance: 300
    collapsedWidth: 55
    collapsedHeight: 30
    expandedWidth: 80
    expandedHeight: 45
    button:
      probe:
        imgloc: {x: 10, y: 10}
        txtloc: {x: 25, y: 10}
        scale: 0.5
      colony:
        imgloc: {x: 10, y: 30}
        txtloc: {x: 25, y: 30}
        scale: 0.5
      attack:
        imgloc: {x: 50, y: 10}
        txtloc: {x: 65, y: 10}
        scale: 0.5
      defense:
        imgloc: {x: 50, y: 30}
        txtloc: {x: 65, y: 30}
        scale: 0.5
  unitDisplay:
    location: {x: -250, y: -140}
    fill: "rgba(255, 255, 0, 0.5)"
    stroke: "rgba(255, 255, 0, 1)"
    red: "rgba(255, 0, 0, 1)"
    orange: "rgba(255, 106, 0, 1)"
    lineWidth: 2
    lineJoin: "miter"
    width: 32
    height: 32
    spacing: 40
    rows: 2
    columns: 5
    numberOffset: {x: 10, y: 20}
  selectionStyle:
    stroke: "rgba(255, 255, 0, 1)"
    lineWidth: 2
    radius: 20
    location: {x: 5, y: 5}
    width: 105
    height: 200
    probeHeight: 80
  stationMenuStyle:
    location: {x: 120, y: 5}
    width: 520
    height: 140
    horizLength: 435
    vert1x: 210
    vert2x: 322
    vert3x: 435
    titleLoc: {x: 10, y: 10}
    availableLoc: {x: 10, y: 45}
    buildingLoc: {x: 10, y: 80}
    cancelLoc: {x: 60, y: 125}
    cancelSize: {w: 60, h: 20}
    probe:
      labelLoc: {x: 220, y: 10}
      imgLoc: {x: 220+32/2, y: 10+20+32/2}
      costLoc: {x: 220+45, y: 10+20}
      turnsLoc: {x: 220+45, y: 10+20+20}
    colony:
      labelLoc: {x: 220, y: 10+70}
      imgLoc: {x: 220+32/2, y: 10+20+32/2+70}
      costLoc: {x: 220+45, y: 10+20+70}
      turnsLoc: {x: 220+45, y: 10+20+20+70}
    attack:
      labelLoc: {x: 332, y: 10}
      imgLoc: {x: 332+32/2, y: 10+20+32/2}
      costLoc: {x: 332+45, y: 10+20}
      turnsLoc: {x: 332+45, y: 10+20+20}
    defense:
      labelLoc: {x: 332, y: 10+70}
      imgLoc: {x: 332+32/2, y: 10+20+32/2+70}
      costLoc: {x: 332+45, y: 10+20+70}
      turnsLoc: {x: 332+45, y: 10+20+20+70}
  outpostMenuStyle:
    location: {x: 120, y: 5}
    width: 200
    height: 120
    titleLoc: {x: 10, y: 10}
    availableLoc: {x: 10, y: 45}
    horiz1y: 70
    upgrade:
      labelLoc: {x: 10, y: 70+10}
      costLoc: {x: 10, y: 70+10+20}
      turnsLoc: {x: 10 + 60, y: 70+10+20}
      imgLoc: {x: 135, y: 70+10+48}
  colonyMenuStyle:
    location: {x: 120, y: 5}
    width: 200
    height: 120
    titleLoc: {x: 10, y: 10}
    availableLoc: {x: 10, y: 45}
    horiz1y: 70
    upgrade:
      labelLoc: {x: 10, y: 70+10}
      costLoc: {x: 10, y: 70+10+20}
      turnsLoc: {x: 10 + 90, y: 70+10+20}
      imgLoc: {x: 170, y: 70+10+40}
  planetRadius: 64
  spriteNames:
    BACKGROUND: new AnimatedSprite(['starry_background.png'])
    ATTACK_SHIP: new AnimatedSprite(['attack_ship.png'])
    DEFENSE_SHIP: new AnimatedSprite(['defense_ship.png'])
    COLONY_SHIP: new AnimatedSprite(['colony_ship.png'])
    PROBE: new AnimatedSprite(['probe.png'])
    PLANET_BLUE: new AnimatedSprite(['planet_blue.png'])
    PLANET_BLUE_FUNGUS: new AnimatedSprite(['planet_blue_fungus.png'])
    PLANET_INVISIBLE: new AnimatedSprite(['planet_invisible.png'])
    PLANET_INVISIBLE_FUNGUS: new AnimatedSprite(['planet_invisible_fungus.png'])
    TITLE: new AnimatedSprite(['title.png'])
    FULL_SCREEN: new AnimatedSprite(['activate_full_screen_button.png'])
    UNFULL_SCREEN: new AnimatedSprite(['deactivate_full_screen_button.png'])
    MUTED: new AnimatedSprite(['muted_button.png'])
    UNMUTED: new AnimatedSprite(['unmuted_button.png'])
    OUTPOST_GATHERING: new AnimatedSprite(['outpost_buildings_gathering_1.png',
      'outpost_buildings_gathering_2.png'], 20)
    OUTPOST_NOT_GATHERING: new AnimatedSprite(
      ['outpost_buildings_not_gathering.png'])
    STATION_GATHERING: new AnimatedSprite(
      ['station_buildings_gathering_1.png',
       'station_buildings_gathering_2.png'], 20)
    STATION_NOT_GATHERING: new AnimatedSprite(
      ['station_buildings_not_gathering.png'])
    STATION_CONSTRUCTING: new AnimatedSprite(['station_constructing.png'])
    STATION_NOT_CONSTRUCTING: new AnimatedSprite(['station_not_constructing.png'])
    PROBE_CONSTRUCTION: new AnimatedSprite(['probe_construction.png'])
    COLONY_SHIP_CONSTRUCTION: new AnimatedSprite(['colony_ship_construction.png'])
    ATTACK_SHIP_CONSTRUCTION: new AnimatedSprite(['attack_ship_construction.png'])
    DEFENSE_SHIP_CONSTRUCTION: new AnimatedSprite(['defense_ship_construction.png'])
    WARP_GATE: new AnimatedSprite(['warp_gate_1.png', 'warp_gate_2.png',
      'warp_gate_3.png', 'warp_gate_4.png'], 3)
    END_TURN_BUTTON_IDLE: new AnimatedSprite(['end_turn_button_idle.png'])
    END_TURN_BUTTON_HOVER: new AnimatedSprite(['end_turn_button_hover.png'])
    START_MISSION_BUTTON_IDLE: new AnimatedSprite(['start_mission_button_idle.png'])
    START_MISSION_BUTTON_HOVER: new AnimatedSprite(
      ['start_mission_button_hover.png'])
    CANCEL_BUTTON_IDLE: new AnimatedSprite(['cancel_button_idle.png'])
    CANCEL_BUTTON_HOVER: new AnimatedSprite(['cancel_button_hover.png'])
  MainMenu:
    home:
      x: 0
      y: 0
    missions:
      x: 0
      y: -400
    mission1:
      x: -400
      y: -750
      menu:
        w: 300
        h: 200
        message: "This is the mission 1 message box"
        textAlign: 'left'
        vAlign: 'top'
        cancel:
          x: 245
          y: 185
          w: 60
          h: 20
        start:
          x: 145
          y: 185
          w: 101
          h: 20
    mission2:
      x: 0
      y: -800
      menu:
        w: 300
        h: 200
        message: "This is the mission 2 message box"
        textAlign: 'left'
        vAlign: 'top'
        cancel:
          x: 245
          y: 185
          w: 60
          h: 20
        start:
          x: 145
          y: 185
          w: 101
          h: 20
    extermination:
      x: 400
      y: 150
      menu:
        w: 400
        h: 100
        message: "Exterminate all fungus before it exterminates you."
        textAlign: 'center'
        vAlign: 'top'
        cancel:
          x: 345
          y: 85
          w: 60
          h: 20
        start:
          x: 245
          y: 85
          w: 101
          h: 20
  units:
    probe:
      cost: 1
      turns: 1
      attack: .1
      defense: .1
    colonyShip:
      cost: 3
      turns: 1
      attack: .1
      defense: .1
    attackShip:
      cost: 4
      turns: 2
      attack: .5
      defense: 0
    defenseShip:
      cost: 3
      turns: 1
      attack: 0
      defense: .5
    fungus:
      attack: .5
      defense: 0
  structures:
    outpost:
      cost: 1
      turns: 1
      defense: .1
    station:
      cost: 10
      turns: 3
      defense: .5
    warpGate:
      cost: 7
      turns: 4
      defense: .1
  visibility:
    visible: 0
    discovered: 1
    undiscovered: 2
    size: 3
  minimumPlanetDistance: 500
  maximumAdjacencyDistance: 800
  resources:
    homePlanetResources: 40
    homePlanetRate: 2
    meanResources: 20
    stdevResources: 40
    maxResources: 80
    minResources: 5
    meanRate: 1
    stdevRate: 4
    maxRate: 5
    minRate: 1

config = root.config
