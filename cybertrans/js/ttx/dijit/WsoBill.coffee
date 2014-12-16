define [
    'dojo/_base/declare',
    'dojo/_base/lang',
    'dojo/_base/fx'
    'dojo/dom'
    'dojo/dom-class',
    'dojo/dom-style',
    'dojo/dom-construct'
    'dojo/dom-geometry'
    'dojo/query'
    'dojo/on'
    'dojo/aspect'
    'dojo/store/Memory'
    'dijit/registry'
    'dijit/layout/ContentPane'
    'dijit/layout/TabContainer'
    'dijit/form/Form'
    'dijit/form/TextBox'
    'dijit/form/Button'
    'dijit/_Container'
    'dijit/Toolbar'
    'dojox/mvc/at'
    'dojox/mvc/getStateful'
    'dojox/mvc/ModelRefController'
    'gridx/Grid',
    'gridx/core/model/cache/Sync'
    'gridx/allModules'
    'ttx/util'# todo
    'ttx/command/actions/BillActionSet'
], (declare, lang, fx, dom, domClass, domStyle, domConstruct, domGeometry, query,
    onn, aspect, Memory, #
    registry, ContentPane, TabContainer, Form, TextBox, Button, _Container, Toolbar,
    at, getStateful, ModelRefController, #
    Grid, Cache, modules,
    WsoDefUtil, BillActionSet) ->
    declare [TabContainer, _Container],
        # summary:
        #   Tab页展示　查询＼列表＼编辑的功能

        # data: dojo/Stateful
        #       数据模型
        data: null
        dataResult: null
        wsoDef: null
        wsoDefResult: null # 界面定义
        wsoItems: {}
        actions: []
        navigatorItem: {}
        app: null # app

        globalActionSet: null # global action definitions
        currentActionSet: null # current user defined action definitions

        cpList: null # content pane 1
        cpBill: null # content pane 2
        cpDetail: null # content pane 3
        queryForm: null # query form in cpList
        listGrid: null # grid in cpList


    # ctrl: dojox/mvc/ModelRefController
    #       控制器
        ctrl: null

    # cols: Integer
    #       当前 Wso 有多少列，用作 Field(FormWidget) 的布局
        cols: 2

    # buttons: Object
    #       当前wso的操作按钮集合
        buttons: {}

    # fields: Object
    #       字段集合
    #       key: key
    #       value: field 的dom，包含 label 和 formWidget
        fields: {}

    # buttonContainer: DOMNode
    #       操作按钮的container
        buttonContainer: null

    # fieldContainer: DOMNode
    #       字段的container
        fieldContainer: null

    # fieldClass: String
    #       每个字段的class。字段是包含label和formWidget的div
        fieldClass: 'wsoField'

    # gridClass: String
    #       grid的class
        gridClass: 'wsoGrid'
        panelClass: 'wsoPanel'

        constructor: ->
            # summary:
            #       构造
            @inherited(arguments);
            @globalActionSet = new BillActionSet({wso: this})

        buildRendering: ->
            # summary:
            #       TODO 显示加载动画，现在是一个 p
            #       设置 containerNode
            #       生成 buttonContainer, fieldContainer
            @inherited arguments
            #TODO: make this better...
            @_loading = domConstruct.toDom '''
<div id="loadingOverlay" class="loadingOverlay pageOverlay">
  <div class="loadingMessage">Loading...</div>
</div>
'''
            node = @_loading;
            #      domClass.add(node, "bafDijitwsoLoading");
            #      node.innerHTML = "Loading...";
            domConstruct.place(node, @domNode, "last");

#            @containerNode = @domNode if not @containerNode
#            @buttonContainer = domConstruct.create 'div', {class: 'wsoButtonContainer'}, @domNode
#            @fieldContainer = domConstruct.create 'div', {class: 'wsoFieldContainer'}, @domNode
#            @containerNode = domConstruct.create 'div', {class: 'wsoContainerNode'}, @domNode

        postCreate: ->
            # summary:
            #       生成控制器
            #       todo 等待 wso 定义获取到之后生成表单
            @inherited arguments

            thiz = this;
            @wsoDef.then (data)->
                thiz._continueWithWsoDef(data);
#            @data.then (data)->
#                thiz._continueWithData(data);
##                lang.hitch(owner,owner._continueWithWsoDef);
#            , (err)->
#                thiz._abortLoad(err);

        submit: ->
            # summary:
            #       提交数据
            @_submit() if not @onSubmit() == false

        _submit: -> #todo 提交数据
            console.log '----------------------Submit----------------------'


#        addChild: (widget) ->
#            domConstruct.place(widget.domNode, @domNode, "last");
#            if (@_started and !widget._started and widget.startup)
#                widget.startup();

        addChild: (widget, insertIndex)->
            # summary:
            #       返回添加的widget
            # tags:
            #       override
            @inherited(arguments)
            widget

        addFields: (fieldDefs, refNode)->
            # summary:
            #       添加 控件
            for widgetDef in fieldDefs
                @addField(widgetDef, refNode)

        addField: (fieldDef, refNode)->
            # summary:
            #       添加一个字段，同时把字段放到 this.fields 里面
            container = refNode || @domNode
            label = fieldDef.label
            key = fieldDef.key
            widgetClass = fieldDef.type
            wdef = fieldDef.widget || {}

            wso = this
            wdef.formWidget = this
            wdef.value = at(@ctrl, wdef.name) if wdef.name
            require {async: false}, [widgetClass], (WidgetClass)->
                widget = new WidgetClass wdef
                wso.addChild widget
                ## todo to delete
                #        onn widget, 'change', (newValue)->
                #          console.log newValue
                #          window.w = this
                #          domStyle.set wso.fields['1'], 'display', 'none'
                #          domStyle.set wso.fields['2'], 'visibility', 'hidden'
                #          domStyle.set wso.fields['3'], 'visible', 'false'
                ##

                field = domConstruct.create 'div', {class: wso.fieldClass}, container
                label = domConstruct.create('label', {
                    class: wso.fieldClass + 'Label',
                    innerHTML: label,
                    for: widget.get('id')
                }, field) if label
                domConstruct.place widget.domNode, field
                wso.fields[key] = field
        addWsoItemDef: (wsoItem, refNode)->
            throw new Error('error type ') if typeof wsoItem is not 'object'
            for k,v of wsoItem
                curWsoNode = refNode
                switch k
                    when wsoItemType.html
                        curWsoNode = @addHTML WsoDefUtil.setDefaults(v, wsoItemDefault.html), refNode
                    when wsoItemType.actions
                        curWsoNode = @actions = @actions.concat v
                    when wsoItemType.action
                        curWsoNode = @actions.push v
                    when wsoItemType.panel
                        curWsoNode = @addPanel WsoDefUtil.setDefaults(v, wsoItemDefault.panel), refNode
                    when wsoItemType.widget
                        curWsoNode = @addWidget WsoDefUtil.setDefaults(v, wsoItemDefault.widget), refNode
                    when wsoItemType.domWidget
                        curWsoNode = @addDomWidget WsoDefUtil.setDefaults(v, wsoItemDefault.widget), refNode
                    else
                        throw new Error('xxx')
                if v.children and v.children.length > 0
                    for w in v.children
                        @addWsoItemDef w, curWsoNode # todo 指定添加方案，现在无法堆
                    registry.byNode(curWsoNode).startup()

        addHTML: (def, refNode)->
            node = domConstruct.toDom def.html
            domConstruct.place node, refNode
            @wsoItems[def.key] = node if def.key
            node

        addPanel: (def, refNode)->
            node = domConstruct.create 'div', lang.mixin(def.dom, cols: def.cols), refNode
            domClass.add node, @panelClass
            @wsoItems[def.key] = node if def.key
            @addFields def.fields, node if def.fields
            node
        addWidget: (def, refNode)->
            parentWidget = registry.byNode refNode
            wso = this
            wsoItems = @wsoItems
            curWsoItem = null
            require async: false, [def.type], (ctor)->
                curWsoItem = child = new ctor(lang.mixin def.widgetArgs, wso: wso)
                parentWidget.addChild child
                #        domConstruct.place child.domNode, refNode
                wsoItems[def.key] = child if def.key
            curWsoItem.containerNode || curWsoItem.domNode

        addDomWidget: (def, refNode)->
            wso = this
            wsoItems = @wsoItems
            curWsoItem = null
            require async: false, [def.type], (ctor)->
                curWsoItem = child = new ctor(lang.mixin def.widgetArgs, wso: wso)
                domConstruct.place child.domNode, refNode
                wsoItems[def.key] = child if def.key
            curWsoItem.containerNode || curWsoItem.domNode

        addGrid: (gridDef)->
            container = @fieldContainer
            label = gridDef.label
            key = gridDef.key
            widgetClass = gridDef.type
            wdef = gridDef.widget || {}
            wso = this
            wdef.formWidget = this
            wdef.value = at(@ctrl, wdef.name) if wdef.name
            require # todo

        layout: ->
            # summary:
            #       设置 field 的多列布局
            #       layout 方法，在resize时候触发
            fieldClass = @fieldClass
            query('.' + @panelClass, @domNode).forEach (panel)->
                cols = panel.getAttribute('cols')
                if cols > 0
                    panelBox = domGeometry.getContentBox panel
                    fieldWidth = parseInt(panelBox.w / cols)
                    query('.' + fieldClass, panel).forEach (field)->
                        domGeometry.setMarginBox field, w: fieldWidth
                        children = field.childNodes
                        if children.length == 2 and children[0].tagName == 'LABEL'
                            domGeometry.setMarginBox children[1], w: fieldWidth - domGeometry.getMarginBox(children[0]).w
#      contentBox = domGeometry.getContentBox @domNode
#      fieldWidth = contentBox.w / @cols
#      query('.' + @fieldClass, @domNode).forEach (node)->
#        domGeometry.setMarginBox(node, {w: fieldWidth})
#        children = node.childNodes
#        if children.length == 2 and children[0].tagName == 'LABEL'
#          domGeometry.setMarginBox children[1], {w: fieldWidth - domGeometry.getMarginBox(children[0]).w}

        setEnable: (field, enable)->
            # summary:
            #       设置字段编辑性
            # field: DOMNode|String
            # enable: Boolean
            if(typeof field != "string")
                field = @fields[field]
            domStyle.set field, 'readOnly', if enable then true else false
#            domStyle.set field, 'disabled', 'disabled'

        setVisible: (field, visible)->
            # summary:
            #       设置字段可见型
            # field: DOMNode|String
            # visible: Boolean
            if(typeof field != "string")
                field = @fields[field]
            # collapse, inherit
            domStyle.set field, 'visibility', if visible then 'visible' else 'hidden'
#            domStyle.set field, 'visible', 'false'
#            domStyle.set field, 'listStructuredisplay', 'none'

#        startup: ->
#            if (!@_started)
#                @_started = true;
#
#            dojo.forEach @getChildren(), (child) ->
#                if (child.startup)
#                    child.startup();
#            @inherited(arguments);


        _continueWithData: (data) ->
            @dataResult = getStateful data;
            @ctrl = new ModelRefController model: @dataResult
            if (@wsoDefResult)
                @_finishLoad();

        _continueWithWsoDef: (wsoDef) ->
            @wsoDefResult = wsoDef;
            #            if (@dataResult)
            @_finishLoad();

        _abortLoad: ->
            return if not @data

            data = @data
            wsoDef = @wsoDef;

            @data = null;
            @wsoDef = null;

            data.cancel();
            wsoDef.cancel();

            @_loading.innerHTML = "FAILED!!";

        _finishLoad: ->
            if (@wsoDefResult.require) # todo 是否需要require
                require @wsoDefResult.require, ->
            @_buildForm();

        _addTtxField: (fdef, pane)->
            # summary:
            #   获取字段定义
            #　      {"id": "code", "type": "string", "field": "code", "name": "代码", "operator": "like"},
            fieldDiv = domConstruct.create 'div', {class: 'ttx-field'}, pane.domNode
            # todo type
            domConstruct.create 'label', {innerHTML: fdef.name}, fieldDiv
            field = new TextBox(name: fdef.field)
            domConstruct.place field.domNode, fieldDiv
            domConstruct.place fieldDiv, pane.domNode

        _getAction: (actDef)->
            #            {"id": "query", "action": "query", "name": "Query"}
            widgetArgs = lang.mixin({label: actDef.name}, actDef.args)
            btn = new Button widgetArgs
            idx = actDef.action.indexOf(':')
            if idx < 0 # global
                if @globalActionSet[actDef.action]
                    btn.onClick = lang.hitch @globalActionSet, actDef.action
                else
                    console.error '配置的 Action 不存在'
            else if idx == 0 # default module
                ''
            else # module need amd
                ''
            btn

        _addAction: (actDef, domNode)->
            domConstruct.place @_getAction(actDef).domNode, domNode

        _createGrid: (container, store, structure, args)->
            g = new Grid(lang.mixin({
#                    id: id,
                    cacheClass: Cache
                    store: store
                    structure: structure
                    selectRowTriggerOnCell: true
                    paginationBarMessage: "[ ${2} 到 ${3} ] (共 ${0} ), 已选择 ${1} 条",
                    modules: [
                        modules.Bar,
                        modules.RowHeader,
                        modules.IndirectSelect,
                        modules.ExtendedSelectRow,
#                        modules.MoveRow,
#                        modules.DndRow,
                        modules.VirtualVScroller
                        modules.SingleSort,
                        modules.ColumnResizer,
                        modules.Pagination,
                        modules.ExtendedSelectColumn,
                        modules.PaginationBar
                    ]
                }, args
            ));
            g.placeAt(container);
            g.startup();
            g

        _buildForm: ->
            fx.fadeOut({
                node: @_loading,
                onEnd: (node)->
                    domStyle.set(node, 'display', 'none')
            }).play()
            domConstruct.destroy @_loading
            delete @_loading

            @cpList = new ContentPane(title: '用户查询', style: "width:100%;height:100%")
            @addChild @cpList
            @cpBill = new ContentPane(title: '内容')
            @addChild @cpBill
            @cpDetail = new ContentPane(title: '明细')
            @addChild @cpDetail

            # 界面定义
            wsoDef = @wsoDefResult

            # 当前界面用户自定义 action 集合
            thiz = this
            actionJs = wsoDef.actionJsModule
            if actionJs && actionJs.length > 0
                require actionJs, (ajs)->
                    @currentActionSet = new ajs wso: thiz
            else
                @currentActionSet = @globalActionSet

            # 查询条件
            queryForm = @queryForm = new Form()
            @cpList.addChild queryForm
            for fdef in wsoDef.queryFields
                @_addTtxField fdef, queryForm

            # 查询按钮
            queryActions = domConstruct.create 'div', {}, queryForm.domNode
            for act in wsoDef.queryActions
                @_addAction act, queryActions

            # 列表
            listDiv = domConstruct.create 'div', {class: 'listGridContainer'}, @cpList.domNode
            listToolbar = new Toolbar {}
            for adef in wsoDef.listActions
                console.log listToolbar.addChild
                btn = @_getAction(adef)
                listToolbar.addChild btn
            #
            #    "listActions": [
            #        {"id": "new", "action": "new", "name": "New"},
            # todo buttons
            @listGrid = @_createGrid(listDiv, new Memory(data: []), wsoDef.listStructure, {
                barTop: [{content: '<h1>用户列表 </h1>'}, listToolbar]
            })





    #            ## todo
    #            for itemDef in wsoDef
    #                @addWsoItemDef itemDef, @containerNode
    #            #      @cols = wsoDef.cols
    #            #      @addFields wsoDef.children if wsoDef.children
    #            #      @addGrid wsoDef.grid if wsoDef.grid
    #            if @actions
    #                for action in @actions
    #                    action.call this
#            @layout()

        _buildForm2: ->
            domConstruct.destroy(@_loading);
            delete @_loading;

            wsoDef = @wsoDefResult

            if wsoDef and wsoDef.size
                domStyle.set @domNode,
                    position: "absolute",
                    width: wsoDef.size[0],
                    height: wsoDef.size[1]
            else
                domStyle.set @domNode,
                    width: '100%'
                    height: '100%'


            walkChildren = (children, parentWidget) ->
                for p of children
                    child = children[p];
                    require [child[0]], (ctor) ->
                        widget = new ctor(child[1]);
                        parentWidget.addChild(widget);
                        if (child[2])
                            walkChildren(child[2], widget)

            if (wsoDef.children)
                walkChildren(wsoDef.children, this);
            @startup()