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

  describe 'hasErrors', ->
    {form} = {}
    beforeEach ->
      form = new Springform

    describe 'when the form has no errors', ->
      it 'is false', ->
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




