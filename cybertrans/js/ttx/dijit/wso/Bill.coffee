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
    'ttx/store/JsonRest'
    'dijit/_WidgetBase'
    'dijit/_TemplatedMixin'
    'dijit/_WidgetsInTemplateMixin'
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
    'ttx/command/actions/BillActionSet'
    'ttx/dijit/_TtxForm'
    'dojo/text!./templates/Bill.html'
], (declare, lang, fx, dom, domClass, domStyle, domConstruct, geo, query,
    onn, aspect, DeferredList, Memory, JsonRest,
    _WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin,
    registry, ContentPane, TabContainer, Form, TextBox, Button, _Container, Toolbar,
    at, getStateful, ModelRefController, #
    Grid, Cache, modules,
    BillActionSet, _TtxForm, template)->
    declare [_WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin, _TtxForm], {

        templateString: template
        _loading: ''

        app: null
        workspace: null
        tc: null
        navigatorItem: {} # id: "", name: "", oid: "", parent: "root", tid: "user", type: "bill"

        actionSets: {
            global: {}
            default: {}
        }

        cpList: null
        cpBill: null
        cpDetail: null

        viewModel: null # 界面模型定义 同 viewDefinition
        viewModelDeferred: null
        billModel: null # 单据模型定义
        headerTableModel: null # 头表模型定义
        detailTableModel: null # 明细表模型定义

        dataCache: {
            billStore: {}
            tableStore: {}
            viewStore: {}
        }

        constructor: (args)->
            @inherited arguments
            @app = args.app # todo delete
        buildRendering: ->
            # summary:
            #       TODO 显示加载动画，现在是一个 p
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
            domConstruct.place(node, @domNode, "last")

        postCreate: ->
            @inherited arguments
            it = @
            onn window, 'resize', ->
                geo.setMarginBox(it.domNode, geo.getContentBox(it.workspace.domNode), true)
            #            @tc.own(aspect.after(
            #                    @tc,
            #                    'selectChild',
            #                    ()->
            #                        pane = arguments[1][0]
            #                        it.layoutPane pane.domNode
            #                )
            #                true
            #            )
            aspect.after(@tc, 'selectChild', ()->
                pane = arguments[1][0]
                it.layoutPane pane.domNode
            )
            @viewModelDeferred.then((vm)->
                it.viewModel = vm
                dm = it.app.dataManager
                dm.getBillModel(vm.billKey).then((bm)->
                    it.billModel = bm
                    new DeferredList([
                        dm.getTableModel(bm.header),
                        dm.getTableModel(bm.detail)
                    ]).then(
                        (res)->
                            it.headerTableModel = res[0][1]
                            it.detailTableModel = res[1][1]

                            # action sets 加载
                            it.actionSets.global = new BillActionSet wso: it
                            if it.viewModel.actionJs
                                try
                                    require {async: false}, [it.viewModel.actionJs], (ajs)->
                                        it.actionSets.default = new ajs(wso: it)
                                catch err
                                    console.error err

                            it._finishLoad() # 完成数据加载
                    )
                )
            )
        _abortLoad: ->
            return if not @viewModelDeferred
            @viewModelDeferred.cancel()
            @_loading.innerHTML = "FAILED!!"
        _finishLoad: ->
            @_buildForm()
            @_finishBuild()
        _buildForm: ->
            fx.fadeOut({
                node: @_loading
                onEnd: (node)->
                    domStyle.set(node, 'display', 'none')
            }).play()
            domConstruct.destroy @_loading
            delete @_loading

            vm = @viewModel
            @__buildCpList(vm.list) if vm.list
            @__buildCpBill(vm.bill) if vm.bill
            @__buildCpDetail(vm.detail) if vm.detail

        __buildCpList: (def)->
            it = @
            cp = @cpList
            # 字段
            form = cp.form = new Form()
            cp.addChild form
            ctrl = cp.ctrl = new ModelRefController model: getStateful {}
            fieldMap = cp.fieldMap = {}
            @addTtxFieldSet(def.fields, ctrl, def.columns, form.domNode, fieldMap)
            # 操作
            actionMap = cp.actionMap = {}
            @addTtxActionSet(def.actions, cp.domNode, actionMap)
            # 表格
            url = @app.dataManager.getTableRestUrl(@headerTableModel.key)
            storeArgs = {
                target: url,
                idProperty: @headerTableModel.idColumnName,
                muteQuery: true,
                headers: {'X-Result-Fields': @_getGridFieldsToRequest(@headerTableModel, @viewModel.list.grid)}
            }
            cp.grid = @addTtxServerGrid(def.grid, cp.domNode, {
                storeArgs: storeArgs
                store: new JsonRest(storeArgs)
            })
            onn cp.grid, 'cellDblClick', (evt)->
                item = cp.grid.row(evt.rowIndex).item()
                it.actionSets.global.edit.call(it.actionSets.global, item)
        __buildCpBill: (def)->
            it = @
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
            url = @app.dataManager.getTableRestUrl(@detailTableModel.key) # todo 如何不加载数据
            storeArgs = {
                target: url,
                idProperty: @detailTableModel.idColumnName,
                muteQuery: true,
                headers: {'X-Result-Fields': @_getGridFieldsToRequest(@detailTableModel, @viewModel.bill.grid)}
            }
            cp.grid = @addTtxServerGrid(def.grid, cp.domNode, {
                storeArgs: storeArgs
                store: new JsonRest(storeArgs)
            })
            onn cp.grid, 'cellDblClick', (evt)->
                item = cp.grid.row(evt.rowIndex).item()
                it.actionSets.global.editDetail.call(it.actionSets.global, item)
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

        _getGridFieldsToRequest: (tableModel, gridDf)->
            # 获取表格要向服务端请求的字段
            res = [tableModel.idColumnName]
            for item in gridDf.structure
                console.log item
                if res.indexOf(item.field) < 0
                    res.push item.field
            res.join ','

        layoutPane: (dom)->
            query('.ttx-field-set', dom).forEach (set)->
                setBox = geo.getContentBox(set)
                query('.ttx-field-row', set).forEach (row)->
                    geo.setMarginBox(row, w: setBox.w, true)
                    cols = row.getAttribute('ttx-field-row-cols') || 2
                    rowBox = geo.getContentBox(row)
                    oneFieldWidth = parseInt(rowBox.w / cols)
                    query('.ttx-field', row).forEach (field)->
                        span = field.getAttribute 'ttx-field-span' || 1
                        fieldWidth = oneFieldWidth * span
                        geo.setMarginBox(field, w: fieldWidth, true)
                        children = field.childNodes
                        if children.length == 2 and children[0].tagName == 'LABEL'
                            geo.setMarginBox(
                                children[1],
                                w: fieldWidth - geo.getMarginBox(children[0], true).w,
                                false # todo read source code
                            )

        startup: ->
            @inherited arguments
            @layoutPane(@cpList.domNode)

    }