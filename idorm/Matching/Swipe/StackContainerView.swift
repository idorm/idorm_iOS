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

class StackContainerView: UIView, SwipeCardDelegate {
  // MARK: - Properties
  var numberOfCardsToShow: Int = 0
  var remainingCards: Int = 0
  var cardViews: [SwipeCardView] = []
  let cardsToBeVisible: Int = 3
  
  let horizontalInset: CGFloat = 10
  let verticalInset: CGFloat = 10
  
  var visibleCards: [SwipeCardView] {
    return subviews as? [SwipeCardView] ?? []
  }
  
  var dataSource: SwipeCardsDataSource? {
    didSet {
      reloadData()
    }
  }
  
  // MARK: - LifeCycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .idorm_blue
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func reloadData() {
    guard let dataSource = dataSource else { return }
    setNeedsLayout()
    layoutIfNeeded()
    numberOfCardsToShow = dataSource.numberOfCardsToShow()
    remainingCards = numberOfCardsToShow
    
    for i in 0..<min(numberOfCardsToShow, cardsToBeVisible) {
      addCardView(cardView: dataSource.card(at: i), at: i)
    }
  }
  
  // MARK: - Configuration
  private func addCardView(cardView: SwipeCardView, at index: Int) {
    cardView.delegate = self
    addCardFrame(index: index, cardView: cardView)
    cardViews.append(cardView)
    insertSubview(cardView, at: 0)
    remainingCards -= 1
  }
  
  func addCardFrame(index: Int, cardView: SwipeCardView) {
    var cardViewFrame = bounds
    let horizontalInset = (CGFloat(index) * self.horizontalInset)
    let verticalInset = (CGFloat(index) * self.verticalInset)
    
    cardViewFrame.size.width -= 2 * horizontalInset
    cardViewFrame.origin.x += horizontalInset
    cardViewFrame.origin.y += verticalInset

    cardView.frame = cardViewFrame
  }
  
  private func removeAllCardViews() {
    for cardView in visibleCards {
      cardView.removeFromSuperview()
    }
    cardViews = []
  }
  
  func swipeDidEnd(on view: SwipeCardView) {
    guard let dataSource = dataSource else { return }
    view.removeFromSuperview()
    
    if remainingCards > 0 {
      let newIndex = dataSource.numberOfCardsToShow() - remainingCards
      addCardView(cardView: dataSource.card(at: newIndex), at: 2)
      for (cardIndex, cardView) in visibleCards.reversed().enumerated() {
        UIView.animate(withDuration: 0.2) {
          cardView.center = self.center
          self.addCardFrame(index: cardIndex, cardView: cardView)
          self.layoutIfNeeded()
        }
      }
    } else {
      for (cardIndex, cardView) in visibleCards.reversed().enumerated() {
        UIView.animate(withDuration: 0.2) {
          cardView.center = self.center
          self.addCardFrame(index: cardIndex, cardView: cardView)
          self.layoutIfNeeded()
        }
      }
    }
  }
}
