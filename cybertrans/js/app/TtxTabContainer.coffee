define [
    'dojo/_base/declare'
    'dojo/dom-construct'
    'dojo/aspect'
    'dijit/form/Button'
    'dijit/layout/TabContainer'
    'dijit/layout/ContentPane'
    "gridx/Grid"
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
], (declare, domCons, aspect, Button, TabContainer, ContentPane
    Grid, Cache,
    VirtualVScroller, ColumnResizer, ExtendedSelectRow, ExtendedSelectColumn, RowHeader,
    SingleSort, Pagination, SelectRow, IndirectSelect,
    PaginationBar, Bar, Summary, DropDownPager,
    Memory)->
    declare TabContainer, {
        fieldTypeMapping: {
            "string": "dijit/form/TextBox"
            "button": "dijit/form/Button"
            "number": "dijit/form/NumberTextBox"
        }
        cpList: null
        cpBill: null
        cpDetail: null
        billStructure: null
        queryFields: {}

        listGrid: null

        postCreate: ->
            this.inherited(arguments)
            @cpList = new ContentPane title: "列表", selected: true
            @addChild @cpList
            @cpBill = new ContentPane title: "单据"
            @addChild @cpBill
            @cpDetail = new ContentPane title: "明细", closable: true
            @addChild @cpDetail

        loadForm: (structure, store)->
            if structure.queryFields
                @billStructure = structure
                @_loadListForm(store)
                @_loadBillForm()
                @_loadDetailForm()


        _loadListForm: (store)->
            @cpList.destroyDescendants()
            ss = @billStructure
            # query field
            #            @queryFieldsDom = domCons.create('div',@cpDetail.domNode)
            fields = @queryFields
            cpList = @cpList

            # 查询字段
            for fdef in ss.queryFields
                require [
                    @fieldTypeMapping[fdef.type]
                ], (dojoType)->
                    domCons.create('label', {innerHTML: fdef.name}, cpList.domNode)
                    f = new dojoType()
                    fields[fdef.id] = f
                    cpList.addChild(f)
            # 查询按钮
            cpList.addChild new Button {
                label: "查询"
                onClick: ->
                    console.log 'query clicked'
            }
            # 列表
            thiz = this
            grid = Grid({
#                id: 'grid',
                cacheClass: Cache,
                store: store,
                structure: @billStructure.listStructure,
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
                onCellDblClick: (evt)->
                    item = @row(evt.rowIndex).item()
                    thiz.selectChild(thiz.cpBill)
                    thiz.cpBill.destroyDescendants()
                    for fdef in thiz.billStructure.billStructure.headerFields
                        require [
                            thiz.fieldTypeMapping[fdef.type]
                        ], (dojoType)->
                            domCons.create('label', {innerHTML: fdef.name}, thiz.cpBill.domNode)
                            f = new dojoType()
#                            fields[fdef.id] = f
                            thiz.cpBill.addChild(f)
#                    request('js/test/json/details.json', {handleAs: 'json'}).then(
#                        (data)->
#                            for key,value of data
#                                require [
#                                    fieldTypeMapping[value[0]]
#                                ], (type)->
#                                    domCons.create('label', {innerHTML: value[1]}, detail.domNode)
#                                    field = new type()
#                                    field.set 'value', item[key]
#                                    detail.addChild(field)
#                                console.log value
#                    )

            })
            gridContainer = domCons.create 'div', {class: 'gridx'}, cpList.domNode
            grid.placeAt gridContainer
            grid.startup()
            @listGrid = grid

#            if(grid.pagination)
#                updateRowNo = ()->
#                    for x in [grid.pagination.lastIndexInPage() .. grid.pagination.firstIndexInPage()]
#                        row = grid.row(x)
#                        item = row.item()
#                        item.order = row.visualIndex() + 1
#                        grid.store.put(item)
#                aspect.after grid.pagination, 'onSwitchPage', updateRowNo
#                aspect.after grid.pagination, 'onChangePageSize', updateRowNo
#                aspect.after grid.sort, 'sort', updateRowNo
#                updateRowNo()



        updateListGrid: (data)->
            if @listGrid
                @listGrid.setStore(new Memory(data: data))


        _loadBillForm: ()->
            @cpBill.destroyDescendants()
            return
        _loadDetailForm: ()->
            @cpDetail.destroyDescendants()
            return

    }