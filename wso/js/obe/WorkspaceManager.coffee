define [
    'dojo/_base/declare',
    'dojo/_base/lang'
    'dojo/topic',
    'baf/dijit/Wso'
], (declare, lang, topic, Wso)->
    nullObjectValue = {type: 0, oid: 0, form: null}
    declare null,
        constructor: ->
            @currentObject = nullObjectValue
#            topic.subscribe 'focusNavNode', lang.hitch(this, @_showObject)
            topic.subscribe 'focusNavNode', lang.hitch @,@_showObject

        _showObject: (store, item)->
            type = item['tid'] # the wosDefinition type
            oid = item['oid'] # the object id
            nid = item['id'] # the navigator id
            currentObject = @currentObject
            return if currentObject.type == type && currentObject.oid == oid

            # TODO: search for non-current, but loaded object
            # load the new current object
            data = main.dataManager.get(oid) # todo remove main
            wsoDef = main.wsoDefinitionsManager.get(type)
            theNewObject = new Wso data: data, wsoDef: wsoDef

            # destroy the old current object...
            @destroy()

            # display the new current object...
            main.appContainer.addChild dojo.mixin theNewObject,
                region: 'center'
                id: nid + '_wso'
            main.appContainer.startup()

            # record the current state...
            currentObject.type = type
            currentObject.oid = oid
            currentObject.nid = nid
            currentObject.form = theNewObject

        destroy: ->
            currentObject = @currentObject
            if currentObject.form
                main.appContainer.removeChild currentObject.form
                currentObject.form.destroyRecursive()
            currentObject = nullObjectValue




