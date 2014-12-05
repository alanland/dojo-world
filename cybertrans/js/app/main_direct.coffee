define [
    "dojo/_base/array",
    'dojo/_base/lang',
    'dojo/on',
    'dojo/dom-construct',
    'dojo/aspect',
    'dojo/request'
    'dojo/DeferredList'
    'dijit/layout/BorderContainer',
    'dijit/layout/TabContainer',
    'dijit/layout/ContentPane',
    'dijit/form/Button',
    'dijit/form/TextBox',
    "dojo/store/Memory",
    'app/TtxTabContainer'
    'app/loadForm'
    'app/support/data/BillListData',
    'app/support/stores/Memory',
    'dojo/domReady!'
], (array, lang, onn, domCons, aspect, request, DeferredList,
    BorderContainer, TabContainer, ContentPane, Button, TextBox,
    Memory,
    TtxTabContainer, loadForm, dataSource, storeFactory)->
    startup: (args)->
        tc = new TabContainer({
            region: "center",
            id: "contentTabs",
            "class": "centerPanel",
            style: "height: 500px; width: 100%;"
            "href": "contentCenter.html"
        }, 'container')
        cpList = new ContentPane title: '列表', style: "height: 100%; width: 100%;"
        cpBill = new ContentPane title: '单据', style: "height: 100%; width: 100%;"
        cpDetail = new ContentPane title: '明细', style: "height: 100%; width: 100%;"

        tc.addChild cpList
        tc.addChild cpBill
        tc.addChild cpDetail
        tc.startup()
        window.tc = tc
        window.detail = cpBill

        billStructure = {}
        request('js/app/support/json/bill-structure.json',{handleAs:'json'}).then(
            (data)->
                billStructure=data
#                Bill.create(data)

        )

        store = storeFactory {
            dataSource: dataSource,
            size: 100
        }





        # from server
        queryFields = {
            "departmentNo": ["string", "用户编码"],
            "username": ["string", "用户名"],
            "department": ["string", "部门"]
        }
        structure = [
            {id: 'order', field: 'order', name: 'Order', width: '30px'},
            {id: 'id', field: 'id', name: 'ID', width: '30px'},
            {id: 'name', field: 'name', name: 'Name', width: '50px'},
            {id: 'city', field: 'city', name: 'City'},
            {id: 'score', field: 'score', name: 'Score', width: '80px'}
        ]
#        listGridData = []
#        request('js/support/json/structure.json', {handleAs: 'json'}).then(
#            (data)->
#                queryFields = data.queryFields
#                listStructure = data.listStructure
#                detailFields = data.detailFields
#                loadForm cpList, queryFields, listStructure, listGridData
#        )
#        request('js/support/json/listGridData.json', {handleAs: 'json'}).then(
#            (data)->
#                listGridData = data
#                if cpList.ttx
#                    cpList.ttx.listGrid.setStore(new Memory(data: data))
#        )



































