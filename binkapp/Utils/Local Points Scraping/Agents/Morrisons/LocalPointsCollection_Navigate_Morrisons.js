var username = "%@"
var password = "%@"
var configurator = "%@"

var formQuery = "form"
var usernameInputQuery = "form#login-form input#email"
var passwordInputQuery = "form#login-form input[type=password]"
var submitButtonQuery = "form#login-form button[type=submit]"

var recaptchaAnchorInvalidQuery = "re-captcha[class*=-invalid]"
var recaptchaAnchorValidQuery = "re-captcha[class*=-valid]"
var recaptchaAnchorContainerQuery = "re-captcha div"
var recaptchaMessage = "You must resolve the CAPTCHA challenge to see your updated Morrisons balance in Bink.\n\n"

var pointsValueQuery = "h1[class='g-h1 g-h1_large']"

var incorrectCredentialsQuery = ".text-danger"

handleNavigation()

function handleNavigation() {

    // If we can identify the points value, scrape

    var pts = document.querySelector(pointsValueQuery)
    if (pts && pts.innerHTML !== "") {
        var num = pts.innerHTML.match(/\d+/);
        return {
            "success": true,
            "points": num[0]
        }
    }


    // If we can't identify a points value, can we identify one of the following:
    // Recaptcha, incorrect credentials message

    var error = document.querySelector(incorrectCredentialsQuery)
    if (error && error.innerHTML !== "") {
        return {
            "did_attempt_login": true,
            "error_message": "Login failed. Incorrect credentials identified: " + error.innerHTML
        }
    }


    // If we can identify a valid or invalid reCaptccha, handle it here

    var rValid = document.querySelector(recaptchaAnchorValidQuery)
    if (rValid && configurator !== "userActionComplete") {
        return {
            "user_action_complete": true
        }
    }

    if (configurator == "userActionRequired") {
        return {}
    }

    var f = document.querySelector(formQuery)
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

        var message = document.createElement('h2')
        message.innerText = recaptchaMessage
        message.style.position = 'relative'
        message.style.zIndex = '1000'

        rInvalid.appendChild(node)
        rInvalid.insertBefore(message, container)

        f.scrollIntoView()

        return {
            "user_action_required": true
        }
    }


    // If we can identify the login form, login

    if (f) {
        // Override the form's id to enable easier querying
        f.id = "login-form"

        var u = document.querySelector(usernameInputQuery)
        if (!u) {
            return {
                "error_message": "Login failed. Email/username input field could not be identified."
            }
        }

        var p = document.querySelector(passwordInputQuery)
        if (!p) {
            return {
                "error_message": "Login failed. Password input field could not be identified."
            }
        }

        var nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, "value").set;
        nativeInputValueSetter.call(u, username);
        nativeInputValueSetter.call(p, password);

        var valueSetterEvent = new Event('input', { bubbles: true });
        u.dispatchEvent(valueSetterEvent);
        p.dispatchEvent(valueSetterEvent);

        var b = document.querySelector(submitButtonQuery)
        if (!b) {
            return {
                "error_message": "Login failed. Submit button could not be identified."
            }
        }
        b.click()

        return {
            "did_attempt_login": true
        }
    }

    // If we cannot identify a login form, points value, recaptcha or incorrect credentials
    // We should assume the client is redirecting, and the idle timer should handle moving to retry state
    return {}
}
