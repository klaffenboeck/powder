#= require line_chart

class @RunListManager
  constructor: (options = {}) ->
    #@run_lists = options.run_lists ? []
    @selection_manager = undefined
    @main_run_list = undefined
    @initial_run_list = undefined
    @display_run_list = undefined

  main: =>
    @main_run_list

  initial: =>
    @initial_run_list

  display: =>
    @display_run_list



class @BaseRunList
  constructor: (options={}) ->
    @runs = options.runs ? []
    @selection_manager = options.selection_manager
    @qm_type = Chi2
    @parameter_space = window.m.param_space

  @factory: (runs, manager = null) ->
    list = new @
    list.selection_manager = manager
    for run in runs
      list.runs.push(Run.fromObject(run, list))
    return list

  compareWithSelection: (selection) ->
    results = []
    for run in @runs
      simulated = run.simulated_data_points
      result = Chi2.compare(simulated, selection)
      results.push(result)
    # if selection.constructor == Selection
    return results


  getRuns: =>
    @runs

  getRun: (id) =>
    _.findWhere(@runs, {id: id})

  addRun: (obj) =>
    run = Run.fromObject(obj, @)
    @runs.push(run)
    run

  findRun: (input_params) =>
    params = _.map(input_params, (num) ->
      return Math.roundFloat(num, 6)
    )
    for run in @runs
      run_params = _.map(run.input_params, (num) ->
        return Math.roundFloat(num, 6)
      )
      return run if _.isEqual(params, run_params)
    return false






  getSelections: =>
    @selection_manager.getSelections()

  getSelection: (index) =>
    @selection_manager.getSelection(index)

  getQMType: =>
    @qm_type

  getPS: =>
    @parameter_space

  getQMs: (pos) =>
    arr = []
    for run in @runs
      arr.push(run.getQM(pos))
    return arr

  calculateAndSaveAllQMs: =>
    for run in @runs
      run.calculateAndSaveAllQMs()
    @runs

  getResults: =>
    arr = []
    for run in @runs
      arr.push(run.getResults())
    arr

  getNormalResults: =>
    arr = []
    for run in @runs
      arr.push(run.getNormalResults())
    arr

  newRunList: (array = []) =>
    ret = []
    for val in array
      ret.push(@runs[val])
    RunList.factory(ret, @selection_manager)

  createDisplayRunList: =>
    DisplayRunList.factory(@)



class @RunList extends BaseRunList
  constructor: (options={}) ->
    super(options)


class @InitialRunList extends BaseRunList
  constructor: (options={}) ->
    super(options)


class @DisplayRunList extends RunList
  constructor: (options={}) ->
    super(options)

  @factory: (run_list) =>
    drl = new DisplayRunList
      runs: _.toArray(run_list.getRuns())
      selection_manager = run_list.selection_manager
      qm_type = run_list.qm_type
      parameter_space = run_list.parameter_space
    return drl


  order: (qm_index = 0, direction = "desc") =>
    if qm_index >= 0
      qms = @getQMs(qm_index)
      ordered = _.sortBy(qms, (qm) ->
        qm.getNormalResult()
      )
      ordered.reverse() if direction == "desc"
      @runs = _.pluck(ordered, "run")
      true
      return @runs
    else
      @runs = _.sortBy(@runs, (run) ->
        return run.id  
      )
      if direction == "desc"
        @runs.reverse() 
      return @runs

  addRun: (run) =>
    unless _.contains(@runs, run)
      @runs.push(run)
    run

  resetRuns: (runs = []) =>
    @runs = runs





class @ParameterSpace
  constructor: (options={}) ->
    @parameter_space = options.parameter_space.content

  get: (key = "all") =>
    return @paramter_space if key == "all"
    return @parameter_space[key]

  @factory: (ps) =>
    space = new ParameterSpace({parameter_space: ps})
    return space

  mapInput: (input_params) =>
    counter = 0
    obj = new InputParams
    for key, value of @parameter_space
      obj[key] = input_params[counter]
      counter += 1
    return obj

  mapInputToObject: (input_params) =>
    keys = _.keys(@parameter_space)
    obj = _.object(keys, input_params)
    return obj

  getOptimumBoundaries: =>
    dims = _.size(@parameter_space)
    size = 0
    right = 10
    left = 35
    if dims <= 2
      size = 240
    else if dims <= 6
      size = 150
    else
      size = 100
      left = 20
      right = 20
    boundaries = new Boundaries
      width: size
      height: size
      margin:
        bottom: 25
        left: left
        right: right
        top: 30
    return boundaries

  renderSelectOptions: (excluded = -1) =>
    keys = _.allKeys(@parameter_space)
    html = new HH
    for key, i in keys
      unless excluded == i
        html.addOption(key, i)
    return html.print()

  renderOptionsY: (excluded = -1) =>
    $("#projection-y-select").html(@renderSelectOptions())

  renderOptionsX: (excluded = -1) =>
    $("#projection-x-select").html(@renderSelectOptions())

  setupSelectListener: =>
    $("#projection-x-select, #projection-y-select").change( (e) ->
      _y = parseInt($("#projection-y-select").val())
      _x = parseInt($("#projection-x-select").val())
      window.m.complex_view_holder.getMaxima(_x, _y)

    )




class @InputParams

  getValues: =>
    _.omit(_.values(@), "functions()")




class @Run
  constructor: (options={}) ->
    {@id, @input_params} = options
    @input_params = @input_params.params unless _.isArray(@input_params)
    @simulated_data_points = options.simulated_data_points ? options.emulated_points.points
    @original_quality_metric = options.quality_metrics[0]
    @quality_metrics = []
    @holder = undefined

  @fromObject: (run_object, holder = null) ->
    run = new Run(run_object)
    run.holder = holder
    run

  calculateQuality: (selection, type = @getQMType()) =>
    qm = type.factory(@, selection)

  calculateAllQualities: (type = @getQMType()) =>
    array = []
    for selection in @getSelections()
      array.push(@calculateQuality(selection, type))
    return array

  calculateAndSaveAllQMs: (type = @getQMType()) =>
    @quality_metrics = @calculateAllQualities(type)

  getSelections: =>
    @holder.getSelections()

  getQMType: =>
    @holder.getQMType()

  getRuns: =>
    return [@]

  getQM: (pos = null) =>
    # console.log(pos)
    return @quality_metrics[pos] unless pos == null
    return @quality_metrics

  getErrorData: (pos) =>
    @getQM(pos).getDifferences()

  getEstFunc: =>


  getInputParams: (mapped = false) =>
    return @getPS().mapInput(@input_params) if mapped == true
    @input_params 

  getPS: =>
    @holder.getPS()

  getPoints: =>
    @simulated_data_points

  getResults: =>
    arr = []
    for qm in @quality_metrics
      arr.push(qm.getResult())
    arr

  getNormalResults: =>
    arr = []
    for qm in @quality_metrics
      arr.push(qm.getNormalResult())
    arr








