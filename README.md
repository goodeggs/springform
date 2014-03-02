Springform [![NPM version](https://badge.fury.io/js/springform.png)](http://badge.fury.io/js/springform) [![Build Status](https://travis-ci.org/goodeggs/springform.png)](https://travis-ci.org/goodeggs/springform)
==============

Full-stack javascript form processing.

Springform is a minimial (mostly convetion) [Presenter](http://en.wikipedia.org/wiki/Model_View_Presenter) or [View Model](http://en.wikipedia.org/wiki/Model_View_ViewModel) with just the right hooks to validate forms in the browser, submit them to a server, validate in node, and show the resulting errors.

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
      Robot.count {sound: form.data.sound}, (err, count) ->
        if count
          form.formError = 'Another robot already makes that sound'
        done()
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
Springform doesn't do this.  You might think of a Springform as a [Presenter](http://en.wikipedia.org/wiki/Model_View_Presenter) or [View Model](http://en.wikipedia.org/wiki/Model_View_ViewModel) that you can use to generate application specific form markup, and that you can bind to. [Ribosprite](http://github.com/hurrymaplelad/ribosprite) is an example to get you started.


Error Representation
--------------------
Springforms pass around error messages with this structure:
```js
{
  formError: < ... >,
  fieldErrors: {
    <fieldName>: < ... >, 
    <otherFieldName>: < ... >
  }
}
```
You'll get an object like this representing the forms current errors by calling `form.errors()`.  If you format a JSON response with this structure, you can pass the reponse directly to the the errors method (`form.errors(res.body)`) to set errors on the form.

There a couple useful conventions for the values in the errors object.  The simplest is to set a user-facing error message:
```js
{formError: "Oops... Something went wrong..."}
```

To flag a field as having problem without adding a message, use Boolean `true`:
```js
{fieldErrors: {sound: true}}
```

If you need to localize later, or you'd rather just keep the messages client-side, send a code:
```js
{fieldErrors: {sound: 'required'}}
```

Validators
----------
Validators are functions with the signature `(form, [done])`.  Validators in Springform have two important responsiblities:

1. They set or select a user-facing error messages.
2. They decide if messages are displayed near a single field, or apply to the whole form.

These two reponsibilities are application specific.  One app might list all required fields at the top of the form, another might flag each missing field individually.  You should definitely compose your validators using existing libraries (like [chriso/validator.js](https://github.com/chriso/validator.js)), but you'll need to add the two responsibilities above following the conventions of your app.

Validators can by syncronous or asyncronous.  

#### Simple
The simplest validators are syncronous.  They just assign error messages to the passed in form:
```js
function(form) {
  if(form.data.color != 'red') {
    form.fieldErrors.color = 'Pick a better color'
  }
}
```

#### Async
If your validator does something slow like talk to the database or make a network request, accept a second `done` argument and call it when you're done:
```js
function(form, done) {
  Robot.count({sound: form.data.sound}, function(err, count) {
    if(count) {
      form.formError = 'Another robot already makes that sound'
    }
    done()
  });
}
```

API
---
#### bind(data)
Chainable sugar to set `form.data`.  Feel free to set form.data directly if you don't need chainability.

#### hasErrors()
Returns true if `formError` or any `fieldErrors[*]` is truthy.

#### validate([done])
Clear `formError` and `fieldErrors` then run all the `validators`.  You can always pass a callback, to be called when all validators have finished.  It's an especially good idea if any of your validators are async.

#### validator(validatorFn)
Chainable sugar to push a [validator function](#validators) onto `validators` to be run when `validate()` is called.

#### validators
An array of [validator function](#validators) to run when `validate()` is called.  You can set `validators` directly, set it on a prototype, or call `validator()` to add validators one at a time.

#### submit([event])
Call `process()` and set the `processing` flag while it's running.  Calls `preventDefault()` on the passed in event if used as an event listener.

#### process(done)
An async function that does the work of submitting the form.  Could be an Ajax POST, a model.save(), or something else entirely.  Be sure to call `done`.  Processors frequently call some combination of `validate()`, `errors({...})`, and `hasErrors()`.  Define this function on an instance, on a prototype, or pass it in to `processor()`.

#### processor(processorFn)
Chainable sugar to set `process`.





