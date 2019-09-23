import Foundation

@objc(CD_MembershipCardStatus)
open class CD_MembershipCardStatus: _CD_MembershipCardStatus {
	// Custom logic goes here.
    
    enum MembershipCardStatus: String, Codable {
        case authorised
        case unauthorised
        case pending
        case failed
    }
    
    var status: MembershipCardStatus? {
        guard let state = state else { return nil }
        
        return MembershipCardStatus(rawValue: state)
    }
}
