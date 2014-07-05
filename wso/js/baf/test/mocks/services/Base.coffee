define [
    'dojo/_base/declare'
    'dojo/_base/lang'
    'dojo/Deferred'
], (declare, lang, Deferred)->
    declare null,
        # summary:
        #       mock服务的父类
        constructor: (args) ->
            @delay = args.delay || 1

        getService: ->
            lang.hitch this, 'call'

        call: (args)->
            result = new Deferred()
            result.then args.success, args.error, args.progress # todo
            setTimeout lang.hitch(this, 'handler', result, args), @delay
            result

        handler: (deferred, args)->
            throw new Error 'baf.test.mocks.services.Base: handler not specified'
