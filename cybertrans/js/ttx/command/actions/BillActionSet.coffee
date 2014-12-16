define [
    'dojo/_base/declare'
    'dojo/request'
], (declare, request)->
    declare null, {
#        app: null
        wsoType: 'amd'
        wso: null
#        queryForm: null
        constructor: (args)->
            # summary:
            #       构造
            @wso = args.wso

        query: (e)->
            if @wsoType != 'amd'
                console.error('action type does not match wso type')
                return
            @wso.queryForm.onSubmit = ->
                console.log this
                alert(this)
            console.log @wso.queryForm.getValues()
        new: (e)->
            @wso.selectChild @wso.cpBill
        edit: (e)->
            @wso.selectChild @wso.cpBill
        delete: (e)->
            server = @wso.app.server
            grid = @wso.listGrid
            request(server + 'rest/' + @wso.navigatorItem.id, {
                method: 'delete'
                handleAs: 'json'
                data: JSON.stringify(grid.select.row.getSelected())
                headers: {'Content-Type': 'application/json'}
            }).then(
                (data)->
                    grid.setStore(new Memory data: data)
            )


    }
