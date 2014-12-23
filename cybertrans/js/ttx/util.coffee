define [
    'dojo/_base/lang'
    'dojo/_base/array'
], (lang, array)->
    empty = {}
    util = {}
    lang.mixin util, {
        setDefaults: (args, defaults)->
            for p of defaults
                continue if empty[p] && `empty[p] == defaults[p]`
                if args[p] is undefined
                    args[p] = lang.clone(defaults[p])
                else if dojo.isObject defaults[p]
                    util.setDefaults args[p], defaults[p]
            args
        forEachString: (strings, proc, context)->
            array.forEach strings.split('.'), proc, context
        defaultWsoPanel: (args)->
            @setDefaults(args, {
                with: '100%'
                height: '100%'
                children: []
            })
    }