import Foundation

@objc(CD_MembershipPlan)
open class CD_MembershipPlan: _CD_MembershipPlan {
	// Custom logic goes here.
    
    func image(of type: ImageType) -> CD_MembershipPlanImage? {
        return images.filtered(using: NSPredicate(format: "type == %@", NSNumber(integerLiteral: type.rawValue))).first as? CD_MembershipPlanImage
    }
    
    func firstIconImage() -> CD_MembershipPlanImage? {
        return images.filtered(using: NSPredicate(format: "type == %@", NSNumber(integerLiteral: 3))).first as? CD_MembershipPlanImage
    }
    
    var imagesSet: Set<CD_MembershipPlanImage>? {
        return images as? Set<CD_MembershipPlanImage>
    }

    var isPLR: Bool {
        return featureSet?.hasVouchers?.boolValue ?? false
    }

    var canAddCard: Bool {
        guard let linkingSupport = featureSet?.formattedLinkingSupport else { return false }
        let linkingSupportTypes = linkingSupport.map { LinkingSupportType(rawValue: $0.value ?? "") }
        return linkingSupportTypes.contains(.add)
    }

    func dynamicContentValue(forColumn column: DynamicContentColumn) -> String? {
        let columns = dynamicContent as? Set<CD_PlanDynamicContent>
        return columns?.first(where: { $0.column == column.rawValue })?.value
    }

    enum DynamicContentColumn: String {
        case voucherStampsExpiredDetail = "Voucher_Stamps_Expired_Detail"
        case voucherStampsRedeemedDetail = "Voucher_Stamps_Redeemed_Detail"
        case voucherStampsInProgressDetail = "Voucher_Stamps_Inprogress_Detail"
        case voucherStampsIssuedDetail = "Voucher_Stamps_Issued_Detail"
    }
}
