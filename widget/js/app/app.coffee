define [
    'dojo/_base/declare'
    'dojo/parser'
    'dojo/ready'
    'dojo/dom-construct'
    'dojo/dom-style'
    'dijit/registry'
    'dijit/_WidgetBase'
    'dijit/_TemplatedMixin'
], (declare, parser, ready, domCons, domStyle, registry, _WidgetBase, _TemplatedMixin)->
    ###
    W1
    ###
    declare 'W1', [_WidgetBase],
        _i: 0,
        constructor: (params, srcNodeRef)->
            console.log "creating #{params}, on node #{srcNodeRef}"

        buildRendering: ->
            # create the dom for this widget
            @domNode = domCons.create 'button', innerHTML: "Count #{@_i}"

        postCreate: ->
            @connect @domNode, 'onclick', 'increment'

        increment: ->
            @domNode.innerHTML = "Count #{++@_i}"

    new W1({}, 'div1')

    ###
    W2
    ###
    declare 'W2', [_WidgetBase, _TemplatedMixin],
        _i: 0
        templateString: """
<div>
  <button data-dojo-attach-event='onclick: increment'>press me</button>
  &nbsp;count: <span data-dojo-attach-point='counter'>0</span>"
</div>
"""
        increment: ->
            @counter.innerHTML = ++@_i

    new W2 {}, 'div2'

    ###
    BusinessCard
    ###
    declare 'BusinessCard', [_WidgetBase, _TemplatedMixin],
        templateString: """
<div class='businessCard'>
  <div>Name: <span data-dojo-attach-point='nameNode'></span></div>
  <div>Phone #: <span data-dojo-attach-point='phoneNode'></span></div>
</div>
"""
        name: 'unknow'
        _setNameAttr:
            node: 'nameNode', type: 'innerHTML'

        nameClass: 'employeeName'
        _setNameClassAttr:
            node: "nameNode", type: "class"

        phone: "unknown"
        _setPhoneAttr:
            node: "phoneNode", type: "innerHTML"

    new BusinessCard {name: 'wang', nameClass: 'specialEmployeeName', phone: '019875'}, 'div3'

    ###
    Custom setters/getters
    ###
    declare 'HidePane', [_WidgetBase, _TemplatedMixin],
        templateString: """
<span>This pane is initially hidden</span>
"""
        open: true
        _setOpenAttr: (open)->
            @_set 'open', open
            domStyle.set @domNode, 'display', if open then 'block' else 'none'

    pane = new HidePane {open: false}, 'pane'
    window.show = ->
        pane.set('open', true);
    window.hide = ->
        pane.set('open', false);

    ###
    life cycle
    ###
    declare 'LifeCycle', [_WidgetBase],
        open: true
        constructor: ->
            console.log 'constructor'
            @watch 'open', ->
                console.log 'open changed'
        postMixInProperties: ->
            console.log 'postMixinProperties'
        buildRendering: ->
            console.log 'buildRendering'
        _setOpenAttr: ->
            console.log '_set open attr'
        postCreate: ->
            console.log 'postCreate'
        startup: ->
            console.log 'startup'
        destroy: ->
            console.log 'destroy'
    console.log '********************' + 'life cycle'
    new LifeCycle {}
    console.log '********************' + 'life cycle end'
    console.log '********************' + 'life cycle'
    new LifeCycle({a: 1, open: true}).set('open', true)
    console.log '********************' + 'life cycle end'

###
parse
###




