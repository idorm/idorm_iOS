struct OnboardingVerifyConfirmList {
  var dorm: Bool
  var gender: Bool
  var period: Bool
  var age: Bool
  var wakeup: Bool
  var cleanup: Bool
  var showerTime: Bool
  
  static func initialValue() -> OnboardingVerifyConfirmList {
    return OnboardingVerifyConfirmList(
      dorm: false,
      gender: false,
      period: false,
      age: false,
      wakeup: false,
      cleanup: false,
      showerTime: false
    )
  }
}
