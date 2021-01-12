var queryString = "%@"

performPointsScraping()

// tesco = .pointvalue
// heathrow = .total-points
// waterstones = .plus-balance-row strong // will need client logic to strip " stamps" text

function performPointsScraping() {
    const p = document.querySelector('.plus-balance-row strong')

    if (p.innerHTML) {
        return {
            "points": p.innerHTML
        }
    } else if (p.innerText) {
        return {
            "points": p.innerText
        }
    } else {
        return {
            "error_message": "Could not scrape points value."
        }
    }
}
