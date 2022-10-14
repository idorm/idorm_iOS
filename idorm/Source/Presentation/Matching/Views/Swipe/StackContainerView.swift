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

class StackContainerView: UIView {
  // MARK: - Properties
  var numberOfCardsToShow: Int = 0
  var remainingCards: Int = 0
  var cardViews: [SwipeCardView] = []
  var deletedCards: [SwipeCardView] = []
  let cardsToBeVisible: Int = 3
  
  let verticalInset: CGFloat = 5
  
  var visibleCards: [SwipeCardView] {
    return subviews as? [SwipeCardView] ?? []
  }
  
  var dataSource: SwipeCardsDataSource? {
    didSet {
      reloadData()
    }
  }
  
  let viewModel: MatchingViewModel
  let disposeBag = DisposeBag()
  
  // MARK: - LifeCycle
  
  init(viewModel: MatchingViewModel) {
    self.viewModel = viewModel
    super.init(frame: .zero)
    backgroundColor = .clear
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func bind() {
    // 스와이프 애니메이션 적용
    viewModel.output.onChangedSwipeAnimation
      .bind(onNext: { [weak self] type in
        switch type {
        case .cancel:
          guard let self = self else { return }
          guard let firstCard = self.visibleCards.last else { return }
          let moveAnimation = CGAffineTransform(translationX: -300, y: -20)
          let rotateAnimation = CGAffineTransform(rotationAngle: 0.1)
          UIView.animate(withDuration: 0.3) {
            let concat = moveAnimation.concatenating(rotateAnimation)
            firstCard.transform = concat
          } completion: { isCompleted in
            if isCompleted {
              firstCard.delegate?.swipeDidEnd(on: firstCard)
              self.deletedCards.append(firstCard)
            }
          }
        case .heart:
          guard let self = self else { return }
          guard let firstCard = self.visibleCards.last else { return }
          let moveAnimation = CGAffineTransform(translationX: 300, y: -50)
          let rotateAnimation = CGAffineTransform(rotationAngle: 0.1)
          UIView.animate(withDuration: 0.3) {
            let concat = moveAnimation.concatenating(rotateAnimation)
            firstCard.transform = concat
          } completion: { isCompleted in
            if isCompleted {
              firstCard.delegate?.swipeDidEnd(on: firstCard)
            }
          }
        }
      })
      .disposed(by: disposeBag)
    
    // 취소할 때 삭제된 카드 배열에 원소 추가하기
    viewModel.output.appendRemovedCard
      .bind(onNext: { [weak self] card in
        self?.deletedCards.append(card)
      })
      .disposed(by: disposeBag)
    
    // 뒤로가기 버튼 누를 때, 카드 되돌리기
    viewModel.output.revertCard
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        self?.revertCard()
      })
      .disposed(by: disposeBag)
  }
  
  func reloadData() {
    removeAllCardViews()
    guard let dataSource = dataSource else { return }
    setNeedsLayout()
    layoutIfNeeded()
    numberOfCardsToShow = dataSource.numberOfCardsToShow() // 원본 카드 갯수
    remainingCards = numberOfCardsToShow
    
    for i in 0..<min(numberOfCardsToShow, cardsToBeVisible) {
      let card = dataSource.card(at: i)
      addCardView(cardView: card, at: i)
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
    let verticalInset = (CGFloat(index) * self.verticalInset)
    
    cardViewFrame.origin.y += verticalInset
    cardView.frame = cardViewFrame
  }
  
  private func removeAllCardViews() {
    for cardView in visibleCards {
      cardView.removeFromSuperview()
    }
    cardViews = []
  }
}

extension StackContainerView: SwipeCardDelegate {
  func revertCard() {
    guard let lastCard = deletedCards.last else { return }
    let rotateAnimation = CGAffineTransform(rotationAngle: .zero)
    
    for (cardIndex, cardView) in visibleCards.reversed().enumerated() {
      var cardViewFrame = bounds
      UIView.animate(withDuration: 0.2, delay: 0) {
        cardView.center = self.center
        let verticalInset = (CGFloat(cardIndex + 1) * self.verticalInset)
        cardViewFrame.origin.y += verticalInset
        cardView.frame = cardViewFrame
      }
    }
    addSubview(lastCard)
    UIView.animate(withDuration: 0.2, delay: 0) {
      lastCard.transform = rotateAnimation
      lastCard.frame = self.bounds
      self.layoutIfNeeded()
    }
    deletedCards.removeLast()
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
