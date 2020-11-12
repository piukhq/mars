import Foundation

@objc(CD_MembershipPlanAccount)
open class CD_MembershipPlanAccount: _CD_MembershipPlanAccount {
	// Custom logic goes here.

    func formattedAddFields(omitting omittedFields: [FieldCommonName]? = nil) -> Set<CD_AddField>? {
        let formattedAddFields = addFields as? Set<CD_AddField>
        guard let omittedFields = omittedFields else {
            return formattedAddFields
        }
        guard let fields = formattedAddFields else { return nil }
        return fields.filter {
            guard let commonName = $0.fieldCommonName else { return true } // If the field has no common name, we should include it to be safe
            return !omittedFields.contains(commonName)
        }
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
    
    var hasEnrolFields: Bool {
        return enrolFields.isEmpty
    }
}
