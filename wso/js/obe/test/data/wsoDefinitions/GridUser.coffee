define ->
  [
    {
      panel:
        key: 'fields'
        dom:
          style:
            width: '100%'
        fields: [
          {
            key: 'username'
            type: 'dijit/form/TextBox'
            label: 'Username'
            widget:
              name: 'username'
          }
          {
            key: 'username'
            type: 'dijit/form/TextBox'
            label: 'Password'
            widget:
              name: 'password'
          }
          {
            key: 'button'
            type: 'dijit/form/Button'
            widget:
              label: 'Login'
          }
        ]
    }
    {
      panel:
        key: 'grid'
        dom:
          style:
            width: '100px'
            height: '200px'
            background: 'red'
    }
    {
      panel:
        key: 'something'
    }
  ]
#
#  cols: 1
#  grid:
#    key: 'gird'
#    type: 'gridx/Grid'
#    widget:
#      cacheClass: "gridx/core/model/cache/Async"
#      structure: [
#        {
#          id: 'name', field: 'name', name: 'Name', width: '50px'
#        },
#        {
#          id: 'score', field: 'score', name: 'Score', width: '50px', editable: true,
#          alwaysEditing: true
#        },
#        {
#          id: 'city', field: 'city', name: 'City', width: '100px', editable: true,
#          alwaysEditing: true
#        },
#        {
#          id: 'birthday', field: 'birthday', name: 'Birthday', width: '100px',
#          editable: true,
#          alwaysEditing: true,
#          dateType: 'date',
#          storePattern: 'yyyy/M/d',
#          gridPattern: 'yyyy/MMMM/dd'
#        }
#      ]