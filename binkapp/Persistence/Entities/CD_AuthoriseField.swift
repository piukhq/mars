import Foundation

@objc(CD_AuthoriseField)
open class CD_AuthoriseField: _CD_AuthoriseField {
    // Custom logic goes here.
    
    var fieldInputType: FieldInputType? {
        guard let rawType = type, let type = FieldInputType(rawValue: rawType.intValue) else { return nil }
        return type
    }
    
    var choicesArray: [String]? {
        return choices.allObjects as? [String]
    }
}
