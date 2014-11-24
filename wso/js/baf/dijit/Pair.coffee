define [
  'dojo/_base/declare'
  'dojo/_base/lang'
  'dojo/dom-class'
  'dojo/dom-style'
  'dojo/dom-construct'
  'dojo/dom-geometry'
  'dijit/_Widget'
  'dijit/_Container'
  'dijit/_Contained'
], (declare, lang, domClass, domStyle, domConstruct, domGeom, _Widget, _Container, _Contained)->
  positToStyle = (posit)->
    result =
      position: 'absolute'
    result.left = posit.l if posit.l
    result.right = posit.r if posit.r
    result.top = posit.t if posit.t
    result.bottom = posit.b if posit.b
    result.width = posit.w if posit.w
    result.height = posit.h if posit.h
    result
  getContentPosit = (quadrant, parent, contentNode)->
    q = quadrant.toLowerCase()
    lang.mixin(
      getContentPosit.calculators[0][q.charAt(0)](parent, contentNode),
      getContentPosit.calculators[1][q.charAt(1)](parent, contentNode)
    )
  getContentPosit.calculators = [
    {
      t: ->
        top: 0
      c: (parent, contentNode)->
        top: ((domGeom.getContentBox(parent).h - domGeom.getMarginBox(contentNode).h) / 2) + 'px'
      b: ->
        bottom: 0
    },
    {
      l: ->
        left: 0
      c: (parent, contentNode)->
        left: ((domGeom.getContentBox(parent).w - domGeom.getMarginBox(contentNode).w) / 2) + 'px'
      r: (parent, contentNode)->
        r: 0
    }
  ]
  getMajorContentPosit = (stack, quadrant, majorNode, minorNode, contentNode)->
    q = quadrant.toLowerCase()
    calculators = getMajorContentPosit.calculators[stack.toLowerCase()]
    lang.mixin(
      calculators[0][q.charAt(0)](majorNode, minorNode, contentNode),
      calculators[1][q.charAt(1)](majorNode, minorNode, contentNode)
    )
    getMajorContentPosit.calculators = {
      h: [
        {
          t: ->
            top: 0
          c: (majorNode, minorNode, contentNode)->
            top: ((domGeom.getContentBox(majorNode).h - domGeom.getContentBox(contentNode).h) / 2) + "px"
          b: ->
            bottom: 0
        },
        {
          l: ->
            left: 0
          c: (majorNode, minorNode, contentNode) ->
            left: ((domGeom.getContentBox(majorNode).w - domGeom.getMarginBox(minorNode).w - domGeom.getMarginBox(contentNode).w) / 2) + "px"
          r: (majorNode, minorNode, contentNode)->
            right: domGeom.getMarginBox(minorNode).w + "px"
        }
      ],
      v: [
        {
          t: ->
            top: 0
          c: (majorNode, minorNode, contentNode)->
            top: ((domGeom.getContentBox(majorNode).h - domGeom.getMarginBox(minorNode).h - domGeom.getContentBox(contentNode).h) / 2) + "px"
          b: ->
            bottom: domGeom.getMarginBox(minorNode).h + "px"
        },
        {
          l: ->
            left: 0
          c: (majorNode, minorNode, contentNode)->
            left: ((domGeom.getContentBox(majorNode).w - domGeom.getMarginBox(contentNode).w) / 2) + "px"
          r: (majorNode, minorNode, contentNode)->
            right: 0
        }
      ]
    }

    return declare [_Widget, _Container, _Contained],
      stack: "h", #h => horizontal, v => vertical
      minorSize: "", #the size of the minor pane
      splitborder: "", #the CSS style of the border between the panes
      major: null, #(widget | text) the contents of the major pane
      minor: null, #(widget | text) the contents of the minor pane
      majorQ: "tl", #the location of the major contents within the major pane
      minorQ: "tl", #the location of the major contents within the minor pane

      postCreate: ->
        domStyle.set @domNode, positToStyle @posit
        posit =
          top: 0, left: 0, right: 0, bottom: 0, position: 'absolute'
        if @stack == 'h'
          posit.left = @minorSize
        else
          posit.top = @minorSize

        if @splitborder
          posit['border' + (if @stack == 'h' then 'Left' else 'Top')] = @splitborder
        domStyle.set @_minor, posit

      buildRendering: ->
        node = @_major = @domNode = document.createElement 'div'
        domClass.add node, 'bafDijitPair bafDijitPairMajor'
        if typeof @major == 'string'
          node = @_majorContentNode = document.createElement 'p'
          domStyle.set node, {node: 0, left: 0, position: 'absolute'}
          node.innerHTML = @major
          domConstruct.place node, @_major, 'last'
        node = @_minor = document.createElement 'div'
        domClass.add node, 'bafDijitPair bafDijitPairMinor'
        domConstruct.place node, @_major, 'last'

        if typeof @_major == 'string'
          node = this._minorContentNode = document.createElement("p");
          domStyle.set(node, {top: 0, left: 0, position: "absolute"});
          node.innerHTML = this.minor;
          domConstruct.place(node, this._minor, "last");

      startup: ->
        if not @_started
          @_started = true
          if @_majorContentNode
            style = lang.mixin(
              {top: "", left: "", bottom: "", right: "", style: "absolute"},
              getMajorContentPosit(this.stack, this.majorQ, this._major, this._minor, this._majorContentNode)
            )
            domStyle.set @_majorContentNode, style
          if @_minorContentNode
            style = lang.mixin(
              {top: "", left: "", bottom: "", right: "", style: "absolute"},
              getContentPosit(this.minorQ, this._minor, this._minorContentNode)
            )
            domStyle.set @_minorContentNode, style
          lang.forEach @getChildren, (child)->
            child.startup() if not child.startup() # ##########
      addChild: (widget)->
        if widget.pairPosition == "major"
          this._majorContentNode = widget.domNode;
          domConstruct.place(widget.domNode, this._major, "last")
        else
          this._minorContentNode = widget.domNode;
          domConstruct.place(widget.domNode, this._minor, "last");
        if @_started and not widget._started
          widget.startup()
