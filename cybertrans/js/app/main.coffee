define [
    "dojo/_base/array",
    'dojo/_base/lang',
    'dojo/dom-construct',
    'dojo/aspect',
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
    'dojo/domReady!'
], (array, lang, domCons, aspect,
    BorderContainer, TabContainer, ContentPane, Button, TextBox,
    Grid, Cache,
    VirtualVScroller, ColumnResizer, ExtendedSelectRow, ExtendedSelectColumn, RowHeader,
    SingleSort, Pagination, SelectRow, IndirectSelect,
    PaginationBar, Bar, Summary, DropDownPager,
    Memory)->
    startup: (args)->
        bc = new BorderContainer {}, 'container'
        left = new ContentPane {id: 'left', region: 'left'}
        bc.addChild(left)
        center = new ContentPane {id: 'center', region: 'center'}
        bc.addChild(center)
        bc.startup()

        fieldTypeMapping = {
            "string": "dijit/form/TextBox"
            "button": "dijit/form/Button"
        }

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
        storeData = [
            {id: 1, name: 'John1', score: 130, city: 'New York', birthday: '1980/2/5'},
            {id: 2, name: 'Alice2', score: 123, city: 'Washington', birthday: '1984/3/7'},
            {id: 3, name: 'Lee3', score: 149, city: 'Shanghai', birthday: '1986/10/8'},
            {id: 4, name: 'Mike', score: 100, city: 'London', birthday: '1988/8/12'},
            {id: 5, name: 'Tom', score: 89, city: 'San Francisco', birthday: '1990/1/21'}
            {id: 6, name: 'John', score: 130, city: 'New York', birthday: '1980/2/5'},
            {id: 7, name: 'Alice', score: 123, city: 'Washington', birthday: '1984/3/7'},
            {id: 8, name: 'Lee', score: 149, city: 'Shanghai', birthday: '1986/10/8'},
            {id: 9, name: 'Mike', score: 100, city: 'London', birthday: '1988/8/12'},
            {id: 10, name: 'Tom', score: 89, city: 'San Francisco', birthday: '1990/1/21'}
            {id: 11, name: 'John', score: 130, city: 'New York', birthday: '1980/2/5'},
            {id: 12, name: 'Alice', score: 123, city: 'Washington', birthday: '1984/3/7'},
            {id: 13, name: 'Lee', score: 149, city: 'Shanghai', birthday: '1986/10/8'},
            {id: 14, name: 'Mike', score: 100, city: 'London', birthday: '1988/8/12'},
            {id: 15, name: 'Tom', score: 89, city: 'San Francisco', birthday: '1990/1/21'}
        ]

        loadForm = (center, structure, storeData)->
            center.destroyDescendants()
            # query fields
            for key,value of queryFields
                require [
                    fieldTypeMapping[value[0]]
                ], (type)->
                    domCons.create('label', {innerHTML: value[1]}, center.domNode)
                    center.addChild(new type())
            # query button
            center.addChild new Button {
                label: "查询"
                onClick: ()->
                    console.log 'query clicked'
            }
            # gridx list
            store = new Memory({
                data: storeData
            });
            grid = Grid({
                id: 'grid',
                cacheClass: Cache,
                store: store,
                structure: structure,
                modules: [
                    SingleSort,
                    ColumnResizer,
                    Pagination,
                    Bar,
                    ExtendedSelectColumn,
                    RowHeader,
                    SelectRow,
                    IndirectSelect
                ]
                barTop: [
                ]
                barBottom: [
                    Summary,
                    DropDownPager,
                    "gridx/support/LinkSizer",
                    {pluginClass: "gridx/support/LinkPager", style: 'text-align: right;'}
                ]
            });
            gridContainer = domCons.create('div', {class: 'gridx'}, center.domNode)
            grid.placeAt(gridContainer);
            grid.startup();

            window.g = grid;

            #
            if(grid.pagination)
                updateRowNo = ()->
                    for x in [grid.pagination.lastIndexInPage() .. grid.pagination.firstIndexInPage()]
                        row = grid.row(x)
                        item = row.item()
                        item.order = row.visualIndex() + 1
                        grid.store.put(item)
                aspect.after grid.pagination, 'onSwitchPage', updateRowNo
                aspect.after grid.pagination, 'onChangePageSize', updateRowNo
                aspect.after grid.sort, 'sort', updateRowNo

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
            tabs = [{
                title: 'Tab 1',
                sub: [{
                    title: 'My 1st inner',
                    content: 'Lorem ipsum dolor sit amet'
                }, {
                    title: 'My 2nd inner',
                    content: 'Consectetur adipiscing elit'
                }]
            }, {
                title: 'Tab 2',
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
            tabContainer = new TabContainer({
                doLayout: true
            })
            array.forEach(tabs, (tab)->
                if(!tab.sub.length)
                    cp = new ContentPane({
                        title: tab.title,
                        content: 'No sub tabs'
                    });
                    tabContainer.addChild(cp);
                    return;

                subTab = new TabContainer({
                    title: tab.title,
                    doLayout: false,
                    nested: true
                })
                array.forEach(tab.sub, (sub)->
                    cp = new ContentPane({
                        title: sub.title,
                        content: sub.content
                    })
                    subTab.addChild(cp);
                )
                tabContainer.addChild(subTab);
            )
            center.addChild tabContainer

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




























