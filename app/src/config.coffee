#_require util/Sprite

window.config =
  windowStyle:
    fill: "rgba(0, 37, 255, 0.5)"
    stroke: "rgba(0, 37, 255, 1)"
    lineJoin: "bevel"
    lineWidth: 5
    title:
      font: "15px Arial"
      color: "rgba(255, 255, 255, 1)"
    label:
      font: "15px Arial"
      color: "rgba(255, 255, 255, 1)"
    value:
      font: "15px Arial"
      color: "rgba(255, 255, 0, 1)"
  toolTipStyle:
    font: "15px Arial"
    color: "rgba(255, 255, 255, 1)"
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
    OUTPOST_GATHERING: new AnimatedSprite(['outpost_buildings_gathering_1.png',
      'outpost_buildings_gathering_2.png'], 30)
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