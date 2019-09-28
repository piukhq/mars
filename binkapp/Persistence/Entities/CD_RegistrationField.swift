import Foundation

@objc(CD_RegistrationField)
open class CD_RegistrationField: _CD_RegistrationField {
    // Custom logic goes here.
    
    var fieldInputType: FieldInputType? {
        guard let rawType = type, let type = FieldInputType(rawValue: rawType.intValue) else { return nil }
        return type
    }
}
