define [
    'dojo/_base/declare',
    'dojo/_base/lang'
    'dojo/_base/array'
    'dojo/request'
    'dojo/Deferred'
    'dojo/store/Memory'
], (declare, lang, array, request, Deferred, Memory)->
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

    cacheIdProp = 'client_cache_url'
    declare null,
        app: null
        service: null
        cache: null
        constructor: (args)->
#            if args && args.dataService
#                @service = args.dataService # todo
#            else
#                @service = new TestData({}) # todo
            @cache = new Memory(data: [], idProperty: cacheIdProp)

        cacheObject: (key, value)->
            value[cacheIdProp] = key
            @cache.put(value)
        clearCache: -> # todo 内存检测，看看直接new一个以及setData，原来的内存有没有释放
            that = @
            data = @cache.query()
            array.forEach data, (item)->
                that.cache.remove item[cacheIdProp]
#            @cache = new Memory(data: [], idProperty: cacheIdProp)

        getJson: (type)->
            request(dataServer + type, {handleAs: 'json'})

        getWsoDefinition: (tid)-> ## todo @Deprecated
            console.error 'deprecated'
            @get(dataServer + 'wsoDefinition/' + tid, {cache: true})
        getBillDefinition: (tid)-> ## todo @Deprecated
            console.error 'deprecated'
            request(dataServer + 'billDefinition/' + tid, {handleAs: 'json'})

        get: (url, options = {})->
            options = lang.mixin {
                cache: false
                updateCache: false # default cache=true
            }, options
            if options.updateCache # 如果更新缓存，默认使用缓存
                options.cache = true

            that = @
            url = url.substr(1) if url.indexOf('/') == 0
            deferred = new Deferred()
            if(options.cache) # 使用缓存
                doRequest = options.updateCache # 是否要请求数据
                cached = null
                if !doRequest # 如果不需要，获取当前缓存
                    cached = that.cache.get(url)
                if !doRequest and !cached # 如果不需要，并且当前缓存没有，还是需要去数据
                    doRequest = true
                if doRequest # 取数据
                    deferred = request(server + url, lang.mixin({handleAs: 'json'}, options))
                    deferred.then(
                        (data)->
                            data[cacheIdProp] = url
                            that.cache.put(data)
                    )
                else # 不取数据
                    deferred.resolve cached
            else # 不使用缓存
                deferred = request(server + url, lang.mixin({handleAs: 'json'}, options))
            deferred

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


        getViewModel: (key)-> # 获取单据界面定义
            @get("rest/creation/viewModels/#{key}", {cache: true})
        getBillModel: (key)->
            @get("rest/creation/billModels/#{key}", {cache: true})
        getTableModel: (key)->
            @get("rest/creation/tableModels/#{key}", {cache: true})

