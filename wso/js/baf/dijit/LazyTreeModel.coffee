declare [
    'dojo/_base/declare'
    'cbtree/model/TreeStoreModel'
], (declare, ObjectStoreModel)->
    declare ObjectStoreModel, {
    # summary
    #    An optimization of dijit.tree.ObjectStoreModel; requires baf.data.LazyTreeStore.

    # mayHaveChildren:
    # (item)->
    #   this.store.hasChildren item

    # root query
        query: {id: 'root'}

        rootLabel: 'TTX'

        checkedRoot: true

        newItem: ->
            throw new Error 'baf.dijit.LazyTreeModel: not implemented.'

        pasteItem: ->
            throw new Error('baf.dijit.LazyTreeModel: not implemented.')

    }
