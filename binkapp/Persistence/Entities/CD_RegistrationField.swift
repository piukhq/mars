import Foundation

@objc(CD_RegistrationField)
open class CD_RegistrationField: _CD_RegistrationField {
    // Custom logic goes here.
    
    var fieldInputType: InputType? {
        guard let rawType = type, let type = InputType(rawValue: rawType.intValue) else { return nil }
        return type
    }
}
