define ->
    oid = 0
    type = {
        root: 0,
        folder: 1,
        demographics: 2
    }
    [
        {id: 'root', name: 'root', type: type.root, tid: 'obe/test/data/wsoDefinitions/Login', oid: oid++},
        {id: '1', name: 'Login', type: type.demographics, tid: 'obe/test/data/wsoDefinitions/Login', oid: oid++, parent: 'root'},
        {id: 'VCI-82-2002-GCR', name: '2 VCI', type: type.folder, tid: 2, oid: oid++, parent: 'root'},
        {id: 'Investigators', name: '3 Investigators', type: type.folder, tid: 3, oid: oid++, parent: 'root'},
        {id: 'Braker', name: '4 Braker', type: type.folder, tid: 4, oid: oid++, parent: 'root'},
        {id: 'Harris', name: 'Harris', type: type.folder, oid: oid++, parent: 'root'},
        {id: 'Audits', name: 'Audits', type: type.folder, oid: oid++, parent: 'root'},
        {id: 'Communications', name: 'Communications', type: type.demographics, oid: oid++, parent: 'Audits'},
        {id: 'xx', name: '1', type: type.folder, oid: oid++, parent: 'root'},
        {id: 'xxxx', name: '1', type: type.folder, oid: oid++, parent: 'root'},
    ]