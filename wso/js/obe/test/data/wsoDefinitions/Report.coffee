define [
  'dojo/_base/fx'
  'dojo/dom-style'
], (fx, domStyle) ->
  [
    {
      actions: [
        ->
          fx.fadeOut(
            node: @wsoItems.query.domNode
            onEnd: (node)->
              domStyle.set node, 'display', 'none'
          ).play()
      ]
    }
    {
      html:
        html: '''
<div><a href="#">click me</a></div>
'''
        children: [
          {
            widget:
              type: 'dijit/form/Button'
              widgetArgs:
                label: '查询show'
                onClick: (e)->
                  fx.fadeIn(
                    node: @wso.wsoItems.query.domNode
                    onEnd: (node)->
                      domStyle.set node, 'display', 'block'
                  ).play()
          }
        ]
    }
    {
      widget:
        type: 'dijit/form/Button'
        widgetArgs:
          label: '查询hide'
          onClick: (e)->
            fx.fadeOut(
              node: @wso.wsoItems.query.domNode
              onEnd: (node)->
                domStyle.set node, 'display', 'none'
            ).play()
    }
    {
      widget:
        type: 'dijit/form/Button'
        widgetArgs:
          label: '查询show'
          onClick: (e)->
            fx.fadeIn(
              node: @wso.wsoItems.query.domNode
              onEnd: (node)->
                domStyle.set node, 'display', 'block'
            ).play()
    }
    {
      widget:
        key: 'query'
        type: 'dijit/TitlePane'
        widgetArgs:
          title: '查询'
          content: 'someconent'
    }
    {
      widget:
        key: 'query'
        type: 'dijit/TitlePane'
        widgetArgs:
          title: '查询'
          content: 'someconent'
    }
    {
      widget:
        key: 'query'
        type: 'dijit/TitlePane'
        widgetArgs:
          title: '查询'
          content: 'someconent'
    }
    {
      widget:
        key: 'query'
        type: 'dijit/TitlePane'
        widgetArgs:
          title: '查询'
          content: 'someconent'
    }
    {
      widget:
        key: 'query'
        type: 'dijit/TitlePane'
        widgetArgs:
          title: '查询'
          content: 'someconent'
    }
    {
      widget:
        key: 'query'
        type: 'dijit/TitlePane'
        widgetArgs:
          title: '查询'
          content: 'someconent'
    }
    {
      widget:
        key: 'query'
        type: 'dijit/TitlePane'
        widgetArgs:
          title: '查询'
          content: 'someconent'
    }
    {
      widget:
        key: 'query'
        type: 'dijit/TitlePane'
        widgetArgs:
          title: '查询'
          content: 'someconent'
    }
    {
      widget:
        key: 'query2'
        type: 'dijit/TitlePane'
        widgetArgs:
          title: '查询'
          content: 'someconent'
        children: [
          {
            widget:
              type: 'dijit/form/Button'
              widgetArgs:
                label: '查询show'
                onClick: (e)->
                  fx.fadeIn(
                    node: @wso.wsoItems.query.domNode
                    onEnd: (node)->
                      domStyle.set node, 'display', 'block'
                  ).play()
          }
        ]
    }
  ]