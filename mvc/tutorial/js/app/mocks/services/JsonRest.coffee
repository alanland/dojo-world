define [
    'dojo/_base/declare'
    'dojo/_base/lang'
    'dojo/Deferred'
    'dojo/store/Memory'
    'dojo/store/Observable'
], (declare, lang, Deferred, Memory, Observable)->
    declare null,
        # summary:
        #       模拟 JsonRest，用于开发中的测试


        constructor: (options)->
            # summary:
            #       模拟 JsonRest，用于开发中的测试
            # options: dojo/store/JsonRest
            #       配置同 dojo/store/JsonRest
            @inherited arguments
            @delay = options.delay || 100
            declare.safeMixin this, options
            @_constructor()

        _memory: null

        _constructor: ->
            @_memory = new Observable(Memory({
                data: [
                    {id: 1, name: "one", prime: false },
                    {id: 2, name: "two", even: true, prime: true},
                    {id: 3, name: "three", prime: true},
                    {id: 4, name: "four", even: true, prime: false},
                    {id: 5, name: "five", prime: true}
                ]
            }))
            @getIdentity = @_memory.getIdentity


        query: (query, options)->
            # summary
            #       模拟服务端交互
            result = new Deferred()
            setTimeout lang.hitch(this, '_query', result, query, options), @delay
            result

        _query: (deferred, query, options)->
            deferred.resolve(lang.hitch(@_memory, @_memory.query)(query, options))

        put: (object, options)->
            result = new Deferred()
            setTimeout lang.hitch(this, '_put', result, object, options), @delay
            result

        _put: (deferred, object, options)->
            deferred.resolve(lang.hitch(@_memory, @_memory.put)(object, options))


