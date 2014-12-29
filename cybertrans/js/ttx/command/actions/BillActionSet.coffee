define [
    'dojo/_base/declare'
    'dojo/request'
], (declare, request)->
    declare null, {
    # todo 事件支持传参数
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
        new: ->
            @wso.selectChild @wso.cpBill
    # todo
        edit: ->
            @wso.selectChild @wso.cpBill
    # todo
        delete: ->
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
        save: ->
            '' #todo
        reset: ->
            '' #todo
        newDetail: ->
            @wso.selectChild @wso.cpDetail
            '' #todo
        editDetail: ->
            @wso.selectChild @wso.cpDetail
            '' #todo
        deleteDetail: ->
            '' #todo
        saveDetail: ->
            '' #todo
        resetDetail: ->
            '' # todo
        gridAddRow: (grid)->
            grid.store.add({
            })
        gridDeleteRow: (grid)->
            for id in grid.select.row.getSelected()
                grid.store.remove(id)


    }
