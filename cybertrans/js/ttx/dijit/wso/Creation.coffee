define [
    'dojo/_base/declare'
    'dojo/_base/array'
    'dojo/_base/lang'
    'dojo/_base/Deferred'
    'dojo/DeferredList'
    'dojo/dom-construct'
    'dojo/dom-geometry'
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
], (declare, array, lang, Deferred,
    DeferredList, domConstruct, domGeometry, aspect, onn, Memory,
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
        app: null
        tp: null

        actionSets: null

        cpTableModel: null
        cpBillModel: null
        cpViewModel: null

        templateString: template

        dataCache: {
            billStore: {}
            tableStore: {}
            viewStore: {}
        }

        constructor: (args)->
            @inherited arguments
            @app = args.app
            that = this
            require {async: false}, [
                    'ttx/command/actions/CreationActionSet',
                    'ttx/command/actions/BillActionSet'
                ], (ajs, global)->
                defaultSet = new ajs(wso: that)
                globalSet = new global(wso: that)
                that.actionSets = {
                    default: defaultSet
                    global: globalSet
                }

        _buildCache: ->
            @_buildCacheTable(@dataCache)
            @_buildCacheBill(@dataCache)
            @_buildCacheView(@dataCache)
        _buildCacheTable: (res)->
            @dataCache.tableStore = new Memory(data: res, idProperty: 'key')
            if @cpBillModel.fieldMap
                @cpBillModel.fieldMap['header'].set 'store', @dataCache.tableStore
                @cpBillModel.fieldMap['detail'].set 'store', @dataCache.tableStore
        _buildCacheBill: (res)->
            @dataCache.billStore = new Memory(data: res, idProperty: 'key')
        _buildCacheView: (res)->
            @dataCache.viewStore = new Memory(data: res, idProperty: 'key')
        _reBuildCacheTable: ->
            that = this
            @app.dataManager.get('/rest/creation/tableModels').then(
                (res)->
                    that._buildCacheTable(res)
                (err)->
                    console.error err
            )
        _reBuildCacheBill: ->
            that = this
            @app.dataManager.get('/rest/creation/billModels').then(
                (res)->
                    that._buildCacheBill(res)
                (err)->
                    console.error err
            )
        _reBuildCacheView: ->
            that = this
            @app.dataManager.get('/rest/creation/viewModels').then(
                (res)->
                    that._buildCacheView(res)
                (err)->
                    console.error err
            )

        postCreate: ->
            @inherited arguments
            that = this
            new DeferredList([
                @app.dataManager.getBillDefinition('Creation'),
                @app.dataManager.get('/rest/creation/tableModels')
                @app.dataManager.get('/rest/creation/billModels')
                @app.dataManager.get('/rest/creation/viewModels')
            ]).then(
                (res)->
                    that._buildCacheTable res[1][1]
                    that._buildCacheBill res[2][1]
                    that._buildCacheView res[3][1]
                    that._buildForm(res[0][1])
                (err)->
                    ''
            )
            aspect.after @tc, 'layout', lang.hitch(this, this._layoutTc)
            aspect.after @tc, 'selectChild', lang.hitch(this, this._layoutTc)

        layout: ->
            @inherited arguments
            @_layoutTc()
            @tc.layout()

        _layoutTc: ->
            @layoutFieldSetsPane(@cpTableModel.domNode)
            @layoutFieldSetsPane(@cpBillModel.domNode)

        _buildForm: (billDef)->
            @_initTableModel(billDef.tableModel)
            @_initBillModel(billDef.billModel)
            @_initViewModel(billDef.viewModel)
            @_initNavigator()
            @startup()
            @layout()

        _initTableModel: (tableModelDef)->
            cp = @cpTableModel
            app = @app
            cp.actionMap = {}
            ctrl = cp.ctrl = new ModelRefController model: getStateful {
                'newBtn:disabled': false
                'createBtn:disabled': false
                'updateBtn:disabled': false
            }
            fieldMap = cp.fieldMap = {}

            # 已保存的模型选择
            modelSelectDom = domConstruct.create 'div', {}, cp.domNode
            domConstruct.create 'div', {innerHTML: 'Table Model', style: 'width:80px;display:inline-block'}, modelSelectDom
            modelSelect = cp.modelSelect = new FilteringSelect(
                searchAttr: 'key'
                disabled: true
                required: false
                onChange: (value)->
                    item = @store.get(value)
                    showModel(item)
                    cp.fieldMap['key'].set 'disabled', value != ''
            )
            domConstruct.place modelSelect.domNode, modelSelectDom
            modelSelect.startup()
            # 获取所有表模型
            app.dataManager.get('/rest/creation/tableModels').then(
                (res)->
                    modelSelect.set('disabled', false)
                    modelSelect.set('store', new Memory(data: res, idProperty: 'key'))
            )

            # 该变量用适应列表 tableName 异步获取下拉框之后 idColumnValue 的值没有设置上去的问题
            modelSelectChange = {status: false, item: {}}
            # 显示选择表模型的信息
            showModel = (item)->
                item = item || {'key': '', 'description': '', 'tableName': '', 'idColumnName': ''}
                modelSelectChange = {status: true, item: item}
                for k in ['key', 'description', 'tableName', 'idColumnName']
                    ctrl.set(k, item[k])

            # actions
            @addTtxActionSet(tableModelDef.actions, cp.domNode, cp.actionMap)

            # form
            form = cp.form = new Form()
            domConstruct.place form.domNode, cp.domNode
            @addTtxFieldSet(tableModelDef.fields, ctrl, 2, form.domNode, fieldMap)

            # grid
            gridDef = tableModelDef.grid

            # 字段数据　后面请求后更新
            fieldData = []

            # 列表
            listDiv = domConstruct.create 'div', {class: 'listGridContainer'}, cp.domNode
            # 列表工具栏
            listToolbar = new Toolbar {}

            # tooltip
            tipCp = new ContentPane()
            tip = new ConfirmTooltipDialog({
                content: tipCp
            })

            ctrlTip = new ModelRefController model: getStateful {}

            row = @addTtxFieldRow(2, tipCp.domNode)
            domConstruct.create 'div', {innerHTML: 'Id', style: 'display:inline-block; width:50px'}, row
            input = new TextBox(value: at(ctrlTip, 'id'))
            input.startup()
            domConstruct.place input.domNode, row

            row = @addTtxFieldRow(2, tipCp.domNode)
            domConstruct.create 'div', {innerHTML: 'Column', style: 'display:inline-block; width:50px'}, row
            tipFilterSelect = new FilteringSelect(value: at(ctrlTip, 'field'), store: new Memory(data: fieldData))
            tipFilterSelect.startup()
            domConstruct.place tipFilterSelect.domNode, row

            row = @addTtxFieldRow(2, tipCp.domNode)
            domConstruct.create 'div', {innerHTML: 'Name', style: 'display:inline-block; width:50px'}, row
            input = new TextBox(value: at(ctrlTip, 'name'))
            input.startup()
            domConstruct.place input.domNode, row

            # 新增确定事件
            tip.onExecute = ->
                id = ctrlTip.model['id']
                item = lang.mixin({}, new Memory(data: fieldData).get(ctrlTip.get('field')))
                if ctrlTip.get('name')
                    item.name = ctrlTip.get('name')
                item.id = ctrlTip.get('id')
                Deferred.when(grid.store.add(item), ->
                    console.log("A new item is saved to server");
                )

            listToolbar.addChild(new DropDownButton(
                label: 'New'
                dropDown: tip
            ))

            for adef in gridDef.actions
                listToolbar.addChild @newTtxAction(adef)
            # 列表Grid
            grid = @addGridx(listDiv, new Memory(data: []), gridDef.structure, {
                barTop: [{content: '<h1>' + gridDef.name || '' + ' </h1>'}, listToolbar],
                modules: [
                    modules.MoveRow,
                    modules.DndRow,
                    modules.CellWidget,
                    modules.Edit
                ]
            })

            cp.grid = grid

            # 选择表之后
            aspect.after cp.fieldMap['tableName'], 'onChange', (value)->
                # 表改变的时候，刷新 idColumnName
                if value == ''
                    return
                app.dataManager.get("rest/creation/tables/#{value}/fields", {async: false}).then(
                    (res)->
                        fieldData = res
                        # {id:0.19843485040876674, field:version, name:version, type:integer}

                        # id column name
                        field = fieldMap['idColumnName']
                        field.set('store', new Memory(idProperty: "field", data: res))
                        field.set 'value', field.get('value')
                        if modelSelectChange.status # 如果是选择表模型的联动
                            field.set 'value', modelSelectChange.item.idColumnName
                            grid.setStore(new Memory(data: modelSelectChange.item.fields.concat()))
                            # reset
                            modelSelectChange = {status: false, value: {}}
                        else # 不是选择表模型的联动
                            # 改变表的时候，更新表格数据
                            grid.setStore(new Memory(data: fieldData.concat()))

                        # new field detail tooltip
                        tipFilterSelect.set('store', new Memory(data: fieldData))


                    (err)->
                        console.error err
                )
            , true

        _initBillModel: (billModelDef)->
            cp = @cpBillModel
            app = @app
            ctrl = cp.ctrl = new ModelRefController model: getStateful {}
            fieldMap = cp.fieldMap = {}

            # 异步更新下拉框数据
            modelSelectChange = {status: true, item: {}}
            # 表模型选择框
            modelSelectDom = domConstruct.create 'div', {}, cp.domNode
            domConstruct.create 'div', {innerHTML: 'Bill Model', style: 'width:80px;display:inline-block'}, modelSelectDom
            modelSelect = cp.modelSelect = new FilteringSelect(
                searchAttr: 'key'
                disabled: true
                required: false
                onChange: (value)->
                    item = @store.get(value)
                    showModel(item)
                    cp.fieldMap['key'].set 'disabled', value != ''
            )
            domConstruct.place modelSelect.domNode, modelSelectDom
            modelSelect.startup()
            # 获取所有表模型
            app.dataManager.get('/rest/creation/billModels').then(
                (res)->
                    modelSelect.set('disabled', false)
                    modelSelect.set('store', new Memory(data: res, idProperty: 'key'))
            )
            deleteBtn = new Button(
                label: 'Delete'
                onClick: lang.hitch @actionSets.default, 'billModel_Delete'
            )
            deleteBtn.startup()
            domConstruct.place deleteBtn.domNode, modelSelectDom

            # show model
            showModel = (item)->
                item = item || {'key': '', 'description': '', 'header': '', 'detail': '', 'principal': '', 'subordinate': ''}
                modelSelectChange = {status: true, item: item}
                for k,v of item
                    ctrl.set k, v

            actionsDom = domConstruct.create 'div', {}, cp.domNode
            # New
            newBtn = new Button(
                label: 'New',
                disabled: at(ctrl, 'newBtn:disabled'),
                onClick: lang.hitch @actionSets.default, 'billModel_New'
            )
            newBtn.startup()
            domConstruct.place newBtn.domNode, actionsDom

            # 新增按钮
            createBtn = new Button(
                label: 'Create',
                disabled: at(ctrl, 'createBtn:disabled')
                onClick: lang.hitch @actionSets.default, 'billModel_Create'
            )
            createBtn.startup()
            domConstruct.place createBtn.domNode, actionsDom

            # 保存按钮
            updateButton = new Button(
                label: 'Update',
                disabled: at(ctrl, 'updateBtn:disabled')
                onClick: lang.hitch @actionSets.default, 'billModel_Update'
            )
            domConstruct.place updateButton.domNode, actionsDom

            # form
            form = cp.form = new Form()
            domConstruct.place form.domNode, cp.domNode
            @addTtxFieldSet billModelDef.fields, ctrl, 2, form.domNode, fieldMap

            fieldMap['header'].set 'store', @dataCache.tableStore
            fieldMap['detail'].set 'store', @dataCache.tableStore

            that = this
            # 选择头表之后
            aspect.after fieldMap['header'], 'onChange', (value)->
                # 表改变的时候，刷新 idColumnName
                if value == ''
                    fieldMap['principal'].set 'value', ''
                    return

                table = that.dataCache.tableStore.get(cp.fieldMap['header'])
                fieldMap['principal'].set 'store', new Memory(idProperty: 'field', data: table.fields)
                if modelSelectChange.item.principal
                    fieldMap['principal'].set 'value', modelSelectChange.item.principal
                    modelSelectChange.item.principal = undefined
            , true
            aspect.after fieldMap['detail'], 'onChange', (value)->
                if value == ''
                    fieldMap['subordinate'].set 'value', ''
                    return

                table = that.dataCache.tableStore.get(cp.fieldMap['detail'])
                fieldMap['subordinate'].set 'store', new Memory(idProperty: 'field', data: table.fields)
                if modelSelectChange.item.subordinate
                    fieldMap['subordinate'].set 'value', modelSelectChange.item.subordinate
                    modelSelectChange.item.subordinate = undefined
            , true

        _initViewModel: (viewModelDef)->
            that = this
            cp = @cpViewModel
            app = @app
            ctrl = cp.ctrl = new ModelRefController model: getStateful {}
            fieldMap = cp.fieldMap = {}
            actionMap = cp.actionMap = {}

            # 已保存的模型选择
            modelSelectDom = domConstruct.create 'div', {}, cp.domNode
            domConstruct.create 'div', {innerHTML: 'View Model', style: 'width:80px;display:inline-block'}, modelSelectDom
            modelSelect = cp.modelSelect = new FilteringSelect(
                searchAttr: 'key'
                disabled: true
                required: false
                onChange: (value)->
                    item = @store.get(value)
                    showModel(item)
                    cp.fieldMap['key'].set 'disabled', value != ''
            )
            domConstruct.place modelSelect.domNode, modelSelectDom
            modelSelect.startup()

            # 获取所有表模型
            app.dataManager.get('/rest/creation/viewModels').then(
                (res)->
                    modelSelect.set('disabled', false)
                    modelSelect.set('store', new Memory(data: res, idProperty: 'key'))
            )

            showModel = (item)->
                for k in ['key', 'billKey', 'actionJs', 'description']
                    ctrl.set k, item[k]
            # 余下的由联动


            # 模型属性
            form = cp.form = @cpViewModelForm
            domConstruct.place form.domNode, cp.domNode
            @addTtxFieldSet viewModelDef.viewFields, ctrl, 2, form.domNode, fieldMap

            @addTtxActionSet viewModelDef.viewActions, cp.domNode, actionMap


            # 下拉框
            fieldMap['billKey'].set 'labelAttr', 'key'
            fieldMap['billKey'].set 'searchAttr', 'key'
            fieldMap['billKey'].set 'store', @dataCache.billStore
            aspect.after fieldMap['billKey'], 'onChange', lang.hitch(this, (value)->
                cp.tcViewModel.destroyRecursive() if cp.tcViewModel
                @_initViewTabContainer(cp, viewModelDef)
                @_initViewTabContainerWithData()
            ), true

    # 初始化页面节点
#            @_initViewTabContainer(cp, viewModelDef)



        _initViewTabContainer: (cp, viewModelDef)->
            # 三个tab页
            tcViewModel = cp.tcViewModel = new TabContainer(nested: true)
            cpList = cp.cpList = new ContentPane(title: 'List')
            tcViewModel.addChild cpList
            cpBill = cp.cpBill = new ContentPane(title: 'Bill')
            tcViewModel.addChild cpBill
            cpDetail = cp.cpDetail = new ContentPane(title: 'Detail')
            tcViewModel.addChild cpDetail
            domConstruct.place tcViewModel.domNode, cp.domNode

            aspect.after tcViewModel, 'selectChild', lang.hitch(this, this._layoutTc)


            # deal data
            billData = @dataCache.billStore.get(cp.ctrl.get 'billKey' || '')
            headerData = @dataCache.tableStore.get billData?.header
            detailData = @dataCache.tableStore.get billData?.detail


            # 表单界面定义
            @_initViewModel_List(viewModelDef.list, billData, headerData, detailData)
            @_initViewModel_Bill(viewModelDef.bill, billData, headerData, detailData)
            @_initViewModel_Detail(viewModelDef.detail, billData, headerData, detailData)
            tcViewModel.startup()

        _initViewModel_List: (listDef, billData, headerData, detailData)->
            cp = @cpViewModel.cpList
            ctrl = cp.ctrl = new ModelRefController model: getStateful {columns: 2}
            fieldMap = cp.fieldMap = {}
            @addTtxFieldSet listDef.viewFields, cp.ctrl, 2, cp.domNode, fieldMap

            # 查询字段
            cp.fieldsGrid = @addTtxGrid listDef.fields, @addTitlePane('查询字段', cp.domNode).containerNode, {
                modules: [modules.CellWidget, modules.Edit]
            }
            cp.actionsGrid = @addTtxGrid listDef.actions, @addTitlePane('查询操作', cp.domNode).containerNode, {
                modules: [modules.CellWidget, modules.Edit]
            }
            # grid
            gridPane = cp.gridPane = @addTitlePane('查询界面列表', cp.domNode)
            gridPane.ctrl = new ModelRefController model: getStateful {columns: 2}
            @addTtxFieldSet listDef.grid.fields, gridPane.ctrl, 2, gridPane.containerNode, {}
            gridPane.actionsGrid = @addTtxGrid listDef.grid.actions, gridPane.containerNode, {
                modules: [modules.CellWidget, modules.Edit]
            }
            gridPane.structureGrid = @addTtxGrid listDef.grid.structure, gridPane.containerNode, {
                modules: [modules.CellWidget, modules.Edit]
            }

            return if not billData


            #
            #
            @__addDefaultGridNewButton(cp.actionsGrid)
            @__addDefaultGridNewButton(gridPane.actionsGrid)


            #
            # list 查询字段的新增 Tooltip
            fdefs = [
                {"id": "id", "type": "string", "field": "id", "name": "Id"},
                {
                    "id": "table", "type": "filteringSelect", "field": "table", "name": "Table",
                    "args": {"searchAttr": "key", "labelAttr": "key"}
                },
                {
                    "id": "field", "type": "filteringSelect", "field": "field", "name": "Field",
                    "args": {"searchAttr": "id", "labelAttr": "id"}
                },
                {"id": "name", "type": "string", "field": "name", "name": "name"},
                {"id": "type", "type": "string", "field": "type", "name": "type"},
                {"id": "operator", "type": "string", "field": "operator", "name": "operator"},
                {"id": "span", "type": "string", "field": "span", "name": "span"},
                {"id": "wrap", "type": "string", "field": "wrap", "name": "wrap"},
                {"id": "args", "type": "string", "field": "args", "name": "args"},
            ]
            tooltip = @newGridAddRowTooltip(fdefs, cp.fieldsGrid, {type: 'string', operator: '='})
            cp.fieldsGrid.barTop[1].actionMap['new'].set 'dropDown', tooltip

            # table 字段
            data = [{key: headerData.key, item: headerData, value: headerData}]
            data.push {key: detailData.key, value: detailData} if detailData
            tipTable = tooltip.fieldMap['table'] # tip 中的 Table 字段
            tipTable.set 'store', new Memory(data: data, idProperty: 'key')
            tipField = tooltip.fieldMap['field']
            aspect.after tipTable, 'onChange', ->
                tipField.set 'store', new Memory(data: tipTable.item.value.fields.concat())

            #
            # list 查询结构列表列的 tooltip
            fdefs = [
                {"id": "id", "type": "string", "field": "id", "name": "Id"},
                {"id": "field", "type": "filteringSelect", "field": "field", "name": "Field"},
                {"id": "name", "type": "string", "field": "name", "name": "name"}
            ]
            tooltip = @newGridAddRowTooltip(fdefs, gridPane.structureGrid)
            gridPane.structureGrid.barTop[1].actionMap['new'].set 'dropDown', tooltip
            tooltip.fieldMap['field'].set 'store', new Memory(data: headerData.fields)


        _initViewModel_Bill: (billDef, billData, headerData, detailData)->
            cp = @cpViewModel.cpBill
            ctrl = cp.ctrl = new ModelRefController model: getStateful {columns: 2}
            fieldMap = cp.fieldMap = {}

            @addTtxFieldSet billDef.viewFields, cp.ctrl, 2, cp.domNode, fieldMap
            cp.actionsGrid = @addTtxGrid billDef.actions, @addTitlePane('单据操作', cp.domNode).containerNode, {
                modules: [modules.CellWidget, modules.Edit]
            }
            cp.fieldsGrid = @addTtxGrid billDef.fields, @addTitlePane('单据字段', cp.domNode).containerNode, {
                modules: [modules.CellWidget, modules.Edit]
            }

            # grid
            gridPane = cp.gridPane = @addTitlePane('明细列表', cp.domNode)
            gridPane.ctrl = new ModelRefController model: getStateful {columns: 2}
            @addTtxFieldSet billDef.grid.fields, gridPane.ctrl, 2, gridPane.containerNode, {}
            gridPane.actionsGrid = @addTtxGrid billDef.grid.actions, gridPane.containerNode, {
                modules: [modules.CellWidget, modules.Edit]
            }
            gridPane.structureGrid = @addTtxGrid billDef.grid.structure, gridPane.containerNode, {
                modules: [modules.CellWidget, modules.Edit]
            }

            return if not billData


            #
            #
            @__addDefaultGridNewButton(cp.actionsGrid)
            @__addDefaultGridNewButton(gridPane.actionsGrid)

            #
            # bill 字段的新增 Tooltip
            fdefs = [
                {"id": "id", "type": "string", "field": "id", "name": "Id"},
                {
                    "id": "field", "type": "filteringSelect", "field": "field", "name": "Field",
                    "args": {"searchAttr": "id", "labelAttr": "id"}
                },
                {"id": "name", "type": "string", "field": "name", "name": "name"},
                {"id": "type", "type": "string", "field": "type", "name": "type"},
                {"id": "span", "type": "string", "field": "span", "name": "span"},
                {"id": "wrap", "type": "string", "field": "wrap", "name": "wrap"},
                {"id": "args", "type": "string", "field": "args", "name": "args"},
            ]
            tooltip = @newGridAddRowTooltip(fdefs, cp.fieldsGrid, {type: 'string', operator: '='})
            cp.fieldsGrid.barTop[1].actionMap['new'].set 'dropDown', tooltip

            # table 字段
            tooltip.fieldMap['field'].set 'store', new Memory(data: headerData.fields)

            #
            # list 查询结构列表列的 tooltip
            fdefs = [
                {"id": "id", "type": "string", "field": "id", "name": "Id"},
                {"id": "field", "type": "filteringSelect", "field": "field", "name": "Field"},
                {"id": "name", "type": "string", "field": "name", "name": "name"}
            ]
            tooltip = @newGridAddRowTooltip(fdefs, gridPane.structureGrid)
            gridPane.structureGrid.barTop[1].actionMap['new'].set 'dropDown', tooltip
            tooltip.fieldMap['field'].set 'store', new Memory(data: detailData.fields)



        _initViewModel_Detail: (detailDef, billData, headerData, detailData)->
            cp = @cpViewModel.cpDetail
            ctrl = cp.ctrl = new ModelRefController model: getStateful {columns: 2}
            fieldMap = cp.fieldMap = {}
            @addTtxFieldSet detailDef.viewFields, cp.ctrl, 2, cp.domNode, fieldMap
            cp.actionsGrid = @addTtxGrid detailDef.actions, @addTitlePane('明细操作', cp.domNode).containerNode, {
                modules: [modules.CellWidget, modules.Edit]
            }
            cp.fieldsGrid = @addTtxGrid detailDef.fields, @addTitlePane('明细字段', cp.domNode).containerNode, {
                modules: [modules.CellWidget, modules.Edit]
            }

            return if not billData

            #
            #
            @__addDefaultGridNewButton(cp.actionsGrid)

            #
            # bill 字段的新增 Tooltip
            fdefs = [
                {"id": "id", "type": "string", "field": "id", "name": "Id"},
                {
                    "id": "field", "type": "filteringSelect", "field": "field", "name": "Field",
                    "args": {"searchAttr": "id", "labelAttr": "id"}
                },
                {"id": "name", "type": "string", "field": "name", "name": "name"},
                {"id": "type", "type": "string", "field": "type", "name": "type"},
                {"id": "span", "type": "string", "field": "span", "name": "span"},
                {"id": "wrap", "type": "string", "field": "wrap", "name": "wrap"},
                {"id": "args", "type": "string", "field": "args", "name": "args"},
            ]
            tooltip = @newGridAddRowTooltip(fdefs, cp.fieldsGrid, {type: 'string', operator: '='})
            cp.fieldsGrid.barTop[1].actionMap['new'].set 'dropDown', tooltip

            # table 字段
            tooltip.fieldMap['field'].set 'store', new Memory(data: detailData.fields)


        _initViewTabContainerWithData: ()->
            cp = @cpViewModel

            data = @dataCache.viewStore.get(cp.modelSelect.get('value'))

            #
            # list
            list = data.list
            cpList = cp.cpList
            cpList.ctrl.set 'columns', list.columns
            cpList.actionsGrid.setStore(new Memory(data: list.actions))
            cpList.fieldsGrid.setStore(new Memory data: list.fields)
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

        __addDefaultGridNewButton: (grid)->
            fdefs = [
                {"id": "id", "type": "string", "field": "id", "name": "Id"},
                {"id": "name", "type": "string", "field": "name", "name": "Name"},
                {"id": "action", "type": "string", "field": "action", "name": "Action"}
            ]
            tooltip = @newGridAddRowTooltip(fdefs, grid)
            grid.barTop[1].actionMap['new'].set 'dropDown', tooltip

        _initNavigator: ->
            cp = @cpNavigator
            that = this

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
                    tree.model.store.put that.getCtrlData cp.ctrl
            )
            bar.addChild btnCreate
            btnUpdate = new Button(
                label: 'Update'
                onClick: ->
                    if(tree.model.store.get cp.ctrl.get('id'))
                        tree.model.store.put that.getCtrlData cp.ctrl
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
            center = new ContentPane {
                region: 'center'
            }
            cp.addChild center
            fdefs = [
                {"id": "id", "type": "string", "field": "id", "name": "Id"},
                {"id": "name", "type": "string", "field": "name", "name": "Name"},
                {
                    "id": "type", "type": "filteringSelect", "field": "type", "name": "Type",
                    "args": {"searchAttr": "id", "labelAttr": "id", "required": false}
                },
                {"id": "tid", "type": "string", "field": "tid", "name": "View"},
                {"id": "parent", "type": "string", "field": "parent", "name": "parent"},
                {"id": "oid", "type": "string", "field": "oid", "name": "oid"}
            ]
            cp.fieldMap = {}
            cp.ctrl = new ModelRefController model: getStateful {}
            @addTtxFieldSet(fdefs, cp.ctrl, 2, center.domNode, cp.fieldMap)

            cp.fieldMap.type.set 'store', new Memory(data: [
                {id: 'amd'},
                {id: 'bill'},
            ])
            cp.fieldMap.type.set 'value', 'bill'


    }