Springform = require '..'

describe 'Springform', ->
  describe 'constructor', ->
    it 'accepts fields and validators', ->
      form = new Springform
        fields: [{name: 'sound'}]
        validators: [(form)->]

      form.fields.length.should.equal 1
      form.fields.sound.should.be.ok
      form.validators.length.should.equal 1

  describe 'subclass', ->
    it 'can define fields and validators on the prototype', ->
      class RobotForm extends Springform
        fields: [{name: 'sound'}]
        validators: [(form)->]

      form = new RobotForm()
      form.fields.length.should.equal 1
      form.fields.sound.should.be.ok
      form.validators.length.should.equal 1

  describe '::bind()', ->
    {form} = {}
    beforeEach ->
      form = new Springform

    it 'sets form data', ->
      form.bind(foo: 'bar')
      form.data.foo.should.equal 'bar'

    it 'is chainable', ->
      form.bind().should.equal.form

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

    it 'is chainable', ->
      form.validate().should.equal form

  describe '::hasErrors()', ->
    {form} = {}
    beforeEach ->
      form = new Springform

    describe 'when the form has no errors', ->
      it 'is false', ->
        form.hasErrors().should.equal false

    describe 'falsy values in fieldsErrors', ->
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


  describe 'prefix', ->
    it 'is omitted by default', ->
      new Springform().should.not.have.property 'prefix'

    describe 'when set', ->
      {form} = {}
      beforeEach ->
        form = new Springform(prefix: 'robo', fields: [{name: 'color'}])

      it 'is passed to fields', ->
        form.fields.color.prefix.should.equal 'robo'


  describe 'fields', ->
    describe 'without a label', ->
      {Form} = {}
      beforeEach ->
        class Form extends Springform
          fields: [{name: 'firstName'}]

      it 'get a generated label', ->
        new Form().fields.firstName.label.should.equal 'firstName'

      it 'can customize label generation', ->
        Form::nameToLabel = (name) ->
          name
            .replace(/([a-z])([A-Z])/g, '$1 $2')
            .replace(/(^[a-z])/g, (str, p1) -> p1.toUpperCase())

        new Form().fields.firstName.label.should.equal 'First Name'


  describe 'validators', ->
    describe 'required', ->
      {Form} = {}
      beforeEach ->
        class Form extends Springform
          fields: [{name: 'sound', required: true}]
          validators: [Springform.validators.required]

      it 'adds per-field error messages for missing values', ->
        new Form()
          .bind({})
          .validate()
          .fieldErrors.sound.should.be.ok

      it 'passes with Boolean false value', ->
        new Form()
          .bind(sound: false)
          .validate()
          .fieldErrors.should.not.have.property 'sound'

  describe 'behaviors', ->
    describe 'asyncSubmission', ->
      {asyncSubmission} = Springform.behaviors
      {form} = {}

      describeAsyncSubmission = ->
        it 'adds submit() and processor() methods', ->
          (typeof form.submit).should.equal 'function'
          (typeof form.processor).should.equal 'function'

        describe 'submit', ->

          it 'calls the processor', ->
            form.submit()
            form.formError.should.equal 'processing failed'

          describe 'given an async processor', ->
            {complete} = {}
            beforeEach ->
              form.processor (done) ->
                complete = done
              form.submit()

            it 'sets processing flag', ->
              form.processing.should.equal true

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

        describe '::processor()', ->
          it 'assigns the process function', ->
            model = save: (done) ->
            form.processor model.save
            form.process.should.equal model.save

          it 'is chainable', ->
            form.processor((done)->).should.equal form


      describe 'on a prototype', ->
        beforeEach ->
          class Form extends Springform
            @::using asyncSubmission

            process: (done) ->
              @formError = 'processing failed'
              done()

          form = new Form()

        describeAsyncSubmission()

      describe 'on an instance', ->
        beforeEach ->
          form = new Springform()
            .using(asyncSubmission)
            .processor (done) ->
              form.formError = 'processing failed'
              done()

        describeAsyncSubmission()

    describe 'asyncValidatation', ->
      {asyncValidation} = Springform.behaviors
      {form} = {}

      describeAsyncValidation = ->

        describe '::validate()', ->
          beforeEach ->
            form.validators = [
              (form) ->
              (form, done) ->
                setTimeout ->
                  form.formError = 'invalid'
                  done()
                , 1
            ]

          it 'calls a callback when all validators complete', (done) ->
            form.validate ->
              form.formError.should.equal 'invalid'
              done()

        it 'is chainable', ->
          form.validate((done)->).should.equal form

      describe 'on a prototype', ->
        beforeEach ->
          class Form extends Springform
            @::using asyncValidation

          form = new Form()

        describeAsyncValidation()

      describe 'on an instance', ->
        beforeEach ->
          form = new Springform().using(asyncValidation)

        describeAsyncValidation()


