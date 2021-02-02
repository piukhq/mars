// Value injection

var username = "%@"
var password = "%@"

// ** QUERY STRINGS - DELETE AS NECESSARY IF MERCHANT DOES NOT REQUIRE **

// Form selector queries

var formQuery = "form#login-form"
var usernameInputQuery = "form#login-form input[type=email]"
var passwordInputQuery = "form#login-form input[type=password]"
var submitButtonQuery = "form#login-form button[type=submit]"


// Recaptcha selector queries

// Override default values if the merchant is known to display recaptcha, and the value are different
// Otherwise, these are best-guesses based on known values

var recaptchaAnchorInvalidQuery = "re-captcha[class*=-invalid]"
var recaptchaAnchorValidQuery = "re-captcha[class*=-valid]"
var recaptchaAnchorContainerQuery = "re-captcha div"
var recaptchaChallengeQuery = ""


// Error state selector queries

var invalidCredentialQuery = ""


// Config

var formForcedValidationClassName = ""
var usernameForcedValidationClassName = ""
var passwordForcedValidationClassName = ""


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


    // ** RE-CAPTCHA


    // Can we detect an invalid recaptcha anchor?
    // If so, display a curtain and tell the client to present to the user.
    var rInvalid = document.querySelector(recaptchaAnchorInvalidQuery)

    if (rInvalid) {
        var node = document.createElement('div')
        node.style.backgroundColor = 'white'
        node.style.position = 'fixed'
        node.style.top = '0'
        node.style.bottom = '0'
        node.style.left = '0'
        node.style.right = '0'
        node.style.zIndex = '999'

        let container = document.querySelector(recaptchaAnchorContainerQuery)
        container.style.position = 'relative'
        container.style.zIndex = '1000'
        
        rInvalid.appendChild(node)

        return {
            "success": false,
            "user_action_required": true
        }
    }

    // Can we detect a valid recaptcha anchor?
    var rValid = document.querySelector(recaptchaAnchorValidQuery)
    // TODO: Can we do anything here?


    // ** FORM VALIDATION **


    // TODO: Logic for rendering the form as valid if required


    // ** SUBMIT **


    var b = document.querySelector(submitButtonQuery)

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