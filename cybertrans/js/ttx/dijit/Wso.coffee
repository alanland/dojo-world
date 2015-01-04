define [
    'dojo/_base/declare',
    'dojo/_base/lang',
    'dojo/_base/fx'
    'dojo/dom'
    'dojo/dom-class',
    'dojo/dom-style',
    'dojo/dom-construct'
    'dojo/dom-geometry'
    'dojo/query'
    'dojo/on'
    'dojo/aspect'
    'dijit/registry'
    'dijit/form/Form',
    'dijit/_Container'
    'dojox/mvc/at'
    'dojox/mvc/getStateful'
    'dojox/mvc/ModelRefController'
    'ttx/util'# todo
], (declare, lang, fx, dom, domClass, domStyle, domConstruct, domGeometry, query, onn, aspect, #
    registry, Form, _Container, #
    at, getStateful, ModelRefController, #
    WsoDefUtil) ->
    wsoItemType =
        html: 'html'
        panel: 'panel'
        widget: 'widget' # 使用 addChild 添加
        domWidget: 'domWidget' # 使用 domConstruct 添加
        actions: 'actions'
        action: 'action'
    wsoItemDefault =
        html:
            key: undefined
            html: ''
        panel:
            width: '100%'
            height: '100%'
            key: undefined
            cols: 0
            children: []
            dom: {}
        domWidget:
            key: undefined
            widgetArgs: {}
        widget:
            key: undefined
            widgetArgs: {}

    declare [Form, _Container],
        # data: dojo/Stateful
        #       数据模型
        data: null
        dataResult: null
        wsoDef: null
        viewModel: null
        wsoItems: {}
        actions: []
        navigator: {}

    # ctrl: dojox/mvc/ModelRefController
    #       控制器
        ctrl: null

#  # cols: Integer
#  #       当前 Wso 有多少列，用作 Field(FormWidget) 的布局
#    cols: 2

    # buttons: Object
    #       当前wso的操作按钮集合
        buttons: {}

    # fields: Object
    #       字段集合
    #       key: key
    #       value: field 的dom，包含 label 和 formWidget
        fields: {}

    # buttonContainer: DOMNode
    #       操作按钮的container
        buttonContainer: null

    # fieldContainer: DOMNode
    #       字段的container
        fieldContainer: null

    # fieldClass: String
    #       每个字段的class。字段是包含label和formWidget的div
        fieldClass: 'wsoField'

    # gridClass: String
    #       grid的class
        gridClass: 'wsoGrid'
        panelClass: 'wsoPanel'

        constructor: ->
            # summary:
            #       构造
            @inherited(arguments);

        buildRendering: ->
            # summary:
            #       TODO 显示加载动画，现在是一个 p
            #       设置 containerNode
            #       生成 buttonContainer, fieldContainer
            @inherited arguments
            #TODO: make this better...
            @_loading = domConstruct.toDom '''
<div id="loadingOverlay" class="loadingOverlay pageOverlay">
  <div class="loadingMessage">Loading...</div>
</div>
'''
            node = @_loading;
            #      domClass.add(node, "bafDijitwsoLoading");
            #      node.innerHTML = "Loading...";
            domConstruct.place(node, @domNode, "last");

            @containerNode = @domNode if not @containerNode
            @buttonContainer = domConstruct.create 'div', {class: 'wsoButtonContainer'}, @domNode
            @fieldContainer = domConstruct.create 'div', {class: 'wsoFieldContainer'}, @domNode
            @containerNode = domConstruct.create 'div', {class: 'wsoContainerNode'}, @domNode

        postCreate: ->
            # summary:
            #       生成控制器
            #       todo 等待 wso 定义获取到之后生成表单
            @inherited arguments

            owner = this;
            @wsoDef.then (data)->
                owner._continueWithWsoDef(data);
            @data.then (data)->
                owner._continueWithData(data);
#                lang.hitch(owner,owner._continueWithWsoDef);
            , (err)->
                owner._abortLoad(err);

        submit: ->
            # summary:
            #       提交数据
            @_submit() if not @onSubmit() == false

        _submit: -> #todo 提交数据
            console.log '----------------------Submit----------------------'


#        addChild: (widget) ->
#            domConstruct.place(widget.domNode, @domNode, "last");
#            if (@_started and !widget._started and widget.startup)
#                widget.startup();

        addChild: (widget, insertIndex)->
            # summary:
            #       返回添加的widget
            # tags:
            #       override
            @inherited(arguments)
            widget

        addFields: (fieldDefs, refNode)->
            # summary:
            #       添加 控件
            for widgetDef in fieldDefs
                @addField(widgetDef, refNode)

        addField: (fieldDef, refNode)->
            # summary:
            #       添加一个字段，同时把字段放到 this.fields 里面
            container = refNode || @domNode
            label = fieldDef.label
            key = fieldDef.key
            widgetClass = fieldDef.type
            wdef = fieldDef.widget || {}

            wso = this
            wdef.formWidget = this
            wdef.value = at(@ctrl, wdef.name) if wdef.name
            require {async: false}, [widgetClass], (WidgetClass)->
                widget = new WidgetClass wdef
                wso.addChild widget
                ## todo to delete
                #        onn widget, 'change', (newValue)->
                #          console.log newValue
                #          window.w = this
                #          domStyle.set wso.fields['1'], 'display', 'none'
                #          domStyle.set wso.fields['2'], 'visibility', 'hidden'
                #          domStyle.set wso.fields['3'], 'visible', 'false'
                ##

                field = domConstruct.create 'div', {class: wso.fieldClass}, container
                label = domConstruct.create('label', {
                    class: wso.fieldClass + 'Label',
                    innerHTML: label,
                    for: widget.get('id')
                }, field) if label
                domConstruct.place widget.domNode, field
                wso.fields[key] = field
        addWsoItemDef: (wsoItem, refNode)->
            throw new Error('error type ') if typeof wsoItem is not 'object'
            for k,v of wsoItem
                curWsoNode = refNode
                switch k
                    when wsoItemType.html
                        curWsoNode = @addHTML WsoDefUtil.setDefaults(v, wsoItemDefault.html), refNode
                    when wsoItemType.actions
                        curWsoNode = @actions = @actions.concat v
                    when wsoItemType.action
                        curWsoNode = @actions.push v
                    when wsoItemType.panel
                        curWsoNode = @addPanel WsoDefUtil.setDefaults(v, wsoItemDefault.panel), refNode
                    when wsoItemType.widget
                        curWsoNode = @addWidget WsoDefUtil.setDefaults(v, wsoItemDefault.widget), refNode
                    when wsoItemType.domWidget
                        curWsoNode = @addDomWidget WsoDefUtil.setDefaults(v, wsoItemDefault.widget), refNode
                    else
                        throw new Error('xxx')
                if v.children and v.children.length > 0
                    for w in v.children
                        @addWsoItemDef w, curWsoNode # todo 指定添加方案，现在无法堆
                    registry.byNode(curWsoNode).startup()

        addHTML: (def, refNode)->
            node = domConstruct.toDom def.html
            domConstruct.place node, refNode
            @wsoItems[def.key] = node if def.key
            node

        addPanel: (def, refNode)->
            node = domConstruct.create 'div', lang.mixin(def.dom, cols: def.cols), refNode
            domClass.add node, @panelClass
            @wsoItems[def.key] = node if def.key
            @addFields def.fields, node if def.fields
            node
        addWidget: (def, refNode)->
            parentWidget = registry.byNode refNode
            wso = this
            wsoItems = @wsoItems
            curWsoItem = null
            require async: false, [def.type], (ctor)->
                curWsoItem = child = new ctor(lang.mixin def.widgetArgs, wso: wso)
                parentWidget.addChild child
                #        domConstruct.place child.domNode, refNode
                wsoItems[def.key] = child if def.key
            curWsoItem.containerNode || curWsoItem.domNode

        addDomWidget: (def, refNode)->
            wso = this
            wsoItems = @wsoItems
            curWsoItem = null
            require async: false, [def.type], (ctor)->
                curWsoItem = child = new ctor(lang.mixin def.widgetArgs, wso: wso)
                domConstruct.place child.domNode, refNode
                wsoItems[def.key] = child if def.key
            curWsoItem.containerNode || curWsoItem.domNode

        addGrid: (gridDef)->
            container = @fieldContainer
            label = gridDef.label
            key = gridDef.key
            widgetClass = gridDef.type
            wdef = gridDef.widget || {}
            wso = this
            wdef.formWidget = this
            wdef.value = at(@ctrl, wdef.name) if wdef.name
            require # todo

        layout: ->
            # summary:
            #       设置 field 的多列布局
            #       layout 方法，在resize时候触发
            fieldClass = @fieldClass
            query('.' + @panelClass, @domNode).forEach (panel)->
                cols = panel.getAttribute('cols')
                if cols > 0
                    panelBox = domGeometry.getContentBox panel
                    fieldWidth = parseInt(panelBox.w / cols)
                    query('.' + fieldClass, panel).forEach (field)->
                        domGeometry.setMarginBox field, w: fieldWidth
                        children = field.childNodes
                        if children.length == 2 and children[0].tagName == 'LABEL'
                            domGeometry.setMarginBox children[1], w: fieldWidth - domGeometry.getMarginBox(children[0]).w
#      contentBox = domGeometry.getContentBox @domNode
#      fieldWidth = contentBox.w / @cols
#      query('.' + @fieldClass, @domNode).forEach (node)->
#        domGeometry.setMarginBox(node, {w: fieldWidth})
#        children = node.childNodes
#        if children.length == 2 and children[0].tagName == 'LABEL'
#          domGeometry.setMarginBox children[1], {w: fieldWidth - domGeometry.getMarginBox(children[0]).w}

        setEnable: (field, enable)->
            # summary:
            #       设置字段编辑性
            # field: DOMNode|String
            # enable: Boolean
            if(typeof field != "string")
                field = @fields[field]
            domStyle.set field, 'readOnly', if enable then true else false
#            domStyle.set field, 'disabled', 'disabled'

        setVisible: (field, visible)->
            # summary:
            #       设置字段可见型
            # field: DOMNode|String
            # visible: Boolean
            if(typeof field != "string")
                field = @fields[field]
            # collapse, inherit
            domStyle.set field, 'visibility', if visible then 'visible' else 'hidden'
#            domStyle.set field, 'visible', 'false'
#            domStyle.set field, 'display', 'none'

        startup: ->
            if (!@_started)
                @_started = true;

            dojo.forEach @getChildren(), (child) ->
                if (child.startup)
                    child.startup();
            @inherited(arguments);


        _continueWithData: (data) ->
            @dataResult = getStateful data;
            @ctrl = new ModelRefController model: @dataResult
            if (@viewModel)
                @_finishLoad();

        _continueWithWsoDef: (wsoDef) ->
            @viewModel = wsoDef;
            if (@dataResult)
                @_finishLoad();

        _abortLoad: ->
            return if not @data

            data = @data
            wsoDef = @wsoDef;

            @data = null;
            @wsoDef = null;

            data.cancel();
            wsoDef.cancel();

            @_loading.innerHTML = "FAILED!!";

        _finishLoad: ->
            if (@viewModel.require) # todo 是否需要require
                require @viewModel.require, ->
            @_buildForm();

        _buildForm: ->
            fx.fadeOut({
                node: @_loading,
                onEnd: (node)->
                    domStyle.set(node, 'display', 'none')
            }).play()
            domConstruct.destroy @_loading
            delete @_loading


            wsoDef = @viewModel
            ## todo
            for itemDef in wsoDef
                @addWsoItemDef itemDef, @containerNode
            #      @cols = wsoDef.cols
            #      @addFields wsoDef.children if wsoDef.children
            #      @addGrid wsoDef.grid if wsoDef.grid
            if @actions
                for action in @actions
                    action.call this
            @layout()

        _buildForm2: ->
            domConstruct.destroy(@_loading);
            delete @_loading;

            wsoDef = @viewModel

            if wsoDef and wsoDef.size
                domStyle.set @domNode,
                    position: "absolute",
                    width: wsoDef.size[0],
                    height: wsoDef.size[1]
            else
                domStyle.set @domNode,
                    width: '100%'
                    height: '100%'


            walkChildren = (children, parentWidget) ->
                for p of children
                    child = children[p];
                    require [child[0]], (ctor) ->
                        widget = new ctor(child[1]);
                        parentWidget.addChild(widget);
                        if (child[2])
                            walkChildren(child[2], widget)

            if (wsoDef.children)
                walkChildren(wsoDef.children, this);
            @startup()