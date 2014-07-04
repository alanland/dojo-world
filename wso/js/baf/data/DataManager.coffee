define [
  'dojo/_base/declare',
  'dojo/Deferred'
  'baf/test/mocks/services/Base'
], (declare, Deferred, Base)->
  declare 'TestData', Base,
    handler: (deferred, args)->
      # args.tid
      # args.oid
      if args.tid == 'obe/test/data/wsoDefinitions/Login'
        deferred.resolve {username: 'wang', password: 'chengyi'}
      else
        deferred.resolve {}

  declare null,
    service: null
    constructor: (args)->
      if args.dataService
        @service = args.dataService # todo
      else
        @service = new TestData({}) # todo

    get: (type, oid)->
      # 返回一个Deferred
      @service.call tid: type, oid: oid