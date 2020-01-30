import Foundation

@objc(CD_AddField)
open class CD_AddField: _CD_AddField {
	// Custom logic goes here.
    
    var fieldInputType: InputType? {
        guard let rawType = type, let type = InputType(rawValue: rawType.intValue) else { return nil }
        return type
    }
    
    var choicesArray: [String]? {
        guard let formatted = choices.allObjects as? [CD_FieldChoice] else { return  nil }
        return formatted.compactMap { $0.value }
    }
    
    var fieldCommonName: FieldCommonName? {
        guard let rawType = commonName, let type = FieldCommonName(rawValue: rawType) else { return nil }
        return type
    }
}
