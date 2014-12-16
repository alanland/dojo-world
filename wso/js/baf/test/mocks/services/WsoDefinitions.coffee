define [
  'dojo/_base/declare'
  'baf/test/mocks/services/Base'
  'dojo/request'
], (declare, Base, request)->
  declare Base,
    # summary:
    #       Wso定义 获取的服务类，根据菜单指定的tid，得到 wso 定义



    handler: (deferred, args)->
      # summary:
      #       获取定义
      # deferred: dojo/Deferred
      # args: Object
      #       args.content.tid 是wso对应的模块名称
      #       args.content.type


      if args.content.tid.endsWith '.json'
        request('js/'+args.content.tid,{handleAs:'json'}).then(
          (data)->
            deferred.resolve data
        );
      else
        require [args.content.tid], (type)->
          deferred.resolve type
