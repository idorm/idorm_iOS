struct FilteringConfirmVerifier {
  var dorm: Bool
  var period: Bool
  
  static func initialValue() -> FilteringConfirmVerifier {
    return FilteringConfirmVerifier(dorm: false, period: false)
  }
}
