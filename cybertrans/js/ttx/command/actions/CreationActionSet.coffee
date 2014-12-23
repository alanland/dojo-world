define [
    'dojo/_base/declare'
    'dojo/request'
], (declare, request)->
    declare null, {
        test: ->
            console.log 'creation action set: test'
    }