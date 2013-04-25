# Testing the Planet class

{Planet} = require "../app/src/backend/Planet"
{config} = require "../app/src/config"

suite 'Planet', ->
  units = config.units

  suite '#Build', ->
    test 'Building fails when not enough available resources.', ->
      testPlanet = new Planet(0, 0, 100, 0)
      assert.throws(-> testPlanet.build(units.probe));
      testPlanet._availableResources = 2
      assert.throws(-> testPlanet.build(units.attackShip));
      assert.doesNotThrow(-> testPlanet.build(units.probe)); 