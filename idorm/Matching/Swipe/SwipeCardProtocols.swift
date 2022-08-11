//
//  SwipeCardProtocols.swift
//  idorm
//
//  Created by 김응철 on 2022/08/07.
//

import UIKit

protocol SwipeCardDelegate {
  func swipeDidEnd(on view: SwipeCardView)
  func revertCard()
}

protocol SwipeCardsDataSource {
  func numberOfCardsToShow() -> Int
  func card(at index: Int) -> SwipeCardView
  func emptyView() -> UIView?
}
