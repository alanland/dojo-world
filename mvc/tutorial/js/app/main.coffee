define [
    'dojo/_base/array'
    'dojo/on'
    'dojo/json'
    'dojo/dom'
    'dojo/dom-construct'
    'dojo/query'
    'dojo/Deferred'
    'app/mocks/services/JsonRest'
    'dojo/store/Memory'
    'dojo/store/Cache'
    'dojo/store/Observable'
], (array, onn, json, dom, domCons, query, Deferred, JsonRest, Memory, Cache, Observable)->
    currentProduct = null
    masterStore = new JsonRest(
        target: '/Inventory/'
    )

    masterStore = new Observable masterStore

    cacheStore = new Memory()
    inventoryStore = new Cache masterStore, cacheStore

    inventoryStore = new Observable(Memory({
        data: [
            {id: 1, name: "one", prime: false },
            {id: 2, name: "two", even: true, prime: true},
            {id: 3, name: "three", prime: true},
            {id: 4, name: "four", even: true, prime: false},
            {id: 5, name: "five", prime: true}
        ]
    }))

    # pass results to view
    viewResults = (results)->
        container = dom.byId('container')
        rows = []

        insertRow = (item, i)->
            row = domCons.create 'div',
                innerHTML: "#{i}: #{json.stringify item}"
            rows.splice i, 0, container.insertBefore(row, rows[i] || null)

        removeRow = (i)->
            domCons.destroy rows.splice(i, 1)[0]

        results.forEach insertRow

        results.observe (item, removeIndex, insertedIndex)->
            removeRow removeIndex if removeIndex > -1
            insertRow insertedIndex if insertedIndex > -1
        , true

    viewInForm = (object, form)->
        updateInput = (name, oldValue, newValue)->
            input = query("input[name=#{name}]", form)[0]
            input.value = newValue if input

        for i of object
            updateInput i, null, object.get(i)
        object.watch updateInput

    # 放入数据的时候进行校验
    oldPut = inventoryStore.put
    inventoryStore.put = (object, options)->
        throw new Error 'xxxx' if object.prime
        oldPut.call this, object, options

    nextId = 10
    onn dom.byId('add'), 'click', ->
        masterStore.put(
            name: '11'
            even: true
            id: nextId++
        ).then ->
            masterStore.query({even: true}).then (res)->
                viewResults(res)

    onn dom.byId('put-negative'), 'click', ->
        try
            inventoryStore.put
                name: 'doeu'
                prime: true
        catch e
            alert e
    onn dom.byId('sell'), 'click', ->
        currentProduct && currentProduct.set("quantity", currentProduct.quantity - 1);
        save();
    save = ->
        return if !currentProduct
        for i of currentProduct
            if(i != "id" && typeof currentProduct[i] != "function" && currentProduct.hasOwnProperty(i))
                console.log(i);
                currentProduct[i] = query("#form input[name=" + i + "]")[0].value;
        try
            inventoryStore.put(currentProduct);
        catch e
            alert(e);


    onn(dom.byId("save"), "click", save);

    onn dom.byId("container"), ".item:click", (evt)->
        Deferred.when(inventoryStore.get(this.itemIdentity), (item)->
            viewInForm(currentProduct = new Stateful(item), dom.byId("form"));
        )

    startup: (args)->
        console.log 'startup'
        masterStore.query(prime: true).then (res)->
            console.log res
            viewResults(res)

