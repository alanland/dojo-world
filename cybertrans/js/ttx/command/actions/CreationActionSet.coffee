define [
    'dojo/_base/declare'
    'dojo/store/Memory'
], (declare, Memory)->
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


    #
    # bill model
    #

        _checkTableModel: ->
            @wso.cpTableModel.form.validate()

        _getTableModelData: ->
            # summary:
            #       获取表模型数据
            gridData = []
            cp = @wso.cpTableModel
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
            data

        tableModel_Delete: ->
            cp = @wso.cpTableModel
            key = cp.ctrl.get('key')
            if key
                @wso.app.dataManager.delete('/rest/creation/tableModels/' + key)
            else
                console.log 'no value to delete'
        tableModel_New: ->
            # summary:
            #       新增动作，清空界面数据
            cp = @wso.cpTableModel
            cp.modelSelect.set 'value', ''
            for k in ['key', 'description', 'tableName', 'idColumnName']
                cp.ctrl.set(k, '')
            cp.grid.setStore(new Memory(data: []))



        tableModel_Create: ->
            # summary:
            #       保存新增的表模型
            if not @_checkTableModel()
                return false
            data = @_getTableModelData()
            @wso.app.dataManager.post('/rest/creation/tableModels', data).then(
                (res)->
                    console.log res
                (err)->
                    console.error err
            )

        tableModel_Update: ->
            # summary:
            #       保存更新表模型
            if not @_checkTableModel()
                return false
            data = @_getTableModelData()
            @wso.app.dataManager.put('/rest/creation/tableModels', data).then(
                (res)->
                    console.log res
                (err)->
                    console.error err
            )

    #
    # bill model
    #

        _checkBillModel: ->
            @wso.cpBillModel.form.validate()

        _getBillModelData: ->
            # summary:
            #       获取表模型数据
            gridData = []
            cp = @wso.cpBillModel
            data = {
                key: cp.ctrl.get('key')
                description: cp.ctrl.get('description')
                header: cp.ctrl.get('header')
                detail: cp.ctrl.get('detail')
                principal: cp.ctrl.get 'principal'
                subordinate: cp.ctrl.get 'subordinate'
            }
            data

        billModel_Delete: ->
            cp = @wso.cpBillModel
            bill = cp.modelSelect.get 'value'
            if bill
                @wso.app.dataManager.delete('/rest/creation/billModels/' + bill)
            else
                console.log 'no value to delete'

        billModel_New: ->
            # summary:
            #       新增动作，清空界面数据
            cp = @wso.cpBillModel
            cp.modelSelect.set 'value', ''
            item = {'key': '', 'description': '', 'header': '', 'detail': '', 'principal': '', 'subordinate': ''}
            for k,v in item
                cp.ctrl.set k, v



        billModel_Create: ->
            # summary:
            #       保存新增的表模型
            if not @_checkBillModel()
                return false
            data = @_getBillModelData()
            @wso.app.dataManager.post('/rest/creation/billModels', data).then(
                (res)->
                    console.log res
                (err)->
                    console.error err
            )

        billModel_Update: ->
            # summary:
            #       保存更新表模型
            if not @_checkBillModel()
                return false
            data = @_getBillModelData()
            @wso.app.dataManager.put('/rest/creation/billModels', data).then(
                (res)->
                    console.log res
                (err)->
                    console.error err
            )

        _checkViewModel: ->
            @wso.cpViewModel.form.validate()
        __getGridData: (grid)->
            data = []
            if grid.rowCount() > 0
                for i in [0..grid.rowCount() - 1]
                    data.push grid.row(i).item()
            data

        _getViewModelData: ->
            # summary:
            #       获取表模型数据
            gridData = []
            cp = @wso.cpViewModel

            #
            # list
            cpList = cp.cpList
            list = {columns: cpList.ctrl.get 'columns'}
            list.actions = @__getGridData(cpList.actionsGrid) # 查询按钮
            list.fields = @__getGridData(cpList.fieldsGrid) # 查询字段
            list.grid = {name: cpList.gridPane.ctrl.get('name')} # 表格
            list.grid.actions = @__getGridData(cpList.gridPane.actionsGrid)
            list.grid.structure = @__getGridData(cpList.gridPane.structureGrid)

            #
            # bill
            cpBill = cp.cpBill
            bill = {columns: cpBill.ctrl.get 'columns'}
            bill.actions = @__getGridData(cpBill.actionsGrid) # 查询按钮
            bill.fields = @__getGridData(cpBill.fieldsGrid) # 查询字段
            bill.grid = {name: cpBill.gridPane.ctrl.get('name')} # 表格
            bill.grid.actions = @__getGridData(cpBill.gridPane.actionsGrid)
            bill.grid.structure = @__getGridData(cpBill.gridPane.structureGrid)

            #
            # detail
            cpDetail = cp.cpDetail
            detail = {columns: cpBill.ctrl.get 'columns'}
            detail.actions = @__getGridData(cpDetail.actionsGrid) # 查询按钮
            detail.fields = @__getGridData(cpDetail.fieldsGrid) # 查询字段

            data = {
                key: cp.ctrl.get('key')
                description: cp.ctrl.get('description')
                billKey: cp.ctrl.get('billKey')
                actionJs: cp.ctrl.get('actionJs')
                list: list
                bill: bill
                detail: detail
            }
            data
        viewModel_New: ->
            1
        viewModel_Create: ->
            # summary:
            #       保存新增的表模型
            if not @_checkViewModel()
                return false
            data = @_getViewModelData()
            @wso.app.dataManager.post('/rest/creation/viewModels', data).then(
                (res)->
                    console.log res
                (err)->
                    console.error err
            )
        viewModel_Update: ->
            # summary:
            #       保存新增的表模型
            if not @_checkViewModel()
                return false
            data = @_getViewModelData()
            @wso.app.dataManager.put('/rest/creation/viewModels', data).then(
                (res)->
                    console.log res
                (err)->
                    console.error err
            )
        viewModel_Delete: ->
            1

        navigatorSave: ->
            cp = @wso.cpNavigator
            data = cp.tree.model.store.query()
            @wso.app.dataManager.put('rest/creation/navigator', {data:data}).then(
                (res)->
                    console.log res
                (err)->
                    console.log err
            )

    }