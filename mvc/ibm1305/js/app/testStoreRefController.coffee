define [
    'dijit/form/TextBox'
    'dojo/Stateful'
    'dojo/store/Memory'
    'dojox/mvc/at'
    'dojox/mvc/StoreRefController'
    'dojo/domReady!'
], (TextBox, Stateful, Memory, at, StoreRefController)->
    store = new Memory data: [
        {id: 'Foo', value: 'Foo'},
        {id: 'Bar', value: 'Bar'}
    ]
    ctrl = new StoreRefController store: store
    new TextBox(value: at(ctrl, 'value'), 'StoreRefController').startup()
    ctrl.getStore("Foo")
    setTimeout ->
        ctrl.getStore("Bar")
    , 1000
