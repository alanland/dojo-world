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
    'dojo/DeferredList'
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
    'ttx/dijit/_TtxForm'
], (declare, lang, fx, dom, domClass, domStyle, domConstruct, domGeometry, query,
    onn, aspect, DeferredList, Memory, #
    registry, ContentPane, TabContainer, Form, TextBox, Button, _Container, Toolbar,
    at, getStateful, ModelRefController, #
    Grid, Cache, modules,
    WsoDefUtil, BillActionSet, _TtxForm) ->
    declare [TabContainer, _Container, _TtxForm],
        # summary:
        #   Tab页展示　查询＼列表＼编辑的功能

        # data: dojo/Stateful
        #       数据模型
        data: null
        dataResult: null
        wsoDef: null
        viewModel: null # 界面定义
        billModel: null
        headerTableModel: null
        lineTableModel: null

        app: null # app
        navigatorItem: {}

        actionSets: {
            global: {}
            default: {}
        }

        cpList: null # content pane 1
        cpBill: null # content pane 2
        cpDetail: null # content pane 3

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

            it = this;
            @wsoDef.then(
                (data)->
                    it._continueWithWsoDef(data)
                (err)->
                    console.log(err)
            )
            this.own(aspect.after @, 'selectChild', ()->
                    pane = arguments[1][0]
                    it.layoutPane pane
                true,)

#            @data.then (data)->
#                thiz._continueWithData(data);
##                lang.hitch(owner,owner._continueWithWsoDef);
#            , (err)->
#                thiz._abortLoad(err);

        submit: ->
            # summary:
            #       提交数据
            @_submit() if not @onSubmit() == false

        addFields: (fieldDefs, refNode)->
            # summary:
            #       添加 控件
            for widgetDef in fieldDefs
                @addField(widgetDef, refNode)

        layout: ->
            # summary:
            #       设置 field 的多列布局
            #       layout 方法，在resize时候触发
            @inherited arguments

            if @cpList # todo layout 的次数？ 调用过多？
                cpListParentBox = domGeometry.getContentBox(@cpList.domNode.parentElement)
                domGeometry.setMarginBox(@cpList.domNode, w: cpListParentBox.w, true)

        layoutPane: (pane)->
            query('.ttx-field-set', pane.domNode).forEach (fieldSet)->
                setBox = domGeometry.getContentBox(fieldSet)
                query('.ttx-field-row', fieldSet).forEach (row)->
                    domGeometry.setMarginBox(row, w: setBox.w, true)
                    cols = row.getAttribute('ttx-field-row-cols') || 3
                    rowBox = domGeometry.getContentBox row
                    singleFieldWidth = parseInt(rowBox.w / cols)
                    query('.ttx-field', row).forEach (field)->
                        span = field.getAttribute('ttx-field-span')
                        fieldWidth = singleFieldWidth * span
                        domGeometry.setMarginBox(field, w: fieldWidth, true)
                        children = field.childNodes
                        if children.length == 2 and children[0].tagName == 'LABEL'
                            domGeometry.setMarginBox children[1], w: fieldWidth - domGeometry.getMarginBox(children[0]).w

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
            if (@viewModel)
                @_finishLoad()

        _continueWithWsoDef: (wsoDef) ->
            @viewModel = wsoDef;
            #            if (@dataResult) #todo
            it = this
            dataManager = @app.dataManager
            dataManager.getBillModel(@viewModel.billKey).then (bd)->
                it.billModel = bd
                dl = new DeferredList(
                    [dataManager.getTableModel(bd.header), dataManager.getTableModel(bd.detail)]
                ).then (res)->
                    it.headerTableModel = res[0][1]
                    it.detailTableModel = res[1][1]
                    it._finishLoad();

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
            if (@viewModel.require) # todo 是否需要require
                require @viewModel.require, ->
            @_buildForm();

        _buildForm: ->
            fx.fadeOut({
                node: @_loading,
                onEnd: (node)->
                    domStyle.set(node, 'display', 'none')
            }).play()
            domConstruct.destroy @_loading
            delete @_loading

            cpList = @cpList = new ContentPane(title: '用户查询')
            @addChild @cpList
            cpBill = @cpBill = new ContentPane(title: '内容')
            @addChild @cpBill
            cpDetail = @cpDetail = new ContentPane(title: '明细')
            @addChild @cpDetail

            # 界面定义
            viewModel = @viewModel

            # 当前界面用户自定义 action 集合
            it = this
            actionJs = viewModel.actionJs
            @actionSets.global = new BillActionSet(wso: @)
            if actionJs && actionJs.length > 0
                try
                    require {async: false}, [actionJs], (ajs)->
                        it.actionSets.default = new ajs(wso: it)
                catch err
                    console.error err

            # 列表页
            if viewModel.list
                @__buildCpList(viewModel.list)

            # 内容页
            if viewModel.bill
                @__buildCpBill(viewModel.bill)

            # 明细页
            if viewModel.detail
                @__buildCpDetail(viewModel.detail)

            @layout()

        __buildCpList: (def)->
            cp = @cpList
            # 字段
            form = cp.form = new Form()
            cp.addChild form
            ctrl = cp.ctrl = new ModelRefController model: getStateful {code: 'code', name: 'name', hintCode: 'hintcode'}
            fieldMap = cp.fieldMap = {}
            @addTtxFieldSet(def.fields, ctrl, def.columns, form.domNode, fieldMap)
            # 操作
            actionMap = cp.actionMap = {}
            @addTtxActionSet(def.actions, cp.domNode, actionMap)
            # 表格
            url = "#{@app.server}/rest/cbt/#{@headerTableModel.key}"
            cp.grid = @addTtxServerGrid(def.grid, cp.domNode, {}, url)

#            @selectChild @cpList # todo


        __buildCpBill: (def)->
            cp = @cpBill
            # 操作
            actionMap = cp.actionMap = {}
            @addTtxActionSet(def.actions, cp.domNode, actionMap)
            # 字段
            form = cp.form = new Form()
            cp.addChild form
            ctrl = cp.ctrl = new ModelRefController model: getStateful {}
            fieldMap = cp.fieldMap = {}
            @addTtxFieldSet(def.fields, ctrl, def.columns, form.domNode, fieldMap)
            # 表格
            cp.grid = @addTtxGrid(def.grid, cp.domNode)

        __buildCpDetail: (def)->
            cp = @cpDetail
            # 操作
            actionMap = cp.actionMap = {}
            @addTtxActionSet(def.actions, cp.domNode, actionMap)
            # 字段
            form = cp.form = new Form()
            cp.addChild form
            ctrl = cp.ctrl = new ModelRefController model: getStateful {}
            fieldMap = cp.fieldMap = {}
            @addTtxFieldSet(def.fields, ctrl, def.columns, form.domNode, fieldMap)

        _buildForm2: -> # @deprecated
            domConstruct.destroy(@_loading);
            delete @_loading;

            wsoDef = @viewModel

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