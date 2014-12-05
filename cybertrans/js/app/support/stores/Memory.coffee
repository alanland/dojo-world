define [
    'dojo/store/Memory',
    'dojo/store/util/QueryResults',
    'dojo/store/util/SimpleQueryEngine'
], (Memory, QueryResults, queryEngine)->
    (args)->
        data = args.dataSource.getData(args)
        store = new Memory data: data.items
        if args.tree
            store.hasChildren = (id, item)->
                item and item.children and item.children.length
            store.getChildren = (item, options)->
                QueryResults(queryEngine(options.query, options)(item.children))
        store

