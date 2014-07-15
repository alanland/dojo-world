define ->
  [
    {
      widget:
        key: 'toolbar'
        type: 'dijit/Toolbar'
        children: [
          {
            widget:
              type: 'dijit/form/Button'
              widgetArgs:
                label: '新增'
                onClick: (e)->
                  alert '新增 clicked'
          }
          {
            widget:
              type: 'dijit/form/Button'
              widgetArgs:
                label: '修改'
          }
          {
            widget:
              type: 'dijit/form/Button'
              widgetArgs:
                label: '保存'
          }
          {
            widget:
              type: 'dijit/form/Button'
              widgetArgs:
                label: '关闭'
          }
        ]
    }
    {
      panel:
        dom:
          style:
            width: '100%'
            height: '100%'
            background: 'blue'
    }
  ]