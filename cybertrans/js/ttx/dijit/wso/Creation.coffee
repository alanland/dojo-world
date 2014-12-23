define [
    'dojo/_base/declare'
    'dojo/_base/lang'
    'dojo/dom-construct'
    'dojo/aspect'
    'dojo/on'
    'dojo/store/Memory'
    'dijit/_WidgetBase'
    'dijit/_TemplatedMixin'
    'dijit/_WidgetsInTemplateMixin'
    'dijit/form/TextBox'
    'dijit/layout/ContentPane'
    'dijit/layout/TabContainer'
    'dojo/text!./templates/Creation.html'
    'dojox/mvc/at'
    'dojox/mvc/getStateful'
    'dojox/mvc/ModelRefController'
    'gridx/allModules'
    'ttx/dijit/_TtxForm'
], (declare, lang, domConstruct, aspect, onn, Memory,
    _WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin, TextBox, ContentPane, TabContainer, template,
    at, getStateful, ModelRefController,
    modules,
    _TtxForm)->
    declare [_WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin, _TtxForm], {
        app: null
        tp: null

        actionSets: null

        cpTableModel: null
        tableModelModel: null
        tableModelCtrl: null
        tableModelFieldMap: {}

        cpBillModel: null
        BillModelModel: null
        BillModelCtrl: null

        templateString: template

        constructor: (args)->
            @inherited arguments
            @app = args.app
            thiz=this
            require {async: false}, ['ttx/command/actions/CreationActionSet'], (ajs)->
                defaultSet = new ajs()
                thiz.actionSets = {
                    default: defaultSet
                    global: defaultSet
                }


        buildRendering: ->
            @inherited arguments

        postCreate: ->
            @inherited arguments

            @
            @_initTableModel()
            aspect.after @tc, 'layout', lang.hitch(this, this._layoutTc)

        layout: ->
            @inherited arguments
            @_layoutTc()

        _layoutTc: ->
            @layoutFieldSetsPane(@cpTableModel.domNode)
            @layoutFieldSetsPane(@cpBillModel.domNode)

        _initTableModel: ->
            cp = @cpTableModel
            app = @app
            model = @tableModelModel = getStateful {}
            ctrl = @tableModelCtrl = new ModelRefController model: model
            defs = [
                {"id": "key", "type": "string", "field": "key", "name": "Key"},
                {
                    "id": "tableName", "type": "filteringSelect", "field": "tableName", "name": "Table Name",
                    "layout": {"wrap": true},
                    "args": {"url": "/rest/creation/tables", "searchAttr": "id"}
                },
                {
                    "id": "description", "type": "string", "field": "description", "name": "Description",
                    "layout": {"wrap": true}
                },
                {
                    "id": "idColumnName", "type": "filteringSelect", "field": "idColumnName", "name": "ID Column",
                    "layout": {"wrap": true}
                    "args": {"searchAttr": "field", "labelAttr": "name"}
                }
            ]
            fieldMap = @tableModelFieldMap
            @addTtxFieldSet(defs, ctrl, 2, cp.domNode, fieldMap)
            # 表改变的时候，刷新 idColumnName
            aspect.after @tableModelFieldMap['tableName'], 'onChange', (value)->
                app.dataManager.get("rest/creation/tables/#{value}/fields").then(
                    (res)->
                        # {id:0.19843485040876674, field:version, name:version, type:integer}
                        field = fieldMap['idColumnName']
                        field.set('store', new Memory(idProperty: "field", data: res))
                        field.set 'value', field.get('value')
                    (err)->
                        console.error err
                )
            , true

            # grid
            gridDef = {
                "name": "表模型字段",
                "actions": [
                    {
                        "id": "newDetail", "action": "", "name": "New Detail",
                        "args": {"showLabel": true, "iconClass": "dijitEditorIcon dijitEditorIconCopy"}
                    },
                    {
                        "id": "editDetail", "action": "", "name": "Edit Detail",
                        "args": {"showLabel": true, "iconClass": "dijitEditorIcon dijitEditorIconWikiword"}
                    },
                    {
                        "id": "deleteDetail", "action": "", "name": "Delete Detail",
                        "args": {"showLabel": true, "iconClass": "dijitEditorIcon dijitEditorIconDelete"}
                    },
                    {
                        "id": "deleteDetail", "action": "", "name": "drop down 1",
                        "args": {"showLabel": true, "iconClass": "dijitEditorIcon dijitEditorIconDelete"},
                        "dropDown": [
                            {
                                "id": "newDetail1", "action": "", "name": "some button1",
                                "args": {"showLabel": true, "iconClass": "dijitEditorIcon dijitEditorIconCopy"}
                            },
                            {
                                "id": "newDetail2", "action": "", "name": "some button2",
                                "args": {"showLabel": true, "iconClass": "dijitEditorIcon dijitEditorIconCopy"}
                            },
                            {
                                "id": "newDetail3", "action": "", "name": "some button3",
                                "args": {"showLabel": true, "iconClass": "dijitEditorIcon dijitEditorIconCopy"}
                            }
                        ]
                    },
                    {
                        "id": "deleteDetail", "action": "test", "name": "drop down 2",
                        "args": {"showLabel": true, "iconClass": "dijitEditorIcon dijitEditorIconDelete"},
                        "dropDown": [
                            {
                                "id": "newDetail1", "action": "", "name": "some button1",
                                "args": {"showLabel": true, "iconClass": "dijitEditorIcon dijitEditorIconCopy"}
                            },
                            {
                                "id": "newDetail2", "action": "", "name": "some button2",
                                "args": {"showLabel": true, "iconClass": "dijitEditorIcon dijitEditorIconCopy"}
                            },
                            {
                                "id": "newDetail3", "action": "", "name": "some button3",
                                "args": {"showLabel": true, "iconClass": "dijitEditorIcon dijitEditorIconCopy"}
                            }
                        ]
                    }
                ],
                "structure": [
                    {"id": "id", "field": "id", "name": "ID", "width": "30px"},
                    {"id": "material", "field": "material", "name": "Material", "width": "50px"},
                    {"id": "spec", "field": "spec", "name": "Spec"},
                    {"id": "qty", "field": "qty", "name": "Quantity", "width": "80px"}
                ]
            }
            @addTtxGrid(gridDef, cp.domNode, {
                modules: [
                    modules.MoveRow,
                    modules.DndRow,
                ]
            })


    }