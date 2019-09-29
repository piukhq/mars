import Foundation

@objc(CD_MembershipTransaction)
open class CD_MembershipTransaction: _CD_MembershipTransaction {
	// Custom logic goes here.
    var formattedAmounts: Set<CD_MembershipCardAmount>? {
        return amounts as? Set<CD_MembershipCardAmount>
    }
}
