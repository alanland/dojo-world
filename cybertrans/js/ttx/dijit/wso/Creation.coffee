define [
    'dojo/_base/declare'
    'dojo/_base/array'
    'dojo/_base/lang'
    'dojo/_base/Deferred'
    'dojo/dom-construct'
    'dojo/aspect'
    'dojo/on'
    'dojo/store/Memory'
    'dijit/_WidgetBase'
    'dijit/_TemplatedMixin'
    'dijit/_WidgetsInTemplateMixin'
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
], (declare, array, lang, Deferred, domConstruct, aspect, onn, Memory,
    _WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin,
    Toolbar, TooltipDialog, ConfirmTooltipDialog,
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
        billModelCtrl: null
        billModelFieldMap: {}

        templateString: template

        constructor: (args)->
            @inherited arguments
            @app = args.app
            thiz = this
            require {async: false}, ['ttx/command/actions/CreationActionSet'], (ajs)->
                defaultSet = new ajs(wso: thiz)
                thiz.actionSets = {
                    default: defaultSet
                    global: defaultSet
                }

        buildRendering: ->
            @inherited arguments

        postCreate: ->
            @inherited arguments
            thiz = this
            @app.dataManager.getBillDefinition('Creation').then(
                (res)->
                    thiz._buildForm(res)
                (err)->
                    ''
            )
            aspect.after @tc, 'layout', lang.hitch(this, this._layoutTc)

        layout: ->
            @inherited arguments
            @_layoutTc()

        _layoutTc: ->
            @layoutFieldSetsPane(@cpTableModel.domNode)
            @layoutFieldSetsPane(@cpBillModel.domNode)

        _buildForm: (billDef)->
            @_initTableModel(billDef.tableModel)
            @layout()

        _initTableModel: (tableModelDef)->
            cp = @cpTableModel
            app = @app
            ctrl = cp.ctrl = new ModelRefController model: getStateful {}
            fieldMap = cp.fieldMap = {}

            tableModelSelectDom = domConstruct.create 'div', {}, cp.domNode
            domConstruct.create 'div', {innerHTML: 'Table Model', style: 'width:80px;display:inline-block'}, tableModelSelectDom
            tableModelSelect = new FilteringSelect(
                searchAttr: 'key'
                disabled: true
                onChange: (value)->
                    console.log value
            )
            domConstruct.place tableModelSelect.domNode, tableModelSelectDom
            tableModelSelect.startup()
            app.dataManager.get('/rest/creation/tableModels').then(
                (res)->
                    tableModelSelect.set('disabled', false)
                    tableModelSelect.set('store', new Memory(data: res, idProperty: 'key'))
            )

            actionsDom = domConstruct.create 'div', {}, cp.domNode
            # 新增按钮
            createBtn = new Button(label: 'Create', onClick: lang.hitch @actionSets.default, 'tableModelCreate')
            domConstruct.place createBtn.domNode, actionsDom

            # 保存按钮
            saveButton = new Button(label: 'Save', onClick: lang.hitch @actionSets.default, 'tableModelCreate')
            domConstruct.place saveButton.domNode, actionsDom

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
            ctrl = new ModelRefController model: getStateful {}

            row = @addTtxFieldRow(2, tipCp.domNode)
            domConstruct.create 'div', {innerHTML: 'Column', style: 'display:inline-block; width:50px'}, row
            tipFilterSelect = new FilteringSelect(value: at(ctrl, 'field'), store: new Memory(data: fieldData))
            tipFilterSelect.startup()
            domConstruct.place tipFilterSelect.domNode, row

            row = @addTtxFieldRow(2, tipCp.domNode)
            domConstruct.create 'div', {innerHTML: 'Name', style: 'display:inline-block; width:50px'}, row
            input = new TextBox(value: at(ctrl, 'name'))
            input.startup()
            domConstruct.place input.domNode, row

            # 新增确定事件
            tip.onExecute = ->
                id = ctrl.model['id']
                item = lang.mixin({}, new Memory(data: fieldData).get(ctrl.get('field')))
                if ctrl.get('name')
                    item.name = ctrl.get('name')
                Deferred.when(grid.store.add(
                        lang.mixin(item, id: Math.random())
                    ), ->
                    console.log("A new item is saved to server");
                )
                window.ctrl = ctrl

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

            aspect.after cp.fieldMap['tableName'], 'onChange', (value)->
                # 表改变的时候，刷新 idColumnName
                app.dataManager.get("rest/creation/tables/#{value}/fields").then(
                    (res)->
                        fieldData = res
                        # {id:0.19843485040876674, field:version, name:version, type:integer}
                        field = fieldMap['idColumnName']
                        field.set('store', new Memory(idProperty: "field", data: res))
                        field.set 'value', field.get('value')
                        tipFilterSelect.set('store', new Memory(data: fieldData))

                        # 改变表的时候，更新表格数据
                        grid.setStore(new Memory(data: fieldData.concat()))

                    (err)->
                        console.error err
                )
            , true


    }