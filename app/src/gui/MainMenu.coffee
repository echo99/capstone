class MainMenu
  instance = null

  class PrivateMainMenu
    that: PrivateMainMenu

    @mx: 0
    @my: 0
    @offsetX: 0
    @offsetY: 0

    universeSize:
      width: 1500
      height: 1200

    planets: [
      ['home', 750, 550, true, true],
      ['missions', 450, 700, false, true],
      ['quick play', 1050, 700, false, true]
      ['mission 1', 50, 650, false, false]
      ['mission 2', 125, 850, false, false]
      ['mission 3', 300, 1050, false, false]
      ['mission 4', 500, 1100, false, false]
    ]

    @selPlanet: 0

    allowedPlanets: [0, 1, 2]

    probe:
      orbitRadius: 70
      angularVelocity: Math.PI / 90
      angle: 0

    constructor: (@ctx, @sheet) ->
      # canvas = ctx.canvas
      # ctx.clearRect(0,0,canvas.width,canvas.height)
      # ctx.save()
      # xPos = (canvas.width/2) - (@universeSize.width/2)
      # yPos = (canvas.height/2) - (@universeSize.height/2)
      # ctx.translate(xPos, yPos)
      # for planet in @planets
      #   sheet.drawSprite(SpriteNames.PLANETS[0], planet[1], planet[2], ctx, 0.5)
      # ctx.restore()
      ctx.font = '15px sans-serif'
      ctx.textAlign = 'center'
      ctx.strokeStyle = 'white'
      # setInterval @draw, 30

    startAnim: ->
      ctx = @ctx
      univSize = @universeSize
      planets = @planets
      sheet = @sheet
      probe = @probe
      selPlanet = @selPlanet
      that = @that
      instance = @

      draw = ->
        canvas = ctx.canvas
        ctx.clearRect(0,0,canvas.width,canvas.height)
        ctx.save()
        # xPos = (canvas.width/2) - (univSize.width/2)
        # yPos = (canvas.height/2) - (univSize.height/2)

        xPos = Math.floor((canvas.width/2) - (planets[that.selPlanet][1]))
        yPos = Math.floor((canvas.height/2) - (planets[that.selPlanet][2]))
        that.offsetX = xPos
        that.offsetY = yPos

        mx = that.mx + (-xPos)
        my = that.my + (-yPos)
        # console.log("#{mx}, #{my}")

        ctx.translate(xPos, yPos)

        ctx.save();
        ctx.strokeStyle = 'rgba(200,200,200,0.3)';
        ctx.lineWidth = 6;
        ctx.beginPath();
        ctx.moveTo(planets[1][1], planets[1][2]);
        ctx.lineTo(planets[0][1], planets[0][2]);
        ctx.lineTo(planets[2][1], planets[2][2]);
        ctx.stroke();
        ctx.restore();

        ctx.font = '15px sans-serif'
        ctx.textAlign = 'center'
        ctx.strokeStyle = 'rgba(255,255,255,0.5)'

        planetId = 0
        selPlan = null
        for planet in planets
          dx = mx - planet[1]
          dy = my - planet[2]
          
          if planetId in instance.allowedPlanets and dx*dx + dy*dy < 1000
            # ctx.fillRect(planet[1], planet[2], 100, 100)
            # ctx.beginPath();
            # ctx.arc(planet[1], planet[2], 40, 0, 2 * Math.PI, false);
            # ctx.fillStyle = 'rgba(255,255,255,0.5)';
            # ctx.fill();
            # create radial gradient (x1, y1, r1, x2, y2, r2)
            ctx.save()
            ctx.beginPath();
            ctx.arc(planet[1], planet[2], 50, 0, 2 * Math.PI, false);
            grd = ctx.createRadialGradient(planet[1], planet[2], 20,
              planet[1], planet[2], 50)
            grd.addColorStop(0, 'white')
            grd.addColorStop(1, 'rgba(255,255,255,0)')
            ctx.fillStyle = grd
            ctx.fill()
            ctx.restore()

          if planet[4]
            sheet.drawSprite(SpriteNames.PLANET_BLUE, planet[1], planet[2], ctx, 0.5)
            sheet.drawSprite(SpriteNames.WARP_GATE, planet[1], planet[2], ctx, 1)
          else
            sheet.drawSprite(SpriteNames.PLANET_INVISIBLE, planet[1], planet[2], ctx, 0.5)

          if planet[3]
            # @ctx.restore()
            ctx.save()
            # @ctx.translate(xPos + planet[1], yPos + planet[2])
            ctx.translate(planet[1], planet[2])
            ctx.beginPath()
            ctx.arc(0, 0, probe.orbitRadius, 0, 2*Math.PI, false);
            ctx.lineWidth = 2;
            ctx.strokeStyle = 'rgba(200,200,100,0.3)';
            ctx.stroke();
            ctx.rotate(probe.angle)
            probe.angle += probe.angularVelocity
            sheet.drawSprite(SpriteNames.PROBE, 0, -probe.orbitRadius, ctx)
            ctx.restore()
            ctx.strokeStyle = 'white'
            ctx.strokeText(planet[0], planet[1], planet[2] - 45);
            selPlan = planet
            # @ctx.translate(xPos, yPos)
          else
            ctx.strokeStyle = 'rgba(255,255,255,0.5)'
            ctx.strokeText(planet[0], planet[1], planet[2] - 45);
          planetId++
        
        # grd = ctx.createRadialGradient(selPlan[1], selPlan[2], 256,
        #   selPlan[1], selPlan[2], 512)
        # grd.addColorStop(0, 'rgba(8,8,8,0)')
        # grd.addColorStop(1, 'rgba(8,8,8,0.5)')
        # ctx.fillStyle = grd
        # ctx.fillRect(-xPos, -yPos, canvas.width, canvas.height)
        
        ctx.restore()
        sheet.drawSprite(SpriteNames.TITLE, canvas.width/2, 75, ctx)

        AnimatedSprite.drawCounter++

      setInterval draw, 30

    moveLeft: ->
      # @selPlanet = 1
      # PrivateMainMenu.selPlanet = 1
      if @that.selPlanet == 0
        @that.selPlanet = 1
        @planets[0][3] = false
        @planets[1][3] = true
      else if @that.selPlanet == 2
        @that.selPlanet = 0
        @planets[2][3] = false
        @planets[0][3] = true

    moveRight: ->
      if @that.selPlanet == 0
        @that.selPlanet = 2
        @planets[0][3] = false
        @planets[2][3] = true
      else if @that.selPlanet == 1
        @that.selPlanet = 0
        @planets[1][3] = false
        @planets[0][3] = true

    mouseMove: (mx, my) ->
      @that.mx = mx
      @that.my = my
      # alert("#{mx}, #{my}")

    click: (mx, my) ->
      posX = mx + (-@that.offsetX)
      posY = my + (-@that.offsetY)
      for i in [0..2]
        planet = @planets[i]
        dx = posX - planet[1]
        dy = posY - planet[2]
        # alert("#{dx}, #{dy}")
        if dx*dx + dy*dy < 1000
          @planets[@that.selPlanet][3] = false
          @planets[i][3] = true
          @that.selPlanet = i
          break



  @get: (ctx, sheet) ->
    instance ?= new PrivateMainMenu(ctx, sheet)