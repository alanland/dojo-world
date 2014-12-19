define [
    'dojo/dom'
    'dijit/form/CheckBox'
    'dojo/store/Observable'
    'dojo/store/Memory'
    'dojox/mvc/at'
    'dojox/mvc/EditStoreRefController'
    'dojo/domReady!'
], (dom, CheckBox, Observable, Memory, at, EditStoreRefController)->

    store = Observable(new Memory({data: [
        {id: "Foo", value: false}
    ]}))
    ctrl = new EditStoreRefController store: store

    checkSource = new CheckBox(checked: at(ctrl, 'value'), 'checkSourceStore').startup()
    checkEdit = new CheckBox(checked: at(ctrl, 'value'), 'checkEditStore').startup()

    ctrl.queryStore().observe (object, previousIndex, newIndex)->
        console.log "ID: #{object.id}, value: #{object.value}"
    , true
    count = 0
    h = setInterval ->
        dom.byId('checkEditStore').click()
        ctrl.commit()
        clearInterval(h) if ++count >= 10
    , 2000

#    new TextBox(value: at(ctrl, 'value'), 'EditStoreRefController').startup()
#    ctrl.getStore("Foo")
#    setTimeout ->
#        ctrl.getStore("Bar")
#    , 1000
#
#    ctrlSource = new ModelRefController model: model
#    ctrlEdit = new EditModelRefController
#        sourceModel: at(ctrlSource, 'model')
#        holdModelUntilCommit: true
#
#
#    setTimeout ->
#        dom.byId("checkEditStore").click()
#        setTimeout ->
#            ctrlEdit.commit()
#            console.log 'committed'
#        , 1000
#        console.log 'clicked'
#    , 1000
