//
//  UIScrollView+Extensions.swift
//  idorm
//
//  Created by 김응철 on 2022/08/03.
//

import UIKit

extension UIScrollView {
  func updateContentSize() {
    let unionCalculatedTotalRect = recursiveUnionInDepthFor(view: self)
    
    self.contentSize = CGSize(width: self.frame.width, height: unionCalculatedTotalRect.height)
    print(unionCalculatedTotalRect.height)
  }
  
  private func recursiveUnionInDepthFor(view: UIView) -> CGRect {
    var totalRect: CGRect = .zero
    
    for subView in view.subviews {
      totalRect = totalRect.union(recursiveUnionInDepthFor(view: subView))
    }
    return totalRect
  }
}
