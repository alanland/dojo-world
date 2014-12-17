define [
    'dojo/_base/declare',
    'dojo/_base/lang'
    'dojo/topic',
    'dijit/layout/ContentPane'
    'dijit/layout/TabContainer'
    'ttx/dijit/Wso'
    'ttx/dijit/WsoBill'
], (declare, lang, topic, ContentPane, TabContainer, Wso, WsoBill)->
    nullObjectValue = {type: 0, oid: 0, form: null}
    declare null,
        app: null
        current: {}
        useTab: false
        wsoContainer: null
        constructor: (args)->
            @inherited(arguments);
            @app = args.app
            #      topic.subscribe 'focusNavNode', lang.hitch @, @_showObject
            topic.subscribe 'clickNavNode', lang.hitch @, @_showObject

        getWsoContainer: ()->
            # summary:
            #   根据是否使用　Tab 返回不同的　Container
            if not @wsoContainer
                if @useTab
                    @wsoContainer = new TabContainer(
                        style: 'width:100%; height:100%'
                        region: "center",
                        splitter: true,
                        tabPosition: "left-h"
                    )
                else
                    @wsoContainer = new ContentPane(
                        style: 'width:100%; height:100%'
                        region: "center",
                        splitter: true
                    )
            @wsoContainer

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
            # tid:
            #   amd:User
            #   wso:xxx/xxx
            #   bll:xxx/xxx
            type = item.type
            tid = item['tid']
            oid = item['nid']
            nid = item['nid']
            current = @current
            return if current.tid = tid && current.oid = oid

            # TODO: search for non-current, but loaded object
            #            if tid.startsWith('amd')

            newWso
            if type == 'amd'
                ''
            else if type == 'bill'
                defDeferred = @app.wsoDefinitionsManager.getBill tid
                newWso = new WsoBill(
                    data: []
                    wsoDef: defDeferred
                    closable: true
                    navigatorItem: item
                    title: item.name
                    app:@app
                )
            else if type == 'wso'
                ''
            else
                ''
            # destroy the old current object...
            @destroy()

            # 显示新的当前界面
            if @useTab
                sameType = @getWsoByType(item)
                if sameType.length > 0
                    @wsoContainer.selectChild sameType[0]
                else
                    @wsoContainer.addChild newWso
                    @wsoContainer.selectChild newWso
            else
                @wsoContainer.destroyDescendants()
                @wsoContainer.addChild newWso
            newWso.startup()

            @wsoContainer.startup()

            # record the current state...
            lang.mixin current, {
                tid: tid
                oid: oid
                nid: nid
                form: newWso # todo 当前对象的重新定义
            }

        destroy: ->
            # todo to delete
#            current = @current
#            if not @usetab
#                if current.form
#          @tabContainer.removeChild current.form
#        else
#                    main.appContainer.removeChild current.form
#                    current.form.destroyRecursive()
            current = nullObjectValue




