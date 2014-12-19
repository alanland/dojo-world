define [
    'dojo/date/locale'
    'dojo/Stateful'
    'dojox/mvc/at'
    'dojox/mvc/sync'
    'dojox/mvc/Output'
], (locale, Stateful, at, sync, Output)->
    testSync = ->
        ###
    我们先来看看 MVC 的数据绑定的相关接口 API。首先我们来看一个数据同步的接口：dojox/mvc/sync。
    使用方式如下：sync(source, sourceProp, target, targetProp, options)。
    source 是源数据，target 是目标数据。sourceProp/targetProp 是指源数据 / 目标数据的属性名，
    最后的 options 用于设定一些同步的参数。
###
        source = new Stateful({foo: "fooValue0"})
        target = new Stateful()

        sync(source, "foo", target, "foo"); # 同步 source 和 target
        alert(target.get("foo"));
        target.set("foo", "fooValue1"); # 该变化会立即同步到 source
        alert(source.get("foo"));

    testSync2 = ->
        source = new Stateful({foo: "fooValue0"})
        target = new Stateful();
        handle = sync(source, "foo", target, "foo"); # 开始同步
        alert(target.get("foo"));
        handle.remove(); # 停止同步
        target.set("foo", "fooValue1");
        alert(source.get("foo"));

    testSync3 = ->
        source = new Stateful({foo: "fooValue0"})
        target = new Stateful();
        # 单向同步 source --> targe
        sync(source, "foo", target, "foo", {bindDirection: sync.from});
        alert(target.get("foo"));
        source.set("foo", "fooValue1"); # 同步数据
        alert(target.get("foo"));
        target.set("foo", "fooValue2"); # 反向不同步数据
        alert(source.get("foo")); # source.foo 仍为 "fooValue1"

    testSync4 = ->
#        sync(source, sourceProp, target, targetProp, {
#            converter:
#                format: (value)->
#                    return "" + value; # source 到 target,
#                parse: (value)->
#                    return value - 0; # target 到 source
#        });
        source = new Stateful({date: new Date(1970, 0, 1, 0, 0, 0, 0)})
        target = new Stateful();
        sync source, 'date', target, 'date', converter: locale
        alert target.get 'date' # target 会返回格式化后的数据
        source.set date new Date() # target 自动返回格式化后的数据
        alert target.get 'date'

