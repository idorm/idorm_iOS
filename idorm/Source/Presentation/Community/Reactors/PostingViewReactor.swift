//
//  PostingViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2023/01/17.
//

import ReactorKit

final class PostingViewReactor: Reactor {
  
  enum Action {
    case didTapPictIv
  }
  
  enum Mutation {
    case setImagePickerVC(Bool)
  }
  
  struct State {
    var showsImagePickerVC: Bool = false
  }
  
  var initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .didTapPictIv:
      return .concat([
        .just(.setImagePickerVC(true)),
        .just(.setImagePickerVC(false))
      ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setImagePickerVC(let isOpened):
      newState.showsImagePickerVC = isOpened
    }
    
    return newState
  }
}
