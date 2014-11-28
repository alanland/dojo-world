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
    "dojo/store/Memory"
], (array, lang, domCons, aspect,
    BorderContainer, TabContainer, ContentPane, Button, TextBox,
    Grid, Cache,
    VirtualVScroller, ColumnResizer, ExtendedSelectRow, ExtendedSelectColumn, RowHeader,
    SingleSort, Pagination, SelectRow, IndirectSelect,
    PaginationBar, Bar, Summary, DropDownPager,
    Memory)->
    fieldTypeMapping = {
        "string": "dijit/form/TextBox"
        "button": "dijit/form/Button"
    }
    (center, queryFields, structure, storeData)->
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
            ],
            barTop: [
            ],
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

        center.ttx={listGrid:grid}
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
