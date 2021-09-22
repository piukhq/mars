var username = "%@"
var password = "%@"
var configurator = "%@"

var usernameInputQuery = "input#sign-email"
var passwordInputQuery = "input#sign-password"
var submitButtonQuery = "button[name=\"Login\"][style=\"display: block;\"]"

var recaptchaAnchorQuery = "div .recaptcha-submit .g-recaptcha"
var recaptchaAnchorValidQuery = submitButtonQuery
var recaptchaMessage = "You must resolve the CAPTCHA challenge to see your updated Subway balance in Bink.\n\n"

var pointsValueQuery = ".green-btn-balance"

var incorrectCredentialsQuery = ""

//r = document.querySelector('div .recaptcha-submit .g-recaptcha')

handleNavigation()

function handleNavigation() {
    var pts = document.querySelector(pointsValueQuery)
    if (pts) {
        return {
            "points": pts.innerText
        }
    }

    var rValid = document.querySelector(recaptchaAnchorValidQuery)
    if (rValid && configurator !== "userActionComplete") {
        return {
            "user_action_complete": true
        }
    }

    if (configurator == "userActionRequired") {
        return {}
    }

    // If we can't identify points, can we identify the login form fields?
    var u = document.querySelector(usernameInputQuery)
    var p = document.querySelector(passwordInputQuery)

    if (u && p) {
        // Username and password fields detected
        // Is the submit button enabled (i.e. is recaptcha completed)?
        var b = document.querySelector(submitButtonQuery)
        if (b) {
            var nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, "value").set
            nativeInputValueSetter.call(u, username)
            nativeInputValueSetter.call(p, password)

            var valueSetterEvent = new Event('input', { bubbles: true })
            u.dispatchEvent(valueSetterEvent)
            p.dispatchEvent(valueSetterEvent)

            b.click()

            return {
                "did_attempt_login": true
            }
        } else {
            // The user needs to complete recaptcha
            return {
                "user_action_required": true
            }
        }
    }


    // If we can't identify a points value, can we identify one of the following:
    // Recaptcha, incorrect credentials message

    // var error = document.querySelector(incorrectCredentialsQuery)
    // if (error && error.innerHTML !== "") {
    //     return {
    //         "did_attempt_login": true,
    //         "error_message": "Login failed. Incorrect credentials identified: " + error.innerHTML
    //     }
    // }

    // if (rInvalid) {
    //     var node = document.createElement('div')
    //     node.style.backgroundColor = 'white'
    //     node.style.position = 'fixed'
    //     node.style.top = '0'
    //     node.style.bottom = '0'
    //     node.style.left = '0'
    //     node.style.right = '0'
    //     node.style.zIndex = '999'

    //     let container = document.querySelector(recaptchaAnchorContainerQuery)
    //     container.style.position = 'relative'
    //     container.style.zIndex = '1000'

    //     var message = document.createElement('h2')
    //     message.innerText = recaptchaMessage
    //     message.style.position = 'relative'
    //     message.style.zIndex = '1000'

    //     rInvalid.appendChild(node)
    //     rInvalid.insertBefore(message, container)

    //     f.scrollIntoView()

    //     return {
    //         "user_action_required": true
    //     }
    // }

    // If we cannot identify a login form, points value, recaptcha or incorrect credentials
    // We should assume the client is redirecting, and the idle timer should handle moving to retry state
    return {}
}
