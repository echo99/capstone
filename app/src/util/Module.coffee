# Code taken from the CoffeeScript Cookbook
moduleKeywords = ['extended', 'included']

class Module
  ###
  An extensible class that enables the use of multiple inheritance and
  interfaces/mixins

  Courtesy: [CoffeeScript Cookbook](http://coffeescriptcookbook.com/)
  ###

  @extend: (obj) ->
    for key, value of obj when key not in moduleKeywords
      @[key] = value

    obj.extended?.apply(@)
    this

  @include: (obj) ->
    for key, value of obj when key not in moduleKeywords
      # Assign properties to the prototype
      @::[key] = value

    obj.included?.apply(@)
    this
