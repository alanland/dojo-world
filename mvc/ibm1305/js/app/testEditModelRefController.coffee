define [
    'dijit/form/CheckBox'
    'dojo/dom'
    'dojo/Stateful'
    'dojo/store/Observable'
    'dojo/store/Memory'
    'dojox/mvc/at'
    'dojox/mvc/ModelRefController'
    'dojox/mvc/EditModelRefController'
    'dojo/domReady!'
], (CheckBox, dom, Stateful, Observable, Memory, at, ModelRefController, EditModelRefController)->
    model = new Stateful value: false

    ctrlSource = new ModelRefController model: model
    ctrlEdit = new EditModelRefController
        sourceModel: at(ctrlSource, 'model')
        holdModelUntilCommit: true

    checkSource = new CheckBox(checked: at(ctrlSource, 'value'), 'checkSource').startup()
    checkEdit = new CheckBox(checked: at(ctrlEdit, 'value'), 'checkEdit').startup()

    setTimeout ->
        dom.byId("checkEdit").click()
        setTimeout ->
            ctrlEdit.commit()
            console.log 'committed'
        , 1000
        console.log 'clicked'
    , 1000
