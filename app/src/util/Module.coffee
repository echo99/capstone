# Code taken from the The Little Book on CoffeeScript
moduleKeywords = ['extended', 'included']

# An extensible class that enables the use of multiple inheritance and
# interfaces/mixins
#
# @see http://arcturo.github.io/library/coffeescript/03_classes.html
#
class Module
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
