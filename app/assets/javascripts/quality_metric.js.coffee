Math.roundFloat = (val, mantisse = 8) ->
  return Number((val).toFixed(mantisse))


class @QualityMetric
  constructor: (options={}) ->
    @expected = options.expected ? window.m.measured_points
    @observed = options.run.emulated_points
    @observed ? options.observed
    @run = options.run
    @selection = options.selection
    @result = undefined


class @Chi2 extends QualityMetric
  constructor: (options={}) ->
    super(options)
    #@value = options.value ? Chi2.perform_comparison(@observed.points, @expected.points)
    @differences = []

  @perform_comparison: (observed, expected = window.m.measured_points.points) =>
    sum = 0
    for val, i in observed
      sum += Chi2.perform_single(val, expected[i])
    res = (sum / observed.length)
    return res


  #observed = simulated
  #expected = measured
  @perform_single: (observed, expected) =>
    v = observed - expected
    v2 = v*v
    res = v2 / expected
    return res

  normal: (max = 10000) =>
    return @result if @result < 1
    bounded_value = @result
    bounded_value = max if @result > max
    val = Math.round(bounded_value)
    res = max - val
    return res / (max - 1)


  @compare: (simulated, selection = null, qm = null) =>

    index_array = []
    if selection.constructor == BaseSelection
      sum = 0
      for val, i in selection.new_base
        if val.constructor == Number
          qm.differences[i] = Math.abs(val - simulated[i]) unless qm == null
          single = Chi2.perform_single(simulated[i], val)
          sum += single
        if val.constructor == Array
          sim = simulated[i]
          if sim >= val[0] and sim <= val[1]
            qm.differences[i] = 0 unless qm == null
            sum += 0
          else if sim <= val[0]
            qm.differences[i] = Math.abs(val[0] - simulated[i]) unless qm == null
            sum += Chi2.perform_single(simulated[i], val[0])
          else if sim >= val[1]
            qm.differences[i] = Math.abs(val[1] - simulated[i]) unless qm == null
            sum += Chi2.perform_single(simulated[i], val[1])
      res = (sum / selection.new_base.length)
      return res

    if selection.constructor == Selection
      sum = 0
      indices = selection.getIterationIndices()
      base = selection.base_selection.new_base
      for i in indices
        if base[i].constructor == Number
          sum += Chi2.perform_single(simulated[i], base[i])
        if base[i].constructor == Array
          val = base[i]
          sim = simulated[i]
          if sim >= val[0] and sim <= val[1]
            sum += 0
          else if sim <= val[0]
            sum += Chi2.perform_single(simulated[i], val[0])
          else if sim >= val[1]
            sum += Chi2.perform_single(simulated[i], val[1])
      res = (sum / indices.length)
      return res

  compare: =>
    res = Chi2.compare(@getPoints(), @getSelection(), @)
    @result = res

  getPoints: =>
    return @run.getPoints()

  getSelection: =>
    return @selection

  getResult: (string = "real") =>
    # if string == "adapted"
    #   length = @getSelection().getLength()
    #   base = 
    @result

  getNormalResult: =>
    @normal()

  getDifferences: =>
    @differences

  @factory: (run, selection) =>
    chi2 = new Chi2({run: run, selection: selection})
    chi2.compare()
    return chi2

