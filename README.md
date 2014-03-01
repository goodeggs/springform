springform [![NPM version](https://badge.fury.io/js/springform.png)](http://badge.fury.io/js/springform) [![Build Status](https://travis-ci.org/goodeggs/springform.png)](https://travis-ci.org/goodeggs/springform)
==============

For cheesecake and full-stack form processing.

Spring form is minimial, it's mostly convetion.  It supplies just the right hooks to validate forms in the browser, submit them to a server, validate in node, and show the resulting errors.

Create just one form with a chainable interface:
```js
var Springform = require('springform')
    robotForm = new Springform()
      .validator(Springform.required('sound'))
      .validator(function(form) {
        if(form.data.color != 'red') {
          form.fieldErrors.color = 'Pick a better color'
        }
      .validator(function (form, done) {
        make-a-request–or-run-a-query function (err, result) {
          form.formError = 'busted'
          done()
        }
      })
```

Or setup a prototype chain for a whole class of forms using a declarative syntax:
```coffee
class RobotForm extends Springform
  validators: [
    Springform.required 'color'
    (form) ->
      {data, fieldErrors} = form
      unless data.color is 'red'
        fieldErrors.color = 'Pick a better color'

    (form, done) ->
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
functinon (req, res) {
  var form = new RobotForm().bind(req.body).validate()
  if(form.hasErrors()) {
    res.json(form.errors())
  } else {
    res.json({})
  }
}
```

Show form errors client-side
----------------------------
You might use [Rivets](http://www.rivetsjs.com/) to bind a Springform form to the DOM:
```
var robot = {sound: 'beep', color: 'red'},
    form = new Springform()
      .bind(robot)
      .processor(function (done) {
        $.ajax({
          dataType: 'json',
          data: robot,
          success: function(response) {
            form.errors(response)
            if(!form.hasErrors()) {
              alert('done!')
            }
            done()
          }
        })
      })

rivets.bind(formEl, form)
```

Generate form HTML
------------------
Springform doesn't do this.  Form markup is usually application specific, so you'll likely need to roll your own template helpers, but [ribosprite](http://github.com/hurrymaplelad/ribosprite) should get you started.

