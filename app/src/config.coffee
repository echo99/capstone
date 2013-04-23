#_require util/Sprite

root = exports ? window

root.config =
  ZOOM_SPEED: 0.02
  PAN_SPEED_FACTOR: 3
  BG_PAN_SPEED_FACTOR: 50
  windowStyle:
    fill: "rgba(0, 37, 255, 0.5)"
    stroke: "rgba(0, 37, 255, 1)"
    lineJoin: "bevel"
    lineWidth: 5
    defaultText:
      font: "15px Arial"
      color: "rgba(255, 255, 255, 1)"
    titleText:
      font: "15px Arial"
      color: "rgba(255, 255, 255, 1)"
    labelText:
      font: "20pt Arial"
      color: "rgba(255, 255, 255, 1)"
    valueText:
      font: "15px Arial"
      color: "rgba(255, 255, 0, 1)"
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
  unitDisplay:
    location: {x: -250, y: -140}
    fill: "rgba(255, 255, 0, 0.5)"
    stroke: "rgba(255, 255, 0, 1)"
    lineWidth: 4
    width: 32
    height: 32
    spacing: 40
  selectionStyle:
    stroke: "rgba(255, 255, 0, 1)"
    lineWidth: 2
    radius: 20
    location: {x: 5, y: 5}
    width: 105
    height: 100
  planetRadius: 64
  spriteNames:
    BACKGROUND: new AnimatedSprite(['starry_background.png'])
    ATTACK_SHIP: new AnimatedSprite(['attack_ship.png'])
    DEFENSE_SHIP: new AnimatedSprite(['defense_ship.png'])
    COLONY_SHIP: new AnimatedSprite(['colony_ship.png'])
    PROBE: new AnimatedSprite(['probe.png'])
    PLANET_BLUE: new AnimatedSprite(['planet_blue.png'])
    PLANET_INVISIBLE: new AnimatedSprite(['planet_invisible.png'])
    TITLE: new AnimatedSprite(['title.png'])
    FULL_SCREEN: new AnimatedSprite(['activate_full_screen_button.png'])
    UNFULL_SCREEN: new AnimatedSprite(['deactivate_full_screen_button.png'])
    MUTED: new AnimatedSprite(['muted_button.png'])
    UNMUTED: new AnimatedSprite(['unmuted_button.png'])
    OUTPOST_GATHERING: new AnimatedSprite(['outpost_buildings_gathering_1.png',
      'outpost_buildings_gathering_2.png'], 20)
    STATION_BUILDINGS_GATHERING: new AnimatedSprite(
      ['station_buildings_gathering_1.png',
       'station_buildings_gathering_2.png'], 20)
    STATION_CONSTRUCTING: new AnimatedSprite(
      ['station_constructing.png'])
    STATION_NOT_CONSTRUCTING: new AnimatedSprite(
      ['station_not_constructing.png'])
    PROBE_CONSTRUCTION: new AnimatedSprite(['probe_construction.png'])
    WARP_GATE: new AnimatedSprite(['warp_gate_1.png', 'warp_gate_2.png',
      'warp_gate_3.png', 'warp_gate_4.png'], 3)
  units:
    probe:
      cost: 1
      turns: 1
      attack: 1
      defense: 1
    colonyShip:
      cost: 3
      turns: 1
      attack: 1
      defense: 1
    attackShip:
      cost: 4
      turns: 2
      attack: 5
      defense: 2
    defenseShip:
      cost: 3
      turns: 1
      attack: 2
      defense: 5
  structures:
    outpost:
      cost: 0
      turns: 0
      defense: 1
    station:
      cost: 10
      turns: 3
      defense: 5
    warpGate:
      cost: 7
      turns: 4
      defense: 1