import Foundation

@objc(CD_MembershipCardBalance)
open class CD_MembershipCardBalance: _CD_MembershipCardBalance {
	// Custom logic goes here.
    
    var formattedBalance: String {
        let prefix = self.prefix ?? ""
        let suffix = self.suffix ?? ""

        let floatBalanceValue = value?.floatValue ?? 0

        if floatBalanceValue.hasDecimals {
             return prefix + String(format: "%.02f", floatBalanceValue) + " " + suffix
        } else {
            return prefix + "\(value?.intValue ?? 0)" + " " + suffix
        }
    }
}
