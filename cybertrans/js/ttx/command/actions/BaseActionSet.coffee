define [
    'dojo/_base/declare'
    'dojo/_base/lang'
], (declare, lang)->
    declare null, {
        wso: null
        app: null
        constructor: (args)->
            lang.mixin(this, args) if args
            @app = @wso.app
            @postCreated()
        postCreated: -> null
    }