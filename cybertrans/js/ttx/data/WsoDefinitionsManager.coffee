define [
    'dojo/_base/declare',
    'dojo/_base/lang'
    'dojo/Deferred'
    './DataManager'
], (declare, lang, Deferred, DataManager) ->
    declare null,
        # summary:
        #       获取wso定义

        # _service: baf/test/mocks/services/Base || 其他服务类
        #       该服务类有个 call({content:{tid: tid}}) 方法，返回一个 Deferred，
        #       deferred.then (wsoDefinition)-> do Something
        _service: null

        constructor: (args)->
#            @_service = args.wsoDefinitionsService;
            @_service = new DataManager()
            @_cache = [];

        getBill: (typeValue)->
            # todo cache
            @_service.getViewModel(typeValue)


        get: (tid)->
            result
            if tid.startsWith('amd') # todo amd 形式的加载
                type = ''.substr(3)
                require type, (t)->
                    result = t
                return result
            else
                if (@_cache[tid])
                    result = new Deferred();
                    result.then(@_cache[tid]);
                else
                    result = @_service.getWsoDefinition(tid);
                #           todo     result.then(lang.hitch(this, "_catchServerResponse", result, tid));
                return result

    # 这个测试方法没有必要
        _catchServerResponse: (theDeferred, tid, wsoDefinition) ->
            if (!wsoDefinition.tid || wsoDefinition.tid != tid)
                return new Error('baf.data.WsoDefinitionsManager: failed to get wsoDefinition');
            else
                #continue with callback chain...
                return wsoDefinition;