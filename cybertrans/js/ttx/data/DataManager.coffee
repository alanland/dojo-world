define [
    'dojo/_base/declare',
    'dojo/_base/lang'
    'dojo/request'
    'dojo/Deferred'
], (declare, lang, request, Deferred)->
    server = 'http://localhost:9000/'
    dataServer = 'http://localhost:9000/rest/data/'
    declare 'TestData', [],
        constructor: (args)->
            @delay = args.delay || 100
        handler: (deferred, args)->
            # args.tid
            # args.oid
            if args.tid == 'obe/test/data/wsoDefinitions/Login'
                deferred.resolve {username: 'wang', password: 'chengyi'}
            else
                deferred.resolve {}
        getService: ->
            lang.hitch this, 'call'

        call: (args)->
            result = new Deferred()
            result.then args.load, args.error, args.handle
            setTimeout lang.hitch(this, 'handler', result, args), @delay
            result

    declare null,
        app: null
        service: null
        constructor: (args)->
            if args && args.dataService
                @service = args.dataService # todo
            else
                @service = new TestData({}) # todo

        getJson: (type)->
            request(dataServer + type, {handleAs: 'json'})
        get: (type)->
            request(server + type, {handleAs: 'json'})

        getWsoDefinition: (tid)->
            request(dataServer + 'wsoDefinition/' + tid, {handleAs: 'json'})
        getBillDefinition: (tid)->
            request(dataServer + 'billDefinition/' + tid, {handleAs: 'json'})

        get: (url)->
            request(server + url, {handleAs: 'json'})
        post: (url, data, options = {})->
            request(server + url, lang.mixin({
                handleAs: 'json'
                method: 'post'
                data: JSON.stringify(data)
                headers: {'Content-Type': 'application/json'}
            }, options))
        put: (url, data, options = {})->
            request(server + url, lang.mixin({
                handleAs: 'json'
                method: 'put'
                data: JSON.stringify(data)
                headers: {'Content-Type': 'application/json'}
            }, options))
        delete: (url, data, options = {})->
            request(server + url, lang.mixin({
                handleAs: 'json'
                method: 'delete'
                data: JSON.stringify(data)
                headers: {'Content-Type': 'application/json'}
            }, options))


#        get: (type, oid)->
#            # 返回一个Deferred
#            @service.call tid: type, oid: oid