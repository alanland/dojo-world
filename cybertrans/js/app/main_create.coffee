define [
    'dojo/_base/lang'
    'dojo/dom-construct'
    'dijit/layout/BorderContainer',
    'dijit/layout/TabContainer',
    'dijit/layout/ContentPane',
    "dijit/layout/StackContainer",
    "dijit/layout/StackController"
    'dojox/widget/Wizard'
    'dojox/widget/WizardPane'
    'dijit/form/Button',
    'dijit/form/TextBox',
    'dijit/form/ComboBox'
    'gridx/Grid',
    'gridx/core/model/cache/Async'
    'gridx/allModules'
    "dojo/store/Memory",
    'dojo/domReady!'
], (lang, domCons, BorderContainer, TabContainer, ContentPane, StackContainer, StackController, Wizard, WizardPane,
    Button, TextBox, ComboBox, Grid, Cache, modules, Memory)->
    startup: (args)->
        cp = new ContentPane({}, 'create')

        cp.addChild new Button {label: '更新'}

        billStore = new Memory(data: [
            {id: 'pick', name: '拣货单', header: 'pick_header', line: 'pick_detail'},
            {id: 'ship', name: '发货单', header: 'ship_header', line: 'ship_detail'}
        ])

        comboStore = new Memory({data: []})
        billStore.query().forEach (item)->
            comboStore.add item

        createGrid = (id, container, store, structure, args)->
            g = new Grid(lang.mixin({
                    id: id,
                    cacheClass: Cache
                    store: store
                    structure: structure
                    modules: [
                        modules.Bar,
                        modules.RowHeader,
                        modules.IndirectSelect,
                        modules.ExtendedSelectRow,
                        modules.MoveRow,
                        modules.DndRow,
                        modules.VirtualVScroller
                    ]
                    selectRowTriggerOnCell: true
                }, args
            ));
            g.placeAt(container);
            g.startup();
            g

        structure = [
            {id: 'id', field: 'id', name: 'ID', width: '30px'},
            {id: 'location', field: 'location', name: '表位置', width: '30px'},
            {id: 'name', field: 'name', name: 'Name', width: '50px'},
            {id: 'operator', field: 'operator', name: '操作符'}
        ]
        grid1Store = new Memory data: [
            {location: '头', id: 'no', name: '单号', operator: 'lk'}
            {location: '头', id: 'owner', name: '货主', operator: 'eq'}
            {location: '头', id: 'count', name: '总件数', operator: 'between'}
            {location: '明细', id: 'material', name: '物料', operator: 'lk'}
            {location: '明细', id: 'spec', name: '规格', operator: 'lk'}
            {location: '明细', id: 'qty', name: '数量', operator: 'eq'}
        ]
        createGrid('grid1', 'grid1Container', grid1Store, structure, {
            style: {width: '400px', height: '300px'},
            barTop: [{content: '<h1>查询条件 (可选) </h1>'}],
            dndRowAccept: ['grid2/rows'],
            dndRowProvide: ['grid1/rows']
        });
        grid2Store = new Memory(data: [])
        window.s = grid2Store
        window.g = createGrid('grid2', 'grid2Container', grid2Store, structure, {
            style: {width: '400px', height: '300px'}, 4
            barTop: [{content: '<h1>查询条件 (已选) </h1>'}],
            dndRowAccept: ['grid1/rows'],
            dndRowProvide: ['grid2/rows']
        })


        comboBox = new ComboBox({
            id: "stateSelect",
            name: "state",
            value: "",
            store: comboStore,
            searchAttr: "name",
            onChange: ->
                item = @item
                console.log item

        });
        cp.addChild(comboBox)
        window.store = comboStore






































