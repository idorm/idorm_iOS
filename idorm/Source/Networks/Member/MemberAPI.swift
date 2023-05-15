import UIKit

import RxSwift
import RxMoya
import Moya

enum MemberAPI {
  case login(email: String, password: String, fcmToken: String)
  case register(email: String, password: String, nickname: String)
  case changePassword_Login(password: String)
  case changePassword_Logout(email: String, password: String)
  case changeNickname(nickname: String)
  case retrieveMember
  case withdrawal
  case saveProfilePhoto(image: UIImage)
  case deleteProfileImage
  case logoutFCM
  case updateFCM(String)
}

extension MemberAPI: TargetType, BaseAPI {
  static let provider = MoyaProvider<MemberAPI>()
  
  var baseURL: URL { getBaseURL() }
  var path: String { getPath() }
  var method: Moya.Method { getMethod() }
  var task: Task { getTask() }
  
  var headers: [String : String]? {
    switch self {
    case .login(_, _, let fcmToken):
      return [
        "fcm-token": fcmToken,
        "Content-Type": "application/json"
      ]
    case .updateFCM(let fcm):
      return [
        "fcm-token": fcm,
        "Content-Type": "application/json",
        "X-AUTH-TOKEN": UserStorage.shared.token
      ]
    default:
      return getJsonHeader()
    }
  }
}
