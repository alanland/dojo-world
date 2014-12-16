define [
    'dojo/_base/declare',
    'dojo/_base/array',
    'dojo/dom-class',
    'dojo/dom-style',
    'dojo/dom-geometry',
    'dijit/_WidgetBase',
    'dijit/layout/_LayoutWidget'
], (declare, array, domClass, domStyle, domGeom, _WidgetBase, _LayoutWidget)->
    # todo Consider adding ability to set and/or freeze the height
    declare _LayoutWidget,
        postCreate: ->
            @inherited arguments
            domClass.add @domNode, 'bafDijitStatus'

        createTextPane: (paneId, args)->
            args = args || {}
            this[paneId] = new _WidgetBase args
            domClass.add this[paneId].domNode, 'bafDijitStatusStaticPane'
            @addChild this[paneId]

        deleteTextPane: (paneId)->
            pane = this[paneId]
            if pane
                @removeChild pane
                pane.destroy

        setTextPane: (paneId, text)->
            pane = this[paneId]
            if pane
                pane.domNode.innerHTML = text

    # something more

        startup: ->
            return if @_started
            array.forEach @getChildren(), @_setupChild, this
            @inherited arguments

        layout: ->
            @_layoutChildren()

        addChild: (child)->
            # child: Widget
            @inherited arguments
            @_layoutChildren if @_started

        setHeight: ->
            height = 0
            domNode = @domNode
            array.forEach @getChildren(), (child)->
                height = Math.max domGeom.getMarginBox(child.domNode).h, height
            height = height + domGeom.getPadBorderExtents(domNode).h
            domGeom.setMarginBox domNode, h: height

        _setupChild: (child)->
            # child: Widget
            child.domNode.style.position = 'absolute' if child.domNode

        _layoutChildren: ->
            domNode = @domNode
            children = @getChildren()
            totalWidth = 0
            e1 = domGeom.getPadBorderExtents domNode
            e2 = domGeom.getMarginExtents domNode
            rightEdge = domGeom.getMarginBox(domNode).w - (e1.w - e1.l) - (e2.w - e2.l)
            for i in [children.length - 1..1]
                node = children[i].domNode
                rightEdge -= domGeom.getMarginBox(node).w
                domGeom.setMarginBox node, l: rightEdge
            l = e1.l + e2.l
            domGeom.setMarginBox children[0].domNode, {l: l, w: rightEdge - l}

        demo: ->
            @createTextPane("message")
            @createTextPane("userName", {style: "width: 20em; height:1.5em"})
            @createTextPane("role", {"class": "statusPaneRed", style: "width: 10em"})



