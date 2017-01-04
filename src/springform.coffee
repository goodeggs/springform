class Springform
  constructor: (attrs={}) ->
    @[key] = value for key, value of attrs

    @fieldErrors ?= {}
    @formError = null
    @validators = if @validators then @validators.slice() else []

    @fields ?= []
    for field in @fields
      @fields[field.name] = field

  set: (key, value) ->
    if typeof key is 'string'
      @[key] = value
    else
      args = key
      for key, value of args
        @[key] = value
    @

  prunedData: ->
    _(data).pick _(@fields).pluck 'name'

  errors: (errors) ->
    if arguments.length
      @formError = errors.formError
      @fieldErrors = errors.fieldErrors or {}
      return @
    else
      {@formError, @fieldErrors}

  addValidator: (validator) ->
    @validators.push validator
    @

  validate: (done) ->
    @formError = null
    @fieldErrors = {}
    gate = new Gate()
    for validator in @validators or []
      if validator.length > 1
        validator @, gate.callback()
      else
        validator @
    gate.finished done
    @

  hasErrors: ->
    Boolean(@formError) or
    Object.keys(@fieldErrors).some (key) =>
      Boolean @fieldErrors[key]

  submit: (event) =>
    event?.preventDefault()
    return if @saving
    @saving = true
    @save =>
      @saving = false

  save: (done) -> done()

Springform.required = (fields...) ->
  ({data, fieldErrors}) ->
    for field in fields
      value = data[field]
      unless value or value is false
        fieldErrors[field] = 'required'

class Gate
  constructor: ->
    @callbacks = []
    @returnedCount = 0

  checkDone: ->
    if @returnedCount == @callbacks.length and @done?
      setTimeout @done, 0

  callback: ->
    called = false
    callback = =>
      return if called; called = true
      @returnedCount += 1
      @checkDone()
    @callbacks.push callback
    return callback

  finished: (callback) ->
    @done = callback
    @checkDone()

module?.exports = Springform
