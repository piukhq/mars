import UIKit

@objc(CD_MembershipPlan)
open class CD_MembershipPlan: _CD_MembershipPlan {
    func image(ofType type: ImageType) -> CD_MembershipPlanImage? {
        return images.filtered(using: NSPredicate(format: "type == %@", NSNumber(value: type.rawValue))).first as? CD_MembershipPlanImage
    }
    
    func firstIconImage() -> CD_MembershipPlanImage? {
        return images.filtered(using: NSPredicate(format: "type == %@", NSNumber(value: 3))).first as? CD_MembershipPlanImage
    }
    
    var imagesSet: Set<CD_MembershipPlanImage>? {
        return images as? Set<CD_MembershipPlanImage>
    }
    
    var isPLL: Bool {
        return featureSet?.planCardType == .link
    }

    var isPLR: Bool {
        return featureSet?.hasVouchers?.boolValue ?? false || hasVouchers?.boolValue ?? false
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
    
    var secondaryBrandColor: UIColor {
        if let secondaryColor = card?.secondaryColour {
            return UIColor(hexString: secondaryColor)
        } else {
            var secondaryColor: UIColor?
            let primaryColor = UIColor(hexString: card?.colour ?? "")
            if primaryColor.isLight() {
                secondaryColor = primaryColor.darker(by: 30)
            } else {
                secondaryColor = primaryColor.lighter(by: 30)
            }
            return secondaryColor ?? .darkGray
        }
    }

    var isPointsScrapable: Bool {
        let planId = Int(id)
        return Current.pointsScrapingManager.planIdIsWebScrapable(planId)
    }

    enum DynamicContentColumn: String {
        case voucherStampsExpiredDetail = "Voucher_Expired_Detail"
        case voucherStampsRedeemedDetail = "Voucher_Redeemed_Detail"
        case voucherStampsInProgressDetail = "Voucher_Inprogress_Detail"
        case voucherStampsIssuedDetail = "Voucher_Issued_Detail"
        case voucherStampsCancelledDetail = "Voucher_Cancelled_Detail"
    }
}
