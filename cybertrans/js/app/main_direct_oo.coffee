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
    'app/support/data/BillListData',
    'app/support/stores/Memory',
    'dojo/domReady!'
], (array, lang, onn, domCons, aspect, request, DeferredList,
    BorderContainer, TabContainer, ContentPane, Button, TextBox,
    Memory,
    TtxTabContainer, dataSource, storeFactory)->
    startup: (args)->
        base_url = 'http://localhost:9000'
        billStructure = {}
        store = storeFactory {
            dataSource: dataSource,
            size: 100
        }

        tc = new TtxTabContainer({
            region: "center",
            id: "contentTabs",
            "class": "centerPanel",
            style: "height: 500px; width: 100%;"
            "href": "contentCenter.html"
        }, 'container')
        tc.loadForm(billStructure, store)
        tc.startup()

        request(base_url + '/rest/creation/billStructure/ship', {handleAs: 'json'}).then(
            (data)->
                tc.loadForm(data, store)
        )

        window.tc = tc




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



































