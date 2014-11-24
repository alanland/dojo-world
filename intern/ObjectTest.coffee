define [
  'intern!object'
  'intern/chai!assert'
], (registerSuite, assert)->
  o1 = null
  registerSuite
    name: 'demo widget'
    setup: ->
      o1 = [1,2,3,4]
    tearDown: ->
      o1 = undefined
    creation: ->
      assert o1.length>0, 'o1 length > 0'
      assert o1.length>10, 'o1 length > 10'
      assert o1.length>2, 'o1 length > 2'
