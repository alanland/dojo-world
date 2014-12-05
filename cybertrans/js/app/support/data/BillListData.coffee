define [
    'dojo/_base/lang',
    'dojo/date/locale',
    'dijit/form/NumberTextBox',
    'dijit/form/DateTextBox',
    'dijit/form/TimeTextBox',
    'dijit/Editor',
    'dijit/ProgressBar',
    'dojo/_base/Color'
], (lang, locale, NumberTextBox, DateTextBox, TimeTextBox, Editor, ProgressBar, Color)->
    items = []
    for i in [1..1000]
        items.push {id: i, no: "20141212" + i, owner: "owner" + parseInt(i / 30), count: parseInt(Math.random() * 30)}

    getData: (args)->
        size = 100
        size = args.size if args.size
        data =
            identifier: 'id', label: 'id', items: []
        for i in [0..size]
            item = items[i % items.length]
            data.items.push lang.mixin({
                id: i
                order: i + 1
            }, item)
        data

