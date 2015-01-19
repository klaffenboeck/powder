class @Sampling
  constructor: (options = {}) ->
    {@amount, @dims, @parameter_space} = options 
    @array = []
    @normal_samples = []
    @samples = []
    @results = []
    @binlist1d = {}
    @binlist2d = {}

  map: (ps = null) =>
    @parameter_space = ps if ps
    parameter_space = ps ? @parameter_space
    _return_array = []
    _start_points = []
    _ranges = []
    for name, space of parameter_space.content
      _start_points.push(space[0])
      _ranges.push(space[1] - space[0])
    for normal_sample in @normal_samples
      inner_array = []
      for normal_value, index in normal_sample
        mapped_value = _ranges[index] * normal_value + _start_points[index]
        inner_array.push(mapped_value)
      _return_array.push(inner_array)
    @samples = _return_array
    return _return_array

  computeResults: (estfunc) =>
    for sample in @samples
      @results.push(estfunc.estimate_normal(sample))
    return @results

  binify2d: (options={}) =>
    return "no results to compute" if !@results.length
    _x = options.x
    _y = options.y
    bins = new Bins2d()
    for result, i in @results
      pos = @normal_samples[i]
      bins.insert(result, pos[_x], pos[_y])
    _id = _x.toString() + _y.toString()
    @binlist2d[_id] = bins

  getMinima: (x, y = null) =>
    list = @binlist2d[id].bins
    minima = []
    for values in list
      minima.push(Math.min.apply(null, values))
    return minima

  getMaxima: (x, y = null) =>
    maxima = []
    for values in @binlist2d[id].bins
      maxima.push(Math.max.apply(null, values))
    return maxima

  getBins: (x, y = null) =>
    id = @getIdString(x,y)
    return @binlist2d[id] if @binlist2d[id]
    @binify2d({x: x, y: y})

  getIdString: (x, y = null) =>
    id = x.toString()
    id += y if y
    id


class @LHS extends Sampling
  constructor: (options = {}) ->
    super(options)

  @sample: (amount, dims, parameter_space = null) ->
    lhs = new LHS({amount: amount, dims: dims})
    _outer_array = []
    _binsize = 1 / amount
    for dim in [1..dims]
      _array = []
      for number in [1..amount]
        position = number * _binsize - _binsize
        value = _binsize * Math.random()
        _array.push(position + value)
      _outer_array.push(_array)
    # lhs.array = _outer_array.slice(0)
    lhs.array = JSON.parse(JSON.stringify(_outer_array))
    _samplearray = _outer_array
    for sample in [1..amount]
      sample = []
      for arr in _samplearray
        pos = Math.floor(Math.random() * arr.length)
        sample.push(arr.splice(pos,1)[0])
      lhs.normal_samples.push(sample)
    lhs.map(parameter_space) if parameter_space
    return lhs


class @Bins
  constructor: (options={})->
    @number = options.number ? 20
    @size = @number
    @bins = []

class @Bins1d extends Bins
  for bin in [1..@size]
    @bins[i-1] = []

class @Bins2d extends Bins
  constructor: (options={}) ->
    super(options)
    @size = Math.pow(@number,2)
    for bin in [1..@size]
      @bins[bin-1] = []

  insert: (value, x, y) =>
    @bins[@position(x,y)].push(value)

  position: (x, y) =>
    @positionX(x) + @positionY(y)

  positionX: (normal) =>
    Math.floor(normal * @number)

  positionY: (normal) =>
    Math.floor(normal * @number) * @number


class @ASync
  @interval = undefined

  start: =>
    @busy = true
    @interval = setInterval =>
      console.log("I am busy")
    , 500
    true


  stop: =>
    @busy = false
    clearInterval(@interval)
    console.log("Bye bye")
