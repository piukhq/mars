import Foundation

@objc(CD_PaymentCard)
open class CD_PaymentCard: _CD_PaymentCard {
    // Custom logic goes here.
    
    var imagesArray: [CD_MembershipCardImage] {
        return (images.allObjects as! [CD_MembershipCardImage])
    }
}
