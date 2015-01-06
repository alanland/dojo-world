define [
    'dojo/_base/declare'
    'ttx/command/actions/BaseActionSet'
], (declare, BaseActionSet)->
    declare [BaseActionSet], {
        syncToFile: ->
            @app.dataManager.post('rest/modelSync/databaseToFile')
        syncToDb: ->
            @app.dataManager.post('rest/modelSync/fileToDatabase')
    }