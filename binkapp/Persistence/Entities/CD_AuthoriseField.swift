import Foundation

@objc(CD_AuthoriseField)
open class CD_AuthoriseField: _CD_AuthoriseField {
    // Custom logic goes here.
    
    var fieldInputType: InputType? {
        guard let rawType = type, let type = InputType(rawValue: rawType.intValue) else { return nil }
        return type
    }
    
    var choicesArray: [String]? {
        guard let formatted = choices.allObjects as? [CD_FieldChoice] else { return  nil }
        return formatted.compactMap { $0.value }
    }
}
