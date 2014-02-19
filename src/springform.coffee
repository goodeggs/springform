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

  data: (data) ->
    if arguments.length
      @data = data
      return @
    else
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
    Object.keys(@fieldErrors).length > 0 or @formError

  nameToLabel: (name) -> name

module.exports = Springform
