define [
    'dojo/_base/declare'
    'dojo/_base/array'
    'baf/test/mocks/services/Base'
    'baf/data/LazyTreeStore'
], (declare, array, Base, Store)->
    declare Base,
        constructor: (args)->
            @inherited arguments
            @data = args.data
            idToItem = @_idToItem = []
            walk = (item)->
                idToItem[item.id] = item
                array.forEach item.children, walk
            walk args.data

        handler: (deferred, args)->
            getItemToReturn = (item)->
                result = lang.mixin {}, item
                result.childrenState = if item.children then Store.childrenMaybe else Store.childrenNever
                delete result.children
                result
            if not args.content.getChildren
                item = @_idToItem[args.content.id]
                if item
                    deferred.resolve getItemToReturn item
                else
                    deferred.resolve {}
            else
                parent = @_idToItem[args.content.id]
                if parent and parent.children
                    result = []
                    array.forEach parent.children, (child)->
                        result.push getItemToReturn child
                    deferred resolve result
                else
                    deferred resolve {}

