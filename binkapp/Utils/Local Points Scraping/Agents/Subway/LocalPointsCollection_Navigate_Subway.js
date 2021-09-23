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

var incorrectCredentialsQuery = "div#errorModal"

//r = document.querySelector('div .recaptcha-submit .g-recaptcha')

handleNavigation()

function handleNavigation() {
    var pts = document.querySelector(pointsValueQuery)
    if (pts) {
        return {
            "points": pts.innerText
        }
    }

    var error = document.querySelector(incorrectCredentialsQuery)
    if (error && error.style.display === "block") {
        var errorMessage = document.querySelector('div#errorModal p')
        return {
            "did_attempt_login": true,
            "error_message": "Login failed. Incorrect credentials identified: " + errorMessage.innerText
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
            // The user needs to complete recaptcha - set the screen up for this

            var navBarButton = document.querySelector('button.navbar-toggle')
            var signInButton = document.querySelector('a[title="Sign in"]')
            if (navBarButton && signInButton) {
                navBarButton.click()
                signInButton.click()

                var node = document.createElement('div')
                node.style.backgroundColor = 'white'
                node.style.opacity = 1.0
                node.style.position = 'fixed'
                node.style.top = '0'
                node.style.bottom = '0'
                node.style.left = '0'
                node.style.right = '0'
                node.style.zIndex = '-1'

                var loginModal = document.querySelector('#loginModal')
                loginModal.appendChild(node)

                var modalContent = loginModal.querySelector('.modal-content')
                modalContent.style.boxShadow = "0px 0px 0px white"

                var header = modalContent.querySelector('.modal-header')
                var fields = modalContent.querySelectorAll('.form-group')
                var options = modalContent.querySelector('.form-options')
                var submitButton = modalContent.querySelector('recaptcha-submit button')

                header.hidden = true
                options.hidden = true

                for (i = 0; i < fields.length; ++i) {
                    fields[i].hidden = true
                }

                var message = document.createElement('h2')
                message.innerText = recaptchaMessage
                message.style.position = 'relative'
                message.style.zIndex = '1000'

                modalBody = modalContent.querySelector('.modal-body')
                modalContent.insertBefore(message, modalBody)

                return {
                    "user_action_required": true
                }
            }
        }
    }

    // If we cannot identify a login form, points value, recaptcha or incorrect credentials
    // We should assume the client is redirecting, and the idle timer should handle moving to retry state
    return {}
}
