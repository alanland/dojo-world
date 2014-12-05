req1 = request('js/test/storeData.json', {handleAs: 'json'})
req2 = request('js/test/structure.json', {handleAs: 'json'})
new DeferredList([req1, req2]).then(
    (result)->
        storeData = result[0]
        structure = result[1]
        console.log result
    (err)->
        console.log err
)