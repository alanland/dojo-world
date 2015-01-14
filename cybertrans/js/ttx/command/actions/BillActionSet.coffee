define [
    'dojo/_base/declare'
    'dojo/_base/lang'
    'dojo/request'
    'ttx/store/JsonRest'
    'dojox/mvc/getStateful'
    'dojox/mvc/ModelRefController'
], (declare, lang, request, JsonRest, getStateful, ModelRefController)->
    getCtrlData = (ctrl)-> # todo 独立到单独模块
        data = lang.mixin({}, ctrl.model)
        data.declaredClass = undefined
        data._attrPairNames = undefined
        data._watchCallbacks = undefined
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
            cp.grid.store.muteQuery = false
            cp.grid.filter.setFilter(expr: {and: res})
#            cp.grid.pagination._updateBody()
#            cp.grid.pagination.gotoPage(0)
#            cp.grid.body.refresh()

        new: ->
            it = @wso
            @wso.tc.selectChild @wso.cpBill

            # 单头字段
            ctrl = it.cpBill.ctrl
            for k,v of getCtrlData(ctrl)
                ctrl.set k, '' if !lang.isFunction(v)
            # 明细
            if it.cpBill.grid
                it.cpBill.grid.store.muteQuery = true
                it.cpBill.grid.model.clearCache()
                it.cpBill.grid.body.refresh()

        edit: (item)->
            it = @wso
            view = @wso.viewModel
            bill = @wso.billModel
            header = @wso.headerTableModel
            detail = @wso.detailTableModel
            @wso.tc.selectChild @wso.cpBill

            id = item[header.idColumnName]
            tableKey = header.key
            it.app.dataManager.get("rest/cbt/#{tableKey}/#{id}").then (data)->
                for k,v of data
                    it.cpBill.ctrl.set k, v

            where = [{field: bill.subordinate, value: id}]
            it.cpBill.grid.store.muteQuery = false
            it.cpBill.grid.filter.setFilter(expr: {and: where})

        delete: ->
            it = @wso
            it.app.dataManager.delete(
                'rest/cbt/' + it.headerTableModel.key,
                {items: it.cpList.grid.select.row.getSelected()}
            ).then(->
                it.cpList.grid.model.clearCache()
                it.cpList.grid.body.refresh()
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
            @wso.tc.selectChild @wso.cpDetail
            '' #todo
        editDetail: (item)->
            it = @wso
            view = @wso.viewModel
            bill = @wso.billModel
            header = @wso.headerTableModel
            detail = @wso.detailTableModel
            id = item[detail.idColumnName]
            tableKey = detail.key
            it.app.dataManager.get("rest/cbt/#{tableKey}/#{id}").then (data)->
                for k,v of data
                    it.cpDetail.ctrl.set k, v
            @wso.tc.selectChild @wso.cpDetail

        deleteDetail: ->
            '' #todo
        createDetail: ->
            it = @wso
            it.app.dataManager.post(
                'rest/cbt/' + @wso.detailTableModel.key,
                @wso.getCtrlData(@wso.cpDetail.ctrl)
            ).then ->
                it.cpBill.grid.model.clearCache()
                it.cpBill.grid.body.refresh()
        updateDetail: ->
            ''
        resetDetail: ->
            '' # todo
        deleteDetail: ->
            it = @wso
            it.app.dataManager.delete(
                'rest/cbt/' + it.detailTableModel.key,
                {items: it.cpBill.grid.select.row.getSelected()}
            ).then(->
                it.cpBill.grid.model.clearCache()
                it.cpBill.grid.body.refresh()
            )
        gridAddRow: (grid)->
            grid.store.add({})
        gridDeleteRow: (grid)->
            for id in grid.select.row.getSelected()
                grid.store.remove(id)


    }
