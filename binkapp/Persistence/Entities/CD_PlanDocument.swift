import Foundation

@objc(CD_PlanDocument)
open class CD_PlanDocument: _CD_PlanDocument {
	// Custom logic goes here.
    
    var formattedDisplay: [CD_PlanDocumentDisplay] {
        return display.allObjects as? [CD_PlanDocumentDisplay] ?? []
    }
}
