//
//  PostingViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2023/01/17.
//

import UIKit

import ReactorKit

final class PostingViewReactor: Reactor {
  
  enum Action {
    case didTapPictIv
    case didPickedImages([UIImage])
    case didTapDeleteBtn(Int)
  }
  
  enum Mutation {
    case setGalleryVC(Bool)
    case setImages([UIImage])
    case deleteImages(Int)
  }
  
  struct State {
    var showsGalleryVC: Bool = false
    var currentImages: [UIImage] = []
  }
  
  var initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .didTapPictIv:
      return .concat([
        .just(.setGalleryVC(true)),
        .just(.setGalleryVC(false))
      ])
      
    case .didPickedImages(let images):
      return .just(.setImages(images))
      
    case .didTapDeleteBtn(let index):
      return .just(.deleteImages(index))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setGalleryVC(let isOpened):
      newState.showsGalleryVC = isOpened
      
    case .setImages(let images):
      newState.currentImages += images
      
    case .deleteImages(let index):
      var images = currentState.currentImages
      images.remove(at: index)
      newState.currentImages = images
    }
    
    return newState
  }
}
