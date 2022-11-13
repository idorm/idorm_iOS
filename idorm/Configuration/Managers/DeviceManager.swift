import Foundation
import DeviceKit

public enum DeviceGroup {
  case resolution_568
  case resolution_667
  case resolution_736
  case resolution_812
  case resolution_844
  case resolution_852
  case resolution_896
  case resolution_926
  case resolution_932
  
  public var rawValue: [Device] {
    switch self {
    case .resolution_568:
      return [.iPhone5, .iPhone5c, .iPhone5s, .iPhoneSE, .simulator(.iPhone5), .simulator(.iPhone5c), .simulator(.iPhone5s), .simulator(.iPhoneSE)]
    case .resolution_667:
      return [.iPhone6, .iPhone6s, .iPhone7, .iPhone8, .iPhoneSE2, .iPhoneSE3, .simulator(.iPhone6), .simulator(.iPhone6s), .simulator(.iPhone7), .simulator(.iPhone8), .simulator(.iPhoneSE2), .simulator(.iPhoneSE3)]
    case .resolution_736:
      return [.iPhone6Plus, .iPhone6sPlus, .iPhone7Plus, .iPhone8Plus, .simulator(.iPhone6Plus), .simulator(.iPhone6sPlus), .simulator(.iPhone7Plus), .simulator(.iPhone8Plus)]
    case .resolution_812:
      return [.iPhoneX, .iPhoneXS, .iPhone11Pro, .iPhone12Mini, .iPhone13Mini, .simulator(.iPhoneX), .simulator(.iPhoneXS), .simulator(.iPhone11Pro), .simulator(.iPhone12Mini), .simulator(.iPhone13Mini)]
    case .resolution_844:
      return [.iPhone12, .iPhone12Pro, .iPhone13, .iPhone13Pro, .iPhone14, .simulator(.iPhone12), .simulator(.iPhone12Pro), .simulator(.iPhone13), .simulator(.iPhone13Pro), .simulator(.iPhone14)]
    case .resolution_852:
      return [.iPhone14Pro, .simulator(.iPhone14Pro)]
    case .resolution_896:
      return [.iPhoneXR, .iPhone11, .iPhoneXSMax, .iPhone11ProMax, .simulator(.iPhoneXR), .simulator(.iPhone11), .simulator(.iPhoneXSMax), .simulator(.iPhone11ProMax)]
    case .resolution_926:
      return [.iPhone12ProMax, .iPhone13ProMax, .iPhone14Plus, .simulator(.iPhone12ProMax), .simulator(.iPhone13ProMax), .simulator(.iPhone14Plus)]
    case .resolution_932:
      return [.iPhone14ProMax, .simulator(.iPhone14ProMax)]
    }
  }
}

class DeviceManager {
  static let shared: DeviceManager = DeviceManager()
  var startDate = Date()
  
  private init() {}
  
  func isResoultion568() -> Bool {
    return Device.current.isOneOf(DeviceGroup.resolution_568.rawValue)
  }
  
  func isResolution667() -> Bool {
    return Device.current.isOneOf(DeviceGroup.resolution_667.rawValue)
  }
  
  func isResolution736() -> Bool {
    return Device.current.isOneOf(DeviceGroup.resolution_736.rawValue)
  }
  
  func isResolution812() -> Bool {
    return Device.current.isOneOf(DeviceGroup.resolution_812.rawValue)
  }
  
  func isResolution844() -> Bool {
    return Device.current.isOneOf(DeviceGroup.resolution_844.rawValue)
  }

  func isResolution852() -> Bool {
    return Device.current.isOneOf(DeviceGroup.resolution_852.rawValue)
  }

  func isResolution896() -> Bool {
    return Device.current.isOneOf(DeviceGroup.resolution_896.rawValue)
  }
  
  func isResolution926() -> Bool {
    return Device.current.isOneOf(DeviceGroup.resolution_926.rawValue)
  }
  
  func isResolution932() -> Bool {
    return Device.current.isOneOf(DeviceGroup.resolution_932.rawValue)
  }
}
