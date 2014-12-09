define [
    "dojo/_base/array",
    'dojo/_base/lang',
    'dojo/on',
    'dojo/dom-construct',
    'dojo/aspect',
    'dojo/request'
    'dojo/keys'
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
], (array, lang, onn, domCons, aspect, request, keys, DeferredList,
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
        tc.set('ttxCurrentData', {})
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
                    selectRowTriggerOnCell: true
                    paginationBarMessage: "[ ${2} 到 ${3} ] (共 ${0} ), 已选择 ${1} 条",
                    modules: [
                        modules.Bar,
                        modules.RowHeader,
                        modules.IndirectSelect,
                        modules.ExtendedSelectRow,
#                        modules.MoveRow,
#                        modules.DndRow,
                        modules.VirtualVScroller
                        modules.SingleSort,
                        modules.ColumnResizer,
                        modules.Pagination,
                        modules.ExtendedSelectColumn,
                        modules.PaginationBar
                    ]
                }, args
            ));
            g.placeAt(container);
            g.startup();
            g

        listDiv = domCons.create 'div', {id: 'listGridContainer'}, cp1.domNode
        structure = [
            {id: 'username', field: 'us_username', name: '用户名称', width: '100px'},
            {id: 'usercode', field: 'us_usercode', name: '用户编码', width: '100px'}
        ]
        grid1Toolbar = new Toolbar({});
        listGridAddButton = new Button({
            label: '新增',
#            showLabel:false,
            iconClass: "dijitEditorIcon dijitEditorIconCopy",
#            onClick: ()->
#                alert('cut');
        })
        grid1Toolbar.addChild(listGridAddButton);
        listGridDeleteButton = new Button({
            label: '删除',
            iconClass: "dijitEditorIcon dijitEditorIconDelete",
#            showLabel: false,
#            onClick: ()->
#                alert('paste');
        })
        grid1Toolbar.addChild(listGridDeleteButton);
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
                {name: "Admin1", id: "Admin1"},
                {name: "AdminUser", id: "AdminUser"},
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

        # default focus
        queryUserCode.focus()

        # load bill form
        loadBillForm = (data)->
            tc.selectChild cp2
            tc.set('ttxCurrentData', data)
            console.log(data)
            editUserCode.focus()
            editUserCode.set 'value', data.us_usercode.trim()
            editUserName.set 'value', data.us_username.trim()
            editDepartment.set 'value', data.us_department.trim()
            editPassword.set 'value', data.us_password.trim()
            editRole.set 'value', data.us_role.trim()
            editActive1.set 'value', data.us_active
            editActive2.set 'value', 1 - data.us_active
            editStartDate.set 'value', data.us_start_date.trim()
            editEndDate.set 'value', data.us_end_date.trim()
            editAllowLogin1.set 'value', data.us_allow_login
            editAllowLogin2.set 'value', 1 - data.us_allow_login
            extr1.set 'value', data.us_extr1
            extr2.set 'value', data.us_extr2
            extr3.set 'value', data.us_extr3
            extr4.set 'value', data.us_extr4
            extr5.set 'value', data.us_extr5
            extr6.set 'value', data.us_extr6
            extr7.set 'value', data.us_extr7
            extr8.set 'value', data.us_extr8
            extr9.set 'value', data.us_extr9
            extr10.set 'value', data.us_extr10


        # action binding
        onn queryButton, 'click', (e)->
            queryButton.set('disabled',true)
            request(base_url + '/rest/demo/user/list', {
                handleAs: 'json'
                query: {
                    'usercode': queryUserCode.get('value')
                    'username': queryUserName.get('value')
                    'department': queryDepartment.get('value')
                }
            }).then(
                (data)->
                    listGrid.setStore(new Memory data: data)
                    queryButton.set('disabled',false)
                (err)->
                    alert(err);
                    queryButton.set('disabled',false)
            )
        onn listGridAddButton, 'click', (e)->
            tc.selectChild cp2
            editUserCode.focus()

        onn listGridDeleteButton, 'click', (e)->
            console.log
            request(base_url + '/rest/demo/user', {
                method: 'delete',
                handleAs: 'json',
                data: JSON.stringify(listGrid.select.row.getSelected())
                headers: {'Content-Type': 'application/json'}
                query: {
                    'usercode': queryUserCode.get('value')
                    'username': queryUserName.get('value')
                    'department': queryDepartment.get('value')
                }
            }).then(
                (data)->
                    listGrid.setStore(new Memory data: data)
            )

        getFormData = ()->
            data = []
            data.us_username = editUserName.get('value')
            data.us_usercode = editUserCode.get('value')
            data.us_department = editDepartment.get('value')
            data

        saveFormData = ()->
            saveButton.set('disabled',true)
            data = getFormData()
            request(base_url + '/rest/demo/user', {
                data: JSON.stringify(lang.mixin(tc.get('ttxCurrentData'), data)),
                handleAs: 'json'
                method: 'put'
                headers: {'Content-Type': 'application/json'}
            }).then(
                (res)->
                    console.log res
                    saveButton.set('disabled',false)
                (err)->
                    alert err
                    saveButton.set('disabled',false)
            )

        onn saveButton, 'click', (e)->
            saveFormData()

        resetFormData = ()->
            loadBillForm(tc.get('ttxCurrentData'))

        onn resetButton, 'click', (e)->
            resetFormData()

        onn listGrid, 'cellDblClick', (evt)->
            item = listGrid.row(evt.rowIndex).item()
            loadBillForm(item)

        # key binding
        onn window, 'keyup', (evt)->
            charOrCode = evt.charCode || evt.keyCode
            if evt.altKey
                if charOrCode == 83
                    saveFormData()
#                    onn.emit saveButton, 'click', {
#                        bubbles: true,
#                        cancelable: true
#                    }
                else if charOrCode == 82
                    resetFormData()
                    onn.emit resetButton, 'click', {
                        bubbles: true,
                        cancelable: true
                    }



































