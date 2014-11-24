define [
    'dojo/_base/declare'
    'dojo/_base/lang'
    'dojo/Deferred'
], (declare, lang, Deferred)->
    declare null,
        constructor: (args)->
            @delay = args.delay || 100

        getService: ->
            lang.hitch this, 'call'

        call: (args)->
            result = new Deferred()
            result.then args.load, args.error, args.handle
            setTimeout lang.hitch(this, 'handler', result, args), @delay
            result

        handler: (deferred, args)->
            throw new Error 'Base service handler not specified'



