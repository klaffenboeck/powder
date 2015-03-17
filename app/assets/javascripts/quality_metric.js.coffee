Math.roundFloat = (val, mantisse = 8) ->
  return Number((val).toFixed(mantisse))

class @QualityMetric
  constructor: (options={}) ->
    @expected = options.expected ? window.m.measured_points
    @observed = options.run.emulated_points
    @observed ? options.observed


class @Chi2 extends QualityMetric
  constructor: (options={}) ->
    super(options)
    @value = options.value ? Chi2.perform_comparison(@observed.points, @expected.points)
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
    bounded_value = @value
    bounded_value = max if @value > max
    val = Math.round(bounded_value)
    res = max - val
    return res / max

  @compare: (simulated, selection = null) =>

    index_array = []
    if selection.constructor == BaseSelection

      sum = 0
      for val, i in selection.new_base
        if val.constructor == Number
          selection.differences[i] = Math.abs(val - simulated[i])
          sum += Chi2.perform_single(val, simulated[i])
        if val.constructor == Array
          sim = simulated[i]
          if sim >= val[0] and sim <= val[1]
            selection.differences[i] = 0
            sum += 0
          else if sim <= val[0]
            selection.differences[i] = Math.abs(val[0] - simulated[i])
            sum += Chi2.perform_single(simulated[i], val[0])
          else if sim >= val[1]
            selection.differences[i] = Math.abs(val[1] - simulated[i])
            sum += Chi2.perform_single(simulated[i], val[1])
      res = (sum / selection.new_base.length)
      return res
    if selection.constructor == Selection
      sum = 0
      indices = selection.getIterationIndices()
      base = selection.base_selection.new_base
      for i in indices
        if base[i].constructor == Number
          sum += Chi2.perform_single(val, simulated[i])
        if base[i].constructor == Array
          sim = simulated[i]
          if sim >= val[0] and sim <= val[1]
            sum += 0
          else if sim <= val[0]
            sum += Chi2.perform_single(simulated[i], val[0])
          else if sim >= val[1]
            sum += Chi2.perform_single(simulated[i], val[1])
      res = (sum / base.length)
      return res





class @SelectionHolder
  constructor: (options={}) ->
    {@inclusions, @exclusions} = options



class @BaseSelection
  constructor: (options={}) ->
    {@exclusions, @measured, @angles} = options
    @setup()
    @differences = []

  setup: =>
    @new_base = @measured.slice()
    console.log(@new_base)
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

  addDiff: (diff) =>
    @differences.push()



  @factory: (exclusions, measured = window.m.measured_points.points, angles = window.m.data_angles.angles) ->
    new BaseSelection({exclusions: exclusions, measured: measured, angles: angles})

class @Selection
  constructor: (options={}) ->
    {@base_selection} = options
    @inclusion = options.inclusion ? null

  addInclusion: (inclusion) =>
    @inclusion = inclusion

  getIterationIndices: =>
    left = @inclusion[0]
    right = @inclusion[1]
    #step_width = @base_selection.step_width
    step_width = 0.002
    left = Math.roundFloat(Math.floor(left / step_width) * step_width, 4)
    right = Math.roundFloat(Math.ceil(right / step_width) * step_width, 4)
    console.log(left)
    console.log(right)
    #angles = @base_selection.angles
    angles = window.m.data_angles.angles
    leftPos = angles.indexOf(left)
    rightPos = angles.indexOf(right)
    arr = []
    for pos in [leftPos..rightPos]
      arr.push(pos)
    return arr


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


  addBlock: (block) =>
    @blocks.push(block)


class @Inclusion
  constructor: (options={}) ->
    {@exclusion, @selection} = options



