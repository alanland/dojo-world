define [
    'dojo/_base/declare',
    'dojo/_base/lang',
    'dojo/dom-class',
    'dojo/dom-style',
    'dojo/dom-construct',
    'dijit/form/Form',
    'dijit/_Container'
], (declare, lang, domClass, domStyle, domConstruct, Form, _Container) ->
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

    # buttonContainer: DOM
    #       操作按钮的container
        buttonContainer: null

    # fieldContainer: DOM
    #       字段的container
        fieldContainer: null

    # fieldClass: string
    #       每个字段的class。字段是包含label和formWidget的div
        fieldClass: 'wso-field'

    # gridClass: string
    #       grid的class
        gridClass: 'wos-grid'

        constructor: ->
            # summary
            #       构造
            @inherited(arguments);
    # todo
        postCreate: ->
            @inherited(arguments);
            owner = this;
            #connect the callbacks...
            #          TODO  @data.addCallback(this, "_continueWithData");
            #          TODO  @data.addErrback(this, "_abortLoad");
            @wsoDef.then (data)->
                owner._continueWithData(data);
                owner._continueWithWsoDef(data);
#                lang.hitch(owner,owner._continueWithWsoDef);
            , (err)->
                owner._abortLoad(err);

        buildRendering: ->
            @inherited(arguments);
            #TODO: make this better...
            @_loading = document.createElement("p");
            node = @_loading;
            domClass.add(node, "bafDijitwsoLoading");
            node.innerHTML = "Loading...";
            domConstruct.place(node, @domNode, "last");
            # END-TODO
            ''

        addChild: (widget) ->
            domConstruct.place(widget.domNode, @domNode, "last");
            if (@_started and !widget._started and widget.startup)
                widget.startup();

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