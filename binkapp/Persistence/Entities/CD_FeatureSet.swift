import Foundation

@objc(CD_FeatureSet)
open class CD_FeatureSet: _CD_FeatureSet {
	// Custom logic goes here.
    
    enum PlanCardType: Int {
        case store
        case view
        case link
    }
    
    var planCardType: PlanCardType? {
        guard let cardType = cardType?.intValue else { return nil }
        return PlanCardType(rawValue: cardType)
    }
    
    var formattedLinkingSupport: [CD_LinkingSupport] {
        return linkingSupport.allObjects as! [CD_LinkingSupport]
    }
}
