define [
    'dojo/_base/declare'
    'dojo/_base/lang'
    'dojo/request'
    'dojo/store/JsonRest'
], (declare, lang, request, JsonRest)->
    getCtrlData = (ctrl)->
        data = lang.mixin({}, ctrl.model)
        data.declaredClass = undefined
        data._attrPairNames = undefined
        data

    declare null, {
    # todo 事件支持传参数
#        app: null
        wsoType: 'amd'
        wso: null

        constructor: (args)->
            # summary:
            #       构造
            @wso = args.wso

        query: (e)-> # 列表和查询
            cp = @wso.cpList
            ctrl = cp.ctrl
            view = @wso.viewModel
            bill = @wso.billModel
            header = @wso.headerTableModel
            detail = @wso.detailTableModel

            res = []
            for fdef in view.list.fields
                if cp.ctrl.get(fdef.id) # 有值
                    res.push {
                        table: fdef.table
                        field: fdef.field
                        value: ctrl.get(fdef.id)
                        operator: fdef.operator
                    }

            if @wsoType != 'amd'
                console.error('action type does not match wso type')
                return
#            cp.grid.setStore(new JsonRest {
#                target: cp.grid.store.target
#                idProperty: cp.grid.store.idProperty
#            })
#            cp.grid.model.clearCache()
            cp.grid.filter.setFilter(expr: {and: res})
#            cp.grid.pagination._updateBody()
#            cp.grid.pagination.gotoPage(0)
#            cp.grid.body.refresh()

        new: ->
            # todo
            @wso.selectChild @wso.cpBill
        edit: ->
            # todo
            @wso.selectChild @wso.cpBill
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
        create: ->
            @wso.app.dataManager.post(
                'rest/cbt/' + @wso.headerTableModel.key,
                @wso.getCtrlData(@wso.cpBill.ctrl)
            )
        update: ->
            ''
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
            grid.store.add({})
        gridDeleteRow: (grid)->
            for id in grid.select.row.getSelected()
                grid.store.remove(id)


    }
