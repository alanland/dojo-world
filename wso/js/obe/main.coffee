define [
  'obe/Navigator',
  'obe/WorkspaceManager',
  'baf/dijit/Statusbar',
  'baf/util',
  'baf/command/ItemManager',
  'baf/dijit/MenuBand',
  'baf/data/LazyTreeStore',
  'baf/dijit/LazyTreeModel',
  'baf/data/WsoDefinitionsManager',
  'baf/data/DataManager',
  'dojo/dom-construct',
  'dijit/layout/BorderContainer',
  'dijit/layout/ContentPane',
  'dijit/Tree',
  'baf/extend/allExtends'
], (Navigator, WorkspaceManager, Statusbar, util, ItemManager, #
    MenuBand, LazyTreeStore, LazyTreeModel, WsoDefinitionsManager, #
    DataManager, domConstruct, BorderContainer, ContentPane, Tree) ->
  defaults =
    navigator:
      store: LazyTreeStore,
      storeArgs: {service: dojo.xhr},
#      model: LazyTreeModel,
      modelArgs: {},
      widget: Tree,
      widgetArgs:
        persist: false,
        region: "left",
        style: "width: 20%; overflow: auto",
        splitter: true,
        id: "navigator",
        showRoot: false

  main = {
    startup: (args)->
      #mixin defaults to args...
      args = util.setDefaults(args, defaults)


      @commandItemStore = new ItemManager({
        data: args.commandItems
      })
      util.setDefaults(args, {commandItemStore: @commandItemStore})

      @menu = new MenuBand(args)
      dojo.mixin(@menu, {
        region: "top",
        id: "menu"
      })

      @navigator = new Navigator(args)
      #
      @wsoDefinitionsManager = new WsoDefinitionsManager(args)
      @dataManager = new DataManager(args)
      @workspaceManager = new WorkspaceManager(args)
      #
      #create a fake status bar...
      @statusbar = new Statusbar()
      @statusbar.createTextPane("message")
      @statusbar.createTextPane("userName", {style: "width: 20em; height:1.5em"})
      @statusbar.createTextPane("role", {"class": "statusPaneRed", style: "width: 10em"})
      dojo.mixin(@statusbar, {
        region: "bottom",
        id: "status"
      })

      #create the main application container....
      appContainer = @appContainer = new BorderContainer({
      #fill up the viewport...
        style: "width: 100%; height: 100%",
        design: "headline"
      })

      #finally, destroy the loading message and show it all...
      domConstruct.destroy("bafLoading")
      domConstruct.place(appContainer.domNode, dojo.body(), "first")
      appContainer.addChild(@menu)
      appContainer.addChild(@statusbar)
      appContainer.addChild(@navigator.widget)
      #appContainer.addChild(@workspaceManager.widget)

      #tell the container to recalculate its layout...
      @statusbar.setHeight()
      appContainer.startup()

      window.onresize = ->
        appContainer.startup()
      window.main = this

  }
  return main