import Foundation

@objc(CD_EnrolField)
open class CD_EnrolField: _CD_EnrolField {
    // Custom logic goes here.
    
    var fieldInputType: FieldInputType? {
        guard let rawType = type, let type = FieldInputType(rawValue: rawType.intValue) else { return nil }
        return type
    }
}
