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
    usetab: false
    tabContainer: null
    constructor: ->
      @currentObject = nullObjectValue
#      topic.subscribe 'focusNavNode', lang.hitch @, @_showObject
      topic.subscribe 'clickNavNode', lang.hitch @, @_showObject

    getWsoByType: (item)->
      # item: navigator item
      return if not @usetab
      results = []
      for child in @tabContainer.getChildren()
        cItem = child.navigator
        if cItem.tid == item.tid and cItem.oid == item.oid
          results.push child
      results

    _showObject: (item)->
      # todo store 什么时候穿寄来的，还没有使用
      type = item['tid'] # the wosDefinition type
      oid = item['oid'] # the object id
      nid = item['id'] # the navigator id
      currentObject = @currentObject
      return if currentObject.type == type && currentObject.oid == oid

      # TODO: search for non-current, but loaded object
      # load the new current object
      data = main.dataManager.get(type, oid) # todo remove main
      wsoDef = main.wsoDefinitionsManager.get(type)
      theNewObject = new Wso {
        data: data,wsoDef: wsoDef, closable: true,
        navigator: item,
        title: item.name
      }

      # destroy the old current object...
      @destroy()

      # 如果使用tab，初始化tabContainer
      if @usetab and not @tabContainer
        @tabContainer = new TabContainer
          style: "height: 500px; width: 100%;"
          tabPosition: "left-h"
        main.appContainer.addChild lang.mixin @tabContainer,
          region: 'center'

      # 显示新的当前界面
      if @usetab
        sameType = @getWsoByType(item)
        if sameType.length>0
          @tabContainer.selectChild sameType[0]
        else
          @tabContainer.addChild theNewObject
          @tabContainer.selectChild theNewObject
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
      if not @usetab
        if currentObject.form
#          @tabContainer.removeChild currentObject.form
#        else
          main.appContainer.removeChild currentObject.form
          currentObject.form.destroyRecursive()
      currentObject = nullObjectValue




