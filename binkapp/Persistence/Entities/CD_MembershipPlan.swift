import Foundation

@objc(CD_MembershipPlan)
open class CD_MembershipPlan: _CD_MembershipPlan {
	// Custom logic goes here.
    
    func image(of type: Int) -> CD_MembershipPlanImage? {
        return images.filtered(using: NSPredicate(format: "type == %@", NSNumber(integerLiteral: type))).first as? CD_MembershipPlanImage
    }
    
    func firstIconImage() -> CD_MembershipPlanImage? {
        return images.filtered(using: NSPredicate(format: "type == %@", NSNumber(integerLiteral: 3))).first as? CD_MembershipPlanImage
    }
    
    var imagesSet: Set<CD_MembershipPlanImage>? {
        return images as? Set<CD_MembershipPlanImage>
    }
}
