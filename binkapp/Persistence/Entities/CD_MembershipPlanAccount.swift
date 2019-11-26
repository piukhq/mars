import Foundation

@objc(CD_MembershipPlanAccount)
open class CD_MembershipPlanAccount: _CD_MembershipPlanAccount {
	// Custom logic goes here.
    
    var formattedAddFields: Set<CD_AddField>? {
        let fields = addFields as? Set<CD_AddField>
        // TODO: This CANNOT be the end solution, we need an identifier from the backend that is localisation free for identifying this field
        return fields?.filter { $0.column?.lowercased() != "barcode" }
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
    
    var formattedPlanDocuments: Set<CD_PlanDocument>? {
        return planDocuments as? Set<CD_PlanDocument>
    }
}
