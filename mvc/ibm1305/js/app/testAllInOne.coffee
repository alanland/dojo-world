define [
    'dojo/_base/declare'
    'dojo/_base/lang'
    'dojo/_base/array'
    'dojo/_base/event'
    'dojo/on'
    'dojo/query'
    'dojo/dom-construct'
    'dojo/dom-style'
    'dojo/dom-geometry'
    'dijit/_WidgetBase'
    'dijit/_TemplatedMixin'
    'dijit/_WidgetsInTemplateMixin'
    'dijit/_Container'
    'dijit/layout/_LayoutWidget'
    'dijit/form/Form'
    'dijit/form/Button'
    'dijit/form/CheckBox'
    'dijit/form/TextBox'
    'dojo/dom'
    'dojo/Stateful'
    'dojo/store/Observable'
    'dojo/store/Memory'
    'dojox/mvc/at'
    'dojox/mvc/getStateful'
    'dojox/mvc/ModelRefController'
    'dojox/mvc/EditModelRefController'
    'dojo/domReady!'
], (declare, lang, array, event, onn, query, domCons, domStyle, domGeom, #
    _WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin, _Container, _LayoutWidget, #
    Form, Button, CheckBox, TextBox, dom, Stateful, Observable, Memory, #
    at, getStateful, ModelRefController, EditModelRefController)->
    declare 'FormField', [_WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin],
        templateString: """
<div><label></label><div></div></div>
"""
    declare 'Wso', [Form, _Container, _LayoutWidget],
        # Wso 定义
        #
        model: null
        ctrl: null
        cols: 2 #多少列
        buttons: {}
        fields: {}
    # 字段的container
        buttonContainer: null
        fieldContainer: null
    #
        fieldClass: 'wso-field'
        gridClass: 'wos-grid'
        constructor: ->
            @inherited arguments
            fields = new Memory(data: [])

        buildRendering: ->
            @inherited arguments
            @containerNode = @domNode if not @containerNode
            @buttonContainer = domCons.create 'div', {class: 'wsoButtonContainer'}, @domNode
            @fieldContainer = domCons.create 'div', {class: 'wsoFieldContainer'}, @domNode

        postCreate: ->
            @inherited arguments
            @ctrl = new ModelRefController model: @model

        submit: ->
            @_submit() if not @onSubmit() == false

        _submit: ->
            console.log '----------------------Submit----------------------'
            console.log @model

        addChild: (widget, insertIndex)->
            @inherited(arguments)
            widget
        addFormWidget22: (widgetDef)->
            form = this
            widgetClass = widgetDef.type
            label = widgetDef.label
            wdef = widgetDef.widget || {}

            wdef.formWidget = this
            wdef.value = at(@ctrl, wdef.name) if wdef.name
            require [widgetClass], (Widget)->
                widget = new Widget(wdef)
                wso.addChild widget
                field = domCons.create 'div', {}, form.domNode
                domCons.create 'label', {innerHTML: label, for: widget.get('id')}, field if label
                domCons.place widget.domNode, field

        addFormWidgets: (widgetDefs)->
            for widgetDef in widgetDefs
                @addFormWidget(widgetDef)

        addFormWidget: (fieldDef)->
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
                ##
                onn widget,'change', (newValue)->
                    console.log newValue
                    window.w = this
                    domStyle.set wso.fields['1'],'display','none'
                    domStyle.set wso.fields['2'],'visibility','hidden'
                    domStyle.set wso.fields['3'],'visible','false'
                ##

                field = domCons.create 'div', {class: wso.fieldClass}, container
                label = domCons.create('label', {
                    class: wso.fieldClass + 'Label',
                    innerHTML: label,
                    for: widget.get('id')
                }, field) if label
                domCons.place widget.domNode, field
                wso.fields[key] = field

        layout22: ->
            children = @getChildren()
            contentBox = domGeom.getContentBox(@domNode)

            inputWidth = contentBox.w / @cols
            array.forEach children, (child)->
#                child.set('style', {width: "#{inputWidth}px"})
                domGeom.setMarginBox(child.domNode, {w: inputWidth})
        layout: ->
            contentBox = domGeom.getContentBox @fieldContainer
            fieldWidth = contentBox.w / @cols
            query('.' + @fieldClass, @fieldContainer).forEach (node)->
                domGeom.setMarginBox(node, {w: fieldWidth})
                children = node.childNodes
                if children.length==2 and children[0].tagName=='LABEL'
                    domGeom.setMarginBox children[1],{w: fieldWidth-domGeom.getMarginBox(children[0]).w}



        addField:->
        removeField: (field)->
        showField:(field)->
        hideField:(field)->
        setEditorable:->
        setEnable:->


    # 模型创建
    model = getStateful username: 'wang', password: 'chengyi'

    wso = new Wso({model: model, cols: 2}, 'allInOne-form')

    # 控件定义
    widgetDefines = [
        {
            key:'1'
            type: 'dijit/form/TextBox'
            label: 'UserName1'
            widget:
                name: 'username'
        }
        {
            key: '2'
            type: 'dijit/form/TextBox'
            label: 'Password2'
            widget:
                name: 'other', placeHolder: 'Test placeHolder'
        }
        {
            key: '3'
            type: 'dijit/form/TextBox'
            label: 'Password3'
            widget:
                name: 'other', placeHolder: 'Test placeHolder'
        }
        {
            key: '4'
            type: 'dijit/form/TextBox'
            label: 'Password4'
            widget:
                name: 'other', placeHolder: 'Test placeHolder'
        }
    ]

    window.domGeo = domGeom
    window.btn = wso.addChild(new Button(label: 'Submit_Dom'))
    wso.addFormWidgets widgetDefines
#    wso.addFormWidgets widgetDefines
#    wso.addFormWidgets widgetDefines
#    wso.addFormWidgets widgetDefines
#    wso.addFormWidgets widgetDefines
#    wso.addFormWidgets widgetDefines
    wso.addFormWidget {
        type: 'dijit/form/Button'
        widget:
            label: 'Submit'
            onClick: ->
                @formWidget.submit()

    }

    #    window.username = wso.addChild new TextBox {
    #        name: 'username',
    #        formWidget: wso
    ##        value: at(ctrl, 'username')
    #    }
    #    password = wso.addChild new TextBox {
    #        name: 'password'
    #        value: at(ctrl, 'password')
    #    }
    #    wso.addChild(new TextBox({name: 'password', value: at(ctrl, 'username')}))
    #    wso.addChild(new TextBox({name: 'password', value: at(ctrl, 'password')}))
    #    wso.addChild(new TextBox({name: 'password', value: at(ctrl, 'password')}))
    #    wso.addChild(new TextBox({name: 'password', value: at(ctrl, 'password')}))
    #    wso.addChild(new TextBox({name: 'password', value: at(ctrl, 'password')}))


    wso.startup();

# 每两秒钟打印一次
#    setInterval(->
#        wso.submit()
#        username.set('value', new Date().getSeconds())
#        username.set('style', {width: '500px'})
#    , 2000)

##

#    ctrlSource = new ModelRefController model: model
#    ctrlEdit = new EditModelRefController
#        sourceModel: at(ctrlSource, 'model')
#        holdModelUntilCommit: true
#
#    checkSource = new CheckBox(checked: at(ctrlSource, 'value'), 'checkSource').startup()
#    checkEdit = new CheckBox(checked: at(ctrlEdit, 'value'), 'checkEdit').startup()
#
#    setTimeout ->
#        dom.byId("checkEdit").click()
#        setTimeout ->
#            ctrlEdit.commit()
#            console.log 'committed'
#        , 1000
#        console.log 'clicked'
#    , 1000
