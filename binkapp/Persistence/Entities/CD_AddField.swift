import Foundation

@objc(CD_AddField)
open class CD_AddField: _CD_AddField {
	// Custom logic goes here.
    
    var fieldInputType: FieldInputType? {
        guard let rawType = type, let type = FieldInputType(rawValue: rawType.intValue) else { return nil }
        return type
    }
    
    var choicesArray: [String]? {
        return choices.allObjects as? [String]
    }
}
