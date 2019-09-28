import Foundation

@objc(CD_MembershipPlanAccount)
open class CD_MembershipPlanAccount: _CD_MembershipPlanAccount {
	// Custom logic goes here.
    
    var formattedAddFields: Set<CD_AddField>? {
        return addFields as? Set<CD_AddField>
    }
    
    var formattedAuthFields: Set<CD_AuthoriseField>? {
        return authoriseFields as? Set<CD_AuthoriseField>
    }
    
    var formattedEnrolFields: Set<CD_EnrolField>? {
        return enrolFields as? Set<CD_EnrolField>
    }
    
    var formattedRegistrationFields: Set<CD_RegistrationField>? {
        return registrationFields as? Set<CD_RegistrationField>
    }
}
