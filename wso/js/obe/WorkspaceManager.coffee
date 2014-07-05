define [
  'dojo/_base/declare',
  'dojo/_base/lang'
  'dojo/topic',
  'dijit/layout/TabContainer'
  'baf/dijit/Wso'
], (declare, lang, topic, TabContainer, Wso)->
  nullObjectValue = {type: 0, oid: 0, form: null}
  declare null,
    currentObject: null
    usetab: true
    tabContainer: null
    constructor: (args)->
      @currentObject = nullObjectValue
      #            topic.subscribe 'focusNavNode', lang.hitch(this, @_showObject)
      topic.subscribe 'focusNavNode', lang.hitch @, @_showObject

    _showObject: (store, item)->
      type = item['tid'] # the wosDefinition type
      oid = item['oid'] # the object id
      nid = item['id'] # the navigator id
      currentObject = @currentObject
      return if currentObject.type == type && currentObject.oid == oid

      # TODO: search for non-current, but loaded object
      # load the new current object
      data = main.dataManager.get(type, oid) # todo remove main
      wsoDef = main.wsoDefinitionsManager.get(type)
      theNewObject = new Wso data: data, wsoDef: wsoDef, closable: true,

      # destroy the old current object...
#      @destroy()

      if @usetab and not @tabContainer
        @tabContainer = new TabContainer
          style: "height: 500px; width: 100%;"
#          tabPosition: "left-h"
        main.appContainer.addChild lang.mixin @tabContainer,
          region: 'center'

      # display the new current object...
      if @usetab
        @tabContainer.addChild theNewObject
      else
        main.appContainer.addChild lang.mixin theNewObject,
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
        if @usetab
          @tabContainer.removeChild currentObject.form
        else
          main.appContainer.removeChild currentObject.form
        currentObject.form.destroyRecursive()
      currentObject = nullObjectValue




