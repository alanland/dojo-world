define [
    "dojo/ready",
    "dojo/store/Memory", # basic dojo/store
    "cbtree/Tree", # Checkbox tree
    "cbtree/model/TreeStoreModel"    # ObjectStoreModel
    "dojo/domReady!"
], (ready, Memory, Tree, ObjectStoreModel)->
    # Create test store, adding the getChildren() method required by ObjectStoreModel
    startup: (args)->
        data = [
            {"id": "root", "name": "TTX", "type": "planet"},
            {"id": "basis", "name": "基础资料", "type": "continent", "parent": "root"},
            {"id": "basis_general", "name": "通用", "type": "country", "parent": "basis"},
            {"id": "owner", "name": "货主", "type": "city", "parent": "basis_general"},
            {"id": "material", "name": "物料", "type": "city", "parent": "basis_general"},
            {"id": "basis_wms", "name": "仓储", "type": "country", "parent": "basis"},
            {"id": "storeroom", "name": "仓间", "type": "country", "parent": "basis_wms"},
            {"id": "storearea", "name": "库区", "type": "city", "parent": "basis_wms"},
            {"id": "location", "name": "储位", "type": "continent", "parent": "basis_wms"},
            {"id": "inbound", "name": "入库", "type": "country", "parent": "root"},
            {"id": "receipt", "name": "入库单", "type": "country", "parent": "inbound"},
            {"id": "outbound", "name": "出库", "type": "country", "parent": "root"},
            {"id": "shipment", "name": "出库单", "type": "country", "parent": "outbound"}
        ]
        store = new Memory({data: data});
        model = new ObjectStoreModel({
            store: store,
            query: {id: "root"},
            rootLabel: "TTX",
            checkedRoot: true
        });
        ready ()->
            tree = new Tree({
                model: model,
                id: "ttx_menu_tree",
                showRoot: false,
                openOnClick:true
            }, "container");
            tree.startup();
