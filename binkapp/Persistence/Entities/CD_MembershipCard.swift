import Foundation

@objc(CD_MembershipCard)
open class CD_MembershipCard: _CD_MembershipCard {
	// Custom logic goes here.
    var formattedBalances: Set<CD_MembershipCardBalance>? {
        return balances as? Set<CD_MembershipCardBalance>
    }
    
    var formattedTransactions: Set<CD_MembershipTransaction>? {
        return transactions as? Set<CD_MembershipTransaction>
    }
}
