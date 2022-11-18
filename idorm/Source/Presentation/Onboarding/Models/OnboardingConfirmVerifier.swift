struct OnboardingConfirmVerifier {
  var dorm: Bool
  var gender: Bool
  var period: Bool
  var age: Bool
  var wakeup: Bool
  var cleanup: Bool
  var showerTime: Bool
  var chatLink: Bool
  
  static func initialValue() -> OnboardingConfirmVerifier {
    return OnboardingConfirmVerifier(
      dorm: false,
      gender: false,
      period: false,
      age: false,
      wakeup: false,
      cleanup: false,
      showerTime: false,
      chatLink: false
    )
  }
}
