Springform = require '..'
sinon = require 'sinon'

describe 'Springform', ->
  describe 'constructor', ->
    {form} = {}
    beforeEach ->
      form = new Springform
        fields: [{name: 'sound'}]
        validators: [(form)->]

    it 'accepts fields and validators', ->
      form.fields.length.should.equal 1
      form.validators.length.should.equal 1

    it 'maps fields by name', ->
      form.fields.sound.should.be.ok

  describe 'subclass', ->
    it 'can define fields and validators on the prototype', ->
      class RobotForm extends Springform
        fields: [{name: 'sound'}]
        validators: [(form)->]

      form = new RobotForm()
      form.fields.length.should.equal 1
      form.fields.sound.should.be.ok
      form.validators.length.should.equal 1

  describe '::errors()', ->
    {form, errors} = {}
    beforeEach ->
      form = new Springform
      errors =
        formError: 'Busted!'
        fieldErrors:
          foo: 'bar'

    describe 'given form and field errors', ->
      it 'sets errors on the form', ->
        form.errors(errors)
        form.fieldErrors.should.eql errors.fieldErrors
        form.formError.should.eql errors.formError

      it 'defaults fieldsErrors to an empty object', ->
        form.errors({})
        form.fieldErrors.should.be.an.Object
        form.fieldErrors.should.be.empty

      it 'is chainable', ->
        form.errors(errors).should.equal form

    describe 'with no arguments', ->
      it 'returns fieldErrors and formError', ->
        form
          .errors(errors)
          .errors().fieldErrors.should.equal errors.fieldErrors

  describe '::validate()', ->
    {form} = {}
    beforeEach ->
      form = new Springform

    describe 'on a form with validators', ->
      beforeEach ->
        form.validators = [
          (form) ->
            form.fieldErrors.beep = true
          (form) ->
            form.fieldErrors.boop = true
        ]

      it 'calls all validators', ->
        form.validate()
        form.fieldErrors.beep.should.equal true
        form.fieldErrors.boop.should.equal true

    describe 'with async validators', ->
      beforeEach ->
        form.validator (form, done) ->
          setTimeout ->
            form.formError = 'invalid'
            done()
          , 1

      it 'calls a callback when all validators complete', (done) ->
        form.validate ->
          form.formError.should.equal 'invalid'
          done()

    it 'is chainable', ->
      form.validate().should.equal form

  describe '::validator()', =>
    {form} = {}
    beforeEach ->
      form = new Springform()

    it 'adds a validator', ->
      form.validator (form) ->
      form.validators.length.should.equal 1

    it 'is chainable', ->
      form.validator((form) ->).should.equal form

  describe '::hasErrors()', ->
    {form} = {}
    beforeEach ->
      form = new Springform

    describe 'when the form has no errors', ->
      it 'is false', ->
        form.hasErrors().should.equal false

    describe 'undefined values in fieldsErrors', ->
      beforeEach ->
        form.fieldErrors.beep = null

      it 'are ignored', ->
        # rivets can be configured to create empty enumerable
        # properties on the errors object
        form.hasErrors().should.equal false

    describe 'with a form level error message', ->
      beforeEach ->
        form.formError = 'Busted!'

      it 'is true', ->
        form.hasErrors().should.equal true

    describe 'with any field level error message', ->
      beforeEach ->
        form.fieldErrors.foo = 'Busted!'

      it 'is true', ->
        form.hasErrors().should.equal true

  describe '::submit()', ->
    {form} = {}
    beforeEach ->
      form = new Springform()
        .set 'process', (done) ->
          form.formError = 'processing failed'
          done()

    it 'calls the processor', ->
      form.submit()
      form.formError.should.equal 'processing failed'

    describe 'given an async processor', ->
      {complete} = {}
      beforeEach ->
        form.process = sinon.spy (done) ->
          complete = done
        form.submit()

      it 'sets processing flag', ->
        form.processing.should.equal true

      describe 'when the form is submitted while processing', ->
        beforeEach ->
          form.submit()

        it "doesn't call the processor again", ->
          form.process.callCount.should.equal 1

      describe 'when the processor completes', ->
        beforeEach (done) ->
          setTimeout (-> complete(); done()), 1

        it 'clears the processing flag', ->
          form.processing.should.equal false

    describe 'given an event', ->
      {event, prevented} = {}
      beforeEach ->
        prevented = false
        event = preventDefault: -> prevented = true

      it 'prevents default submission', ->
        form.submit(event)
        prevented.should.equal true

    describe 'called without context', ->
      it 'is bound to the form', ->
        submit = form.submit
        submit()

    describe '::set()', ->
      {form} = {}
      beforeEach ->
        form = new Springform

      it 'assigns data', ->
        form.set 'data', foo: 'bar'
        form.data.foo.should.equal 'bar'

      it 'assigns the process function', ->
        model = save: (done) ->
        form.set 'process', model.save
        form.process.should.equal model.save

      it 'supports object notation', ->
        model = save: (done) ->

        form.set process: model.save
        form.process.should.equal model.save

      it 'is chainable', ->
        form.set('processor', (done)->).should.equal form

  describe 'validators', ->
    describe 'required', ->
      {Form} = {}
      beforeEach ->
        class Form extends Springform
          validators: [
            Springform.required 'sound'
          ]

      it 'adds per-field error messages for missing values', ->
        new Form(data: {})
          .validate()
          .fieldErrors.sound.should.be.ok

      it 'passes with Boolean false value', ->
        new Form(data: sound: false)
          .validate()
          .fieldErrors.should.not.have.property 'sound'

