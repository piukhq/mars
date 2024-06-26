import Foundation

@objc(CD_FeatureSet)
open class CD_FeatureSet: _CD_FeatureSet {
    // Custom logic goes here.
    
    enum PlanCardType: Int, Codable {
        case store
        case view
        case link
        case comingSoon
        
        var walletPromptSectionIndex: Int? {
            let order: [PlanCardType] = [.link, .view, .store]
            return order.firstIndex(of: self)
        }
    }
    
    var planCardType: PlanCardType? {
        guard let cardType = cardType?.intValue else { return nil }
        return PlanCardType(rawValue: cardType)
    }
    
    var formattedLinkingSupport: [CD_LinkingSupport] {
        return linkingSupport.allObjects as? [CD_LinkingSupport] ?? []
    }
    
    func hasLinkingSupportForType(_ type: LinkingSupportType) -> Bool {
        return formattedLinkingSupport.contains { $0.value == type.rawValue }
    }
}
