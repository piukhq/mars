import Foundation

@objc(CD_MembershipCardStatus)
open class CD_MembershipCardStatus: _CD_MembershipCardStatus {
	// Custom logic goes here.
    
    var status: MembershipCardStatus? {
        guard let state = state else { return nil }
        
        return MembershipCardStatus(rawValue: state)
    }
    
    var formattedReasonCodes: Set<CD_ReasonCode>? {
        return reasonCodes as? Set<CD_ReasonCode>
    }
}
