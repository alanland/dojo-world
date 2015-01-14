define [
    'dojo/_base/lang'
    'dojo/dom-construct'
    'ttx/store/JsonRest'
    'dijit/ConfirmDialog'
    'dijit/form/TextBox'
    'dijit/layout/BorderContainer'
    'dijit/layout/ContentPane'
    'ttx/WorkspaceManager'
    'ttx/Navigator'
    'ttx/command/ItemManager'
    'ttx/data/DataManager'
    'ttx/data/WsoDefinitionsManager'
    'ttx/dijit/MenuBand'
    'ttx/dijit/StatusBar'
    'ttx/dijit/NotifyBox'
    "dojo/domReady!"
], (lang, domConstruct, JsonRest, ConfirmDialog, TextBox, BorderContainer, ContentPane,
    WorkspaceManager,
    Navigator, ItemManager, DataManager, WsoDefinitionsManager,
    MenuBand, StatusBar, NotifyBox)->
    # Create test store, adding the getChildren() method required by ObjectStoreModel
    app = {
        server: 'http://localhost:9000/'
        user: {
        # todo 登录机制，存储令牌而不是明文
            username: 'admin1'
            token: 'pass'
        }
        loginDialog: new ConfirmDialog {
            title: 'Login'
            draggable: false
            closable: false
            style: "width:400px"
        }
        dataManager: null
        wsoDefinitionsManager: null
        workspaceManager: null
        navigator: null
        menu: null
        statusBar: null
        appContainer: null
        startup: (args)->
            @buildLogin()
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

#            window.app = this
            # build cache
            @buildCache()

        buildCache: ->
            @rebuildCache('table')
            @rebuildCache('bill')
            @rebuildCache('view')

        rebuildCache: (type)->
            dataManager = @dataManager
            dataManager.get("rest/creation/#{type}Models", {updateCache: true}).then(
                (res)->
                    for r in res
                        dataManager.cacheObject("rest/creation/#{type}Models/#{r.key}", r)
                (err)->
                    console.error err
            )
        buildLogin: ->
            it = @
            username = new TextBox()
            password = new TextBox()
            dialog = @loginDialog
            dialog.addChild(username)
            dialog.addChild(password)
            dialog.onExecute = ->
                it.dataManager.post('/rest/auth/login', {
                    username: username.get 'value'
                    password: password.get 'value'
                }).then(
                    (res)->
                        if(res.code == '0' or res.code == 0)
                            it.user = res.user
                            it.navigator.reload()
                            it.loginDialog.hide()
                        else
                            new NotifyBox {
                                msg: "<b>登录失败 !</b>",
                                type: 'error'
                                position: "center"
                            }
                    (res)->
                        new NotifyBox {
                            msg: "<b>Network Error !</b>",
                            type: 'error'
                            position: "center"
                        }
                )
    }
    window.app = app
    app
