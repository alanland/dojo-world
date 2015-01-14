define [
    'dojo/_base/declare'
    'dojo/_base/array'
    'dojo/_base/lang'
    'dojo/_base/fx'
    'dojo/_base/Deferred'
    'dojo/DeferredList'
    'dojo/dom-construct'
    'dojo/dom-geometry'
    'dojo/dom-style'
    'dojo/aspect'
    'dojo/on'
    'dojo/store/Memory'
    'dijit/_WidgetBase'
    'dijit/_TemplatedMixin'
    'dijit/_WidgetsInTemplateMixin'
    'dijit/TitlePane'
    'dijit/Toolbar'
    'dijit/TooltipDialog'
    'dijit/ConfirmTooltipDialog'
    'dijit/form/Form'
    'dijit/form/Button'
    'dijit/form/TextBox'
    'dijit/form/FilteringSelect'
    'dijit/form/DropDownButton'
    'dijit/layout/ContentPane'
    'dijit/layout/TabContainer'
    'dijit/tree/dndSource'
    'dojo/text!./templates/Creation.html'
    'dojox/mvc/at'
    'dojox/mvc/getStateful'
    'dojox/mvc/ModelRefController'
    'gridx/allModules'
    'cbtree/Tree'
    'cbtree/store/ObjectStore'
    'cbtree/model/TreeStoreModel'
    'ttx/dijit/_TtxForm'
], (declare, array, lang, fx, Deferred,
    DeferredList, domConstruct, geo, domStyle,
    aspect, onn, Memory,
    _WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin,
    TitlePane, Toolbar, TooltipDialog, ConfirmTooltipDialog,
    Form, Button, TextBox, FilteringSelect, DropDownButton,
    ContentPane, TabContainer,
    dndSource,
    template,
    at, getStateful, ModelRefController,
    modules,
    Tree, ObjectStore, ObjectStoreModel,
    _TtxForm)->
    declare [_WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin, _TtxForm], {
        templateString: template
        _loading: ''

        app: null
        workspace: null
        tc: null
        navigatorItem: {}

        actionSets: {
            global: {}
            default: {}
        }

        cpTableModel: null
        cpBillModel: null
        cpViewModel: null
        cpNavigator: null

        cache: {
            table: new Memory(data: [], idProperty: 'key')
            bill: new Memory(data: [], idProperty: 'key')
            view: new Memory(data: [], idProperty: 'key')
            viewTemplate: {}
        }

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
            node = @_loading; # todo 统一的动画加载模块
            #            domClass.add(node, "bafDijitwsoLoading");
            node.innerHTML = "Loading...";
            domConstruct.place(node, @domNode, "last")

        postCreate: ->
            @inherited arguments
            it = @
            onn window, 'resize', ->
                geo.setMarginBox(it.domNode, geo.getContentBox(it.workspace.domNode), true) if it.domNode
            aspect.after(@tc, 'selectChild', ()->
                it.layoutPane arguments[1][0].domNode
            )
            # actions
            require {async: false}, [
                'ttx/command/actions/CreationActionSet',
                'ttx/command/actions/BillActionSet'
            ], (ajs, global)->
                defaultSet = new ajs(wso: it)
                globalSet = new global(wso: it)
                it.actionSets = {
                    default: defaultSet
                    global: globalSet
                }
            # cache
            new DeferredList([
                @app.dataManager.get('/rest/creation/tableModels')
                @app.dataManager.get('/rest/creation/billModels')
                @app.dataManager.get('/rest/creation/viewModels')
                @app.dataManager.getBillDefinition('Creation')
                @app.dataManager.getBillDefinition('BillTemplate')
            ]).then(
                (res)->
                    it._cache 'table', res[0][1]
                    it._cache 'bill', res[1][1]
                    it._cache 'view', res[2][1]
                    it.cache.viewTemplate = res[4][1]
                    it._buildForm(res[3][1])
                (err)->
                    ''
            )

        _cache: (type, data)->
            @cache[type].setData(data)
        reCache: (type)-> # todo 如何返回一个 Deferred，用于该部分代码的重用
            # todo 是否要改成 同步请求
            it = @
            if(type)
                @app.dataManager.get("rest/creation/#{type}Models").then(
                    (data)->
                        it._cache type, data
                )
            else
                new DeferredList([
                    @app.dataManager.get('rest/creation/tableModels')
                    @app.dataManager.get('rest/creation/billModels')
                    @app.dataManager.get('rest/creation/viewModels')
                ]).then(
                    (res)->
                        it._cache 'table', res[0][1]
                        it._cache 'bill', res[1][1]
                        it._cache 'view', res[2][1]
                    (err)->
                        console.error err
                )
        _buildForm: (def)->
            fx.fadeOut({
                node: @_loading
                onEnd: (node)->
                    domStyle.set(node, 'display', 'none')
            }).play()
            domConstruct.destroy @_loading

            delete @_loading
            @__buildTableModel(def.tableModel)
            @__buildBillModel(def.billModel)
            @__buildViewModel(def.viewModel)
            @__buildNavigator(def.navigator)
        __buildTableModel: (def)->
            it = @
            cp = @mixinCp @cpTableModel #, {autoNoExpression: "{yyyyMMdd}{0000000}"}
            msDom = domConstruct.create 'div', {}, cp.domNode # modelSelectDom
            domConstruct.create 'div', {innerHTML: 'Table Model', style: 'width:80px;display:inline-block'}, msDom
            ms = cp.modelSelect = new FilteringSelect(# model select
                searchAttr: 'key'
                store: @cache.table
                required: false
                onChange: (value)->
                    showModel(@item)
            )
            domConstruct.place ms.domNode, msDom
            ms.startup()

            # 该变量用适应列表 tableName 异步获取下拉框之后 idColumnValue 的值没有设置上去的问题
            msChanging = false
            # 显示选择表模型的信息
            showModel = (item)->
                item = item || it.getEmptyItems(def.fields)
                msChanging = item
                for k,v of item
                    cp.ctrl.set k, v
            # actions
            @addTtxActionSet def.actions, cp.domNode, cp.actionMap
            # field
            cp.form = new Form()
            cp.addChild cp.form
            @addTtxFieldSet(def.fields, cp.ctrl, 2, cp.form.domNode, cp.fieldMap)
            # grid
            cp.grid = @addTtxGrid(def.grid, cp.domNode, {
                modules: [
                    modules.MoveRow,
                    modules.DndRow,
                    modules.CellWidget,
                    modules.Edit
                ]
            })
            tip = @newGridAddRowTooltip(def.grid.newTipFields, cp.grid)
            cp.grid.barTop[1].actionMap['new'].set 'dropDown', tip
            # 新增确定事件
            tip.onExecute = ->
                id = tip.ctrl.model['id']
                item = lang.mixin({}, new Memory(data: []).get(tip.ctrl.get('field')))
                if tip.ctrl.get('name')
                    item.name = tip.ctrl.get('name')
                item.id = tip.ctrl.get('id')
                # Deferred 用法
                Deferred.when(cp.grid.store.add(item), ->
                    console.log("A new item is saved to server")
                )
            tableNameField = cp.fieldMap['tableName']
            tipField = tip.fieldMap['field']
            aspect.after tableNameField, 'onChange', ->
                tableName = tableNameField.get 'value'
                return if not tableName
                it.app.dataManager.get(
                    "rest/creation/tables/#{tableName}/fields",
                    {async: false, cache: true}
                ).then(
                    (res)->
                        cp.fieldMap['idColumnName'].set 'store', new Memory(data: res)
                        cp.fieldMap['idColumnName'].set 'value', msChanging.idColumnName
                        tipField.set 'store', new Memory(data: res)
                        tipField.set 'value', tipField.get('value')
                        if !msChanging == false # todo to check
                            cp.grid.setStore new Memory(data: msChanging.fields.concat())
                            msChanging = false
                        else
                            cp.grid.setStore new Memory(data: res.concat())
                )
            aspect.after tipField, 'onChange', ->
                return if not tipField.item
                tip.ctrl.set 'id', tipField.item.id
                tip.ctrl.set 'name', tipField.item.name
                tip.ctrl.set 'type', tipField.item.type

        __buildBillModel: (def)->
            it = @
            cp = @mixinCp(@cpBillModel)
            msDom = domConstruct.create 'div', {}, cp.domNode # modelSelectDom
            domConstruct.create 'div', {innerHTML: 'Bill Model', style: 'width:80px;display:inline-block'}, msDom
            ms = cp.modelSelect = new FilteringSelect(# model select
                searchAttr: 'key'
                store: @cache.bill
                required: false
                onChange: (value)->
                    showModel(@item)
            )
            domConstruct.place ms.domNode, msDom
            ms.startup()

            # 该变量用适应列表 tableName 异步获取下拉框之后 idColumnValue 的值没有设置上去的问题
            msChanging = false
            # 显示选择表模型的信息
            showModel = (item)->
                item = item || it.getEmptyItems(def.fields)
                msChanging = item
                for k,v of item
                    cp.ctrl.set k, v
            # actions
            @addTtxActionSet def.actions, cp.domNode, cp.actionMap
            # field
            cp.form = new Form()
            cp.addChild cp.form
            @addTtxFieldSet(def.fields, cp.ctrl, 2, cp.form.domNode, cp.fieldMap)
            cp.fieldMap['header'].set 'store', @cache.table
            cp.fieldMap['detail'].set 'store', @cache.table

            fieldMap = cp.fieldMap
            # 选择头表之后
            aspect.after fieldMap['header'], 'onChange', (value)->
                # 表改变的时候，刷新 idColumnName
                if value == ''
                    fieldMap['principal'].set 'value', ''
                    return
                cp.fieldMap['principal'].store.setData it.cache.table.get(value).fields
                cp.fieldMap['principal'].set 'value', msChanging.principal
            , true
            aspect.after fieldMap['detail'], 'onChange', (value)->
                # 表改变的时候，刷新 idColumnName
                if value == ''
                    fieldMap['subordinate'].set 'value', ''
                    return
                cp.fieldMap['subordinate'].store.setData it.cache.table.get(value).fields
                cp.fieldMap['subordinate'].set 'value', msChanging.subordinate
            , true

        __buildViewModel: (def)->
            it = @
            cp = @mixinCp(@cpViewModel)
            msDom = domConstruct.create 'div', {}, cp.domNode # modelSelectDom
            msChanging = false
            domConstruct.create 'div', {innerHTML: 'View Model', style: 'width:80px;display:inline-block'}, msDom
            ms = cp.modelSelect = new FilteringSelect(# model select
                searchAttr: 'key'
                store: @cache.view
                required: false
                onChange: (value)->
                    msChanging = true
                    showModel(@item)
            )
            domConstruct.place ms.domNode, msDom
            ms.startup()

            # 该变量用适应列表 tableName 异步获取下拉框之后 idColumnValue 的值没有设置上去的问题
            msChanging = false
            # 显示选择表模型的信息
            showModel = (item)->
                item = item || it.getEmptyItems(def.fields)
                msChanging = item
                for k,v of item
                    cp.ctrl.set k, v
            # actions
            @addTtxActionSet def.actions, cp.domNode, cp.actionMap
            # field
            cp.form = new Form()
            cp.addChild cp.form
            @addTtxFieldSet(def.fields, cp.ctrl, 2, cp.form.domNode, cp.fieldMap)
            cp.fieldMap['billKey'].set 'store', @cache.bill
            aspect.after cp.fieldMap['billKey'], 'onChange', lang.hitch(@, (value)->
                @__rebuildViewModelTabContainer(cp, def)
                data = @cache.view.get(cp.modelSelect.get('value'))
                if  !msChanging
                    data = it.cache.viewTemplate
                    billData = @cache.bill.get(cp.ctrl.get 'billKey')
                    header = @cache.table.get billData.header
                    detail = @cache.table.get billData.detail
                    headerFieldStore = new Memory(data: header.fields, idProperty: 'id')
                    detailFieldStore = new Memory(data: detail.fields, idProperty: 'id') if detail
                    data.list.grid.structure = header.fields.concat()
                    data.bill.fields = header.fields.concat()
                    data.bill.grid.structure = detail.fields.concat() if detail
                    data.detail.fields = detail.fields.concat() if detail
                #                    @__buildViewModelTcDataByBill()
                @__buildViewModelTcDataByView(data)
                msChanging = false
            ), true
        __rebuildViewModelTabContainer: (cp, def)-> # viewModelDef
            it = @
            cp.tc.destroyRecursive() if cp.tc
            tc = cp.tc = new TabContainer(nested: true)
            cp.addChild tc
            cpList = cp.cpList = new ContentPane(title: 'List')
            tc.addChild cpList
            cpBill = cp.cpBill = new ContentPane(title: 'Bill')
            tc.addChild cpBill
            cpDetail = cp.cpDetail = new ContentPane(title: 'Detail')
            tc.addChild cpDetail

            billData = @cache.bill.get(cp.ctrl.get 'billKey' || '')
            headerData = @cache.table.get billData?.header
            detailData = @cache.table.get billData?.detail
            headerFieldStore = new Memory(data: headerData.fields, idProperty: 'field')
            detailFieldStore = new Memory(data: detailData.fields, idProperty: 'field') if detailData
            @__buildViewTcList(def.list, billData, headerData, detailData, headerFieldStore, detailFieldStore)
            @__buildViewTcBill(def.bill, billData, headerData, detailData, headerFieldStore, detailFieldStore)
            @__buildViewTcDetail(def.detail, billData, headerData, detailData, headerFieldStore, detailFieldStore)
            tc.startup()


        __buildViewTcList: (def, billData, headerData, detailData, headerFieldStore, detailFieldStore)->
            it = @
            cp = @mixinCp(@cpViewModel.cpList, {columns: 2})
            @addTtxFieldSet def.viewFields, cp.ctrl, 2, cp.domNode, cp.fieldMap
            # 查询字段
            cp.fieldsGrid = @addTtxGrid def.fields, @addTitlePane('查询字段配置', cp.domNode).containerNode, {
                modules: [modules.CellWidget, modules.Edit]
            }
            cp.actionsGrid = @addTtxGrid def.actions, @addTitlePane('查询操作配置', cp.domNode).containerNode, {
                modules: [modules.CellWidget, modules.Edit]
            }
            # grid
            gridCp = cp.gridPane = @addTitlePane('单据列表配置', cp.domNode)
            gridCp.ctrl = new ModelRefController model: getStateful {columns: 2}
            @addTtxFieldSet def.grid.fields, gridCp.ctrl, 2, gridCp.containerNode, {}
            gridCp.actionsGrid = @addTtxGrid def.grid.actions, gridCp.containerNode, {
                modules: [modules.CellWidget, modules.Edit]
            }
            gridCp.structureGrid = @addTtxGrid def.grid.structure, gridCp.containerNode, {
                modules: [modules.CellWidget, modules.Edit]
            }

            return if not billData

            # 查询字段 新增 tip

            fieldTip = cp.fieldsGrid.barTop[1].actionMap['new'].dropDown
            data = [{key: headerData.key, item: headerData, value: headerData}]
            data.push {key: detailData.key, value: detailData} if detailData
            tipTable = fieldTip.fieldMap['table'] # tip 中的 Table 字段
            tipTable.set 'store', new Memory(data: data, idProperty: 'key')
            tipField = fieldTip.fieldMap['field']

            aspect.after tipTable, 'onChange', ->
                tipField.set 'store', new Memory(data: tipTable.item.value.fields.concat())
            aspect.after tipField, 'onChange', (value)->
                store = (if tipTable.get('value') == billData.header then headerFieldStore else detailFieldStore)
                item = store.get(value)
                it.setCtrlDataFromMap(item, fieldTip.ctrl, ['id', 'name', 'type'])
                fieldTip.ctrl.set 'operator', (if item.type == 'string' then 'like' else '=')
            , true

            # 表格 structure 的新增tip
            structureTip = gridCp.structureGrid.barTop[1].actionMap['new'].dropDown
            structureTip.fieldMap['field'].set 'store', new Memory(data: headerData.fields)
            aspect.after structureTip.fieldMap['field'], 'onChange', (value)->
                it.setCtrlDataFromMap(headerFieldStore.get(value), structureTip.ctrl, ['id', 'name'])
            , true

        __buildViewTcBill: (def, billData, headerData, detailData, headerFieldStore, detailFieldStore)->
            it = @
            cp = @mixinCp(@cpViewModel.cpBill, {columns: 2})
            @addTtxFieldSet def.viewFields, cp.ctrl, 2, cp.domNode, cp.fieldMap
            cp.actionsGrid = @addTtxGrid def.actions, @addTitlePane('单据操作配置', cp.domNode).containerNode, {
                modules: [modules.CellWidget, modules.Edit]
            }
            # 字段
            cp.fieldsGrid = @addTtxGrid def.fields, @addTitlePane('单据字段配置', cp.domNode).containerNode, {
                modules: [modules.CellWidget, modules.Edit]
            }
            if detailData
                # grid
                gridCp = cp.gridPane = @addTitlePane('明细列表配置', cp.domNode)
                gridCp.ctrl = new ModelRefController model: getStateful {columns: 2}
                @addTtxFieldSet def.grid.fields, gridCp.ctrl, 2, gridCp.containerNode, {}
                gridCp.actionsGrid = @addTtxGrid def.grid.actions, gridCp.containerNode, {
                    modules: [modules.CellWidget, modules.Edit]
                }
                gridCp.structureGrid = @addTtxGrid def.grid.structure, gridCp.containerNode, {
                    modules: [modules.CellWidget, modules.Edit]
                }

            return if not billData

            # 字段 新增 tip
            fieldTip = cp.fieldsGrid.barTop[1].actionMap['new'].dropDown
            tipField = fieldTip.fieldMap['field']
            tipField.set 'store', new Memory(data: headerData.fields)
            aspect.after tipField, 'onChange', (value)->
                it.setCtrlDataFromMap(headerFieldStore.get(value), fieldTip.ctrl, ['id', 'name', 'type'])
            , true

            if detailData
                # 表格 structure 的新增tip
                structureTip = gridCp.structureGrid.barTop[1].actionMap['new'].dropDown
                structureTip.fieldMap['field'].set 'store', new Memory(data: detailData.fields)
                aspect.after structureTip.fieldMap['field'], 'onChange', (value)->
                    it.setCtrlDataFromMap(detailFieldStore.get(value), structureTip.ctrl, ['id', 'name'])
                , true

        __buildViewTcDetail: (def, billData, headerData, detailData, headerFieldStore, detailFieldStore)->
            it = @
            cp = @mixinCp(@cpViewModel.cpDetail, {columns: 2})
            @addTtxFieldSet def.viewFields, cp.ctrl, 2, cp.domNode, cp.fieldMap
            cp.actionsGrid = @addTtxGrid def.actions, @addTitlePane('明细操作配置', cp.domNode).containerNode, {
                modules: [modules.CellWidget, modules.Edit]
            }
            # 查询字段
            cp.fieldsGrid = @addTtxGrid def.fields, @addTitlePane('明细字段配置', cp.domNode).containerNode, {
                modules: [modules.CellWidget, modules.Edit]
            }

            return if not billData

            if detailData
                # 字段 新增 tip
                fieldTip = cp.fieldsGrid.barTop[1].actionMap['new'].dropDown
                fieldTip.fieldMap['field'].set 'store', new Memory(data: detailData.fields)
                aspect.after fieldTip.fieldMap['field'], 'onChange', (value)->
                    it.setCtrlDataFromMap(detailFieldStore.get(value), fieldTip.ctrl, ['id', 'name', 'type'])
                , true

        __buildViewModelTcDataByView: (data) ->
            cp = @cpViewModel
            return if not data
            #
            # list
            list = data.list
            cpList = cp.cpList
            cpList.ctrl.set 'columns', list.columns
            cpList.actionsGrid.setStore(new Memory(data: list.actions))
            cpList.fieldsGrid.setStore(new Memory data: list.fields)
            cpList.fieldsGrid.startup()
            cpList.gridPane.ctrl.set 'name', list.grid.name
            cpList.gridPane.actionsGrid.setStore(new Memory data: list.grid.actions)
            cpList.gridPane.structureGrid.setStore(new Memory data: list.grid.structure)
            #
            # bill
            bill = data.bill
            cpBill = cp.cpBill
            cpBill.ctrl.set 'columns', bill.columns
            cpBill.actionsGrid.setStore(new Memory data: bill.actions)
            cpBill.fieldsGrid.setStore(new Memory data: bill.fields)
            if bill.grid
                cpBill.gridPane.ctrl.set 'name', bill.grid.name
                cpBill.gridPane.actionsGrid.setStore(new Memory data: bill.grid.actions)
                cpBill.gridPane.structureGrid.setStore(new Memory data: bill.grid.structure)
                #
                # detail
                detail = data.detail
                cpDetail = cp.cpDetail
                cpBill.ctrl.set 'columns', detail.columns
                cpDetail.actionsGrid.setStore(new Memory data: detail.actions)
                cpDetail.fieldsGrid.setStore(new Memory data: detail.fields)

        __buildViewModelTcDataByBill: ->
            cp = @cpViewModel
            data = @cache.bill.get(cp.ctrl.get 'billKey')
            return if not data
            header = @cache.table.get data.header
            detail = @cache.table.get data.detail
            headerFieldStore = new Memory(data: header.fields, idProperty: 'id')
            # todo 这里暂时选不自动带出所有字段
            tip = cp.cpBill.gridPane.structureGrid.barTop[1].actionMap['new'].dropDown
            aspect.after tip.fieldMap['field'], 'onChange', (value)->
                headerFieldStore
                tip.fieldMap['id'].set 'value'
            , true

        __buildNavigator: (def)->
            it = this
            cp = @mixinCp(@cpNavigator, {columns: 2})
            # left
            model = new ObjectStoreModel({
                store: new ObjectStore({
                    url: @app.navigator.url
                    handleAs: 'json'
                }),
                query: {id: "root"},
                rootLabel: "TTX",
                checkedRoot: true
            })
            # dnd support
            acceptItem = (target, source, position)->
                console.log '--------------------------'
                console.log target
                console.log source
                console.log position
                return true
            #                targetWidget = registry.getEnclosingWidget(target)
            #                (targetWidget.tree == earthTree)
            domNodeToItem = ->
                console.log "+++++++++++++"
                console.log arguments

            tree = cp.tree = new Tree(
                model: model,
                showRoot: true,
                openOnClick: false #响应点击事件而非展开动作
                region: 'left'
                splitter: true
                style: {width: "200px"}
                checkItemAcceptance: acceptItem,
                itemCreator: domNodeToItem,
                dndController: dndSource,
                betweenThreshold: 5,
                checkAcceptance: (source, nodes) ->
                    return !!source.tree;
            )
            tree.startup()
            cp.addChild tree
            onn tree, 'click', (item)->
                window.c = tree
                cp.ctrl.set 'model', lang.mixin {}, item
                console.log item
            # top
            bar = new ContentPane {
                region: 'top'
#                style: {'background-color': 'rgba(255, 255, 255, 0.3)'}
            }
            btnCreate = new Button (
                label: 'Create',
                onClick: ->
                    if(tree.model.store.get cp.ctrl.get('id'))
                        return alert 'id 已存在'
                    tree.model.store.put it.getCtrlData cp.ctrl
            )
            bar.addChild btnCreate
            btnUpdate = new Button(
                label: 'Update'
                onClick: ->
                    if(tree.model.store.get cp.ctrl.get('id'))
                        tree.model.store.put it.getCtrlData cp.ctrl
                    else
                        alert 'id 不存在'
            )
            bar.addChild btnUpdate
            btnDelete = new Button(
                label: 'Delete'
                onClick: ->
                    if(tree.model.store.get cp.ctrl.get('id'))
                        tree.model.store.remove cp.ctrl.get('id')
                    else
                        alert 'id 不存在'
            )
            bar.addChild btnDelete

            btnSaveNav = new Button(
                label: 'Save Navigator'
                onClick: lang.hitch @actionSets.default, 'navigatorSave'
            )
            bar.addChild(btnSaveNav)
            cp.addChild bar

            # center
            center = new ContentPane {region: 'center'}
            cp.addChild center
            @addTtxFieldSet(def.fields, cp.ctrl, 2, center.domNode, cp.fieldMap)
            cp.fieldMap.type.set 'store', new Memory(data: [
                {id: 'amd'},
                {id: 'bill'},
            ])
            cp.fieldMap.type.set 'value', 'bill'

        startup: ->
            @inherited arguments
    }