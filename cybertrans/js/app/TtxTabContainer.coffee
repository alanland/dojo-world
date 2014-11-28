define [
    'dojo/_base/declare'
    'dijit/layout/TabContainer'
    'dijit/layout/ContentPane'
], (declare, TabContainer, ContentPane)->
    declare TabContainer, {
        listPane: null
        detailPane: null
        postCreate: ->
            this.inherited(arguments)
            @listPane = new ContentPane(title: "查询", selected: true)
            closablePane = new ContentPane(
                title: "Close Me",
                closable: true
            )
            @detailPane = new ContentPane(title: "详细")
            @addChild @listPane
            @addChild @detailPane
            @set('doLayout', false)
            @addChild(closablePane)
            @layout()
    }