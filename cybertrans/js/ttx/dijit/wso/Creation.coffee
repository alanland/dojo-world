define [
    'dojo/_base/declare'
    'dojo/dom-construct'
    'dijit/layout/ContentPane'
    'dijit/layout/StackContainer'
    'dijit/layout/StackController'
], (declare, domConstruct, ContentPane, StackContainer, StackController)->
    declare [ContentPane], {
        app: null
        sc: null
        constructor: (args)->
            @inherited arguments
            @app = args.app
        buildRendering: ->
            @inherited arguments
        postCreate: ->
            @inherited arguments
            sc = @sc = new StackContainer({
                style: "height: 300px; width: 400px;",
            })
            sc.addChild(
                new ContentPane({
                    title: "page 1",
                    content: "page 1 content"
                });
            )
            controller = new StackController(
                {containerId: "myProgStackContainer"}
            )
            domConstruct.place sc.domNode, @domNode
            domConstruct.place controller.domNode, sc.domNode

            sc.startup();
            controller.startup();
    }