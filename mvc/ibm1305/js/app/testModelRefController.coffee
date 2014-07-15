define [
    'dijit/registry'
    'dijit/form/TextBox'
    'dojo/Stateful'
    'dojox/mvc/at'
    'dojox/mvc/ModelRefController'
    'dojo/domReady!'
], (registry, TextBox, Stateful, at, ModelRefController)->
    modelBar = new Stateful value: 'Foo'
    modelFoo = new Stateful()
    ctrl = new ModelRefController model: modelFoo
#    new TextBox value: at('widget:ctrl', 'value'), 'value'
    new TextBox(value: at(ctrl, 'value'), 'ModelRefController').startup()
    setTimeout ->
        ctrl.set("model", modelBar)
    , 2000
