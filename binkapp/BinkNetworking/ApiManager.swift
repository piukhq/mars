//
//  BaseRequest.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import Keys
import Alamofire

enum RequestURL {
    case login
    case register
    case facebook
    case logout
    case renew
    case preferences
    case forgotPassword
    case membershipPlans
    case membershipCards
    case membershipCard(cardId: String)
    case paymentCards
    case paymentCard(cardId: String)
    case linkMembershipCardToPaymentCard(membershipCardId: String, paymentCardId: String)
    
    var value: String {
        switch self {
        case .login:
            return "/users/login"
        case .register:
            return "/users/register"
        case .facebook:
            return "/users/auth/facebook"
        case .logout:
            return "/users/me/logout"
        case .renew:
            return "/users/renew_token"
        case .preferences:
            return "/users/me/settings"
        case .forgotPassword:
            return "/users/forgotten_password"
        case .membershipPlans:
            return "/ubiquity/membership_plans"
        case .membershipCards:
            return "/ubiquity/membership_cards"
        case .membershipCard(let cardId):
            return "/ubiquity/membership_card/\(cardId)"
        case .paymentCards:
            return "/ubiquity/payment_cards"
        case .paymentCard(let cardId):
            return "/ubiquity/payment_card/\(cardId)"
        case .linkMembershipCardToPaymentCard(let membershipCardId, let paymentCardId):
            return "/ubiquity/membership_card/\(membershipCardId)/payment_card/\(paymentCardId)"
        }
    }
    
    var authRequired: Bool {
        switch self {
        case .register, .login, .renew:
            return false
        default:
            return true
        }
    }
}

enum RequestHTTPMethod {
    case get
    case post
    case put
    case delete
    case patch
    
    var value: HTTPMethod {
        switch self {
        case .get: return .get
        case .post: return .post
        case .put: return .put
        case .delete: return .delete
        case .patch: return .patch
        }
    }
}

class ApiManager {
    private let reachabilityManager = NetworkReachabilityManager()
    private let session: Session

    enum NetworkStrength: String {
        case wifi
        case cellular
        case unknown
    }
    
    struct Certificates {
      static let bink = Certificates.certificate(filename: "bink-com")
      
      private static func certificate(filename: String) -> SecCertificate {
        let filePath = Bundle.main.path(forResource: filename, ofType: "der")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        let certificate = SecCertificateCreateWithData(nil, data as CFData)!
        
        return certificate
      }
    }

    var networkIsReachable: Bool {
        return reachabilityManager?.isReachable ?? false
    }

    var networkStrength: NetworkStrength {
        if reachabilityManager?.isReachableOnCellular == true {
            return .cellular
        }
        if reachabilityManager?.isReachableOnEthernetOrWiFi == true {
            return .wifi
        }
        return .unknown
    }
    
    init() {
        let evaluators = [
          "api.bink.com":
            PinnedCertificatesTrustEvaluator(certificates: [
              Certificates.bink
            ])
        ]
        
        session = Session(serverTrustManager: ServerTrustManager(allHostsMustBeEvaluated: false, evaluators: evaluators))
    }
    
    func doRequest<Resp: Decodable>(url: RequestURL, httpMethod: RequestHTTPMethod, headers: [String: String]? = nil, isUserDriven: Bool, onSuccess: @escaping (Resp) -> (), onError: @escaping (Error?) -> () = { _ in }) {

        if !networkIsReachable && isUserDriven {
            NotificationCenter.default.post(name: .noInternetConnection, object: nil)
            onError(nil)
            return
        }
        
        let authRequired = url.authRequired
        let headerDict = headers != nil ? headers! : getHeader(authRequired: authRequired)
        let requestHeaders = HTTPHeaders(headerDict)
        
        session.request(APIConstants.baseURLString + "\(url.value)", method: httpMethod.value, parameters: nil, encoding: JSONEncoding.default, headers: requestHeaders).responseJSON { (response) in
            self.responseHandler(response: response, authRequired: authRequired, onSuccess: onSuccess, onError: onError)
        }
    }

    func doRequest<Resp, T: Encodable>(url: RequestURL, httpMethod: RequestHTTPMethod, headers: [String: String]? = nil, parameters: T, isUserDriven: Bool, onSuccess: @escaping (Resp) -> (), onError: @escaping (Error?) -> () = { _ in }) where Resp: Decodable {

        if !networkIsReachable && isUserDriven {
            NotificationCenter.default.post(name: .noInternetConnection, object: nil)
            onError(nil)
            return
        }
        
        let authRequired = url.authRequired
        let headerDict = headers != nil ? headers! : getHeader(authRequired: authRequired)
        let requestHeaders = HTTPHeaders(headerDict)
                
        session.request(APIConstants.baseURLString + "\(url.value)", method: httpMethod.value, parameters: parameters, encoder: JSONParameterEncoder.default, headers: requestHeaders).responseJSON { (response) in
            self.responseHandler(response: response, authRequired: authRequired, onSuccess: onSuccess, onError: onError)
        }
    }

    func getImage(fromUrlString urlString: String, completion: @escaping (UIImage?, Error?) -> Void) {
        session.request(urlString).responseImage { response in
            if let error = response.error {
                completion(nil, error)
                return
            }

            do {
                let image = try response.result.get()
                completion(image, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    private func responseHandler<Resp: Decodable>(response: AFDataResponse <Any>, authRequired: Bool, onSuccess: (Resp) -> (), onError: (Error) -> ()) {
        
        if case let .failure(error) = response.result, error.isServerTrustEvaluationError {
            // SSL/TLS Pinning Failure
            NotificationCenter.default.post(name: .didFailServerTrustEvaluation, object: nil)
            onError(error)
            return
        }
        
        guard let data = response.data else {
            return
        }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys

            do {
                let statusCode = response.response?.statusCode ?? 0
                if statusCode == 200 || statusCode == 201 {
                    let models = try decoder.decode(Resp.self, from: data)
                    onSuccess(models)
                } else if statusCode == 401 && authRequired {
                    /*
                     If the endpoint expects an authorisation token,
                     ensure that we aggressively respond in app to a 401.
                     */
                    NotificationCenter.default.post(name: .didLogout, object: nil)
                } else if statusCode == 400 {
                    let errorArray = try decoder.decode([String].self, from: data)
                    let customError = CustomError(errorMessage: errorArray.first ?? "", statusCode: statusCode)
                    onError(customError)
                } else if let error = response.error {
                    print(error)
                    onError(error)
                } else {
                    print("something went wrong, statusCode: \(statusCode)")
                    let error = NSError(domain: "", code: statusCode, userInfo: nil) as Error
                    onError(error)
                }
            } catch (let error) {
                print("decoding error: \(error)")
                onError(error)
            }
    }
    
    typealias NoCodableResponse = (_ success: Bool, _ error: Error?) -> ()
    
    func doRequestWithNoResponse(url: RequestURL, httpMethod: RequestHTTPMethod, parameters: [String: Any], isUserDriven: Bool, completion: NoCodableResponse?) {

        if !networkIsReachable && isUserDriven {
            NotificationCenter.default.post(name: .noInternetConnection, object: nil)
            return
        }

        let authRequired = url.authRequired
        let requestHeaders = HTTPHeaders(getHeader(authRequired: authRequired))
        
        session.request(APIConstants.baseURLString + "\(url.value)", method: httpMethod.value, parameters: parameters, encoding: JSONEncoding.default, headers: requestHeaders).responseJSON { response in
            
            let statusCode = response.response?.statusCode ?? 0
            if statusCode == 200 || statusCode == 201 || statusCode == 204 {
                completion?(true, nil)
            } else if statusCode == 401 && authRequired {
                /*
                 If the endpoint expects an authorisation token,
                 ensure that we aggressively respond in app to a 401.
                 */
                NotificationCenter.default.post(name: .didLogout, object: nil)
            } else if let error = response.error {
                print(error)
                completion?(false, error)
            } else {
                print("something went wrong, statusCode: \(statusCode)")
                completion?(false, NSError(domain: "", code: statusCode, userInfo: nil) as Error)
            }
        }
    }
}

private extension ApiManager {
    private func getHeader(authRequired: Bool) -> [String: String] {
        var header = ["Content-Type": "application/json;v=1.1"]
        
        if authRequired {
            guard let token = Current.userManager.currentToken else { return header }
            header["Authorization"] = "Token " + token
        }

        return header
    }
}

