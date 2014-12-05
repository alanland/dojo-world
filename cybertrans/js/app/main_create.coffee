define [
    'dojo/_base/lang'
    'dojo/on'
    'dojo/dom-construct'
    'dojo/request'
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
], (lang, dojon, domCons, request, BorderContainer, TabContainer, ContentPane, StackContainer, StackController, Wizard, WizardPane,
    Button, TextBox, ComboBox, Grid, Cache, modules, Memory)->
    startup: (args)->
        base_url = 'http://localhost:9000'
        cp = new ContentPane({}, 'create')

        # 单据选择框
        comboBox = new ComboBox({
            id: "stateSelect",
            name: "state",
            value: "",
            store: new Memory(data: []),
            searchAttr: "name",
            onChange: ->
                item = @item
                request(base_url + '/rest/' + item.id + '/queryFieldData', {handleAs: 'json'}).then(
                    (data)->
                        gridx1.setStore(new Memory data: data)
                )
        });
        window.c = comboBox
        cp.addChild(comboBox)

        request(base_url + '/rest/creator/billMapping', {handleAs: 'json'}).then(
            (data)->
                comboBox.store.setData(data)
        )

        prtButton = new Button {label: '打印JSON'}
        cp.addChild prtButton

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
            {id: 'id', field: 'id', name: 'ID', width: '80px'},
            {id: 'location', field: 'location', name: '表位置', width: '80px'},
            {id: 'name', field: 'name', name: 'Name', width: '100px'},
            {id: 'operator', field: 'operator', name: '操作符'}
        ]
        grid1Store = new Memory data: [
#            {location: '头', id: 'no', field: 'no', name: '单号', operator: 'lk', type: 'string'}
#            {location: '头', id: 'owner', field: 'owner', name: '货主', operator: 'eq', type: 'string'}
#            {location: '头', id: 'count', field: 'count', name: '总件数', operator: 'between', type: 'string'}
#            {location: '明细', id: 'material', field: 'material', name: '物料', operator: 'lk', type: 'string'}
#            {location: '明细', id: 'spec', field: 'spec', name: '规格', operator: 'lk', type: 'string'}
#            {location: '明细', id: 'qty', field: 'qty', name: '数量', operator: 'eq', type: 'string'}
        ]
        gridx1 = createGrid('grid1', 'grid1Container', grid1Store, structure, {
            style: {width: '400px', height: '300px'},
            barTop: [{content: '<h1>查询条件 (可选) </h1>'}],
            dndRowAccept: ['grid2/rows'],
            dndRowProvide: ['grid1/rows']
        });
        grid2Store = new Memory(data: [])
        window.s = grid2Store
        gridx2 = createGrid('grid2', 'grid2Container', grid2Store, structure, {
            style: {width: '400px', height: '300px'}, 4
            barTop: [{content: '<h1>查询条件 (已选) </h1>'}],
            dndRowAccept: ['grid1/rows'],
            dndRowProvide: ['grid2/rows']
        })

        dojon prtButton, 'click', ->
            json = []
            if gridx2.rowCount() > 0
                for i in [0..gridx2.rowCount() - 1]
                    json.push gridx2.row(i).item()
                console.log json
                console.log JSON.stringify(json)

        # listStructure
        structure = [
            {field: 'field', name: '字段', width: '80px'},
            {field: 'name', name: '名称', width: '80px'},
            {field: 'width', name: '宽度', width: '80px'}
        ]
        grid3Store = new Memory data: [

        ]
        gridx3 = createGrid('grid3', 'grid3Container', grid3Store, structure, {
            style: {width: '400px', height: '300px'},
            barTop: [{content: '<h1>列表字段 (可选) </h1>'}],
            dndRowAccept: ['grid4/rows'],
            dndRowProvide: ['grid3/rows']
        })
        gridx4 = createGrid('grid4', 'grid4Container', new Memory(data: []), structure, {
            style: {width: '400px', height: '300px'},
            barTop: [{content: '<h1>列表字段 (已选) </h1>'}],
            dndRowAccept: ['grid3/rows'],
            dndRowProvide: ['grid4/rows']
        })






































