define [
    'dojo/parser'
    'dojo/Stateful'
    'dojox/mvc/at'
    'dojox/mvc/sync'
    'dojox/mvc/Output'
], (parser, Stateful, at, sync, Output)->
    window.model = new Stateful
        First: "John", Last: "Doe", Email: "jdoe@example.com"

    # 通过 at(model, 'First') 实现数据绑定
    firstnameOutput = new Output(value: at(model, 'First'), 'firstnameOutput').startup()
    lastnameOutput = new Output(value: at(model, 'Last'), 'lastnameOutput').startup()
    emailOutpub = new Output(value: at(model, 'Email'), 'emailOutput').startup()


    parser.parse()

    startup: (args)->
        console.log 'startup'
        console.log args