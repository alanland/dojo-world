define [
    "dojo/_base/array",
    'dojo/_base/lang',
    'dojo/dom-construct',
    'dojo/aspect',
    'dojo/request'
    'dojo/DeferredList'
    'dijit/layout/BorderContainer',
    'dijit/layout/TabContainer',
    'dijit/layout/ContentPane',
    'dijit/form/Button',
    'dijit/form/TextBox',
    "gridx/Grid",
    "gridx/core/model/cache/Sync",
    "gridx/modules/VirtualVScroller",
    "gridx/modules/ColumnResizer",
    "gridx/modules/extendedSelect/Row",
    "gridx/modules/extendedSelect/Column",
    "gridx/modules/RowHeader",
    "gridx/modules/SingleSort",
    "gridx/modules/Pagination",
    "gridx/modules/select/Row",
    "gridx/modules/IndirectSelect",
    "gridx/modules/pagination/PaginationBar",
    "gridx/modules/Bar",
    "gridx/support/Summary",
    "gridx/support/DropDownPager",
    "dojo/store/Memory",
    'app/TtxTabContainer'
    'app/loadForm'
    'dojo/domReady!'
], (array, lang, domCons, aspect, request, DeferredList,
    BorderContainer, TabContainer, ContentPane, Button, TextBox,
    Grid, Cache,
    VirtualVScroller, ColumnResizer, ExtendedSelectRow, ExtendedSelectColumn, RowHeader,
    SingleSort, Pagination, SelectRow, IndirectSelect,
    PaginationBar, Bar, Summary, DropDownPager,
    Memory,
    TtxTabContainer, loadForm)->
    startup: (args)->
        bc = new BorderContainer {}, 'container'
        left = new ContentPane {id: 'left', region: 'left'}
        bc.addChild(left)
        center = new ContentPane {id: 'center', region: 'center'}
        bc.addChild(center)
        bc.layout()
        bc.startup()

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
        listGridData = []
        request('js/test/json/structure.json', {handleAs: 'json'}).then(
            (data)->
                queryFields = data.queryFields
                listStructure = data.listStructure
                detailFields = data.detailFields
                loadForm center, queryFields, listStructure, listGridData
        )
        request('js/test/json/listGridData.json', {handleAs: 'json'}).then(
            (data)->
                listGridData = data
                if center.ttx
                    center.ttx.listGrid.setStore(new Memory(data: data))
        )

        tabs = [{
            title: '查询',

            sub: [{
                title: 'My 1st inner',
                content: 'Lorem ipsum dolor sit amet'
            }, {
                title: 'My 2nd inner',
                content: 'Consectetur adipiscing elit'
            }]
        }, {
            title: '基本信息',
            sub: [{
                title: 'My 3rd inner',
                content: 'Vivamus orci massa rhoncus a lacinia'
            }, {
                title: 'My 4th inner',
                content: 'Fusce sed orci magna, vitae aliquet quam'
            }]
        }, {
            title: 'Tab 3',
            sub: []
        }]


        loadTab2 = (center)->
            center.destroyDescendants()
            tc = new TabContainer({
                style: "height: 100%; width: 100%;"
            })
            cp1 = new ContentPane({
                title: "Food",
                content: "We offer amazing food"
            })
            tc.addChild(cp1)
            cp2 = new ContentPane({
                title: "Drinks",
                content: "We are known for our drinks."
            })
            tc.addChild(cp2);

            center.addChild new TabContainer({
                style: "height: 100%; width: 100%;"
            })
            tc.startup()

        loadTab = ()->
            center.destroyDescendants()
            tc = new TabContainer({
                region: "center",
                id: "contentTabs",
                tabPosition: "bottom",
                "class": "centerPanel",
                href: "contentCenter.html"
            })
            tc.addChild new ContentPane title: '1111'

            #            tc = new TtxTabContainer(style: "height: 100%; width: 100%;")
            center.addChild tc
            tc.startup()
        #            tabContainer = new TabContainer({
        #                doLayout: true
        #            })
        #            center.addChild tabContainer
        #
        #            array.forEach(tabs, (tab)->
        #                if(!tab.sub.length)
        #                    cp = new ContentPane({
        #                        title: tab.title,
        #                        content: 'No sub tabs'
        #                    });
        #                    tabContainer.addChild(cp);
        #                    return;
        #
        #                subTab = new TabContainer({
        #                    title: tab.title,
        #                    doLayout: false,
        #                    nested: true
        #                })
        #                array.forEach(tab.sub, (sub)->
        #                    cp = new ContentPane({
        #                        title: sub.title,
        #                        content: sub.content
        #                    })
        #                    subTab.addChild(cp);
        #                )
        #                tabContainer.addChild(subTab);
        #            )
        #            tabContainer.startup()
        #            center.addChild tabContainer
        #            window.tab = tabContainer

        left.addChild(new Button({
            label: '用户'
#            onClick: ->
#                center.destroyDescendants()
#                tc = new TabContainer({
#                    style: "height: 100%; width: 100%;"
#                })
#                center.addChild tc
#            onClick: lang.hitch this, loadForm, center, structure, storeData
            onClick: lang.hitch this, loadTab, center
        }))

        left.addChild(new Button({
            label: 'LoadForm'
            onClick: lang.hitch this, loadForm, center, queryFields, structure, []
        }))

        left.addChild new Button {
            label: "表格测试"
            onClick: ->
                grid = window.g

                for x in [0..grid.pagination.pageSize() - 1]
                    row = grid.row(x)
                    item = row.item()
                    item.order = row.visualIndex() + 1
                    grid.store.put(item)
        }




























