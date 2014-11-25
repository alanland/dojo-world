define [
  'dojo/_base/lang'
  'lib/LodopFuncs'
], (lang, LodopFnucs)->
  getLodopPrint: (config)->
    config = lang.mixin({
      "taskName": "default_print_task",
      "preview": 0,
      "copies": 1,
      "reselect": false,
      "pageCount": 1,
      "children": [
      ]
    }, config)
    LODOP = getLodop();
    LODOP.PRINT_INIT(config.taskName)
    # preview todo
    # 设置打印份数 TODO
    #  LODOP.LODOPSET_PRINT_COPIES(config.copies)

    # 设置打印模式
    if config.printMode
      modes = config.printMode
      for key,value of modes
        LODOP.SET_PRINT_MODE key, value

    # 设置纸张大小
    if config.pageSize
      page = lang.mixin config.pageSize, {
        "orient": 0,
        "width": 0,
        "height": 0,
        "name": ""
      }
      LODOP.SET_PRINT_PAGESIZE(page[0], page[1], page[2], page[3])

    # 风格
    if config.style
      for key,value of config.style
        LODOP.SET_PRINT_STYLE(key, value)

    # 填充页面
    for child,index in config.children
      # 如果设置多页发送，那么进行适当分页 TODO 是否需要设置 TEXT NAME
      if index < 0 and index % config.pageCount == 0
        LODOP.NewPage()
      type = child.type
      ags = child.args
      if type == 'text'
        if child.style
          for key,value of child.style
            LODOP.SET_PRINT_STYLE(key, value)
        LODOP.ADD_PRINT_TEXT ags[0], ags[1], ags[2], ags[3], ags[4]
      else if type == 'html'
        content = child.content
        if child.style
          content = "${child.style}<body>${content}</body>"
        LODOP.ADD_PRINT_HTM ags[0], ags[1], ags[2], ags[3], ags[4]
      else if type == 'shape'
        LODOP.ADD_PRINT_SHAPE ags[0], ags[1], ags[2], ags[3], ags[4], ags[5], ags[6], ags[7]
      else if type == 'rect'
        LODOP.ADD_PRINT_RECT ags[0], ags[1], ags[2], ags[3], ags[4], ags[5]
      else if type == 'barcode'
        LODOP.ADD_PRINT_BARCODE ags[0], ags[1], ags[2], ags[3], ags[4], ags[5]
    # end if
    LODOP
