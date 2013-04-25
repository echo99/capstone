{Camera} = require '../app/src/util/Camera'

suite 'Camera', ->
  width = 700
  height = 500
  halfWidth = width / 2
  halfHeight = height / 2
  camera = null

  suite "(size: #{width} x #{height})", ->
    setup ->
      camera = new Camera(0, 0, width, height)

    suite '.constructor', ->
      test 'should be at (0,0)', ->
        assert.equal(camera.x, 0)
        assert.equal(camera.y, 0)
      test 'should have the given width', ->
        assert.equal(camera.width, width)
      test 'should have the given height', ->
        assert.equal(camera.height, height)
      test 'should have zoom of 1.0', ->
        assert.equal(camera.zoom, 1.0)

    suite '#getScreenCoordinates', ->
      suite 'with coordinate (0, 0)', ->
        coords =
          x: 0
          y: 0
        startCoords =
          x: halfWidth+coords.x
          y: halfHeight+coords.y

        test "should start at (#{startCoords.x}, #{startCoords.y})", ->
          assert.deepEqual(camera.getScreenCoordinates(coords), startCoords)

        cameraOffset1 =
          x: -250
          y: 0
        expCoords1 =
          x: startCoords.x + cameraOffset1.x
          y: startCoords.y + cameraOffset1.y
        test "moving camera to (#{cameraOffset1.x}, #{cameraOffset1.y})", ->
          camera.setPosition(cameraOffset1.x, cameraOffset1.y)
          assert.deepEqual(camera.getScreenCoordinates(coords), expCoords1)
          # console.log "Screen coordinates:"
          # console.log camera.getScreenCoordinates(coords)

        cameraOffset2 =
          x: 0
          y: -250
        expCoords2 =
          x: startCoords.x + cameraOffset2.x
          y: startCoords.y + cameraOffset2.y
        test "moving camera to (#{cameraOffset2.x}, #{cameraOffset2.y})", ->
          camera.setPosition(cameraOffset2.x, cameraOffset2.y)
          # console.log coords
          assert.deepEqual(camera.getScreenCoordinates(coords), expCoords2)

      suite 'with coordinate (350, 0)', ->
        coords =
          x: 350
          y: 0
        startCoords =
          x: halfWidth+coords.x
          y: halfHeight+coords.y
        cameraOffset =
          x: -halfWidth
          y: 0
        expCoords =
          x: startCoords.x + cameraOffset.x
          y: startCoords.y + cameraOffset.y
        test "should start at (#{startCoords.x}, #{startCoords.y})", ->
          assert.deepEqual(camera.getScreenCoordinates(coords), startCoords)
        test "moving camera to (#{cameraOffset.x}, #{cameraOffset.y})", ->
          camera.setPosition(cameraOffset.x, cameraOffset.y)
          assert.deepEqual(camera.getScreenCoordinates(coords), expCoords)
          # console.log camera.getScreenCoordinates(coords)

