var username = "%@"
var password = "%@"

var formIds = ["sign-in-form", "login-form", "loginForm"]

performLogin()

function performLogin() {


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


    // Can we detect an invalid recaptcha anchor container on the web page?
    let recaptcha = document.querySelector('re-captcha[class*=-invalid]')

    if (recaptcha) {
        var node = document.createElement('div')
        // node.style.backgroundColor = 'white'
        node.style.position = 'fixed'
        node.style.top = '0'
        node.style.bottom = '0'
        node.style.left = '0'
        node.style.right = '0'
        node.style.zIndex = '999'

        let container = document.querySelector('re-captcha div')
        container.style.position = 'relative'
        container.style.zIndex = '1000'

        recaptcha.appendChild(node)

        return {
            "user_action_required": true
        }
    }


    //  ** SUBMIT **


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
