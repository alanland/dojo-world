window.x = 1
require [
  'dojo/_base/lang'
], (lang)->
  o =
    x: 2

  func1 = ->
    console.log this.x

  x = 3
  func2 = lang.hitch o, func1
  func3 = lang.hitch null, func1
  func4 = lang.hitch null, func1
  func5 = lang.hitch func1
  func6 = lang.partial func1

  x = 4
  func1() # 1
  func2() # 2
  func3() # 1
  func4() # 1
  func5() # 1
  func6() # 1