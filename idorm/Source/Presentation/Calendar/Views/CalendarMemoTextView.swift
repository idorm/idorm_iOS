//
//  CalendarMemoTextView.swift
//  idorm
//
//  Created by 김응철 on 7/26/23.
//

import UIKit

/// 줄 공책 처럼 많은 수의 `Line`이 있는 `UITextView`
final class CalendarMemoTextView: UITextView {
  
  // MARK: - Properties
  
  /// `Line`사이 정해진 간격의 `CGFloat`
  private var linePadding: CGFloat = 29.0
  
  // MARK: - Life Cycle
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.setupStyles()
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    self.drawUnderLine(rect)
  }
  
  override func caretRect(for position: UITextPosition) -> CGRect {
    var rect = super.caretRect(for: position)
    rect.size.height = 22.0
    return rect
  }
  
  // MARK: - Setup
  
  private func setupStyles() {
    // ParagraphStyle
    let style = NSMutableParagraphStyle()
    style.lineSpacing = 8.0
    style.minimumLineHeight = 21.0
    style.maximumLineHeight = 21.0
    
    self.typingAttributes = [
      .paragraphStyle: style,
      .font: UIFont.iDormFont(.regular, size: 14.0)
    ]
    
    // Attributes
    self.isScrollEnabled = false
    self.textContainerInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 0.0, right: 16.0)
  }
}

// MARK: - Privates

private extension CalendarMemoTextView {
  /// `TextView`에 UnderLine들을 그립니다.
  func drawUnderLine(_ rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()
    context?.setStrokeColor(UIColor.iDormColor(.iDormGray200).cgColor)
    context?.setLineWidth(1.0)
    
    let numberOfLines = Int(rect.height / self.linePadding)
    
    for i in 1...numberOfLines {
      let y = CGFloat(i) * self.linePadding + 10.0

      let line = CGMutablePath()
      line.move(to: CGPoint(x: 0, y: y))
      line.addLine(to: CGPoint(x: rect.width, y: y))
      context?.addPath(line)
    }
    
    self.textContainer.maximumNumberOfLines = numberOfLines
    context?.strokePath()
  }
}
