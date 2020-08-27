import Foundation

@objc(CD_MembershipCardStatus)
open class CD_MembershipCardStatus: _CD_MembershipCardStatus {
	// Custom logic goes here.
    
    var status: MembershipCardStatus? {
        guard let state = state else { return nil }
        
        return MembershipCardStatus(rawValue: state)
    }
    
    var formattedReasonCodes: [ReasonCode]? {
        guard let formattedReasonCodes = reasonCodes as? Set<CD_ReasonCode> else { return nil }
        var reasonCodes: [ReasonCode]? = []
        formattedReasonCodes.forEach {
            if let value = $0.value, let reasonCode = ReasonCode(rawValue: value) {
                reasonCodes?.append(reasonCode)
            }
        }
        return reasonCodes
    }
}
