var username = "%@"
var password = "%@"

const formIds = ["sign-in-form", "login-form", "loginForm"]

performLogin()

function performLogin() {

    console.log("Checkpoint 1")

    //  ** FORM **


    // Get all forms
    var formId
    var formClass
    var forms = document.querySelectorAll('form')

    if (forms.length === 0) {
        // If there are no forms, return an error message
        return {
            "error_message": "No forms found."
        }
    } else if (forms.length === 1) {
        forms[0].id = "login-form"
        formId = forms[0].id
        if (formId == null || formId === "") {
            return {
                "error_message": "A single form was found, but the form had no id."
            }
        }
    } else {
        // If there are multiple forms, select the correct form by iterating over know form id's
        for (i = 0; i < formIds.length; i++) {
            var form = document.querySelector('form[id="' + formIds[i] + '"]')
            if (form !== null) {
                formId = formIds[i]
                break
            }
        }
    }

    // Verify form exists
    if (formId == null) {
        return {
            "error_message": "formId could not be determined."
        }
    }

    var f = document.querySelector('form[id=' + formId + ']')
    if (f == null) {
        return {
            "error_message": "No form found with id: " + formId
        }
    }


    //  ** EMAIL/USERNAME **

    console.log("Checkpoint 2")
    console.log("Form ID: " + formId)


    // To get email field, we should first check for type=email
    var e
    e = document.querySelector('form[id=' + formId + '] input[type=email]')

    if (e == null) {
        // If that is null, we should check id="username"
        e = document.querySelector('form[id=' + formId + '] input#username')

        if (e == null) {
            // If still null, then check id="email".
            e = document.querySelector('form[id=' + formId + '] input#email')

            if (e == null) {
                // If still null, then check title for "username". This is last resort as will be getting non performant at this stage.
                e = document.querySelector('form[id=' + formId + '] input[title=username]')
            }
        }
    }

    // Set the email/username value if possible
    if (e == null) {
        return {
            "error_message": "Could not find email/username input field."
        }
    }
    e.value = username


    //  ** PASSWORD **

    console.log("Checkpoint 3")


    // All password fields are input[type=password]
    var p = document.querySelector('form[id="' + formId + '"] input[type="password"]')

    // Set the password value if possible
    if (p == null) {
        return {
            "error_message": "Could not find password input field."
        }
    }
    p.value = password


    // ** RECAPTCHA **

    console.log("Checkpoint 4")


    // Can we detect a recaptcha anchor container on the web page?
    let anchor = document.querySelector('div#rc-anchor-container')

    console.log("Checkpoint 4.1")

    if (anchor) {

        console.log("Checkpoint 4.2")
        // Anchor container detected
        // We should trigger the recaptcha challenge and display it to the user
        anchor.click()

        return {
            "user_action_required": true
        }
    }


    //  ** SUBMIT **

    console.log("Checkpoint 5")


    // To get button, try button[type=submit], otherwise filter.
    var b

    b = document.querySelector('form[id="' + formId + '"] button[type=submit]')

    if (b == null) {
        b = Array.from(document.querySelectorAll('form[id="' + formId + '"] button')).filter(el => el.type === "submit")[0]
    }

    // Click submit if possible
    if (b == null) {
        return {
            "error_message": "Could not find submit button."
        }
    }

    b.click()

    return {}
}
