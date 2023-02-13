//
//  PostingViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2023/01/17.
//

import UIKit

import ReactorKit
import RxMoya
import Photos

final class PostingViewReactor: Reactor {
  
  enum Action {
    case didTapPictIv
    case didTapCompleteBtn
    case didPickedImages([PHAsset])
    case didTapDeleteBtn(Int)
    case didChangeTitle(String)
    case didChangeContent(String)
    case didTapAnonymousBtn(Bool)
  }
  
  enum Mutation {
    case setGalleryVC(Bool)
    case setImages([PHAsset])
    case deleteImages(Int)
    case setTitle(String)
    case setContents(String)
    case setCompleteBtn
    case setAnonymous(Bool)
    case setLoading(Bool)
    case setPopVC(Bool)
  }
  
  struct State {
    var showsGalleryVC: Bool = false
    var currentImages: [PHAsset] = []
    var currentTitle: String = ""
    var currentContents: String = ""
    var isEnabledCompleteBtn: Bool = false
    var isAnonymous: Bool = true
    var isLoading: Bool = false
    var popVC: Bool = false
  }
    
  private let currentDorm: Dormitory
  var postingCompletion: (() -> Void)?
  var initialState: State = State()
  
  init(_ dorm: Dormitory) {
    self.currentDorm = dorm
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .didTapPictIv:
      return .concat([
        .just(.setGalleryVC(true)),
        .just(.setGalleryVC(false))
      ])
      
    case .didTapCompleteBtn:
      let newPost = CommunityRequestModel.Post(
        content: currentState.currentContents,
        title: currentState.currentTitle,
        dormNum: currentDorm,
        assets: currentState.currentImages,
        isAnonymous: currentState.isAnonymous
      )
      
      return .concat([
        .just(.setLoading(true)),
        CommunityAPI.provider.rx.request(.savePost(newPost))
          .asObservable()
          .retry()
          .withUnretained(self)
          .flatMap { owner, response -> Observable<Mutation> in
            switch response.statusCode {
            case 200..<300:
              owner.postingCompletion?()
              return .concat([
                .just(.setLoading(false)),
                .just(.setPopVC(true))
              ])
              
            default:
              fatalError("게시글 저장 실패")
            }
          }
      ])
      
    case .didPickedImages(let images):
      return .just(.setImages(images))
      
    case .didTapDeleteBtn(let index):
      return .just(.deleteImages(index))
      
    case .didChangeTitle(let title):
      return .concat([
        .just(.setTitle(title)),
        .just(.setCompleteBtn)
      ])
      
    case .didChangeContent(let contents):
      return .concat([
        .just(.setContents(contents)),
        .just(.setCompleteBtn)
      ])
      
    case .didTapAnonymousBtn(let isSelected):
      return .just(.setAnonymous(isSelected))
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
      
    case .setTitle(let title):
      newState.currentTitle = title
      
    case .setContents(let contents):
      newState.currentContents = contents
      
    case .setCompleteBtn:
      if !currentState.currentTitle.isEmpty,
         !currentState.currentContents.isEmpty
      {
        newState.isEnabledCompleteBtn = true
      } else {
        newState.isEnabledCompleteBtn = false
      }
      
    case .setAnonymous(let isSelected):
      newState.isAnonymous = isSelected
      
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setPopVC(let state):
      newState.popVC = state
    }
    
    return newState
  }
}
