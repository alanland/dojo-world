define [
    'dijit/form/Button',
    "gridx/Grid",
    "gridx/core/model/cache/Async",
    "gridx/modules/VirtualVScroller",
    "gridx/modules/ColumnResizer",
    "gridx/modules/extendedSelect/Row",
    "gridx/modules/SingleSort",
    "gridx/modules/Filter",
    "gridx/modules/Pagination",
    "gridx/modules/pagination/PaginationBar",
    "gridx/modules/pagination/PaginationBarDD",
    "dojo/store/JsonRest",
    "dojo/domReady!"
], (Button, Grid, Cache,
    VirtualVScroller, ColumnResizer, SelectRow,
    SingleSort, Filter, Pagination, PaginationBar,
    PaginationBarDD, JsonRest)->
    startup: (args)->
        store = new JsonRest({target: 'http://localhost:9000/rest/ship/list'})
        grid = new Grid {
            store: store,
            cacheClass: Cache,
            structure: [
                {id: "column_1", field: "id", name: "Id", width: "50%"},
                {id: "column_2", field: "no", name: "No"},
                {id: "column_3", field: "owner", name: "Owner"},
                {id: "column_4", field: "count", name: "Count"}
            ],
            selectRowTriggerOnCell: true,
            filterServerMode: true,
            filterSetupQuery:(expr)->
                console.log expr
                a = 10001
                r=""
                for i in [100000..1000]
                    r+=i
                "?abc="+r
#            filterSetupFilterQuery: (expr)->
#                toExpr = (expr)->
#                    JSON.stringify(expr)
#                newExpr = toExpr(exp
#                newExpr += ";" if newExpr
#                console.log("expr is: ", newExpr)
#                return {query: newExpr}
            modules: [
                VirtualVScroller,
                ColumnResizer,
                SelectRow,
                SingleSort,
                Filter,
                Pagination,
                PaginationBar,
                PaginationBarDD,
            ]
        }
        grid.placeAt("gridContainer")
        grid.startup()
        window.g = grid

        F = Filter

        query = [
            {op: 'lt', column: 'abc', value: '222', type: 'number'},
            {op: 'lt', column: 'abc', value: '222', type: 'number'},
            {op: 'lt', column: 'abc', value: '222', type: 'number'},
            {op: 'lt', column: 'abc', value: '222', type: 'number'}
        ]

        new Button({
            title: 'xxx'
            onClick: ->
                expr = F.and(
                    F.and(
                        F.startWith(F.column('colA', 'string'), F.value('123abc', 'string')),
                        F.greater(F.column('colB', 'number'), F.value(456, 'number'))
                    ),
                    F.or(
                        F.lessEqual(F.column('colC', 'number'), F.value(89, 'number')),
                        F.not(
                            F.endWith(F.column('colD', 'string'), F.value('xyz', 'string'))
                        )
                    )
                );
                grid.filter.setFilter({random:Math.random()})
                window.expr = expr
        }, 'top')

# test query






































