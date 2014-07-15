define [
    'dojo/parser'
    'dojo/when'
    'dojo/Stateful'
    'dojox/mvc/at'
    'dijit/form/TextBox'
    'dojo/domReady!'
], (parser, whenn, Stateful, at, TextBox)->
    window.model = model= new Stateful({value: "Foo"})
    new TextBox(value: at(model, 'value'), 'value').startup()
    setTimeout ->
        model.set("value", "Bar")
    , 2000
    console.log parser

