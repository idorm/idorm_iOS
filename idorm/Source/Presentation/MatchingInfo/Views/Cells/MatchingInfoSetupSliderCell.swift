//
//  MatchingInfoSetupSliderCell.swift
//  idorm
//
//  Created by 김응철 on 9/25/23.
//

import UIKit

import RangeSeekSlider
import SnapKit

final class MatchingInfoSetupSliderCell: BaseCollectionViewCell {
  
  // MARK: - UI Components
  
  private lazy var slider: RangeSeekSlider = {
    let slider = RangeSeekSlider()
    slider.sliderLine.borderWidth = 1.0
    slider.sliderLine.borderColor = UIColor.iDormColor(.iDormGray200).cgColor
    slider.backgroundColor = .white
    slider.colorBetweenHandles = .iDormColor(.iDormBlue)
    slider.tintColor = .white
    slider.labelPadding = 6
    slider.minLabelColor = .black
    slider.maxLabelColor = .black
    slider.minLabelFont = .iDormFont(.medium, size: 12.0)
    slider.maxLabelFont = .iDormFont(.medium, size: 12.0)
    slider.minValue = 20
    slider.maxValue = 40
    slider.selectedMaxValue = 30
    slider.selectedMinValue = 20
    slider.lineHeight = 11
    slider.handleImage = .iDormIcon(.select)?.resize(newSize: 30.0)
    slider.minDistance = 1
    slider.enableStep = true
    slider.selectedHandleDiameterMultiplier = 1.0
    slider.delegate = self
    return slider
  }()
  
  // MARK: - Properties
  
  var sliderHandler: ((_ minAge: Int, _ maxAge: Int) -> Void)?
  
  // MARK: - Setup
  
  override func setupStyles() {}
  
  override func setupLayouts() {
    self.addSubview(self.slider)
  }
  
  override func setupConstraints() {
    self.slider.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(-20.0)
      make.bottom.directionalHorizontalEdges.equalToSuperview()
    }
  }
  
  // MARK: - Configure
  
  func configure(minAge: Int, maxAge: Int) {
    self.slider.selectedMinValue = CGFloat(minAge)
    self.slider.selectedMaxValue = CGFloat(maxAge)
  }
}

extension MatchingInfoSetupSliderCell: RangeSeekSliderDelegate {
  func rangeSeekSlider(
    _ slider: RangeSeekSlider,
    didChange minValue: CGFloat,
    maxValue: CGFloat
  ) {
    let minValue = Int(round(minValue))
    let maxValue = Int(round(maxValue))
    self.sliderHandler?(minValue, maxValue)
  }
}
