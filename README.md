springform [![NPM version](https://badge.fury.io/js/springform.png)](http://badge.fury.io/js/springform) [![Build Status](https://travis-ci.org/goodeggs/springform.png)](https://travis-ci.org/goodeggs/springform)
==============

For cheesecake and full-stack form processing.

Spring form is minimial, mostly convetion, and mildly opinionated.  It'll give you just the right hooks to validate forms in the browser and / or node, and show the resulting errors.

Create just one form:
```js
var Springform = require('springform'),
    robotForm = new Springform({
      validators: [
        function(form) {
          if(form.data.color != 'red') {
            form.fieldErrors.color = 'Pick a better color'
          }
        }
      ]
    })
```

Or setup a prototype chain for a whole class of forms:
```coffee
class RobotForm extends Springform
  fields: [
    {name: 'color'}
    {name: 'sound', label: 'What noise does it make?'}
  ]

  validators: [
    (form) ->
      {data, fieldErrors} = form
      unless data.color is 'red'
        fieldErrors.color = 'Pick a better color'

    (form) ->
      done = @async()
      if Robot.count {sound: form.data.sound}, (err, count) ->
        if count
          form.formError = 'Another robot already makes that sound'
          done(err)
  ]
```

Validate a form server-side
---------------------------
Here's how you might validate an XMLHttpRequest JSON form POST from an express controller, and send back validation errors to be shown on the client:
```js
(req, res) ->
  var form = new RobotForm().bind(req.body).validate()
  if(form.hasErrors()) {
    res.json(form.errors())
  } else {
    res.json({})
  }
```

Show form errors client-side
----------------------------
You might use [Rivets](http://www.rivetsjs.com/) to bind a Springform form to the DOM:
```
var robot = {sound: 'beep', color: 'red'},
    form = new RobotForm({data: robot})

rivets.bind(formEl, {
  form: form
  onSubmit: function () {
    $.ajax({
      type: 'POST',
      dataType: 'json',
      data: robot,
      success: function(response) {
        form.errors(response)
        if(!form.hasErrors()) {
          alert('done!')
        }
      }
    })
  }
});
```

Generate form HTML
--------------------
Render client or server side, with whatever templates make you happy.  Building up a set of template helpers specific to your applications works well.

Here's an example from [rivetted-springform-teacup](http://github.com/goodeggs/rivetted-springform-teacup):

```coffee
# TODO
```

