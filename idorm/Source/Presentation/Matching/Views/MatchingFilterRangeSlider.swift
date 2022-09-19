//
//  MatchingFilterRangeSlider.swift
//  idorm
//
//  Created by 김응철 on 2022/07/31.
//

import UIKit
import QuartzCore
import SnapKit

//class RangeSlider: UIControl {
//  // MARK: - Properties
//  let track = UIView()
//  let activeTrack = UIView()
//  let leftThumb = UIImageView(image: UIImage(named: "thumb(Matching)"))
//  let rightThumb = UIImageView(image: UIImage(named: "thumb(Matching)"))
//
//  var minimumValue = 20
//  var maximumValue = 40
//  var minimumValueNow = 20
//  var maximumValueNow = 30
//
//  var values: (minimum: Int, maximum: Int) {
//    get { return (minimumValueNow, maximumValueNow) }
//    set {
//      var newMin: Int = .zero; var newMax: Int = .zero
//      if newValue.minimum <= .zero {
//        newMin = self.minimumValue
//      }
//      if newValue.minimum <= self.minimumValue {
//        newMin = self.minimumValue
//      }
//      if newValue.minimum > newValue.maximum {
//        newMin = newValue.maximum
//      }
//      if newValue.maximum <= .zero {
//        newMax = self.minimumValue
//      }
//      if newValue.maximum >= self.maximumValue {
//        newMax = self.maximumValue
//      }
//      if newValue.maximum < newValue.minimum {
//        newMax = newValue.minimum
//      }
//      self.minimumValueNow = newMin
//      self.maximumValueNow = newMax
//    }
//  }
//
//  var newMinimalValue: Int {
//
//  }
//
//  // MARK: - LifeCycle
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//  }
//
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//
//  // MARK: - Helpers
//  private func configureUI() {
//    [ track, activeTrack, leftThumb, rightThumb ]
//      .forEach { addSubview($0) }
//
//    track.snp.makeConstraints { make in
//      make.leading.trailing.equalToSuperview()
//      make.centerY.equalToSuperview()
//    }
//
//    activeTrack.snp.makeConstraints { make in
//      make.leading.equalTo(track.snp.leading)
//      make.trailing.equalTo(track.snp.trailing)
//    }
//  }
//
//  private func updateValues(_ completion: @escaping () -> Void) {
//    self.lowerValue =
//  }
//}
