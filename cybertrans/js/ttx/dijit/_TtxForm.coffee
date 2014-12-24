define [
    'dojo/_base/declare'
    'dojo/_base/lang'
    'dojo/dom-construct'
    'dojo/dom-geometry'
    'dojo/query'
    'dojo/request'
    'dojo/store/Memory'
    'dojo/store/JsonRest'
    'dijit/Toolbar'
    'dijit/Menu'
    'dijit/MenuItem'
    'dijit/form/Button'
    'dijit/form/DropDownButton'
    'dijit/form/ComboButton'
    'dijit/form/TextBox'
    'dijit/form/FilteringSelect'
    'dojox/mvc/at'
    'dojox/mvc/getStateful'
    'dojox/mvc/ModelRefController'
    'gridx/Grid',
    'gridx/core/model/cache/Sync'
    'gridx/allModules'
    'ttx/util'
], (declare, lang, domConstruct, domGeometry, query, request,
    Memory, JsonRest,
    Toolbar, Menu, MenuItem,
    Button, DropDownButton, ComboButton, TextBox, FilteringSelect,
    at, getStateful, ModelRefController,
    Grid, Cache, modules,
    util)->
    declare null, {
        actionSets: {default: {}, global: {}}

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
                when 'string' then field = new TextBox(name: def.field, value: at(ctrl, def.field))
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
            field.startup()
            domConstruct.place field.domNode, fieldDiv
            fieldDiv

        addTtxField: (def, ctrl, span, domNode)->
            domConstruct.place @newTtxField(def, ctrl, span), domNode

        newTtxAction: (def)->
            # def:
            #   {"id": "query", "action": "query", "name": "Query"}
            # actionSets:
            #   actionSets {global:obj,default:obj}
            widgetArgs = lang.mixin({label: def.name}, def.args)
            btn = null
            if def.dropDown
                menu = @_newDropDownMenu(def.dropDown)
                widgetArgs = lang.mixin(widgetArgs, {dropDown: menu})
                if def.action
                    btn = new ComboButton widgetArgs
                    @_addActionClick def, btn
                else
                    btn = new DropDownButton widgetArgs
            else
                btn = new Button widgetArgs
                if def.action  # 如果有配置动作
                    @_addActionClick def, btn
            btn

        _addActionClick: (def, btn)->
            if not def.action
                btn.onClick = ->
                    console.error '未配置Action'
                    console.log def
                return ''
            idx = def.action.indexOf(':')
            # [action] default
            # [:action] global
            # [some.model:action] custom
            actionSets = @actionSets
            if idx < 0 # global
                if actionSets.global[def.action]
                    btn.onClick = lang.hitch actionSets.global, def.action
                else
                    console.error '配置的 Action 不存在'
                    console.log def
            else if idx == 0 # default module
                ''
            else # module need amd

        _newDropDownMenu: (actionsDef)->
            menu = new Menu()
            for def in actionsDef
                widgetArgs = lang.mixin({label: def.name}, def.args)
                item = new MenuItem(widgetArgs)
                @_addActionClick def, item
                menu.addChild item
            menu.startup()
            menu

        addTtxAction: (def, domNode)->
            domConstruct.place @newAction(def).domNode, domNode

        addGridx: (container, store, structure, args)->
            defaultModules = [
                modules.Bar,
                modules.RowHeader,
                modules.IndirectSelect,
                modules.ExtendedSelectRow,
#                modules.MoveRow,
#                modules.DndRow,
                modules.VirtualVScroller
                modules.SingleSort,
                modules.ColumnResizer,
                modules.Pagination,
                modules.ExtendedSelectColumn,
                modules.PaginationBar
            ]
            if args.modules
                for m in args.modules
                    defaultModules.push m
                args.modules = defaultModules
            g = new Grid(lang.mixin({
                cacheClass: Cache
                store: store
                structure: structure
                selectRowTriggerOnCell: true
                paginationBarMessage: "[ ${2} 到 ${3} ] (共 ${0} ), 已选择 ${1} 条",
                rowHeaderCellProvider: (row)->
                    row.id
                modules: defaultModules
            }, args));
            g.placeAt(container)
            g.startup()
            g

        addTtxGrid: (def, domNode, args)->
            # 列表容器
            listDiv = domConstruct.create 'div', {class: 'listGridContainer'}, domNode
            # 列表工具栏
            listToolbar = new Toolbar {}
            for adef in def.actions
                listToolbar.addChild @newTtxAction(adef)
            # 列表Grid
            grid = @addGridx(listDiv, new Memory(data: []), def.structure, lang.mixin({
                barTop: [{content: '<h1>' + def.name || '' + ' </h1>'}, listToolbar]
            }, args))
            grid

        layoutFieldSetsPane: (pane)->
            # 查询pane所有的　fieldSet 进行布局
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

    }