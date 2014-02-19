require 'should'
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





