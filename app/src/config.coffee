#_require util/Sprite

if not root?
  root = exports ? window

if exports?
  {Sprite, AnimatedSprite} = require './util/Sprite'

DRAG_TYPES = ['DEFAULT', 'ONE_TO_ONE']

root.config =
  ZOOM_SPEED: 0.04
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
      green: "rgba(0, 255, 0, 1)"
      value: "rgba(255, 255, 0, 1)"
    smallText:
      font: "10px Arial"
    lageText:
      fontObj: {sizeVal: 20, unit: "px", family: "Arial"}
      color: "rgba(255, 255, 255, 1)"
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
      lineHeight: 28
      padding: 5
  toolTipStyle:
    font: "15px Arial"
    color: "rgba(255, 255, 255, 1)"
    xOffset: 15
    yOffset: 30
  carrierStyle:
    speed: 10
    delay: 10
    radius: 7
    color: "rgba(0, 255, 255, 1)"
  arrowStyle:
    color: "rgba(255, 255, 255, 1)"
    width: 2
    angle: 145
  combatStyle:
    good:
      fontObj: {sizeVal: 15, unit: "px", family: "Arial"}
      color: "rgba(0, 255, 0, 1)"
      speed: 0.5
      distance: -200
    bad:
      fontObj: {sizeVal: 15, unit: "px", family: "Arial"}
      color: "rgba(255, 0, 0, 1)"
      speed: 0.5
      distance: -200
    fungusLoc: {x: 0, y: 0}
    probeLoc: {x: -230, y: -90}
    colonyLoc: {x: -230, y: -10}
    attackLoc: {x: -80, y: 70}
    defenseLoc: {x: -80, y: 150}
  connectionStyle:
    normal:
      visible: "rgba(200, 200, 200, 0.8)"
      discovered: "rgba(128, 128, 128, 0.5)"
      undiscovered: "rgba(128, 128, 128, 0.0)"
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
    distance: 290
    collapsedWidth: 55
    collapsedHeight: 30
    expandedWidth: 80
    expandedHeight: 46
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
    pathColor: "rgba(0, 40, 255, 0.8)"
    pathWidth: 6
    finishRadius: 30
  rallyPoint:
    color: "rgba(0, 255, 0, 0.8)"
    width: 2
    radius: 40
  unitDisplay:
    location: {x: -220, y: -70}
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
    columns: 4
    numberOffset: {x: 10, y: 20}
    button:
      offset: {x: 50, y: 16}
      smallLoc: {x: 60/2, y: 25*3/2}
      smallW: 60
      smallH: 25
      bigLoc: {x: 80*3/2, y: 25*3/2}
      bigW: 80*3
      bigH: 25*3
      imgOffset: 83
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
    rallyLoc: {x: 130, y: 20}
    rallySize: {w: 112, h: 20}
    cancelRallyLoc: {x: 112, y: 20}
    cancelRallySize: {w: 60, h: 20}
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
    cancelLoc: {x: 60, y: 90}
    cancelSize: {w: 60, h: 20}
    sendLoc: {x: 130, y: 20}
    sendSize: {w: 125, h: 20}
    stopLoc: {x: 130, y: 20}
    stopSize: {w: 106, h: 20}
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
    cancelLoc: {x: 60, y: 90}
    cancelSize: {w: 60, h: 20}
  planetRadius: 64
  buttonSpacing: 5
  spriteNames:
    BACKGROUND: new AnimatedSprite(['starry_background.png'])
    ATTACK_SHIP: new AnimatedSprite(['attack_ship.png'])
    DEFENSE_SHIP: new AnimatedSprite(['defense_ship.png'])
    COLONY_SHIP: new AnimatedSprite(['colony_ship.png'])
    PROBE: new AnimatedSprite(['probe.png'])
    PLANET_BLUE: new AnimatedSprite(['planet_blue.png'])
    PLANET_BLUE_FUNGUS: new AnimatedSprite(['planet_blue_fungus.png'])
    PLANET_BLUE_FUNGUS_MAX: new AnimatedSprite(
      ['planet_blue_fungus_max_1.png', 'planet_blue_fungus_max_2.png',
       'planet_blue_fungus_max_3.png', 'planet_blue_fungus_max_4.png',
       'planet_blue_fungus_max_5.png', 'planet_blue_fungus_max_6.png',
       'planet_blue_fungus_max_7.png', 'planet_blue_fungus_max_8.png'], 1)
    PLANET_INVISIBLE: new AnimatedSprite(['planet_invisible.png'])
    PLANET_INVISIBLE_FUNGUS: new AnimatedSprite(['planet_invisible_fungus.png'])
    TITLE: new AnimatedSprite(['title.png'])
    FULL_SCREEN: new AnimatedSprite(['activate_full_screen_button.png'])
    UNFULL_SCREEN: new AnimatedSprite(['deactivate_full_screen_button.png'])
    MUTED: new AnimatedSprite(['muted_button.png'])
    UNMUTED: new AnimatedSprite(['unmuted_button.png'])
    CLOSE: new AnimatedSprite(['close_button.png'])
    NEXT: new AnimatedSprite(['next_button.png'])
    FEEDBACK: new AnimatedSprite(['feedback_button_hover.png'])
    OUTPOST_GATHERING: new AnimatedSprite(['outpost_buildings_gathering_1.png',
      'outpost_buildings_gathering_2.png'], 20)
    OUTPOST_NOT_GATHERING: new AnimatedSprite(
      ['outpost_buildings_not_gathering.png'])
    STATION_GATHERING: new AnimatedSprite(
      ['station_buildings_gathering_1.png',
       'station_buildings_gathering_2.png'], 20)
    STATION_NOT_GATHERING: new AnimatedSprite(
      ['station_buildings_not_gathering.png'])
    STATION_CONSTRUCTING: new AnimatedSprite(
      ['station_constructing_1.png', 'station_constructing_2.png',
       'station_constructing_3.png', 'station_constructing_4.png',
       'station_constructing_5.png', 'station_constructing_6.png',
       'station_constructing_7.png', 'station_constructing_8.png',
       'station_constructing_9.png', 'station_constructing_10.png',
       'station_constructing_11.png', 'station_constructing_12.png',
       'station_constructing_13.png', 'station_constructing_14.png',
       'station_constructing_15.png', 'station_constructing_16.png',
       'station_constructing_17.png'], 5)
    STATION_NOT_CONSTRUCTING: new AnimatedSprite(['station_not_constructing.png'])
    STATION_CONSTRUCTION: new AnimatedSprite(['station_construction.png'])
    OUTPOST_CONSTRUCTION: new AnimatedSprite(['outpost_construction.png'])
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
    RESTART_BUTTON_IDLE: new AnimatedSprite(['restart_button_idle.png'])
    RESTART_BUTTON_HOVER: new AnimatedSprite(['restart_button_hover.png'])
    QUIT_BUTTON_IDLE: new AnimatedSprite(['quit_button_idle.png'])
    QUIT_BUTTON_HOVER: new AnimatedSprite(['quit_button_hover.png'])
    NEXT_BUTTON_IDLE: new AnimatedSprite(['next_mission_button_idle.png'])
    NEXT_BUTTON_HOVER: new AnimatedSprite(['next_mission_button_hover.png'])
    SEND_RESOURCES_BUTTON_IDLE: new AnimatedSprite(
      ['send_resources_button_idle.png'])
    SEND_RESOURCES_BUTTON_HOVER: new AnimatedSprite(
      ['send_resources_button_hover.png'])
    STOP_SENDING_BUTTON_IDLE: new AnimatedSprite(
      ['stop_sending_button_idle.png'])
    STOP_SENDING_BUTTON_HOVER: new AnimatedSprite(
      ['stop_sending_button_hover.png'])
    MENU_BUTTON_IDLE: new AnimatedSprite(['menu_button_idle.png'])
    MENU_BUTTON_HOVER: new AnimatedSprite(['menu_button_hover.png'])
    RALLY_BUTTON_IDLE: new AnimatedSprite(['rally_button_idle.png'])
    RALLY_BUTTON_HOVER: new AnimatedSprite(['rally_button_hover.png'])
    NEXT_STATION_BUTTON_IDLE: new AnimatedSprite(['next_station_button_idle.png'])
    NEXT_STATION_BUTTON_HOVER: new AnimatedSprite(['next_station_button_hover.png'])
  Missions:
    w: 244
    h: 60
    textAlign: 'center'
    vAlign: 'top'
    restart:
      x: 41
      y: 45
      w: 63
      h: 20
    quit:
      x: 103
      y: 45
      w: 40
      h: 20
    next:
      x: 183
      y: 45
      w: 101
      h: 20
    close:
      x: 232
      y: 12
      w: 16
      h: 16
    menu:
      w: 50
      h: 20
    #one:
    two:
      startingProbes: 7
      startingColonyShips: 5
      startingAttackShips: 10
      resourceGoal: 50
    three:
      startingProbes: 2
      startingDefenseShips: 10
      resourceGoal: 150
      homeAvailable: 13
      homeResources: 30
      o1Available: 6
      o1Resources: 32
      o2Available: 7
      o2Resources: 30
      o3Available: 9
      o3Resources: 44
      o4Available: 10
      o4Resources: 26
  MainMenu:
    home:
      x: 0
      y: 0
    missions:
      x: 0
      y: -400
    mission:
      x: 0
      y: -400
      menu:
        w: 300
        h: 100
        message: "Mission\n\n" +
                 "Estimated Time: 5-10 minutes"
        textAlign: 'left'
        vAlign: 'top'
        font: "15px Arial"
        lineHeight: 19
        cancel:
          x: 245
          y: 100 - 15
          w: 60
          h: 20
        start:
          x: 145
          y: 100 - 15
          w: 101
          h: 20
    mission1:
      x: -400
      y: -750
      menu:
        w: 400
        h: 290
        message: "Mission 1\n\n" +
                 "We lost communications with a scouting party. They had several " +
                 "attack ships which we would rather not lose so we're giving " +
                 "you a probe to go check out the area. Try to bring any ships " +
                 "you find back safely, and be sure to exterminate any fungus " +
                 "hanging around. Oh, and please don't lose the probe, it's the " +
                 "only one we have right now.\n\n" +
                 "Tasks:\n" +
                 "  - Rescue at least one ship\n" +
                 "  - Eliminate all fungus\n" +
                 "  - Don't lose your probe."
        textAlign: 'left'
        vAlign: 'top'
        font: "15px Arial"
        lineHeight: 19
        cancel:
          x: 245
          y: 290 - 15
          w: 60
          h: 20
        start:
          x: 145
          y: 290 - 15
          w: 101
          h: 20
    mission2:
      x: 0
      y: -800
      menu:
        w: 400
        h: 365
        message: "Mission 2\n\n" +
                 "Many of our other scouting missions were successful and we " +
                 "now have several ships available. However we are very low on " +
                 "resources. We're giving you some colony ships and sending you " +
                 "to an area of low fungus activity. Use the colony ships to " +
                 "make outposts to gather resources, about 50 should do for " +
                 "now.\n\n" +
                 "We've outfitted your probes with scanners that can tell you " +
                 "how many resources you can gather from a planet and how fast " +
                 "they can be collected. Unfortunely the scanners are very short " +
                 "range, but after your success with the last mission we are " +
                 "confident you'll manage.\n\n" +
                 "Tasks:\n" +
                 "  - Gather a total of 50 resources"
        textAlign: 'left'
        vAlign: 'top'
        font: "15px Arial"
        lineHeight: 19
        cancel:
          x: 245
          y: 365 - 15
          w: 60
          h: 20
        start:
          x: 145
          y: 365 - 15
          w: 101
          h: 20
    mission3:
      x: 400
      y: -750
      menu:
        w: 400
        h: 200
        message: "Mission 3\n\n" +
                 "It turns out that 50 resorces wasn't enough, but the fungus is " +
                 "closing in on our outposts. Send in some defense ships to hold " +
                 "off the fungus long enough to gather 150 resources.\n\n" +
                 "Tasks:\n" +
                 "  - Gather a total of 150 resources"
        textAlign: 'left'
        vAlign: 'top'
        font: "15px Arial"
        lineHeight: 19
        cancel:
          x: 245
          y: 200 - 15
          w: 60
          h: 20
        start:
          x: 145
          y: 200 - 15
          w: 101
          h: 20
    extermination:
      x: 400
      y: 150
    small:
      x: 900
      y: 150
      menu:
        w: 400
        h: 200
        message: "Extermination - Small map\n\n" +
                 "Estimated Time: 5-10 minutes\n\n" +
                 "Task:\n" +
                 "  - Exterminate all fungus before it exterminates you.\n\n" +
                 "Note: It is recommended that you complete the missions before " +
                 "attempting this."
        textAlign: 'left'
        vAlign: 'top'
        font: "15px Arial"
        lineHeight: 15
        cancel:
          x: 245
          y: 200 - 15
          w: 60
          h: 20
        start:
          x: 145
          y: 200 - 15
          w: 101
          h: 20
    medium:
      x: 750
      y: 500
      menu:
        w: 400
        h: 200
        message: "Extermination - Medium map\n\n" +
                 "Estimated Time: 20-40 minutes\n\n" +
                 "Task:\n" +
                 "  - Exterminate all fungus before it exterminates you.\n\n" +
                 "Note: It is recommended that you complete the missions before " +
                 "attempting this."
        textAlign: 'left'
        vAlign: 'top'
        font: "15px Arial"
        lineHeight: 15
        cancel:
          x: 245
          y: 200 - 15
          w: 60
          h: 20
        start:
          x: 145
          y: 200 - 15
          w: 101
          h: 20
    large:
      x: 400
      y: 650
      menu:
        w: 400
        h: 200
        message: "Extermination - Large map\n\n" +
                 "Estimated Time: 60+ minutes\n\n" +
                 "Task:\n" +
                 "  - Exterminate all fungus before it exterminates you.\n\n" +
                 "Note: It is recommended that you complete the missions before " +
                 "attempting this."
        textAlign: 'left'
        vAlign: 'top'
        font: "15px Arial"
        lineHeight: 15
        cancel:
          x: 245
          y: 200 - 15
          w: 60
          h: 20
        start:
          x: 145
          y: 200 - 15
          w: 101
          h: 20
  units:
    probe:
      cost: 1
      turns: 1
      attack: .05
      defense: .05
      isStructure: false
    colonyShip:
      cost: 3
      turns: 3
      attack: .05
      defense: .05
      isStructure: false
    attackShip:
      cost: 5
      turns: 3
      attack: .5
      defense: 0.001
      isStructure: false
    defenseShip:
      cost: 6
      turns: 4
      attack: 0.001
      defense: .5
      isStructure: false
    fungus:
      attack: .50
      defense: 0.001
      growthPerTurn: 0
      growthChancePerTurn: 0.15
  structures:
    outpost:
      cost: 1
      turns: 2
      defense: .1
      isStructure: true
      sendRate: 5
    station:
      cost: 8
      turns: 3
      defense: .5
      isStructure: true
      sendRate: 5
    warpGate:
      cost: 7
      turns: 4
      defense: .1
      isStructure: true
  visibility:
    visible: 0
    discovered: 1
    undiscovered: 2
    size: 3
  minimumPlanetDistance: 500
  maximumAdjacencyDistance: 800
  minimumFungusDistance: 5000
  fungusInitialStrength: 1
  numberOfPlanetsInExterminateSmall: 20
  numberOfPlanetsInExterminateMedium: 50
  numberOfPlanetsInExterminateLarge: 100
  resources:
    homePlanetResources: 40
    homePlanetRate: 2
    meanResources: 30
    stdevResources: 90
    maxResources: 80
    minResources: 5
    meanRate: 1
    stdevRate: 15
    maxRate: 5
    minRate: 1
    sendRate: 5

config = root.config
