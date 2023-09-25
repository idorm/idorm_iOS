import UIKit

import RxSwift
import RxMoya
import Moya

enum MemberAPI {
  /**
   로그인
   
   - 헤더에 토큰을 담아 응답합니다
   */
  case login(email: String, password: String)
  
  /**
   비밀번호 변경
   
   - 이메일 API 에서 /verifyCode/password/{email} 인증 후 5분동안 비밀번호 변경 가능합니다.
   - 비밀번호 변경용 이메일이 인증되지 않았다면 UNAUTHORIZED_EMAIL(401)을 던집니다.
   - 비밀번호 변경용 이메일 인증 성공 시점으로 5분 후에 해당 API 요청 시 EXPIRED_CODE(401)를 던집니다.
   */
  case updatePassword(email: String, password: String)
  
  /**
   회원 가입
   
   - 회원 가입은 이메일 인증이 완료된 후 가능합니다.
   */
  case register(email: String, password: String, nickname: String)
  
  /**
   회원 단건 조회
   */
  case getUser
  
  /**
   회원 탈퇴
   */
  case deleteUser
  
  /**
   로그아웃 / FCM 제거 용도
   
   - FCM 토큰 관리를 위해 로그아웃 시 해당 API를 호출해주세요.
   */
  case logout
  
  /**
   로그인 시 FCM 토큰 업데이트
   
   - 앱을 실행할 때 로그인이 되어 있으면 타임스탬프 갱신을 위한 FCM 토큰을 서버에 전송해주세요.
   - FCM 토큰이 만료되었을 때 FCM 토큰을 업데이트해주세요.
   */
  case updateFCM
  
  /**
   닉네임 변경
   
   - 기존 닉네임과 동일 닉네임으로 변경 요청 시 DUPLICATE_SAME_NICKNAME(409)를 던집니다.
   - 요청한 닉네임을 가진 다른 회원 존재 시 409(DUPLICATE_NICKNAME)를 던집니다.
   - 30일 이내로 닉네임 변경 기록이 있으면 409(CANNOT_UPDATE_NICKNAME)를 던집니다.
   - 닉네임 형식은 영문, 숫자, 또는 한글의 조합 / 2-8 글자 입니다.
   */
  case updateNickname(nickname: String)
  
  /**
   프로필 사진 저장
   
   - 기존 프로필 사진을 삭제 후 새로운 프로필 사진을 저장합니다.
   */
  case createProfilePhoto(image: UIImage)
  
  /**
   프로필 사진 삭제
   
   - 삭제할 사진이 없다면 404(FILE_NOT_FOUND)를 던집니다.
   */
  case deleteProfilePhoto
}

extension MemberAPI: BaseTargetType {
  static let provider = MoyaProvider<MemberAPI>()
  
  var baseURL: URL {
    self.getBaseURL()
  }
  
  var path: String {
    self.getPath()
  }
  
  var method: Moya.Method {
    self.getMethod()
  }
  
  var task: Task {
    self.getTask()
  }
  
  var headers: [String : String]? {
    return self.getHeader().header
  }
}
