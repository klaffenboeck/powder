class @EstimationFunction
  @create: (params) ->
    type = Object.keys(params)[0] # first key defines the object
    switch type
      when "gaussian_process_model" then new GaussianProcessModel(params[type])

  @factory: (params) ->
    @create(params)

  compute: ->
    return "computation going on"



class @EstimationFunctionList
  constructor: (options={}) ->
    @functions = options.functions ? []

  @list = @functions

  addFunction: (func) =>
    @functions.push(func)



class @GaussianProcessModel extends EstimationFunction
  constructor: (options={}) ->
    {@input_matrix, @result_vector, @mu, @theta, @sig2, @parameter_space, @corr_response, @inv_var_matrix, @big_sigma_inverse} = options
    @keys = Object.keys(@parameter_space)
    @accuracy = @result_vector.length
    @estimate = @est

  est: (current_vector, mat = @input_matrix) =>
    vector = @compose_vector(current_vector)
    vec = []
    for row in mat
      vec.push(@corr_theta(row, vector))
    return +@mu + numbers.matrix.dotproduct(vec, @corr_response)

  @estimate = @est

  estimate_normal: (current_vector) =>
    value = @est(current_vector)
    normal = (10000 - value) / 10000
    normal = 0 if normal < 0
    normal = 1 if normal > 1
    return normal

  corr_theta: (vector1, vector2, t = @theta) =>
    sum = 0
    for value, index in t
      sum += value * Math.pow(Math.abs(vector1[index] - vector2[index]),2) #exchange 2 for _alpha
    return Math.exp(-sum)

  compose_vector: (vector) =>
    return vector if vector instanceof Array
    new_vector = []
    for key in @keys
      new_vector.push(vector[key])
    return new_vector

  est_error: (current_vector, mat = @input_matrix) =>
    vector = @compose_vector(current_vector)
    vec = []
    for row in mat
      vec.push(@corr_theta(row, vector))
    # new_vec = @multiply(mat, vec)
    return vec

  multiply: (matrix, vector) =>
    return_vector = []
    for row in matrix 
      sum = 0
      for value, index in row
        sum += value * vector[index]
      return_vector.push(sum)
    return return_vector

  calcPredictionError: (vector) =>
    r = @calcCorOneObs(vector)
    part = @matrixVectorMultiplication(@inv_var_matrix, r)
    scalar = numbers.matrix.dotproduct(r, part)
    v = @sig2 - (@sig2 * scalar * @sig2)
    return 0 if v < 0
    return Math.sqrt(v)

  calcCorOneObs: (vec2) =>
    newCor = []
    for vec1 in @input_matrix
      newCor.push(@calcSingleNewCor(vec1, vec2))
    return newCor

  calcSingleNewCor: (vec1, vec2) =>
    sum = 0
    for val, i in vec1
      val = Math.pow(Math.abs(@roundFloat(@roundFloat(val) - @roundFloat(vec2[i]))),2)
      sum += (val * @theta[i])
    return Math.exp(-sum)

  roundFloat: (val, mantisse = 8) =>
    return Number((val).toFixed(mantisse))

  matrixVectorMultiplication: (mat, vec) =>
    result_vector = []
    for mat_vec in mat
      result_vector.push(numbers.matrix.dotproduct(mat_vec, vec))
    return result_vector











