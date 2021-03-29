var username = "%@"
var password = "%@"

var formQuery = "form.gigya-login-form"
var usernameInputQuery = "form#login-form input[name=username]"
var passwordInputQuery = "form#login-form input[type=password]"
var submitButtonQuery = "form#login-form input[type=submit]"

var pointsValueQuery = "p#advantageCardDetails span:first-of-type"

var incorrectCredentialsQuery = "div[class*=validation-error-message] p"

handleNavigation()

function handleNavigation() {
    // If we can identify the points value, scrape

    var pts = document.querySelector(pointsValueQuery)
    if (pts && pts.innerHTML !== "") {
        return {
            "points": pts.innerHTML
        }
    }


    // If we can't identify a points value, can we identify one of the following:
    // Recaptcha, incorrect credentials message

    var error = document.querySelector(incorrectCredentialsQuery)
    if (error) {
        return {
            "did_attempt_login": true,
            "error_message": "Login failed. Incorrect credentials identified: " + error.innerHTML
        }
    }

    // TODO: Recaptcha


    // If we can identify the login form, login

    var f = document.querySelectorAll(formQuery)
    if (f) {
        // Override the form's id to enable easier querying
        var fIndex
        for (fIndex = 0; fIndex < f.length; fIndex++) { 
            f[fIndex].id = "login-form"
        }

        var u = document.querySelectorAll(usernameInputQuery)
        if (!u) {
            return {
                "error_message": "Login failed. Email/username input field could not be identified."
            }
        }
        var uIndex
        for (uIndex = 0; uIndex < u.length; uIndex++) { 
            u[uIndex].value = username
        }

        var p = document.querySelectorAll(passwordInputQuery)
        if (!p) {
            return {
                "error_message": "Login failed. Password input field could not be identified."
            }
        }
        var pIndex
        for (pIndex = 0; pIndex < p.length; pIndex++) { 
            p[pIndex].value = password
        }

        var b = document.querySelectorAll(submitButtonQuery)
        if (!b) {
            return {
                "error_message": "Login failed. Submit button could not be identified."
            }
        }
        var bIndex
        for (bIndex = 0; bIndex < b.length; bIndex++) { 
            b[bIndex].click()
        }

        return {
            "did_attempt_login": true
        }
    }

    // If we cannot identify a login form, points value, recaptcha or incorrect credentials
    // We should assume the client is redirecting, and the idle timer should handle moving to retry state
    return {}
}
