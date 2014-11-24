define ->
  oid = 1
  type = {
    root: 0,
    folder: 1,
    demographics: 2
  }
  [
    {id: 'root', name: 'root', type: type.root, tid: 0, oid: oid++},
    {id: 'Def', name: '定义测试', type: type.folder, tid: 0, oid: oid++, parent: 'root'},
    {id: oid++, name: 'Login', type: type.demographics, tid: 'obe/test/data/wsoDefinitions/Login', oid: oid++, parent: 'Def'},
    {id: oid++, name: 'Users', type: type.demographics, tid: 'obe/test/data/wsoDefinitions/GridUser', oid: oid++, parent: 'Def'},
    {id: oid++, name: 'Report', type: type.demographics, tid: 'obe/test/data/wsoDefinitions/Report', oid: oid++, parent: 'Def'},
    {id: oid++, name: '工具栏', type: type.demographics, tid: 'obe/test/data/wsoDefinitions/Toolbar', oid: oid++, parent: 'Def'},
    {id: oid++, name: 'Json', type: type.demographics, tid: 'obe/test/data/wsoDefinitions/json/Login.json', oid: oid++, parent: 'Def'},
    {id: oid++, name: 'Lookup', type: type.demographics, tid: 'obe/test/data/wsoDefinitions/Lookup', oid: oid++, parent: 'root'},
    {id: 'Investigators', name: '3 Investigators', type: type.folder, tid: 3, oid: oid++, parent: 'root'},
    {id: 'Braker', name: '4 Braker', type: type.folder, tid: 4, oid: oid++, parent: 'root'},
    {id: 'Harris', name: 'Harris', type: type.folder, oid: oid++, parent: 'root'},
    {id: 'Audits', name: 'Audits', type: type.folder, oid: oid++, parent: 'root'},
    {id: 'Communications', name: 'Communications', type: type.demographics, oid: oid++, parent: 'Audits'},
    {id: 'xx', name: '1', type: type.folder, oid: oid++, parent: 'root'},
    {id: 'xxxx', name: '1', type: type.folder, oid: oid++, parent: 'root'},
  ]