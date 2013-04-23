{Elements} = require '../app/src/gui/uielements'

suite 'UIElement', ->
  test 'should be visible when initialized', ->
    elem = new Elements.UIElement()
    assert.isTrue(elem.visible)


suite 'BoxElement', ->
  box = null
  x = 10
  y = 20
  w = 50
  h = 40
  cx = -Math.round(w/2)
  cy = -Math.round(h/2)

  setup ->
    box = new Elements.BoxElement(x, y, w, h)

  test '.constructor', ->
    assert.equal(box.x, x)
    assert.equal(box.y, y)
    assert.equal(box.w, w)
    assert.equal(box.h, h)

  suite '#containsPoint', ->
    test 'should calculate center offset correctly', ->
      assert.equal(box.cx, cx)
      assert.equal(box.cy, cy)
    test 'should contain points inside box', ->
      assert.isTrue(box.containsPoint(x, y))
      assert.isTrue(box.containsPoint(x+cx+1, y+cy+1))
      assert.isTrue(box.containsPoint(x+cx+w-1, y+cy+h-1))
    test 'should contain points on edge of box', ->
      assert.isTrue(box.containsPoint(x+cx, y+cy))
      assert.isTrue(box.containsPoint(x+cx+w, y+cy+h))
    test 'should not contain points to left of box', ->
      assert.isFalse(box.containsPoint(x+cx-1, y))
    test 'should not contain points to right of box', ->
      assert.isFalse(box.containsPoint(x+cx+w+1, y))
    test 'should not contain points above box', ->
      assert.isFalse(box.containsPoint(x, y+cy-1))
    test 'should not contain points below box', ->
      assert.isFalse(box.containsPoint(x, y+cy+h+1))

suite 'RadialElement', ->
  circle = null
  x = 100
  y = 200
  r = 10
  circleStr = "Circle {x:#{x},y:#{y},r:#{r}}"

  setup ->
    circle = new Elements.RadialElement(x, y, r)

  test '.constructor', ->
    assert.equal(circle.x, x)
    assert.equal(circle.y, y)
    assert.equal(circle.r, r)

  suite '#containsPoint', ->
    test 'should contain points inside circle', ->
      assert.isTrue(circle.containsPoint(x, y))
      assert.isTrue(circle.containsPoint(x+r-1, y))
      assert.isTrue(circle.containsPoint(x-r+1, y))
      assert.isTrue(circle.containsPoint(x, y+r-1))
      assert.isTrue(circle.containsPoint(x, y-r+1))
    test 'should contain points on edge of circle', ->
      assert.isTrue(circle.containsPoint(x+r, y))
      assert.isTrue(circle.containsPoint(x-r, y))
      assert.isTrue(circle.containsPoint(x, y+r))
      assert.isTrue(circle.containsPoint(x, y-r))
    test 'should not contain points outside circle', ->
      assert.isFalse(circle.containsPoint(x+r, y+r),
        "#{circleStr} should not contain (#{x+r},#{y+r})")
      assert.isFalse(circle.containsPoint(x-r, y-r),
        "#{circleStr} should not contain (#{x-r},#{y-r})")
      assert.isFalse(circle.containsPoint(x+r+1, y),
        "#{circleStr} should not contain (#{x+r+1},#{y})")
      assert.isFalse(circle.containsPoint(x-r-1, y),
        "#{circleStr} should not contain (#{x-r-1},#{y})")
      assert.isFalse(circle.containsPoint(x, y+r+1),
        "#{circleStr} should not contain (#{x},#{y+r+1})")
      assert.isFalse(circle.containsPoint(x, y-r-1),
        "#{circleStr} should not contain (#{x},#{y-r-1})")