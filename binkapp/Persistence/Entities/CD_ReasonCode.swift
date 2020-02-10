import Foundation

@objc(CD_ReasonCode)
open class CD_ReasonCode: _CD_ReasonCode {
	// Custom logic goes here.
    
    public enum ReasonCode: String, Codable {
        case X000
        case X101
        case X102
        case X103
        case X104
        case X105
        case X200
        case X201
        case X202
        case X301
        case X302
        case X303
        case X304
    }
    
    var code: ReasonCode? {
        guard let value = value else { return nil }
        
        return ReasonCode(rawValue: value)
    }
}
