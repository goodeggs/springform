class Springform
  constructor: (attrs={}) ->
    @[key] = value for key, value of attrs

    @prefix ?= 'springform'
    @fieldErrors ?= {}
    @formError = null

    @fields ?= []
    for field in @fields
      field.label ?= @nameToLabel field.name
      field.id ?= [@prefix, field.name].join '-'
      @fields[field.name] = field

  bind: (data) ->
    @data = data
    @

  prunedData: ->
    _(data).pick _(@fields).pluck 'name'

  errors: (errors) ->
    if arguments.length
      @formError = errors.formError
      @fieldErrors = errors.fieldErrors or []
      return @
    else
      {@formError, @fieldErrors}

  validate: ->
    @formError = null
    @fieldErrors = {}
    for validator in @validators or []
      validator(@)
    @

  hasErrors: ->
    Boolean Object.keys(@fieldErrors).length > 0 or @formError

  nameToLabel: (name) -> name

Springform.validators =
  required: (form) ->
    for {name, required} in form.fields
      value = form.data[name]
      if required and not (value or value is false)
        form.fieldErrors[name] = 'required'

module.exports = Springform
