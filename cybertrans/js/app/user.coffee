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
    'dijit/form/ComboBox',
    'dijit/form/Button',
    'dijit/form/TextBox',
    'dijit/form/FilteringSelect'
    'dijit/form/DateTextBox'
    'dijit/form/RadioButton'
    'dijit/form/ToggleButton'
    'dijit/Toolbar'
    "dojo/store/Memory",
    'gridx/Grid',
    'gridx/core/model/cache/Sync'
    'gridx/allModules'
    'app/TtxTabContainer'
    'app/support/data/BillListData',
    'app/support/stores/Memory',
    'dojo/domReady!'
], (array, lang, onn, domCons, aspect, request, DeferredList,
    BorderContainer, TabContainer, ContentPane,
    ComboBox, Button, TextBox, FilteringSelect, DateTextBox, RadioButton, ToggleButton,
    Toolbar,
    Memory, Grid, Cache, modules,
    TtxTabContainer, dataSource, storeFactory)->
    startup: (args)->
        base_url = 'http://localhost:9000'
        billStructure = {}
        store = storeFactory {
            dataSource: dataSource,
            size: 100
        }

        tc = new TabContainer({
            region: "center",
            id: "contentTabs",
            "class": "centerPanel",
            style: "height: 500px; width: 100%;"
        }, 'container')
        tc.startup()

        cp1 = new ContentPane {
            title: '用户查询'
        }
        tc.addChild cp1
        cp2 = new ContentPane {
            title: '内容'
        }
        tc.addChild cp2
        #        tc.selectChild cp2

        # query field
        cp1query = new ContentPane()
        cp1.addChild cp1query

        domCons.create 'label', {innerHTML: '用户编码'}, cp1query.domNode
        queryUserCode = new TextBox()
        cp1query.addChild queryUserCode

        domCons.create 'label', {innerHTML: '用户名'}, cp1query.domNode
        queryUserName = new TextBox()
        cp1query.addChild queryUserName

        domCons.create 'label', {innerHTML: '部门'}, cp1query.domNode
        queryDepartment = new TextBox()
        cp1query.addChild queryDepartment

        buttonsDiv = domCons.create 'div', {class: 'toolbar'}, cp1.domNode
        queryButton = new Button label: '查询'
        domCons.place queryButton.domNode, buttonsDiv


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

        listDiv = domCons.create 'div', {id: 'listGridContainer'}, cp1.domNode
        structure = [
            {id: 'username', field: 'username', name: '用户名称', width: '100px'},
            {id: 'usercode', field: 'usercode', name: '用户编码', width: '100px'}
        ]
        grid1Toolbar = new Toolbar({});
        grid1Toolbar.addChild(new Button({
            label: '新增',
#            showLabel:false,
            iconClass: "dijitEditorIcon dijitEditorIconCopy",
            onClick: ()->
                alert('cut');
        }));
        grid1Toolbar.addChild(new Button({
            label: '删除',
            iconClass: "dijitEditorIcon dijitEditorIconDelete",
#            showLabel: false,
            onClick: ()->
                alert('paste');
        }));
        listGrid = createGrid('listGrid', 'listGridContainer', new Memory(data: []), structure, {
            style: {width: '100%', height: '300px'},
            barTop: [{content: '<h1>用户列表 </h1>'}, grid1Toolbar]
        });


        #  界面操作按钮
        contentButtons = domCons.create 'div', id: 'contentButtons', cp2.domNode
        domCons.create 'h1', {innerHTML: '用户资料', class: 'inline-block'}, contentButtons

        contentButtonsDiv = domCons.create 'div', id: 'contentButtonsDiv', contentButtons
        saveButton = new Button label: '保存'
        domCons.place saveButton.domNode, contentButtonsDiv

        resetButton = new Button label: '重置'
        domCons.place resetButton.domNode, contentButtonsDiv

        # 编辑区域
        # 基本信息
        domCons.create 'h2', {innerHTML: '基本信息'}, cp2.domNode

        domCons.create 'label', {innerHTML: '用户代码', for: 'editUserCode'}, cp2.domNode
        editUserCode = new TextBox {id: 'editUserCode'}
        domCons.place editUserCode.domNode, cp2.domNode

        domCons.create 'label', {innerHTML: '用户名', for: 'editUserName'}, cp2.domNode
        editUserName = new TextBox {id: 'editUserName'}
        domCons.place editUserName.domNode, cp2.domNode

        domCons.create 'label', {innerHTML: '部门', for: 'editDepartment'}, cp2.domNode
        editDepartment = new TextBox {id: 'editDepartment'}
        domCons.place editDepartment.domNode, cp2.domNode

        domCons.create 'label', {innerHTML: '密码', for: 'editPassword'}, cp2.domNode
        editPassword = new TextBox {id: 'editPassword', type: 'password'}
        domCons.place editPassword.domNode, cp2.domNode

        roleStore = new Memory({
            data: [
                {name: "Admin", id: "Admin"},
                {name: "Admin 1", id: "Admin-1"},
                {name: "Admin User", id: "Admin-User"},
                {name: "User", id: "User"},
                {name: "SJ", id: "SJ"},
                {name: "CG", id: "CG"},
                {name: "DD", id: "DD"}
            ]
        });
        domCons.create 'label', {innerHTML: '角色', for: 'editRole'}, cp2.domNode
        editRole = new FilteringSelect({
            store: roleStore,
            searchAttr: "name"
        })
        editRole.startup()
        domCons.place editRole.domNode, cp2.domNode

        domCons.create 'label', {innerHTML: '活动', for: 'editActive'}, cp2.domNode
        radioDiv = domCons.create 'div', {class: 'radioDiv'}, cp2.domNode
        editActive1 = new RadioButton({
            checked: true,
            value: "1",
            name: "editActive",
        })
        editActive1.startup()
        domCons.create 'label', {innerHTML: '是', for: editActive1.id, class: 'radioLabel'}, radioDiv
        domCons.place editActive1.domNode, radioDiv

        editActive2 = new RadioButton({
            value: "0",
            name: "editActive",
        })
        editActive2.startup()
        domCons.create 'label', {innerHTML: '否', for: editActive2.id, class: 'radioLabel'}, radioDiv
        domCons.place editActive2.domNode, radioDiv


        domCons.create 'label', {innerHTML: '生效日期', for: 'editStartDate'}, cp2.domNode
        editStartDate = new DateTextBox {id: 'editStartDate', constraints: {datePattern: 'yyyy-MM-dd'}}
        domCons.place editStartDate.domNode, cp2.domNode

        domCons.create 'label', {innerHTML: '失效日期', for: 'editEndDate'}, cp2.domNode
        editEndDate = new DateTextBox {id: 'editEndDate', constraints: {datePattern: 'yyyy-MM-dd'}}
        domCons.place editEndDate.domNode, cp2.domNode

        domCons.create 'label', {innerHTML: '允许用户登录', for: 'editAllowLogin'}, cp2.domNode
        radioDiv = domCons.create 'div', {class: 'radioDiv'}, cp2.domNode
        editAllowLogin1 = new RadioButton({
            value: "1",
            name: "editAllowLogin",
        })
        editAllowLogin1.startup()
        domCons.create 'label', {innerHTML: '是', for: editAllowLogin1.id, class: 'radioLabel'}, radioDiv
        domCons.place editAllowLogin1.domNode, radioDiv

        editAllowLogin2 = new RadioButton({
            checked: true,
            value: "0",
            name: "editAllowLogin",
        })
        editAllowLogin2.startup()
        domCons.create 'label', {innerHTML: '否', for: editAllowLogin2.id, class: 'radioLabel'}, radioDiv
        domCons.place editAllowLogin2.domNode, radioDiv


        # 扩展信息
        domCons.create 'h2', {innerHTML: '扩展信息'}, cp2.domNode
        domCons.create 'label', {innerHTML: '自定义字段1', for: 'extr1'}, cp2.domNode
        extr1 = new TextBox {id: 'extr1'}
        domCons.place extr1.domNode, cp2.domNode

        domCons.create 'label', {innerHTML: '自定义字段2', for: 'extr2'}, cp2.domNode
        extr2 = new TextBox {id: 'extr2'}
        domCons.place extr2.domNode, cp2.domNode

        domCons.create 'label', {innerHTML: '自定义字段3', for: 'extr3'}, cp2.domNode
        extr3 = new TextBox {id: 'extr3'}
        domCons.place extr3.domNode, cp2.domNode

        domCons.create 'label', {innerHTML: '自定义字段4', for: 'extr4'}, cp2.domNode
        extr4 = new TextBox {id: 'extr4'}
        domCons.place extr4.domNode, cp2.domNode

        domCons.create 'label', {innerHTML: '自定义字段5', for: 'extr5'}, cp2.domNode
        extr5 = new TextBox {id: 'extr5'}
        domCons.place extr5.domNode, cp2.domNode

        domCons.create 'label', {innerHTML: '自定义字段6', for: 'extr6'}, cp2.domNode
        extr6 = new TextBox {id: 'extr6'}
        domCons.place extr6.domNode, cp2.domNode

        domCons.create 'label', {innerHTML: '自定义字段7', for: 'extr7'}, cp2.domNode
        extr7 = new TextBox {id: 'extr7'}
        domCons.place extr7.domNode, cp2.domNode

        domCons.create 'label', {innerHTML: '自定义字段8', for: 'extr8'}, cp2.domNode
        extr8 = new TextBox {id: 'extr8'}
        domCons.place extr8.domNode, cp2.domNode

        domCons.create 'label', {innerHTML: '自定义字段9', for: 'extr9'}, cp2.domNode
        extr9 = new TextBox {id: 'extr9'}
        domCons.place extr9.domNode, cp2.domNode

        domCons.create 'label', {innerHTML: '自定义字段10', for: 'extr10'}, cp2.domNode
        extr10 = new TextBox {id: 'extr10'}
        domCons.place extr10.domNode, cp2.domNode





























