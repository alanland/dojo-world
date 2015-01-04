require [
    'dojo/_base/declare'
    'dojo/on'
    'dojo/store/Memory'
    'dojo/store/JsonRest'
    'dijit/layout/ContentPane'
    'gridx/Grid'
    'gridx/core/model/cache/Async'
    'gridx/allModules'
], (declare, onn,
    Memory, JsonRest,
    ContentPane,
    Grid, Async, modules)->
    cp = new ContentPane({}, 'cp')
    cp.startup()

    structure = [
        {id: 'id', field: 'id', name: 'id', width: '150px'}
    ]
    store = new JsonRest {
        target: 'js/data.json'
#        headers: {}
    }
    grid = window.grid = new Grid({
            cacheClass: Async
            store: store
            structure: structure
            filterServerMode: true,
            modules: [
                modules.Filter
                modules.SingleSort
            ]
            filterSetupFilterQuery: (expr)->
                console.log expr
                @grid.store.headers["afilter"] = JSON.stringify(expr)
                #                return '' if !exp
                ''
        }
    )
    grid.startup()
    cp.addChild grid

    grid.filter.setFilter(expr: {a: 1, b: 2})


