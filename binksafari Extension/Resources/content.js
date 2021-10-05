var promoCodeInput = document.querySelector('input#dwfrm_cart_couponCode');
var applyButton = document.querySelector('button#add-coupon');
if (promoCodeInput && applyButton) {
    promoCodeInput.value = "FF0001ABC";
    applyButton.click();
    alert("You have a FatFace promotion code in Bink. We'ven tried applying it to your basket.");
}
