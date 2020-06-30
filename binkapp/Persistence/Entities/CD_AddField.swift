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
        let sortedChoices = formatted.sorted(by: { $0.id < $1.id })
        return sortedChoices.compactMap { $0.value }
    }
    
    var fieldCommonName: FieldCommonName? {
        guard let rawType = commonName, let type = FieldCommonName(rawValue: rawType) else { return nil }
        return type
    }
    
    func alternative(matching commonName: FieldCommonName) -> CD_AddField? {
        guard let alternatives = alternatives else { return nil }
        
        // Does this field's plan have an add field with the specified common name?
        guard let matchingField = planAccount?.formattedAddFields()?.first(where: { $0.commonName == commonName.rawValue }), let matchingFieldColumn = matchingField.column else { return nil }
        
        // If so, does that field's column name appear in this fields alternatives?
        return alternatives.contains(matchingFieldColumn) ? matchingField : nil
    }
}
