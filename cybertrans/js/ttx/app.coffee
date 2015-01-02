define [
    'dojo/_base/lang'
    'dojo/dom-construct'
    'dojo/store/JsonRest'
    'dijit/layout/BorderContainer'
    'dijit/layout/ContentPane'
    'ttx/WorkspaceManager'
    'ttx/Navigator'
    'ttx/command/ItemManager'
    'ttx/data/DataManager'
    'ttx/data/WsoDefinitionsManager'
    'ttx/dijit/MenuBand'
    'ttx/dijit/StatusBar'
    "dojo/domReady!"
], (lang, domConstruct, JsonRest, BorderContainer, ContentPane,
    WorkspaceManager,
    Navigator, ItemManager, DataManager, WsoDefinitionsManager,
    MenuBand, StatusBar)->
    # Create test store, adding the getChildren() method required by ObjectStoreModel
    app = {
        server: 'http://localhost:9000/'
        dataManager: null
        wsoDefinitionsManager: null
        workspaceManager: null
        navigator: null
        menu: null
        statusBar: null
        appContainer: null
        startup: (args)->
            @dataManager = new DataManager(app: @)
            @wsoDefinitionsManager = new WsoDefinitionsManager(app: @)
            @workspaceManager = new WorkspaceManager(app: @)
            @navigator = new Navigator(app: @)
            @dataManager.getJson('menu').then(
                (data)->
                    commandItemStore = new ItemManager(
                        data: data.commandItems
                    )
                    mainMenu = data.mainMenu
                    @menu = new MenuBand(
                        commandItemStore: commandItemStore
                        menu: mainMenu
                        region: 'top'
                        app: app
                        id: 'menu'
                    )
                    appContainer.addChild @menu
                (err)->
                    console.error('error')
            )
            @statusBar = new StatusBar(region: 'bottom')
            @statusBar.demo()
            appContainer = @appContainer = new BorderContainer(
                style: 'width:100%; height:100%'
                design: 'headline'
                gutters: true
                liveSplitters: true
            )

            # 删除等待动画　　TODO　等待动画的制作
            domConstruct.destroy 'bafLoading'
            domConstruct.place appContainer.domNode, dojo.body(), 'first'

            # 添加布局元素
            appContainer.addChild @navigator.widget
            appContainer.addChild @statusBar
            appContainer.addChild @workspaceManager.getWsoContainer()
            appContainer.startup()
            window.onresize = ->
                appContainer.startup()

            window.app = this
            # build cache
            @buildInitCache()

        buildInitCache: ->
            dataManager = @dataManager
            dataManager.get('/rest/creation/tableModels', {cache: true}).then(
                (res)->
                    for r in res
                        dataManager.cacheObject("rest/creation/tableModels/#{r.key}", r)
                (err)->
                    console.error err
            )
            dataManager.get('/rest/creation/billModels', {cache: true}).then(
                (res)->
                    for r in res
                        dataManager.cacheObject("rest/creation/billModels/#{r.key}", r)
                (err)->
                    console.error err
            )
            dataManager.get('/rest/creation/viewModels', {cache: true}).then(
                (res)->
                    for r in res
                        dataManager.cacheObject("rest/creation/viewModels/#{r.key}", r)
                (err)->
                    console.error err
            )
            console.log 'app cache initialized'

    }
    app
