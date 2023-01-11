//
//  PostListVC.swift
//  idorm
//
//  Created by 김응철 on 2023/01/11.
//

import UIKit

import SnapKit

final class PostListViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let floatyBtn: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "ellipse_posting"), for: .normal)
    btn.setImage(UIImage(named: "ellipse_posting_activated"), for: .highlighted)
    
    return btn
  }()
  
  private let dormBtn: UIButton = {
    var container = AttributeContainer()
    container.font = .init(name: MyFonts.bold.rawValue, size: 20)
    container.strokeColor = .black

    var config = UIButton.Configuration.plain()
    config.imagePadding = 16
    config.imagePlacement = .trailing
    config.image = #imageLiteral(resourceName: "downarrow")
    config.attributedTitle = AttributedString("인천대 3기숙사", attributes: container)
    
    let btn = UIButton(configuration: config)
    
    return btn
  }()
  
  private let bellBtn: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "bell"), for: .normal)
    
    return btn
  }()
  
  // MARK: - Setup
  
  override func setupStyles() {
    view.backgroundColor = .white
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dormBtn)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bellBtn)
  }
  
  override func setupLayouts() {
    
  }
  
  override func setupConstraints() {
    
  }
  
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct PostListVC_PreView: PreviewProvider {
  static var previews: some View {
    PostListViewController().toPreview()
  }
}
#endif
