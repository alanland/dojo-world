define [
    'dojo/_base/declare'
    'dojo/_base/lang'
    'dojo/_base/Deferred'
    'dojo/on'
    'dojo/dom-construct'
    'dojo/dom-geometry'
    'dojo/query'
    'dojo/request'
    'dojo/store/Memory'
    'ttx/store/JsonRest'
    'dijit/TitlePane'
    'dijit/Toolbar'
    'dijit/TooltipDialog'
    'dijit/ConfirmTooltipDialog'
    'dijit/Menu'
    'dijit/MenuItem'
    'dijit/form/Form'
    'dijit/form/Button'
    'dijit/form/DropDownButton'
    'dijit/form/ComboButton'
    'dijit/form/TextBox'
    'dijit/form/FilteringSelect'
    'dijit/layout/ContentPane'
    'dojox/mvc/at'
    'dojox/mvc/getStateful'
    'dojox/mvc/ModelRefController'
    'gridx/Grid',
    'gridx/core/model/cache/Sync'
    'gridx/core/model/cache/Async'
    'gridx/allModules'
    'ttx/util'
], (declare, lang, Deferred,
    onn, domConstruct, geo, query, request,
    Memory, JsonRest,
    TitlePane, Toolbar, TooltipDialog, ConfirmTooltipDialog, Menu, MenuItem,
    Form, Button, DropDownButton, ComboButton, TextBox, FilteringSelect,
    ContentPane,
    at, getStateful, ModelRefController,
    Grid, Cache, AsyncCache, modules,
    util)->
    defaultDropDown = new TooltipDialog({content: "未实现的下拉操作"})
    declare null, {
        actionSets: {default: {}, global: {}}

        addTitlePane: (title, domNode)->
            pane = new TitlePane(title: title)
            domConstruct.place pane.domNode, domNode
            pane

        newTtxFieldSet: (defs, ctrl, columns, fieldMap = {})->
            row = null # row 定义
            fieldNumber = 0
            fieldSetDom = domConstruct.create 'div', {class: 'ttx-field-set'}
            for fdef in defs
                layout = lang.mixin {span: 1, wrap: false}, (fdef.layout || {}) # 默认 layout
                layout.span = columns if layout.span > columns # 限制当前 span 大小
                fieldNumber = fieldNumber % columns # 当前fieldNumber取余数，便于因为当前大小超出的字段换行处理
                if fieldNumber == 0 || layout.wrap || (fieldNumber + layout.span > columns)
                    # 对新行的判断 行尾自动换行 || 强制换行　|| 放不下了，自动换行
                    row = @addTtxFieldRow(columns, fieldSetDom)
                    fieldNumber = 0
                fieldNumber += layout.span
                domConstruct.place @newTtxField(fdef, ctrl, layout.span, fieldMap), row
            fieldSetDom

        addTtxFieldSet: (defs, ctrl, columns, domNode, fieldMap = {})->
            domConstruct.place @newTtxFieldSet(defs, ctrl, columns, fieldMap), domNode

        newTtxFieldRow: (columns)->
            div = domConstruct.create 'div', {class: 'ttx-field-row ttx-field-row-' + columns}
            div.setAttribute('ttx-field-row-cols', columns)
            div

        addTtxFieldRow: (columns, domNode)->
            domConstruct.place @newTtxFieldRow(columns), domNode

        newTtxField: (def, ctrl, span, fieldMap = {})->
            # summary:
            #   获取字段定义
            #　      {"id": "code", "type": "string", "field": "code", "name": "代码", "operator": "like"},
            fieldDiv = domConstruct.create 'div', {
                class: 'ttx-field ttx-field-col-' + span,
                'ttx-field-span': span
            }
            # todo type
            field = null
            switch def.type
                when 'string' then field = new TextBox(
                    name: def.field,
                    value: at(ctrl, def.field)
                )
                when 'filteringSelect'
                    field = new FilteringSelect(lang.mixin({
                            name: def.field,
                            value: at(ctrl, def.field)
                            store: new Memory({data: []})
                        }, def.args)
                    )
                    @app.dataManager.get(def.args.url).then(
                        (res)->
                            field.set('store', new Memory(data: res))
                        (err)->
                            console.error err
                    ) if def.args and def.args.url # condition
                when 'number' then '' # todo
                else
                    throw new Error('未实现的空空间类型' + def.type)

            # todo for
            domConstruct.create 'label', {innerHTML: def.name, for: field}, fieldDiv
            fieldMap[def.id] = field
            field.set 'disabled',!!def.disabled # todo 放到构造里？
            field.startup()
            domConstruct.place field.domNode, fieldDiv
            fieldDiv

        addTtxField: (def, ctrl, span, domNode)->
            domConstruct.place @newTtxField(def, ctrl, span), domNode

        newTtxAction: (def, actionMap = {}, args)->
            # def:
            #   {"id": "query", "action": "query", "name": "Query"}
            # actionSets:
            #   actionSets {global:obj,default:obj}
            # args:
            #   grid
            widgetArgs = lang.mixin({label: def.name}, def.args)
            btn = null
            if def.dropDown # 有下拉属性的按钮
                if lang.isArray def.dropDown # 下拉按钮
                    widgetArgs = lang.mixin(widgetArgs, {dropDown: @_newDropDownMenu(def.dropDown)})
                    if def.action # 单击 + 下拉
                        btn = new ComboButton widgetArgs
                        @_addActionClick def, btn, args
                    else # 单纯下拉
                        btn = new DropDownButton widgetArgs
                else # 下拉表单
                    if def.action # 指定tooltip函数 @newGridAddRowButton 表示回调函数 # todo 会造成布局失败
                        # btn = this[def.action].call this, args, widgetArgs # todo dropDown
                        btn = new DropDownButton widgetArgs
                    else
                        btn = new DropDownButton widgetArgs
            else # 一个普通的按钮
                btn = new Button widgetArgs
                if def.action  # 如果有配置动作
                    @_addActionClick def, btn, args
            actionMap[def.id] = btn
            btn

        addTtxAction: (def, domNode, actionMap = {})->
            domConstruct.place @newTtxAction(def, actionMap).domNode, domNode

        newTtxActionSet: (defs, actionMap)->
            dom = domConstruct.create 'div', {}
            for def in defs
                @addTtxAction def, dom, actionMap
            dom

        addTtxActionSet: (defs, domNode, actionMap)->
            domConstruct.place @newTtxActionSet(defs, actionMap), domNode

        _addActionClick: (def, btn, args)->
            if not def.action
                btn.onClick = ->
                    console.log '未配置Action'
                    console.log def
                return ''
            idx = def.action.indexOf(':')
            act = def.action.substr(idx + 1)
            # [action] default
            # [:action] global
            # [some.model:action] custom
            actionSets = @actionSets
            if idx < 0 # global
                if actionSets.default[act]
                    btn.onClick = lang.hitch actionSets.default, act, args
                else
                    console.log '配置的 Action 不存在'
                    console.log def
            else if idx == 0 # global module
                if actionSets.global[act]
                    btn.onClick = lang.hitch actionSets.global, act, args
                else
                    console.log '配置的 Action 不存在'
                    console.log def
            else # module need amd
                that = this
                request [def.action.substr(0, idx)], (ajs)->
                    # todo 是否可能产生内存泄漏
                    acs = new ajs(wso: that.wso) # customize action set
                    if acs[act]
                        btn.onClick = lang.hitch acs, act, args
                    else
                        console.log '配置的 Action 不存在'
                        console.log def


        _newDropDownMenu: (actionsDef)->
            menu = new Menu()
            for def in actionsDef
                widgetArgs = lang.mixin({label: def.name}, def.args)
                item = new MenuItem(widgetArgs)
                @_addActionClick def, item
                menu.addChild item
            menu.startup()
            menu

        addGridx: (container, structure, args)->
            defaultModules = [
                modules.Bar,
                modules.RowHeader,
                modules.IndirectSelect,
                modules.ExtendedSelectRow,
#                modules.Filter,
#                modules.MoveRow,
#                modules.DndRow,
                modules.VirtualVScroller
                modules.SingleSort,
                modules.ColumnResizer,
#                modules.Pagination,
                modules.ExtendedSelectColumn,
#                modules.PaginationBar
            ]
            if args.modules
                for m in args.modules
                    defaultModules.push m
                args.modules = defaultModules
            g = new Grid(lang.mixin({
                cacheClass: Cache
                structure: structure
                selectRowTriggerOnCell: true
                paginationBarMessage: "[ ${2} 到 ${3} ] (共 ${0} ), 已选择 ${1} 条",
                rowHeaderCellProvider: (row)->
                    row.id
                modules: defaultModules
            }, args));
            g.placeAt(container)
            #            g.startup()
            g

        addTtxGrid: (def, domNode, args)->
            return if not def.structure || (def.structure.length == 0 and def.actions.length == 0 ) # 如果没定义
            # 列表容器
            listDiv = domConstruct.create 'div', {class: 'listGridContainer'}, domNode
            # 列表工具栏
            listToolbar = new Toolbar {actionMap: {}}
            # 列表Grid
            grid = @addGridx(listDiv, def.structure, lang.mixin({
                store: new Memory(data: [])
                barTop: [{content: '<h1>' + def.name || '' + ' </h1>'}, listToolbar]
            }, args))
            if def.actions
                for adef in def.actions
                    btn = @newTtxAction(adef, {}, grid)
                    listToolbar.actionMap[adef.id] = btn
                    listToolbar.addChild btn
            grid
        addTtxServerGrid: (def, domNode, args)->
            return if not def.structure || (def.structure.length == 0 and def.actions.length == 0 )
            # 列表容器
            listDiv = domConstruct.create 'div', {class: 'listGridContainer'}, domNode
            # 列表工具栏
            listToolbar = new Toolbar {actionMap: {}}
            # 列表Grid
            args = lang.mixin({
                store: new Memory(data: {})
                filterServerMode: true,
                filterSetupFilterQuery: (expr)->
                    @grid.store.headers["filter"] = JSON.stringify(expr)
                    if grid.pagination # todo
                        @grid.store.headers['Range'] = 'items=0-' + @grid.pagination.pageSize()
                    ''
            }, args)
            grid = @addGridx(
                listDiv,
                def.structure, lang.mixin({
                    cacheClass: AsyncCache
                    barTop: [{content: '<h1>' + def.name || '' + ' </h1>'}, listToolbar],
                    modules: [
                        modules.Pagination,
                        modules.PaginationBar
                        modules.Filter
                    ]
                }, args)
            )

            if def.actions
                for adef in def.actions
                    btn = @newTtxAction(adef, {}, grid)
                    listToolbar.actionMap[adef.id] = btn
                    listToolbar.addChild btn
            grid

        layoutFieldSetsPane: (pane)-> # todo
            # 查询pane所有的　fieldSet 进行布局
            query('.ttx-field-set', pane.domNode).forEach (fieldSet)->
                setBox = geo.getContentBox(fieldSet)
                query('.ttx-field-row', fieldSet).forEach (row)->
                    geo.setMarginBox(row, w: setBox.w, true)
                    cols = row.getAttribute('ttx-field-row-cols') || 3
                    rowBox = geo.getContentBox row
                    singleFieldWidth = parseInt(rowBox.w / cols)
                    query('.ttx-field', row).forEach (field)->
                        span = field.getAttribute('ttx-field-span')
                        fieldWidth = singleFieldWidth * span
                        geo.setMarginBox(field, w: fieldWidth, true)
                        children = field.childNodes
                        if children.length == 2 and children[0].tagName == 'LABEL'
                            geo.setMarginBox children[1], w: fieldWidth - geo.getMarginBox(children[0]).w
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
        mixinCp: (cp)->
            lang.mixin cp, {
                actionMap: {}
                ctrl: new ModelRefController model: getStateful {}
                fieldMap: {}
            }
        getCtrlData: (ctrl)->
            data = lang.mixin({}, ctrl.model)
            data.declaredClass = undefined
            data._attrPairNames = undefined
            data

        newGridAddRowButton: (grid, widgetArgs)->
            defs = [
                {"id": "id", "type": "string", "field": "id", "name": "Id"},
                {"id": "field", "type": "filteringSelect", "field": "field", "name": "Field"},
                {"id": "name", "type": "string", "field": "name", "name": "name"}
            ]
            #            tip = @newGridAddRowTooltip fdefs, grid
            #            btn = new DropDownButton widgetArgs
            #            btn.set 'dropDown', tip
            ##            btn.startup()
            #            btn


            defaultValues = {}

            # grid new action tooltip
            tipCp = new Form()
            tipCp.startup()
            tip = new ConfirmTooltipDialog({
                defaultValues: defaultValues
                content: tipCp
                fieldMap: {}
                ctrl: new ModelRefController model: getStateful defaultValues
                reset: ()->
                    @ctrl.model = getStateful @defaultValues
            })
            #            tip.startup()
            @addTtxFieldSet(defs, tip.ctrl, 2, tipCp.domNode, tip.fieldMap)

            that = this
            # 新增确定事件
            tip.onExecute = ->
                data = that.getCtrlData(tip.ctrl)
                Deferred.when(grid.store.add(data), ->
                    console.log("A new item is saved to server");
#                    tip.reset()
                )
            tip

            btn = new DropDownButton widgetArgs
            btn.set 'dropDown', tip
            btn



        newGridAddRowTooltip: (defs, grid, defaultValues = {})->
            # grid new action tooltip
            tipCp = new Form()
            tip = new ConfirmTooltipDialog({
                defaultValues: defaultValues
                content: tipCp
                fieldMap: {}
                ctrl: new ModelRefController model: getStateful defaultValues
                reset: ()->
                    @ctrl.model = getStateful @defaultValues
            })
            tip.form = tipCp
            #            tip.startup()
            @addTtxFieldSet(defs, tip.ctrl, 2, tipCp.domNode, tip.fieldMap)

            that = this
            # 新增确定事件
            tip.onExecute = ->
                data = that.getCtrlData(tip.ctrl)
                Deferred.when(grid.store.add(data), ->
                    console.log("A new item is saved to server");
#                    tip.reset()
                )

            tipCp.startup()
            tip

        getEmptyItems:(fields)->
            m = []
            for f in fields
                m[f.field]=''
            m

    }