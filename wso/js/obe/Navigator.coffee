define [
    'dojo/_base/declare',
    'dojo/on'
    'dojo/aspect',
    'dojo/topic'
    'dojo/store/Memory'
    'cbtree/model/TreeStoreModel'
], (declare, onn, aspect, topic, Memory, ObjectStoreModel)->
    declare null,
        # summary:
        #   导航树

        showRoot: false

    # store: TreeModelStore
    #   导航的store。new args.navigator.store(args.navigator.storeArgs)
    #
    #   item 中的type:
    #       'amd': 加载 amd 模块返回一个界面widget对象，符合 wso 接口
    #       'wso': workspace object 定义
        store: null

    # model: TreeModel
    #   导航树的model。new args.navigator.model(args.navigator.modelArgs)
        model: null

    # widget: dijit/Tree
    #   导航控件，默认为tree，由args.navigator.widget指定控件类型。
    #   args.navigator.widgetArgs 指定参数，混入：
    #     store: this.store
    #     model: this.model
        widget: ObjectStoreModel

        _getDefaultModel: ()->
            # summary:
            #   获取默认的 model
            data = [
                {"id": "root", "name": "TTX", "type": "root"},
                {"id": "user", "name": "用户", "type": "amd", "parent": "root"},
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
            })
            model

        constructor: (args)->
            # summary:
            #   根据传入的 nav 参数，生成 store和model，以及最终的widget
            #
            #   参数默认在 main 模块里面
            nav = args.navigator

            if args.model == undefined
                nav.widgetArgs.model = @_getDefaultModel()

            if nav.store
                @store = new nav.store(nav.storeArgs)
                nav.modelArgs.store = @store
                nav.widgetArgs.store = @store #todo
            if nav.model
                @model = new nav.model(nav.modelArgs)
                nav.widgetArgs.model = @model
            @widget = new nav.widget(nav.widgetArgs)
            @widget.startup()

            # tree的 focusNode 事件绑定，发布事件，提供订阅
            store = @store
            aspect.after @widget, 'focusNode', (node)->
                # todo @store 是不是当前的store
                topic.publish 'focusNavNode', store, node.item, node
            , true
            # click 事件发布，参数为item
            onn @widget, 'click', (item)->
                topic.publish 'clickNavNode', item
            window.tree = @widget




