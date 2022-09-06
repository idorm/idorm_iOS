//
//  StackViewContainer.swift
//  idorm
//
//  Created by 김응철 on 2022/08/07.
//

import SnapKit
import UIKit
import RxSwift
import RxCocoa

class SwipeCardView: UIView {
  // MARK: - Properties
  var swipeView: UIView!
  var infoView: MyInfoView!
  
  var delegate: SwipeCardDelegate?
  
  let myInfo: MyInfo
  let viewModel: MatchingViewModel
  
  // MARK: - LifeCycle
  init(myInfo: MyInfo, viewModel: MatchingViewModel) {
    self.myInfo = myInfo
    self.viewModel = viewModel
    super.init(frame: .zero)
    configureUI()
    addPanGestureOnCards()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configuration
  func configureUI() {
    swipeView = UIView()
    swipeView.backgroundColor = .clear
    addSubview(swipeView)
    
    swipeView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    infoView = MyInfoView(myInfo: myInfo)
    swipeView.addSubview(infoView)
    
    infoView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  func addPanGestureOnCards() {
    self.isUserInteractionEnabled = true
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(sender:)))
    addGestureRecognizer(panGesture)
  }
  
  // MARK: - Handler
  @objc func handlePanGesture(sender: UIPanGestureRecognizer) {
    let card = sender.view as! SwipeCardView
    let point = sender.translation(in: self)
    let centerOfParentContainer = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
    card.center = CGPoint(x: centerOfParentContainer.x + point.x, y: centerOfParentContainer.y + point.y)
    
    let velocity = sender.velocity(in: self)
    if abs(velocity.x) > abs(velocity.y) {
      velocity.x < 0 ? viewModel.input.swipeObserver.onNext(.cancel) : viewModel.input.swipeObserver.onNext(.heart)
    }
    
    switch sender.state {
    case .ended:
      viewModel.input.didEndSwipeObserver.onNext(.none)
      if (card.center.x) > 400 {
        delegate?.swipeDidEnd(on: card)
        viewModel.input.didEndSwipeObserver.onNext(.heart)
        UIView.animate(withDuration: 0.2) {
          card.center = CGPoint(x: centerOfParentContainer.x + point.x + 200, y: centerOfParentContainer.y + point.y + 75)
          card.alpha = 0
          self.layoutIfNeeded()
        }
        return
      } else if card.center.x < -25 {
        delegate?.swipeDidEnd(on: card)
        viewModel.input.didEndSwipeObserver.onNext(.cancel)
        viewModel.input.cancelDeliverCardObserver.onNext(card)
        UIView.animate(withDuration: 0.2) {
          card.center = CGPoint(x: centerOfParentContainer.x + point.x - 200, y: centerOfParentContainer.y + point.y + 75)
          card.alpha = 0
          self.layoutIfNeeded()
        }
        return
      }
      UIView.animate(withDuration: 0.2) {
        card.transform = .identity
        card.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        self.layoutIfNeeded()
      }
    case .changed:
      let rotation = tan(point.x / (self.frame.width * 2.0))
      card.transform = CGAffineTransform(rotationAngle: rotation)
    default:
      break
    }
  }
}
