// Value injection

var username = "%@"
var password = "%@"


// Form selector queries

var formQuery = "form#sign-in-form"
var usernameInputQuery = "form#login-form input[type=email]"
var passwordInputQuery = "form#login-form input[type=password]"
var submitButtonQuery = "form#login-form button[type=submit]"


performLogin()


function performLogin() {


    // ** FORM **


    var f = document.querySelector(formQuery)

    if (!f) {
        return {
            "success": false,
            "error_message": "Failed to identify form."
        }
    }

    // Override the form's id to enable easier querying
    f.id = "login-form"


    // ** USERNAME **


    var u = document.querySelector(usernameInputQuery)

    if (!u) {
        return {
            "success": false,
            "error_message": "Failed to identify email/username input field."
        }
    }

    u.value = username


    // ** PASSWORD **


    var p = document.querySelector(passwordInputQuery)

    if (!p) {
        return {
            "success": false,
            "error_message": "Failed to identify password input field."
        }
    }

    p.value = password


    // ** SUBMIT **


    var b = Array.from(document.querySelectorAll('form#login-form button')).filter(el => el.type === "submit")[0]

    if (!b) {
        return {
            "success": false,
            "error_message": "Failed to identify submit button."
        }
    }

    b.click()

    return {
        "success": true
    }
}
