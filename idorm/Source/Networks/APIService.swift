import Foundation

import RxSwift
import RxCocoa
import Alamofire

enum ServerError: Error {
  case unAuthorized
  case forbidden
  case errorMessage
}

enum Encoding {
  case json
  case query
}

class APIService {
  static func load(_ url: URLConvertible, httpMethod: HTTPMethod, body: Parameters?, encoding: Encoding) -> Observable<AFDataResponse<Data>> {
    return Observable.create { observer in
      let header: HTTPHeaders = [
        "Content-Type": "application/json",
        "X-AUTH-TOKEN": TokenManager.loadToken()
      ]
      let request: DataRequest
      if encoding == .json {
        request = AF.request(url, method: httpMethod, parameters: body, encoding: JSONEncoding.default, headers: header)
      } else {
        request = AF.request(url, method: httpMethod, parameters: body, encoding: URLEncoding.queryString, headers: header)
      }
      
      DispatchQueue.global().async {
        request
          .responseData { response in
            DispatchQueue.main.async {
              observer.onNext(response)
            }
          }
        }
      return Disposables.create {
        request.cancel()
      }
    }
  }
  
  static func decode<T: Codable>(_ t: T.Type, data: Data) -> T {
    let decoder = JSONDecoder()
    guard let json = try? decoder.decode(T.self, from: data) else { fatalError("Decoding Error!") }
    return json
  }
}
