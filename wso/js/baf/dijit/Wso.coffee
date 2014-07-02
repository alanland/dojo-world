define [
    'dojo/_base/declare',
    'dojo/_base/lang',
    'dojo/dom'
    'dojo/dom-class',
    'dojo/dom-style',
    'dojo/dom-construct'
    'dojo/dom-geometry'
    'dojo/query'
    'dojo/on'
    'dijit/form/Form',
    'dijit/_Container'
    'dojox/mvc/at'
    'dojox/mvc/ModelRefController'
], (declare, lang, dom, domClass, domStyle, domConstruct, domGeometry, query,onn, Form, _Container, #
    at, ModelRefController) ->
    declare [Form, _Container],
        dataResult: null,
        wsoDefResult: null,
        wsoDef: null,

    # model: dojo/Stateful
    #       数据模型
        model: null

    # ctrl: dojox/mvc/ModelRefController
    #       控制器
        ctrl: null

    # cols: Integer
    #       当前 Wso 有多少列，用作 Field(FormWidget) 的布局
        cols: 2

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
        fieldClass: 'wso-field'

    # gridClass: String
    #       grid的class
        gridClass: 'wos-grid'

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
            @_loading = document.createElement("p");
            node = @_loading;
            domClass.add(node, "bafDijitwsoLoading");
            node.innerHTML = "Loading...";
            domConstruct.place(node, @domNode, "last");

            @containerNode = @domNode if not @containerNode
            @buttonContainer = domConstruct.create 'div', {class: 'wsoButtonContainer'}, @domNode
            @fieldContainer = domConstruct.create 'div', {class: 'wsoFieldContainer'}, @domNode

        postCreate: ->
            console.log 'postcreate'
            # summary:
            #       生成控制器
            #       todo 等待 wso 定义获取到之后生成表单
            @inherited arguments
            @ctrl = new ModelRefController model: @model

            owner = this;
            @wsoDef.then (data)->
                owner._continueWithData(data);
                owner._continueWithWsoDef(data);
#                lang.hitch(owner,owner._continueWithWsoDef);
            , (err)->
                owner._abortLoad(err);
            console.log 'end postcreate'

        submit: ->
            # summary:
            #       提交数据
            @_submit() if not @onSubmit() == false

        _submit: -> #todo 提交数据
            console.log '----------------------Submit----------------------'
            console.log @model


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

        addFields: (fieldDefs)->
            # summary:
            #       添加 控件
            for widgetDef in fieldDefs
                @addField(widgetDef)

        addField: (fieldDef)->
            # summary:
            #       添加一个字段，同时把字段放到 this.fields 里面
            container = @fieldContainer
            label = fieldDef.label
            key = fieldDef.key
            widgetClass = fieldDef.type
            wdef = fieldDef.widget || {}

            wso = this
            wdef.formWidget = this
            wdef.value = at(@ctrl, wdef.name) if wdef.name
            require [widgetClass], (WidgetClass)->
                widget = new WidgetClass wdef
                wso.addChild widget
                ## todo to delete
                onn widget, 'change', (newValue)->
                    console.log newValue
                    window.w = this
                    domStyle.set wso.fields['1'], 'display', 'none'
                    domStyle.set wso.fields['2'], 'visibility', 'hidden'
                    domStyle.set wso.fields['3'], 'visible', 'false'
                ##

                field = domConstruct.create 'div', {class: wso.fieldClass}, container
                label = domConstruct.create('label', {
                    class: wso.fieldClass + 'Label',
                    innerHTML: label,
                    for: widget.get('id')
                }, field) if label
                domConstruct.place widget.domNode, field
                wso.fields[key] = field

        layout: ->
            # summary:
            #       设置 field 的多列布局
            #       layout 方法，在resize时候触发
            console.log 'layout'
            contentBox = domGeometry.getContentBox @fieldContainer
            fieldWidth = contentBox.w / @cols
            query('.' + @fieldClass, @fieldContainer).forEach (node)->
                domGeometry.setMarginBox(node, {w: fieldWidth})
                children = node.childNodes
                if children.length == 2 and children[0].tagName == 'LABEL'
                    domGeometry.setMarginBox children[1], {w: fieldWidth - domGeometry.getMarginBox(children[0]).w}
            console.log 'end layout'

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
            @dataResult = data;
            if (@wsoDefResult)
                @_finishLoad();

        _continueWithWsoDef: (wsoDef) ->
            @wsoDefResult = wsoDef;
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
            if (@wsoDefResult.require)
                require @wsoDefResult.require, ->
            @_buildForm();

        _buildForm: ->
            console.log 'buildform'
            domConstruct.destroy @_loading
            delete @_loading

            wsoDef = @wsoDefResult
            @cols = wsoDef.cols
            @addFields wsoDef.children
            console.log 'end buildform'
            @layout()

        _buildForm2: ->
            domConstruct.destroy(@_loading);
            delete @_loading;

            wsoDef = @wsoDefResult

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