var queryString = "%@"

performPointsScraping()

// tesco = .pointvalue
// heathrow = .total-points

function performPointsScraping() {
    const p = document.querySelector('.total-points')

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
