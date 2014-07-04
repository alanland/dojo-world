define [
  'dojo/_base/declare',
  'dojo/aspect',
  'dojo/topic'
], (declare, aspect, topic)->
  declare null,
    # summary:
    #   导航树

    # store: TreeModelStore
    #   导航的store。new args.navigator.store(args.navigator.storeArgs)
    store: null

  # model: TreeModel
  #   导航树的model。new args.navigator.model(args.navigator.modelArgs)
    model: null

  # widget: dijit/Tree
  #   导航控件，默认为tree，由args.navigator.widget指定控件类型。
  #   args.navigator.widgetArgs 指定参数，混入：
  #     store: this.store
  #     model: this.model
    widget: null

    constructor: (args)->
      # summary:
      #   根据传入的 nav 参数，生成 store和model，以及最终的widget
      #
      #   参数默认在 main 模块里面
      nav = args.navigator
      if nav.store
        @store = new nav.store(nav.storeArgs)
        nav.modelArgs.store = @store
        nav.widgetArgs.store = @store #todo
      if nav.model
        @model = new nav.model(nav.modelArgs)
        nav.widgetArgs.model = @model
      @widget = new nav.widget(nav.widgetArgs)

      # tree的 focusNode 时间绑定，发布事件，提供订阅
      store = @store
      aspect.after @widget, 'focusNode', (node)->
        # todo @store 是不是当前的store
        topic.publish 'focusNavNode', @store, node.item, node
      ,true


