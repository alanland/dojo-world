define [
    'dojo/_base/declare'
], (declare)->
    declare null, {
        wso: null
        constructor: (args)->
            @wso = args.wso
        test: ->
            console.log 'creation action set: test'

        removeTableModelSelectRows: (grid)->
            grid = @wso.cpTableModel.grid
            for id in grid.select.row.getSelected()
                grid.store.remove(id)

        _checkTableModel: ->
            @wso.cpTableModel.form.validate()

        _getTableModelData: ->
            # summary:
            #       获取表模型数据
            gridData = []
            if cp.grid.rowCount() > 0
                for i in [0..cp.grid.rowCount() - 1]
                    gridData.push cp.grid.row(i).item()
            data = {
                key: cp.ctrl.get('key')
                tableName: cp.ctrl.get('tableName')
                description: cp.ctrl.get('description')
                idColumnName: cp.ctrl.get('idColumnName')
                fields: gridData
            }
            gridData

        tableModelCreate: ->
            # summary:
            #       新增表模型
            if not @_checkTableModel()
                return false
            data = @_getTableModelData()
            @wso.app.dataManager.post('/rest/creation/tableModels', data).then(
                (res)->
                    console.log res
                (err)->
                    console.error err
            )

        tableModelUpdate: ->
            # summary:
            #       更新表模型
            if not @_checkTableModel()
                return false
            data = @_getTableModelData()
            @wso.app.dataManager.put('/rest/creation/tableModels', data).then(
                (res)->
                    console.log res
                (err)->
                    console.error err
            )
    }