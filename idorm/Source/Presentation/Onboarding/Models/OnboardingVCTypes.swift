struct OnboardingVCTypes {
  
  enum OnboardingVCType {
    /// 회원가입 후 최초 온보딩 접근
    case initial
    /// 메인페이지 최초 접속 후 온보딩 접근
    case initial2
    /// 온보딩 수정
    case update
  }

  enum OnboardingDetailVCType {
    case initilize
    case update
  }
}
