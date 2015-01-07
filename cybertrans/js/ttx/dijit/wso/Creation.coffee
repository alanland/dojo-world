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
                a = 1
                geo.setMarginBox(it.domNode, geo.getContentBox(it.workspace.domNode), true)
            aspect.after(@tc, 'selectChild', ()->
                pane = arguments[1][0]
                it.layoutPane pane.domNode
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
            ]).then(
                (res)->
                    it._cache 'table', res[0][1]
                    it._cache 'bill', res[1][1]
                    it._cache 'view', res[2][1]
                    it._buildForm(res[3][1])
                (err)->
                    ''
            )
    # todo layout ?
#            aspect.after @tc, 'layout', lang.hitch(this, this._layoutTc)
#            aspect.after @tc, 'selectChild', lang.hitch(this, this._layoutTc)

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
            @__buildNavigator()
        __buildTableModel: (def)->
            it = @
            cp = @mixinCp(@cpTableModel)
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
                        if !msChanging==false # todo to check
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

        __buildNavigator: ()->


        startup: ->
            @inherited arguments
            @layoutPane(@tc.domNode)


    }