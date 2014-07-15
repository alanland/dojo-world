define ->
  [
    panel:
      cols: 1
      fields:
        [
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
              onClick: ->
                alert 'login clicked.'
          }
        ]
  ]