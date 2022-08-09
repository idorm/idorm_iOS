//
//  DeviceHeight.swift
//  idorm
//
//  Created by 김응철 on 2022/08/06.
//

import UIKit
import DeviceKit

public enum DeviceGroup {
  case fourInches
  case fiveInches
  case fiveInches_Plus
  case xSeries_812
  case xSeries_844
  case xSeries_896
  case xSeries_926
  
  public var rawValue: [Device] {
    switch self {
    case .fourInches:
      return [.iPhone5s, .iPhoneSE, .iPodTouch7, .simulator(.iPodTouch7)]
    case .fiveInches:
      return [.iPhone6, .iPhone6s, .iPhone7, .iPhone8, .simulator(.iPhone8)]
    case .fiveInches_Plus:
      return [.iPhone6Plus, .iPhone7Plus, .iPhone8Plus, .iPhone6Plus, .simulator(.iPhone8Plus)]
    case .xSeries_812:
      return [.iPhoneX, .iPhoneXS, .iPhone11Pro, .iPhone12Mini, .iPhone13Mini, .simulator(.iPhone13Mini), .simulator(.iPhone11Pro)]
    case .xSeries_844:
      return [.iPhone12Pro, .iPhone12, .iPhone13, .iPhone13Pro, .simulator(.iPhone13)]
    case .xSeries_896:
      return [.iPhoneXSMax, .iPhoneXR, .iPhone11, .iPhone11ProMax, .simulator(.iPhone11ProMax)]
    case .xSeries_926:
      return [.iPhone12ProMax, .iPhone13ProMax, .simulator(.iPhone13ProMax)]
    }
  }
}

class DeviceManager {
  static let shared: DeviceManager = DeviceManager()
  
  private init() {}
  
  func isFourIncheDevices() -> Bool {
    return Device.current.isOneOf(DeviceGroup.fourInches.rawValue)
  }
  
  func isFiveIncheDevices() -> Bool {
    return Device.current.isOneOf(DeviceGroup.fiveInches.rawValue)
  }
  
  func isFiveInchePlusDevices() -> Bool {
    return Device.current.isOneOf(DeviceGroup.fiveInches_Plus.rawValue)
  }
  
  func isXSeriesDevices_812() -> Bool {
    return Device.current.isOneOf(DeviceGroup.xSeries_812.rawValue)
  }
  
  func isXSeriesDevices_844() -> Bool {
    return Device.current.isOneOf(DeviceGroup.xSeries_844.rawValue)
  }

  func isXSeriesDevices_896() -> Bool {
    return Device.current.isOneOf(DeviceGroup.xSeries_896.rawValue)
  }

  func isXSeriesDevices_926() -> Bool {
    return Device.current.isOneOf(DeviceGroup.xSeries_926.rawValue)
  }
}
