define [
    'dojo/_base/declare'
    'dojo/Deferred'
    'dojo/store/Memory'
], (declare, Deferred, Memory)->
    childrenLoaded = -1
    childrenNever = 0
    childrenMaybe = 1
    LazyTreeStore = declare Memory, {

    }
    LazyTreeStore.childrenLoaded = childrenLoaded
    LazyTreeStore.childrenNever = childrenNever
    LazyTreeStore.childrenMaybe = childrenMaybe

    LazyTreeStore
