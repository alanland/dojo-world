define [
  'dojo/_base/declare',
  'dojo/_base/lang'
  'dojo/Deferred'
], (declare, lang, Deferred) ->
  declare null,
    # summary:
    #       获取wso定义

    # _service: baf/test/mocks/services/Base || 其他服务类
    #       该服务类有个 call({content:{tid: tid}}) 方法，返回一个 Deferred，
    #       deferred.then (wsoDefinition)-> do Something
    _service: null

    constructor: (args)->
      @_service = args.wsoDefinitionsService;
      @_cache = [];

    get: (tid)->
      result
      if (@_cache[tid])
        result = new Deferred();
        result.then(@_cache[tid]);
      else
        result = @_service.call({content: {tid: tid}});
      #           todo     result.then(lang.hitch(this, "_catchServerResponse", result, tid));
      result

  # 这个测试方法没有必要
    _catchServerResponse: (theDeferred, tid, wsoDefinition) ->
      if (!wsoDefinition.tid || wsoDefinition.tid != tid)
        return new Error('baf.data.WsoDefinitionsManager: failed to get wsoDefinition');
      else
        #continue with callback chain...
        return wsoDefinition;