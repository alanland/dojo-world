define [
    'dojo/_base/declare'
    'dojo/_base/lang'
    'dojo/store/Memory',
    'dojo/store/Observable',
    './commandType'
], (declare, lang, Memory, Observable, commandType)->
    # 默认的命令，对于Item没有的定义的属性都会用下面的
    defaultCommandItem = {
        id: null,
        type: commandType.invalid,
        order: Number.MAX_VALUE,
        group: Number.MAX_VALUE,
        text: "undefined(debug)",
        accelText: "",
        mnemonic: "",
        accelKey: 0,
        accelShift: 0,
        statusText: null,
        helpUrl: null,
        tooltipText: null,
        enabledIcon: null,
        disabledIcon: null
    }
    declare Memory,
        # summary:
        #       继承 dojo/store/Memory，重写 get 方法

        get: (id) ->
            #  summary:
            #       重写get方法，混入默认的值
            #       Returns a command item as a hash; guaranteed to return immediately
            item = @inherited arguments || text: id
            lang.mixin {}, defaultCommandItem, item



