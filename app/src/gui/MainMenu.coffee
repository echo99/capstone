class MainMenu
  instance = null

  class PrivateMainMenu
    universeSize:
      width: 400
      height: 400

    planets: [
      ['home', 200, 150, true],
      ['missions', 50, 300, false],
      ['quick play', 350, 300, false]
    ]

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
      draw = ->
        canvas = ctx.canvas
        ctx.clearRect(0,0,canvas.width,canvas.height)
        ctx.save()
        xPos = (canvas.width/2) - (univSize.width/2)
        yPos = (canvas.height/2) - (univSize.height/2)
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
        ctx.strokeStyle = 'white'

        for planet in planets
          sheet.drawSprite(SpriteNames.PLANETS[0], planet[1], planet[2], ctx, 0.5)

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
            # @ctx.translate(xPos, yPos)

          ctx.strokeText(planet[0], planet[1], planet[2] - 45);
        ctx.restore()
        sheet.drawSprite(SpriteNames.TITLE, canvas.width/2, 75, ctx)
      setInterval draw, 30

  @get: (ctx, sheet) ->
    instance ?= new PrivateMainMenu(ctx, sheet)