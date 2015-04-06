#= require quality_metric

class @SelectionManager
  
  constructor: (options={}) ->
    {@inclusions, @exclusions} = options
    @selections = []
    @functions = []
    @temporary = null
    @projection_slide = 0
    @_current = null
    @_current_run = null
    @_temp_run = null
    @_temp_func = null
    @full_run_list = null
    @display_run_list = null
    @initial_run_list = null
    @navigation = null
    @setupSMD()
    @_loaded = []
    @_current_order = "desc"
    @_order_by = "id"
    @_current_clusters = []
    @_remaining_params = []
    @_qm_index = -1

  setupSMD: =>
    @current_smd = new SMD({select: "#current"})
    @smd = new SMD({select: "#runlist"})

  @factory: (func, measured, angles) =>
    sm = new SelectionManager()
    sm.createNewBaseSelection(func, measured, angles)
    return sm

  addSelection: (selection) =>
    @selections.push(selection)
    @setCurrentSelection(selection)

  getCurrentSelection: (no_index = true) =>
    return @_current if no_index
    _.indexOf(@selections, @_current)

  setCurrentSelection: (selection) =>
    @_current = selection

  getCurrentBase: =>
    @_current.getBase()

  getCurrentFunction: =>
    @getCurrentSelection().getFunction()

  getEstimationFunction: (id) =>
    @getSelection(id).getFunction()

  setTempEstimationFunction: (id) =>
    @_temp_func = @getEstimationFunction(id)
    #@navigation.setEstimationFunction(func)

  resetTempEstimationFunction: =>
    @_temp_func = @getCurrentFunction()
    #@navigation.setEstimationFunction(func)
    #@navigation.show_preview_lines()

  setTempRun: (run_index) =>
    # console.log("setTempRun" + run_index)
    @_temp_run = @display_run_list.runs[run_index]
    # console.log(@getTempRun())
    @_temp_run

  resetTempRun: =>
    # console.log("resetTempRun")
    @_temp_run = null

  getTempRun: =>
    @_temp_run

  getTempEstimationFunction: =>
    return @_temp_func if @_temp_func
    @getCurrentFunction()


  showTempEstimation: =>
    run = @getTempRun()
    if run 
      params = run.getInputParams()
      @navigation.setEstimationFunction(@getTempEstimationFunction())
      @navigation.show_preview_lines()
      @navigation.estimate_preview(run.getInputParams())


  hideTempEstimation: =>
    # console.log("hideTempEstimation")
    @resetTempRun()
    @resetTempEstimationFunction()
    @navigation.hide_preview_lines()


  setFunction: (func) =>
    @getCurrentSelection().setFunction(func)


  getCurrentRun: =>
    @_current_run

  setCurrentRun: (run) =>
    @_current_run = run

  setProjectionSlide: (id) =>
    @projection_slide = id

  getProjectionSlide: =>
    @projection_slide

  updateProjectionSlide: (_index) =>
    @setProjectionSlide(_index)
    window.m.complex_view_holder.getSlide(_index)

  restoreProjectionSlide: =>
    window.m.complex_view_holder.getSlide(@getProjectionSlide())



  createNewBaseSelection: (func = null, measured = null, angles = null) =>
    if func and measured and angles
      base = BaseSelection.factory(new Exclusions(), measured, angles)
      base.setFunction(func)
      @addSelection(base)
      @setCurrentSelection(base)
      return true
    else
      base = @getCurrentBase().extractNewBaseSelection()
      @addSelection(base)
      @setCurrentSelection(base)


  addBlock: (block) =>
    @getCurrentBase().addBlock(block)


  createNewSelection: (inclusion) =>
    sel = Selection.factory(inclusion, @getCurrentBase())
    @addSelection(sel)
    @setCurrentSelection(sel)



  getSelections: =>
    return @selections

  getSelection: (index) =>
    return @selections[index]

  renderDisplayRunList: (qm_index = undefined, order = undefined) =>
    @_qm_index = qm_index unless _.isUndefined(qm_index)
    @_current_order = order unless _.isUndefined(order)
    @display_run_list = @full_run_list.createDisplayRunList() if @display_run_list == null
    @display_run_list.calculateAndSaveAllQMs()
    #qm_index = _.indexOf(@getOrderItems(), qm_index) unless _.isNumber(qm_index)
    @display_run_list.order(@_qm_index, @_current_order)
    @smd.render(@display_run_list)
    @renderOrderBar()
    @renderCurrentRun()

  updateDisplayRunList: (run) =>
    #@setCurrentRun(run)
    @loadRun(run.id)
    @renderDisplayRunList()

  updateColorsInRunList: =>

    @renderDisplayRunList(@getOrderBy(), @getOrderDirection())


  getRun: (id) =>
    @full_run_list.getRun(id)

  getDisplayRun: (index) =>
    @display_run_list.runs[index]

  renderCurrentRun: (current = undefined) =>
    unless current == undefined
      current = @full_run_list.getRun(current) if current.constructor == Number
      @setCurrentRun(current)
    unless @getCurrentRun() == null
      @stopSpinner()
      @getCurrentRun().calculateAndSaveAllQMs()
      @current_smd.render(@getCurrentRun()) 
    

  loadRun: (id) =>
    run = @getRun(id)
    if run
      @startSpinner()
      @setCurrentRun(run)
      window.m.updateLineChart(run)
      @setSimLabel(id)
      @navigation.set_current_x_values(run.getInputParams())
      @navigation.estimate_all_lines()
      @renderCurrentRun(id)


  startSpinner: =>
    $("#current-progress-switch").html(HH.pulseSpin())

  stopSpinner: =>
    $("#current-progress-switch").html("current")

  compareRun: (id) =>
    run = @getRun(id)
    if run and @getCurrentRun()
      @setCompLabel(id)
      window.m.compareLineChart(run)

  resetComparedRun: =>
    window.m.compareLineChart()
    @resetCompLabel()


  getLoaded: =>
    @_loaded

  setLoaded: (loaded) =>
    @_loaded = loaded


  getErrorData: (run_id, qm_index) =>
    @getRun(run_id).getErrorData(qm_index)

  getDisplayErrorData: (run_index, qm_index) =>
    console.log("qm_index")
    console.log(qm_index)
    @getDisplayRun(run_index).getErrorData(qm_index)

  drawErrors: (run_indices, qm_index) =>
    window.m.errorchart.removeAllLines()
    for index in run_indices
      err = @getDisplayErrorData(index, qm_index)
      window.m.errorchart.createLine("line" + index, err)
    window.m.errorchart.drawLines()

  updateLoaded: (qm_index = 0) =>
    arr = []
    $(".run-loaded input:checked").each( ->
      arr.push($(@).val())
    )
    @setLoaded(arr)
    # console.log(@getLoaded(arr))
    @drawErrors(arr, qm_index)

  loadQOI: (qoi) =>
    index = @getCurrentSelection(false)
    qms = @full_run_list.getQMs(0)
    filtered = _.filter(qms, (qm) ->
      return qm.getNormalResult() > qoi[0] and qm.getNormalResult() <= qoi[1]
    )



  getOrderItems: =>
    arr = ["id"]
    base_counter = -1
    sel_counter = 1
    for sel, i in @getSelections()
      if sel.constructor == BaseSelection
        base_counter += 1
        arr.push("b" + base_counter)
        sel_counter = 1
      else 
        arr.push("s" + base_counter + sel_counter)
        sel_counter += 1
    return arr



  renderOrderBar: =>
    @unbindSegments()
    html = new HH
    klass = "segment"
    for item, i in @getOrderItems()
      id = "segment-" + item
      klass = "segment"
      data = HH.data("segment", item) + " " + HH.data("qm-index", i - 1) 
      content = item
      if item == @getOrderBy()
        dir = @getOrderDirection()
        klass += " current " + dir
        data += " " + HH.data("order-direction", dir)
        content += '<i class="fa fa-sort-' + dir + '"></i>'

      html.addDiv
        id: id
        class: klass
        data: data
        content: content
    $("#order-bar").html(html.print())
    @bindSegments()


  bindSegments: =>
    that = @
    $(".segment").click( ->
      that.toggleOrderDirection() if $(@).data("order-direction")
      that.setOrderBy($(@).data("segment"))
      qm_index = $(@).data("qm-index")
      that.renderDisplayRunList(qm_index, that.getOrderDirection())
      #that.renderOrderBar()
    )

  toggleOrderDirection: =>
    if @getOrderDirection() == "desc"
      @setOrderDirection("asc")
    else
      @setOrderDirection("desc")

  unbindSegments: =>
    $(".segment").unbind()

  getOrderBy: =>
    @_order_by

  setOrderBy: (order) =>
    @_order_by = order

  getOrderDirection: =>
    @_current_order

  setOrderDirection: (dir) =>
    @_current_order = dir


  setSimLabel: (val) =>
    $(".legend-entry.simulated text").html("sim-" + val)

  resetSimLabel: =>
    $(".legend-entry.simulated text").html("simulated")

  setCompLabel: (val) =>
    $(".legend-entry.compared text").html("sim-" + val)

  resetCompLabel: =>
    $(".legend-entry.compared text").html("compared")



  resetClusters: =>
    @_current_cluster = []

  addCluster: (cluster) =>
    @_current_cluster.push(cluster)

  getCluster: (pos) =>
    @_current_cluster[pos]

  setupClusterListener: =>
    that = @
    $(".cluster.region").click( (e) ->
      that.loadAndRunCluster($(@).data("load-cluster"))
    )

  loadAndRunCluster: (pos) =>
    tiles = @getCluster(pos).getTiles()
    params = _.map(tiles, (p) -> 
      return p.getSampleAtNormalPosition()
    )
    @batchRun(params)


  batchRun: (input_params = []) =>
    @startSpinner()
    runs = []
    @_remaining_params = []
    for params in input_params
      run = @full_run_list.findRun(params)
      if run
        runs.push(run)
      else
        @_remaining_params.push(params)
    console.log("REMAINING PARAMS")
    console.log(@_remaining_params)
    @display_run_list.runs = runs
    unless _.isEmpty(runs)
      @renderDisplayRunList()
      $(".run-loaded input:checkbox").prop("checked", true)
      @updateLoaded()
    first_run = @_remaining_params.splice(0,1)[0]
    @remotepostRun(first_run)


  remotepostRun: (input_params = []) =>
    unless _.isEmpty(input_params)
      console.log("CURRENT INPUT PARAMS")
      console.log(input_params)
      @startSpinner()
      input_params = window.m.param_space.mapInputToObject(input_params) if input_params.constructor == Array
      $.ajax(
        url: document.URL + "/remotepost"
        cache: false
        type: "POST"
        data:
          parameters: input_params
      ).done (json) =>
        run = @full_run_list.addRun(json.run)
        @display_run_list.addRun(run)
        @updateDisplayRunList(run)
        window.manager.updateLineChart(run)
        $(".run-loaded input:checkbox").prop("checked", true)
        @updateLoaded()
        next_run = @_remaining_params.splice(0,1)[0]
        @remotepostRun(next_run)


  # changeDomain: (bounds) =>
  #   @smd.changeDomain(bounds)
  #   @current_smd.changeDomain(bounds)






@SelectionHolder = SelectionManager


class @VirtualBasicSelection

  basicSetup: =>
    @estimation_function = undefined

  setFunction: (func) =>
    @estimation_function = func

  getFunction: =>
    return @estimation_function


class @BaseSelection extends VirtualBasicSelection
  constructor: (options={}) ->
    {@exclusions, @measured, @angles} = options
    @basicSetup()
    @setup()
    @differences = []
    @blocks = @exclusions.getBlocks()
    @_next_exclusions = new Exclusions

  setup: =>
    @new_base = @measured.slice()

    @step_width = Math.roundFloat(@angles[1] - @angles[0], 4)
    return if @exclusions == null
    exclusions = @exclusions.getExclusions()
    excX = exclusions.rangesX
    excY = exclusions.rangesY
    for eX, i in excX
      left = eX[0]
      right= eX[1]
      left = Math.roundFloat(Math.floor(left / @step_width) * @step_width, 4)
      right = Math.roundFloat(Math.ceil(right / @step_width) * @step_width, 4)
      leftPos = @angles.indexOf(left)
      rightPos = @angles.indexOf(right)
      bottom = excY[i][0]
      top = excY[i][1]
      for pos in [leftPos..rightPos]
        num = @new_base[pos]
        if num.constructor == Number
          @new_base[pos] = [bottom, top] if(num >= bottom and num <= top)
        if num.constructor == Array
          @new_base[pos][0] = bottom if bottom < @new_base[pos][0]
          @new_base[pos][1] = top if top > @new_base[pos][1] 

  @factory: (exclusions, measured = window.manager.measured_points.points, angles = window.manager.data_angles.angles) ->
    new BaseSelection({exclusions: exclusions, measured: measured, angles: angles})

  addDiff: (diff) =>
    @differences.push()

  getBase: =>
    return @

  addBlock: (block) =>
    @_next_exclusions.addBlock(block)

  extractNewBaseSelection: =>
    @_next_exclusions.addBlocks(@exclusions.getBlocks())
    new_base = BaseSelection.factory(@_next_exclusions)
    #console.log(new_base)
    @_next_exclusions = new Exclusions()
    return new_base



class @Selection extends VirtualBasicSelection
  constructor: (options={}) ->
    {@base_selection} = options
    @basicSetup()
    @inclusion = options.inclusion ? null
    @_iteration_indices = []
    @_length = undefined

  @factory: (inclusion, base_selection) =>
    new Selection({base_selection: base_selection, inclusion: inclusion})

  addInclusion: (inclusion) =>
    @inclusion = inclusion

  getIterationIndices: =>
    if @_iteration_indices.length == 0
      left = @inclusion[0]
      right = @inclusion[1]
      #step_width = @base_selection.step_width
      step_width = 0.002
      left = Math.roundFloat(Math.floor(left / step_width) * step_width, 4)
      right = Math.roundFloat(Math.ceil(right / step_width) * step_width, 4)
      #console.log(left)
      #console.log(right)
      #angles = @base_selection.angles
      angles = window.m.data_angles.angles
      leftPos = angles.indexOf(left)
      rightPos = angles.indexOf(right)
      arr = []
      for pos in [leftPos..rightPos]
        arr.push(pos)
      @_iteration_indices = arr
      @_length = arr.length
    return @_iteration_indices

  getLength: =>
    @_length ? @getIterationIndices.length

  getBase: =>
    return @base_selection


class @TempSelection


class @ExclusionsList
  _current = null
  constructor: (options={}) ->
    @list = []
    exclusions = new Exclusions()
    @addExclusions(exclusions)

  addExclusions: (exclusions) =>
    @list.push(exclusions)
    @setCurrent(exclusions)

  getCurrent: =>
    return _current

  setCurrent: (exclusions) =>
    _current = exclusions

  addBlockToCurrent: (block) =>
    @getCurrent().addBlock(block)



class @Exclusions
  constructor: (options={}) ->
    @blocks = options.blocks ? []

  getExclusions: =>
    rangesX = []
    rangesY = []
    for block in @blocks
      x = block.getRangeX()
      y = block.getRangeY()
      rangesX.push(x)
      rangesY.push(y)
    obj = {rangesX: rangesX, rangesY: rangesY}
    return obj

  getBlocks: =>
    @blocks


  addBlock: (block) =>
    @blocks.push(block)

  addBlocks: (blocks) =>
    # console.log(blocks)
    @blocks = _.union(@blocks, blocks)


class @Inclusion
  constructor: (options={}) ->
    {@exclusion, @selection} = options



