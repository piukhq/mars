import Foundation

@objc(CD_MembershipPlan)
open class CD_MembershipPlan: _CD_MembershipPlan {
	// Custom logic goes here.
    
    func image(of type: Int) -> CD_MembershipCardImage? {
        return images.filtered(using: NSPredicate(format: "type == %@", String(type))).first as? CD_MembershipCardImage
    }
    
    func firstIconImage() -> CD_MembershipCardImage? {
        return images.filtered(using: NSPredicate(format: "type == %@", NSNumber(integerLiteral: 3))).first as? CD_MembershipCardImage
    }
}
