define [
    'dojo/_base/declare',
    'dojo/_base/lang'
    'dojo/topic',
    'dijit/layout/ContentPane'
    'dijit/layout/TabContainer'
    'ttx/dijit/wso/Bill'
], (declare, lang, topic, ContentPane, TabContainer, Bill)->
    nullObjectValue = {type: -2, tid: -2, oid: -2, nid: -2, form: null}
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
                        id: 'workspace'
                    )
                else
                    @wsoContainer = new ContentPane(
                        style: 'width:100%; height:100%'
                        region: "center",
                        splitter: true
                        id: 'workspace'
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
            return if @current.tid = tid && @current.oid = oid

            # TODO: search for non-current, but loaded object
            #            if tid.startsWith('amd')

            it = this
            newWso = null
            if type == 'amd'
#                require {async: false}, ['ttx/dijit/wso/Creation'], (Creation)->
#                    alert(1)
#                    newWso = new Creation(app: @app)
                require {async: false}, [tid], (amdType)->
                    newWso = new amdType(app: it.app, workspace: @wsoContainer)
            else if type == 'bill'
                viewModelDeferred = @app.wsoDefinitionsManager.getBill tid
                newWso = new Bill(
                    viewModelDeferred: viewModelDeferred
#                    closable: true
                    navigatorItem: item
                    title: item.name
                    app: @app
                    workspace: @wsoContainer
                )
            else if type == 'wso'
                ''
            else
                ''

            # 显示新的当前界面
            if @useTab
                sameType = @getWsoByType(item) # todo
                if sameType and sameType.length > 0
                    @wsoContainer.selectChild sameType[0]
                else
                    @wsoContainer.addChild newWso
                    @wsoContainer.selectChild newWso
            else
                @destroyCurrent()
                @wsoContainer.addChild newWso

            #            @wsoContainer.startup()

            # record the current state...
            lang.mixin @current, {
                tid: tid
                oid: oid
                nid: nid
                form: newWso # todo 当前对象的重新定义
            }
    # destroy the old current object...
#            @destroy()


        destroyCurrent: ->
            # destroyDescendants
            # destroyRecursive
            current = this.current
            if (current.form)
                try
                    @wsoContainer.removeChild(current.form);
                    current.form.destroyRecursive();


            current = nullObjectValue;

#            if not @useTab && @current.form
#                @current.form = undefined
#                for child in @wsoContainer.getChildren()
#                    @wsoContainer.removeChild(child)
#                    try
#                        child.destroy
#                        child.destroyRecursive()
#                    catch e
#                        console.error e
##                @wsoContainer.removeChild @current.form
##                @current.form.destroyRecursive()
#                delete @current.form

#            current = @current = {}


        destroy: ->
            ''
            # todo to delete
            #            current = @current
            #            if not @usetab
            #                if current.form
            #          @tabContainer.removeChild current.form
            #        else
            #                    main.appContainer.removeChild current.form
            #                    current.form.destroyRecursive()
            current = nullObjectValue




