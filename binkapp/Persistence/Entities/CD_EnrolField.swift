import Foundation

@objc(CD_EnrolField)
open class CD_EnrolField: _CD_EnrolField {
    // Custom logic goes here.
    
    var fieldInputType: InputType? {
        guard let rawType = type, let type = InputType(rawValue: rawType.intValue) else { return nil }
        return type
    }
}
