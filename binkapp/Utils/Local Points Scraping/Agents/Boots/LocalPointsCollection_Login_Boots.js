// Value injection

var username = "%@"
var password = "%@"


// Form selector queries

var formQuery = "form.gigya-login-form"
var usernameInputQuery = "form#login-form input[name=username]"
var passwordInputQuery = "form#login-form input[type=password]"
var submitButtonQuery = "form#login-form input[type=submit]"


performLogin()


function performLogin() {


    // ** FORM **


    var f = document.querySelectorAll(formQuery)

    if (!f) {
        return {
            "success": false,
            "error_message": "Failed to identify form."
        }
    }

    // Override the form's id to enable easier querying
    var fIndex
    for (fIndex = 0; fIndex < f.length; fIndex++) { 
        f[fIndex].id = "login-form"
    }


    // ** USERNAME **


    var u = document.querySelectorAll(usernameInputQuery)

    if (!u) {
        return {
            "success": false,
            "error_message": "Failed to identify email/username input field."
        }
    }

    
    // ** PASSWORD **


    var p = document.querySelectorAll(passwordInputQuery)

    if (!p) {
        return {
            "success": false,
            "error_message": "Failed to identify password input field."
        }
    }


    // ** VALUE SETTING **


    var uIndex
    for (uIndex = 0; uIndex < u.length; uIndex++) { 
        u[uIndex].value = username
    }
    
    var pIndex
    for (pIndex = 0; pIndex < p.length; pIndex++) { 
        p[pIndex].value = password
    }


    // ** SUBMIT **


    var b = document.querySelectorAll(submitButtonQuery)

    if (!b) {
        return {
            "success": false,
            "error_message": "Failed to identify submit button."
        }
    }

    var bIndex
    for (bIndex = 0; bIndex < b.length; bIndex++) { 
        b[bIndex].click()
    }
    
    return {
        "success": true
    }
}
