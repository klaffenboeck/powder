class @Sampling
  constructor: (options = {}) ->
    {@amount, @dims, @parameter_space} = options 
    @array = []
    @normal_samples = []
    @samples = []
    @results = []
    @binlist1d = {}
    @binlist2d = {}
    @number_of_bins = options.number_of_bins ? 20

  map: (ps = null, ns = null) =>
    @parameter_space = ps if ps
    console.log("ParameterSpace: ")
    console.log(@parameter_space)
    normal_samples = ns ? @normal_samples
    parameter_space = ps ? @parameter_space
    _return_array = []
    _start_points = []
    _ranges = []
    for name, space of parameter_space.content
      _start_points.push(space[0])
      _ranges.push(space[1] - space[0])
    for normal_sample in normal_samples
      inner_array = []
      for normal_value, index in normal_sample
        mapped_value = _ranges[index] * normal_value + _start_points[index]
        inner_array.push(mapped_value)
      _return_array.push(inner_array)
    @samples = _return_array if ps
    return _return_array


  computeResults: (options = {}) =>
    @estfunc = options.estfunc if options.estfunc
    samples = options.samples ? @samples
    results = if options.samples then [] else @results
    for sample in samples
      results.push(@estfunc.estimate_normal(sample))
    return results

  binify2d: (options={}) =>
    return "no results to compute" if !@results.length
    _x = options.x
    _y = options.y

    bins = new BinSet({number: @number_of_bins})
    for result, i in @results
      pos = @normal_samples[i]
      # bins["results"].insert(result, pos[_x], pos[_y])
      # bins["samples"].insert(@samples[i], pos[_x], pos[_y])
      # bins["normal_samples"].insert(@normal_samples[i], pos[_x], pos[_y])
      bins.insert({result: result, sample: @samples[i], normal_sample: @normal_samples[i], x: pos[_x], y: pos[_y]})
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

  @_hyper_sample_arrays: (amount, dims, obj) =>
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
    obj.array = JSON.parse(JSON.stringify(_outer_array))
    return _outer_array

  @_init_counter_array: (dims, init_value = 0) =>
    _arr = []
    for dim in [0..dims-1]
      _arr[dim] = init_value
    _arr


  @_increase_counter_array: (spd, ca) =>
    for val,i in ca
      ca[i] = ++val
      if val % spd == 0
        ca[i] = 0
      else
        break
    ca

  @_decrease_counter_array: (spd = null, ca = null) =>
    _arr = @_flip_array_values(ca, spd - 1)
    # console.log(_arr)
    _arr = @_increase_counter_array(spd, _arr)
    # console.log(_arr)
    _arr = @_flip_array_values(_arr, spd - 1)
    _arr

  @_flip_array_values: (array, max_val) =>
    return_array = []
    for value in array
      return_array.push(max_val - value)
    return_array

  @_equal_divide: (value, divider) =>
    val = value / divider
    retarray = []
    temp = 0
    for pos in [0..(divider - 1)]
      retarray.push(Math.round(val * pos))
    retarray.push(value)
    retarray

  @_splice_array: (array, divider) =>
    ret_array = []
    length = array.length / divider
    currlength = undefined
    previous = 0
    for num in [1..divider]
      offset = Math.round(length * num)
      currlength = offset - previous
      ret_array.push(array.splice(0,currlength))
      previous = offset
    ret_array

  @_calc_opt_sample: (amount, dims) =>
    subspaces = Math.floor(Math.pow(amount, 1/dims))
    sample_amount = Math.pow(subspaces, dims)
    samples_per_subspace = Math.floor(amount / sample_amount)
    number_of_points = Math.pow(subspaces, dims) * samples_per_subspace
    obj = {
      dims: dims,
      subspaces: subspaces,
      samples_per_subspace: samples_per_subspace,
      rest: amount - number_of_points
    }
    return obj

  @_ortho_sample: (obj) =>

    _init_value = 0
    for sps in [1..obj.samples_per_subspace]
      _counter_array = @_init_counter_array(obj.dims, _init_value)
      for subspace in [0..obj.amount_subspaces-1]
        sample = []
        for curr_dim, i in obj.sample_array
          arr = curr_dim[_counter_array[i]]
          pos = Math.floor(Math.random() * arr.length)
          sample.push(arr.splice(pos,1)[0])
        _counter_array = @_increase_counter_array(obj.subspaces_per_dim, _counter_array)
        obj.normal_samples.push(sample)
      obj.map(obj.parameter_space) if obj.parameter_space
    return obj

  @_hyper_sample: (obj) =>

    for sample in [1..obj.sample_array[0].length]
      sample = []
      for arr in obj.sample_array
        pos = Math.floor(Math.random() * arr.length)
        sample.push(arr.splice(pos,1)[0])
      obj.normal_samples.push(sample)
    obj.map(obj.parameter_space) if obj.parameter_space
    return obj


class @LHS extends Sampling
  constructor: (options = {}) ->
    super(options)

  @sample: (amount, dims, parameter_space = null) ->
    lhs = new LHS({amount: amount, dims: dims})

    lhs.sample_array = @_hyper_sample_arrays(amount, dims, lhs)

    @_hyper_sample(lhs)
    return lhs

class @OrthogonalSampling extends Sampling
  constructor: (options = {}) ->
    super(options)

  _counter_array = undefined

  @sample: (amount, dims, parameter_space = null) ->
  # @sample: (samples_per_subspace, subspaces_per_dim, dims, parameter_space = null) =>
    obj = @_calc_opt_sample(amount, dims)
    samples_per_subspace = obj.samples_per_subspace
    subspaces_per_dim = obj.subspaces
    amount_subspaces = Math.pow(subspaces_per_dim, dims)
    amount = amount_subspaces * samples_per_subspace
    os = new OrthogonalSampling({amount: amount, dims: dims, parameter_space: parameter_space})
    os.subspaces = subspaces_per_dim
    os.sps = samples_per_subspace
    os.rest = obj.rest
    os.samples_per_subspace = obj.samples_per_subspace
    os.amount_subspaces = amount_subspaces
    os.subspaces_per_dim = subspaces_per_dim

    _outer_array = @_hyper_sample_arrays(amount, dims, os)
    os.sample_array = []

    for arr in _outer_array
      os.sample_array.push(@_splice_array(arr, subspaces_per_dim))
 
    @_ortho_sample(os)
    return os


@Ortho = OrthogonalSampling

class @HybridSampling extends Sampling
  constructor: (options = {}) ->
    super(options)

  _counter_array = undefined

  @sample: (amount, dims, parameter_space = null) ->
    obj = @_calc_opt_sample(amount, dims)
    samples_per_subspace = obj.samples_per_subspace
    subspaces_per_dim = obj.subspaces
    amount_subspaces = Math.pow(subspaces_per_dim, dims)
    os = new HybridSampling({amount: amount, dims: dims, parameter_space: parameter_space})
    os.subspaces = subspaces_per_dim
    os.sps = samples_per_subspace
    os.rest = obj.rest
    os.samples_per_subspace = obj.samples_per_subspace
    os.amount_subspaces = amount_subspaces
    os.subspaces_per_dim = obj.subspaces
    _outer_array = @_hyper_sample_arrays(amount, dims, os)
    os.sample_array = []

    for arr in _outer_array
      os.sample_array.push(@_splice_array(arr, subspaces_per_dim))

    @_ortho_sample(os)

    for arr,i in os.sample_array
      merged = []
      merged = merged.concat.apply(merged, arr)
      os.sample_array[i] = merged

    @_hyper_sample(os)
    return os

@Hybrid = HybridSampling

class @Bins
  constructor: (options={})->
    @number = options.number ? 20
    @size = @number
    @bins = []

  getMinima: =>
    minima = []
    for values in @bins
      minima.push(Math.min.apply(null, values))
    return minima

  getMaxima: =>
    maxima = []
    for values in @bins 
      maxima.push(Math.max.apply(null, values))
    return maxima

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

  getValueAtArrayPosition: (x, y) =>
    return null if x < 0 or x > @number or y < 0 or y > @number
    pos = x + y * @number
    @bins[pos]


class @BinSet 
  constructor: (options = {}) ->
    @number = options.number ? 20
    @results = new Bins2d({number: @number})
    @samples = new Bins2d({number: @number})
    @normal_samples = new Bins2d({number: @number})

  insert: (obj) =>
    _x = obj.x
    _y = obj.y ? null
    @results.insert(obj.result, _x, _y) if obj.result
    @samples.insert(obj.sample, _x, _y) if obj.sample
    @normal_samples.insert(obj.normal_sample, _x, _y) if obj.normal_sample

  getMinima: =>
    min_results = @results.getMinima()
    minima = {results: min_results, samples: [], normal_samples: [], indices: []}
    for min_result, i in min_results
      index = @results.bins[i].indexOf(min_result)
      minima.indices.push(index)
      minima["samples"].push(@samples.bins[i][index])
      minima["normal_samples"].push(@normal_samples.bins[i][index])
    return minima

  getMaxima: =>
    max_results = @results.getMaxima()
    maxima = {results: max_results, samples: [], normal_samples: [], indices: []}
    for max_result, i in max_results
      index = @results.bins[i].indexOf(max_result)
      maxima.indices.push(index)
      maxima["samples"].push(@samples.bins[i][index])
      maxima["normal_samples"].push(@normal_samples.bins[i][index])
    return maxima



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
