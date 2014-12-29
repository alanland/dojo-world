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
    'dojo/text!./templates/Creation.html'
    'dojox/mvc/at'
    'dojox/mvc/getStateful'
    'dojox/mvc/ModelRefController'
    'gridx/allModules'
    'ttx/dijit/_TtxForm'
], (declare, array, lang, Deferred,
    DeferredList, domConstruct, domGeometry, aspect, onn, Memory,
    _WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin,
    TitlePane, Toolbar, TooltipDialog, ConfirmTooltipDialog,
    Form, Button, TextBox, FilteringSelect, DropDownButton,
    ContentPane, TabContainer, template,
    at, getStateful, ModelRefController,
    modules,
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
            thiz = this
            require {async: false}, [
                    'ttx/command/actions/CreationActionSet',
                    'ttx/command/actions/BillActionSet'
                ], (ajs, global)->
                defaultSet = new ajs(wso: thiz)
                globalSet = new global(wso: thiz)
                thiz.actionSets = {
                    default: defaultSet
                    global: globalSet
                }

        _buildCache: ->
            @_buildCacheTable(@dataCache)
            @_buildCacheBill(@dataCache)
        _buildCacheTable: (res)->
            @dataCache.tableStore = new Memory(data: res, idProperty: 'key')
            if @cpBillModel.fieldMap
                @cpBillModel.fieldMap['header'].set 'store', @dataCache.tableStore
                @cpBillModel.fieldMap['detail'].set 'store', @dataCache.tableStore
        _buildCacheBill: (res)->
            @dataCache.billStore = new Memory(data: res, idProperty: 'key')
        _reBuildCacheTable: (dataCache)->
            thiz = this
            @app.dataManager.get('/rest/creation/tableModels').then(
                (res)->
                    thiz._buildCacheTable(res)
                (err)->
                    console.error err
            )
        _reBuildCacheBill: (dataCache)->
            thiz = this
            @app.dataManager.get('/rest/creation/billModels').then(
                (res)->
                    thiz._buildCacheBill(res)
                (err)->
                    console.error err
            )

        postCreate: ->
            @inherited arguments
            thiz = this
            new DeferredList([
                @app.dataManager.getBillDefinition('Creation'),
                @app.dataManager.get('/rest/creation/tableModels')
                @app.dataManager.get('/rest/creation/billModels')
            ]).then(
                (res)->
                    thiz._buildCacheTable res[1][1]
                    thiz._buildCacheBill res[2][1]
                    thiz._buildForm(res[0][1])
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
            @startup()
            @layout()

        _initTableModel: (tableModelDef)->
            cp = @cpTableModel
            app = @app
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


            actionsDom = domConstruct.create 'div', {}, cp.domNode
            # New
            newBtn = new Button(
                label: 'New',
                disabled: at(ctrl, 'newBtn:disabled'),
                onClick: lang.hitch @actionSets.default, 'tableModel_New'
            )
            newBtn.startup()
            domConstruct.place newBtn.domNode, actionsDom

            # 新增按钮
            createBtn = new Button(
                label: 'Create',
                disabled: at(ctrl, 'createBtn:disabled')
                onClick: lang.hitch @actionSets.default, 'tableModel_Create'
            )
            createBtn.startup()
            domConstruct.place createBtn.domNode, actionsDom

            # 保存按钮
            updateButton = new Button(
                label: 'Update',
                disabled: at(ctrl, 'updateBtn:disabled')
                onClick: lang.hitch @actionSets.default, 'tableModel_Update'
            )
            domConstruct.place updateButton.domNode, actionsDom

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
            tipCp = new ContentPane()
            tip = new ConfirmTooltipDialog({
                content: tipCp
            })
            ctrlTip = new ModelRefController model: getStateful {}
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
                Deferred.when(grid.store.add(
                        lang.mixin(item, id: Math.random())
                    ), ->
                    console.log("A new item is saved to server");
                )

            listToolbar.addChild(new DropDownButton(
                label: 'New'
                dropDown: tip,
                "iconClass": "dijitEditorIcon dijitEditorIconCopy"
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

            thiz = this
            # 选择头表之后
            aspect.after fieldMap['header'], 'onChange', (value)->
                # 表改变的时候，刷新 idColumnName
                if value == ''
                    fieldMap['principal'].set 'value', ''
                    return

                table = thiz.dataCache.tableStore.get(cp.fieldMap['header'])
                fieldMap['principal'].set 'store', new Memory(idProperty: 'field', data: table.fields)
                if modelSelectChange.item.principal
                    fieldMap['principal'].set 'value', modelSelectChange.item.principal
                    modelSelectChange.item.principal = undefined
            , true
            aspect.after fieldMap['detail'], 'onChange', (value)->
                if value == ''
                    fieldMap['subordinate'].set 'value', ''
                    return

                table = thiz.dataCache.tableStore.get(cp.fieldMap['detail'])
                fieldMap['subordinate'].set 'store', new Memory(idProperty: 'field', data: table.fields)
                if modelSelectChange.item.subordinate
                    fieldMap['subordinate'].set 'value', modelSelectChange.item.subordinate
                    modelSelectChange.item.subordinate = undefined
            , true

        _initViewModel: (viewModelDef)->
            thiz = this
            cp = @cpViewModel
            app = @app
            ctrl = cp.ctrl = new ModelRefController model: getStateful {}
            fieldMap = cp.fieldMap = {}
            actionMap = cp.actionMap = {}
            dataCache = @dataCache

            # 模型属性
            form = cp.form = @cpViewModelForm
            domConstruct.place form.domNode, cp.domNode
            @addTtxFieldSet viewModelDef.viewFields, ctrl, 2, form.domNode, fieldMap

            @addTtxActionSet viewModelDef.viewActions, cp.domNode, actionMap

            # 三个tab页
            tcViewModel = cp.tcViewModel = new TabContainer(nested: true)
            cpList = cp.cpList = new ContentPane(title: 'list')
            tcViewModel.addChild cpList
            cpBill = cp.cpBill = new ContentPane(title: 'Bill')
            tcViewModel.addChild cpBill
            cpDetail = cp.cpDetail = new ContentPane(title: 'Detail')
            tcViewModel.addChild cpDetail
            domConstruct.place tcViewModel.domNode, cp.domNode

            aspect.after tcViewModel, 'selectChild', lang.hitch(this, this._layoutTc)

            # 表单界面定义
            @_initViewModel_List(viewModelDef.list)
            @_initViewModel_Bill(viewModelDef.bill)
            @_initViewModel_Detail(viewModelDef.detail)
            tcViewModel.startup()


            # 下拉框
            fieldMap['bill'].set 'labelAttr', 'key'
            fieldMap['bill'].set 'searchAttr', 'key'
            fieldMap['bill'].set 'store', @dataCache.billStore

            # deal data

            billData = @dataCache.billStore.get(ctrl.get 'bill' || '')
            headerData = @dataCache.tableStore.get billData?.header
            detailData = @dataCache.tableStore.get billData?.detail
            @__initViewModel_DealWithBill(billData, headerData, detailData)

        _initViewModel_List: (listDef)->
            cp = @cpViewModel.cpList
            ctrl = cp.ctrl = new ModelRefController model: getStateful {columns: 2}
            fieldMap = cp.fieldMap = {}
            @addTtxFieldSet listDef.viewFields, cp.ctrl, 2, cp.domNode, fieldMap
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
            gridPane.actionsGrid = @addTtxGrid listDef.grid.actions, gridPane.containerNode, {}
            gridPane.structureGrid = @addTtxGrid listDef.grid.structure, gridPane.containerNode, {}


        _initViewModel_Bill: (billDef)->
            cp = @cpViewModel.cpBill
            ctrl = cp.ctrl = new ModelRefController model: getStateful {columns: 2}
            fieldMap = cp.fieldMap = {}

            @addTtxFieldSet billDef.viewFields, cp.ctrl, 2, cp.domNode, fieldMap
            @addTtxGrid billDef.actions, @addTitlePane('单据操作', cp.domNode).containerNode, {}
            @addTtxGrid billDef.fields, @addTitlePane('单据字段', cp.domNode).containerNode, {}

            # grid
            gridPane = cp.gridPane = @addTitlePane('明细列表', cp.domNode)
            gridPane.ctrl = new ModelRefController model: getStateful {columns: 2}
            @addTtxFieldSet billDef.grid.fields, gridPane.ctrl, 2, gridPane.containerNode, {}
            gridPane.actionsGrid = @addTtxGrid billDef.grid.actions, gridPane.containerNode, {}
            gridPane.structureGrid = @addTtxGrid billDef.grid.structure, gridPane.containerNode, {}

        _initViewModel_Detail: (detailDef)->
            cp = @cpViewModel.cpDetail
            ctrl = cp.ctrl = new ModelRefController model: getStateful {columns: 2}
            fieldMap = cp.fieldMap = {}
            @addTtxFieldSet detailDef.viewFields, cp.ctrl, 2, cp.domNode, fieldMap
            cp.actionsGrid = @addTtxGrid detailDef.actions, @addTitlePane('明细操作', cp.domNode).containerNode, {}
            cp.fieldsGrid = @addTtxGrid detailDef.fields, @addTitlePane('明细字段', cp.domNode).containerNode, {}

        __initViewModel_DealWithBill: (billData, headerData, detailData)->
            cp = cp = @cpViewModel
            g = cp.cpList.fieldsGrid
            # update structure

            window.store = new Memory(data: [{id: 1, name: 11}])
            structure = g.structure.concat()
            #            structure[1].alwaysEditing = false
#            structure[1].editor = FilteringSelect
            structure[1].editorArgs = {"props": '{store: store, labelAttr: "id"}'}
            g.setColumns structure
            g.startup()


    }