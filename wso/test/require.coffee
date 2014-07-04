require [
  'dojo/_base/declare',
  'dojo/_base/lang'
], (lang, declare)->
  declare null, {
    test: 1,
    func: ->
      console.log 123
  }
