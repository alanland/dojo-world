define [
    'dojo/_base/declare'
    'dojo/store/Memory', # basic dojo/store
    'cbtree/Tree', # Checkbox tree
    'cbtree/model/TreeStoreModel'    # ObjectStoreModel
], (declare, Memory, Tree, ObjectStoreModel)->
    declare [Tree], {
        showRoot: false,
        openOnClick: true

    }

