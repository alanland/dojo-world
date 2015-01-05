define [
    'dojo/_base/declare'
    'dojo/Deferred'
    'dojo/store/JsonRest'
], (declare, Deferred, JsonRest)->
    declare [JsonRest], {
        muteQuery: false #true不进行服务端查询
        constructor: (options)->
            @inherited arguments
        query: (query, options)->
            res = new Deferred()
            res.resolve([])
            return res if @muteQuery
            @inherited arguments

    }