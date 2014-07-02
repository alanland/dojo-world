define [
    'dojo/_base/declare'
    'baf/test/mocks/services/Base'
], (declare, Base)->
    declare Base,
        # summary:
        #       Wso定义 获取的服务类，根据菜单指定的tid，得到 wso 定义

        handler: (deferred, args)->
            # summary:
            #       获取定义
            # deferred: dojo/Deferred
            # args: Object
            #       args.content.tid 是wso对应的模块名称
            require [args.content.tid], (type)->
                deferred.resolve type