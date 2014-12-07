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
                    (data)->  # 查询字段
                        gridQueryProvide.setStore(new Memory data: data)
                )
                request(base_url + '/rest/' + item.id + '/listStructureData', {handleAs: 'json'}).then(
                    (data)-> # 查询列表字段
                        gridListProvide.setStore(new Memory data: data)
                )
                request(base_url + '/rest/' + item.id + '/headerFieldData', {handleAs: 'json'}).then(
                    (data)-> # 单头字段
                        gridHeaderProvide.setStore(new Memory data: data)
                )
                request(base_url + '/rest/' + item.id + '/lineStructureData', {handleAs: 'json'}).then(
                    (data)-> # 明细列表字段
                        gridLineProvide.setStore(new Memory data: data)
                )
                request(base_url + '/rest/' + item.id + '/lineFieldData', {handleAs: 'json'}).then(
                    (data)-> # 明细编辑字段
                        gridLineFieldProvide.setStore(new Memory data: data)
                )
        });
        window.c = comboBox
        cp.addChild(comboBox)

        request(base_url + '/rest/creation/billMapping', {handleAs: 'json'}).then(
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
#            {id: 'id', field: 'id', name: 'ID', width: '80px'},
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
        gridQueryProvide = createGrid('gridQueryProvide', 'grid1Container', new Memory(data: []), structure, {
            style: {width: '400px', height: '300px'},
            barTop: [{content: '<h1>查询条件 (可选) </h1>'}],
            dndRowAccept: ['gridQueryAccept/rows'],
            dndRowProvide: ['gridQueryProvide/rows']
        });
        gridQueryAccept = createGrid('gridQueryAccept', 'grid2Container', new Memory(data: []), structure, {
            style: {width: '400px', height: '300px'}, 4
            barTop: [{content: '<h1>查询条件 (已选) </h1>'}],
            dndRowAccept: ['gridQueryProvide/rows'],
            dndRowProvide: ['gridQueryAccept/rows']
        })

        # test button
        dojon prtButton, 'click', ->
            json = []
            if gridQueryAccept.rowCount() > 0
                for i in [0..gridQueryAccept.rowCount() - 1]
                    json.push gridQueryAccept.row(i).item()
                console.log json
                console.log JSON.stringify(json)

        # listStructure
        structure = [
            {field: 'field', name: '字段', width: '80px'},
            {field: 'name', name: '名称', width: '80px'},
            {field: 'width', name: '宽度', width: '80px'}
        ]
        gridListProvide = createGrid('gridListProvide', 'grid3Container', new Memory(data: []), structure, {
            style: {width: '400px', height: '300px'},
            barTop: [{content: '<h1>列表字段 (可选) </h1>'}],
            dndRowAccept: ['gridListAccept/rows'],
            dndRowProvide: ['gridListProvide/rows']
        })
        gridListAccept = createGrid('gridListAccept', 'grid4Container', new Memory(data: []), structure, {
            style: {width: '400px', height: '300px'},
            barTop: [{content: '<h1>列表字段 (已选) </h1>'}],
            dndRowAccept: ['gridListProvide/rows'],
            dndRowProvide: ['gridListAccept/rows']
        })


        # header field structure
        structure = [
            {field: 'field', name: '字段', width: '80px'},
            {field: 'name', name: '名称', width: '80px'},
            {field: 'type', name: '类型', width: '80px'}
        ]
        gridHeaderProvide = createGrid('gridHeaderProvide', 'grid5Container', new Memory(data: []), structure, {
            style: {width: '400px', height: '300px'},
            barTop: [{content: '<h1>单头字段 (可选) </h1>'}],
            dndRowAccept: ['gridHeaderAccept/rows'],
            dndRowProvide: ['gridHeaderProvide/rows']
        })
        gridHeaderAccept = createGrid('gridHeaderAccept', 'grid6Container', new Memory(data: []), structure, {
            style: {width: '400px', height: '300px'},
            barTop: [{content: '<h1>单头字段 (已选) </h1>'}],
            dndRowAccept: ['gridHeaderProvide/rows'],
            dndRowProvide: ['gridHeaderAccept/rows']
        })


        # line structure
        structure = [
            {field: 'field', name: '字段', width: '80px'},
            {field: 'name', name: '名称', width: '80px'},
            {field: 'type', name: '类型', width: '80px'}
        ]
        gridLineProvide = createGrid('gridLineProvide', 'grid7Container', new Memory(data: []), structure, {
            style: {width: '400px', height: '300px'},
            barTop: [{content: '<h1>明细字段 (可选) </h1>'}],
            dndRowAccept: ['gridLineAccept/rows'],
            dndRowProvide: ['gridLineProvide/rows']
        })
        gridLineAccept = createGrid('gridLineAccept', 'grid8Container', new Memory(data: []), structure, {
            style: {width: '400px', height: '300px'},
            barTop: [{content: '<h1>明细字段 (已选) </h1>'}],
            dndRowAccept: ['gridLineProvide/rows'],
            dndRowProvide: ['gridLineAccept/rows']
        })


        # line field structure
        structure = [
            {field: 'field', name: '字段', width: '80px'},
            {field: 'name', name: '名称', width: '80px'},
            {field: 'type', name: '类型', width: '80px'}
        ]
        gridLineFieldProvide = createGrid('gridLineFieldProvide', 'grid9Container', new Memory(data: []), structure, {
            style: {width: '400px', height: '300px'},
            barTop: [{content: '<h1>明细编辑字段 (可选) </h1>'}],
            dndRowAccept: ['gridLineFieldAccept/rows'],
            dndRowProvide: ['gridLineFieldProvide/rows']
        })
        gridLineFieldAccept = createGrid('gridLineFieldAccept', 'grid10Container', new Memory(data: []), structure, {
            style: {width: '400px', height: '300px'},
            barTop: [{content: '<h1>明细编辑字段 (已选) </h1>'}],
            dndRowAccept: ['gridLineFieldProvide/rows'],
            dndRowProvide: ['gridLineFieldAccept/rows']
        })

        getAcceptedData = (grid)->
            json = []
            if grid.rowCount > 0
                for i in [0..gridQueryAccept.rowCount() - 1]
                    json.push gridQueryAccept.row(i).item()
                console.log json
            json

        createBtn = new Button({
            label: '创建'
            onClick: (e)->
                result = {
                    billKey: comboBox.get('value')
                    queryFields: getAcceptedData(gridQueryAccept)
                    listActions: []
                    listStructure: getAcceptedData gridListAccept
                    billStructure: {
                        headerFields: getAcceptedData gridHeaderAccept
                        detailsStructure: getAcceptedData(gridLineAccept)
                        detailEditFields: getAcceptedData(gridLineFieldAccept)
                    }
                }
                console.log(JSON.stringify(result))
                request(base_url + '/rest/creation/create', {
                    method: 'post'
                    data: JSON.stringify(result)
                    headers: {'Content-Type': 'application/json'}
                }).then(
                    (data)->
                        console.log 'success'
                    (err)->
                        console.log 'error'
                )
        }, 'createBtn')







































