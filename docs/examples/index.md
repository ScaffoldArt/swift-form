# Examples

SAForm is designed to be easy to try from a complete form.
If you already know what kind of form you need, open the closest example, copy the shape, and adapt the fields and validation rules to your app.

Each page below contains a focused explanation and a full SwiftUI example.

## Login Form

Start here if you want the smallest useful setup.
This example shows how to define fields, bind them to SwiftUI controls, show validation errors, and submit typed validated data.

[Open Login Form](/examples/login-form)

## Cross-Field Validation

Use this when one field is not enough to decide whether the form is valid.
This example shows `refine`, where the form compares multiple values such as password and confirm password.

[Open Cross-Field Validation](/examples/cross-field-validation)

## Initial Values

Use this when a form starts from existing data loaded from your backend.
This example shows how to set fetched values as defaults so loaded data does not count as user edits.

[Open Initial Values](/examples/initial-values)

## Server Errors

Use this when your API returns field-level validation errors after submit.
This example shows how to map backend errors back onto SAForm fields and display them in the UI.

[Open Server Errors](/examples/server-errors)

## Server Validation

Use this when a field needs an async check, such as verifying whether an email is already taken.
This example shows how to run local validation first and call the server only after the value passes.

[Open Server Validation](/examples/server-validation)
