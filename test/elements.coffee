{Elements} = require '../app/src/gui/uielements'

suite 'UIElements', ->
  test 'should be visible when initialized', ->
    elem = new Elements.UIElement()
    assert.isTrue(elem.visible)


suite 'BoxElements', ->
  box = null
  x = 10
  y = 20
  w = 50
  h = 40

  setup ->
    box = new Elements.BoxElement(x, y, w, h)

  test '.constructor', ->
    assert.equal(box.x, x)
    assert.equal(box.y, y)
    assert.equal(box.w, w)
    assert.equal(box.h, h)

  suite '#containsPoint', ->
    test 'should contain points inside box', ->
      assert.isTrue(box.containsPoint(x+1, y+1))
      assert.isTrue(box.containsPoint(x+w-1, y+h-1))
    test 'should contain points on edge of box', ->
      assert.isTrue(box.containsPoint(x, y))
      assert.isTrue(box.containsPoint(x+w, y+h))
    test 'should not contain points to left of box', ->
      assert.isFalse(box.containsPoint(x-1, y))
    test 'should not contain points to right of box', ->
      assert.isFalse(box.containsPoint(x+w+1, y))
    test 'should not contain points above box', ->
      assert.isFalse(box.containsPoint(x, y-1))
    test 'should not contain points below box', ->
      assert.isFalse(box.containsPoint(x, y+h+1))