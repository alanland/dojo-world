define [
    'dojo/_base/declare',
    'dojo/on'
    'dojo/aspect',
    'dojo/topic'
    'dojo/request'
    'dojo/store/Memory'
    'cbtree/Tree'
    'cbtree/store/ObjectStore'
    'cbtree/model/TreeStoreModel'
], (declare, onn, aspect, topic, request, Memory, Tree, ObjectStore, ObjectStoreModel)->
    Navigator = declare null,
        # summary:
        #   导航树

        app: null
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

        constructor: (args)->
            # summary:
            #   根据传入的 nav 参数，生成 store和model，以及最终的widget
            #
            #   参数默认在 main 模块里面
            data = [
                {"id": "root", "name": "TTX", "tid": "root"},
                {"id": "user", "name": "用户", "tid": "bll:User", "parent": "root", oid: 'user'},
#                {"id": "basis", "name": "基础资料", "tid": "continent", "parent": "root"},
#                {"id": "basis_general", "name": "通用", "tid": "country", "parent": "basis"},
#                {"id": "owner", "name": "货主", "tid": "city", "parent": "basis_general"},
#                {"id": "material", "name": "物料", "tid": "city", "parent": "basis_general"},
#                {"id": "basis_wms", "name": "仓储", "tid": "country", "parent": "basis"},
#                {"id": "storeroom", "name": "仓间", "tid": "country", "parent": "basis_wms"},
#                {"id": "storearea", "name": "库区", "tid": "city", "parent": "basis_wms"},
#                {"id": "location", "name": "储位", "tid": "continent", "parent": "basis_wms"},
#                {"id": "inbound", "name": "入库", "tid": "country", "parent": "root"},
#                {"id": "receipt", "name": "入库单", "tid": "country", "parent": "inbound"},
#                {"id": "outbound", "name": "出库", "tid": "country", "parent": "root"},
#                {"id": "shipment", "name": "出库单", "tid": "country", "parent": "outbound"}
            ]
            store = new Memory({data: data});
            store = new ObjectStore({
                url: args.app.server + 'rest/data/navigator',
                handleAs: 'json'
            });
            model = new ObjectStoreModel({
                store: store,
                query: {id: "root"},
                rootLabel: "TTX",
                checkedRoot: true
            })

            @widget = new Tree(
                model: model,
                showRoot: false,
                openOnClick: true
                region: 'left'
                splitter: true
                id: 'navigator'
            )

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

        postCreate: ->
            server = @app.server
            thiz = this
            request(server + 'rest/data/navigator', {
                handleAs: 'json'
            }).then(
                (data)->
#                    model = new ObjectStoreModel({
#                        store: new Memory({data: data}),
#                        query: {id: "root"},
#                        rootLabel: "TTX",
#                        checkedRoot: true
#                    })
#                    thiz.widget.model = model
#                    alert('aa')

#                    thiz.widget = new Tree(
#                        model: model,
#                        showRoot: false,
#                        openOnClick: true
#                        region: 'left'
#                        splitter: true
#                    )

#                    thiz.widget.startup()

#                    # tree的 focusNode 事件绑定，发布事件，提供订阅
#                    aspect.after(thiz.widget, 'focusNode', (node)->
#                        # todo @store 是不是当前的store
#                        topic.publish 'focusNavNode', store, node.item, node
#                    , true)
#                    # click 事件发布，参数为item
#                    onn thiz.widget, 'click', (item)->
#                        topic.publish 'clickNavNode', item
#                    window.tree = thiz.widget # todo to delete
            )
    Navigator




