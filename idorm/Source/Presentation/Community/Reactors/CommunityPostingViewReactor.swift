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
import Kingfisher

final class CommunityPostingViewReactor: Reactor {
  
  enum ViewType {
    case new
    case update(Post)
  }
  
  enum Action {
    case viewDidLoad
    case anonymousButtonDidTap
    case titleTextFieldDidChange(String)
    case contentTextViewDidChange(String)
    case imagesCountButtonDidTap
    case imagesDidPick([UIImage])
    case removeButtonDidTap(CommunityPostingSectionItem)
  }
  
  enum Mutation {
    case setAnonymous
    case setTitle(String)
    case setContent(String)
    case setImagePickerVC
    case setImagesData([PostImageData])
    case removeImagesData(CommunityPostingSectionItem)
  }
  
  struct State {
    var post: Post
    var sections: [CommunityPostingSection] = []
    var items: [[CommunityPostingSectionItem]] = []
    var isEnabledConfirmButton: Bool = false
    var isAnonymous: Bool = true
    @Pulse var presentToImagePickerVC: Int = 0
  }
  
  // MARK: - Properties
  
  var initialState: State
  private let viewType: ViewType
//  private let communityService = NetworkService<CommunityAPI>()
  
  // MARK: - Initializer
  
  init(_ viewType: ViewType) {
    self.viewType = viewType
    switch viewType {
    case .new:
      self.initialState = State(post: .init())
    case .update(let post):
      self.initialState = State(post: post)
    }
  }
  
  // MARK: - Functions
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      var post = self.currentState.post
      self.currentState.post.imagesData.enumerated().forEach { index, imageData in
        ImageDownloader.downloadImage(from: imageData.imageURL) { image in
          post.imagesData[index].image = image
        }
      }
      return .just(.setImagesData(post.imagesData))
    case .anonymousButtonDidTap:
      return .just(.setAnonymous)
    case .titleTextFieldDidChange(let title):
      return .just(.setTitle(title))
    case .contentTextViewDidChange(let content):
      return .just(.setContent(content))
    case .imagesCountButtonDidTap:
      guard !(self.currentState.post.imagesData.count == 10) else { return .empty() }
      return .just(.setImagePickerVC)
    case .imagesDidPick(let images):
      return .just(.setImagesData(images.map { PostImageData(identifier: -1, imageURL: "", image: $0) }))
    case .removeButtonDidTap(let item):
      return .just(.removeImagesData(item))
    default:
      return .empty()

    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setAnonymous:
      newState.isAnonymous = !state.isAnonymous
    case .setTitle(let title):
      newState.post.title = title
    case .setContent(let content):
      newState.post.content = content
    case .setImagePickerVC:
      newState.presentToImagePickerVC = 10 - state.post.imagesData.count
    case .setImagesData(let imagesData):
      newState.post.imagesData.append(contentsOf: imagesData)
    case .removeImagesData(let item):
      if case .image(let image) = item {
        state.post.imagesData.enumerated().forEach { index, imageData in
          if imageData.image!.isEqual(image!) {
            newState.post.imagesData.remove(at: index)
          }
        }
      }
    default:
      break
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state

      newState.sections =
      state.post.imagesData.isEmpty ? [.title, .content] : [.title, .images, .content]

      newState.items.append([.title])
      if !state.post.imagesData.isEmpty {
        newState.items.append(state.post.imagesData.map { .image($0.image) })
      }
      newState.items.append([.content])
      
      if state.post.title.isNotEmpty &&
         state.post.content.isNotEmpty {
        newState.isEnabledConfirmButton = true
      } else {
        newState.isEnabledConfirmButton = false
      }
      
      return newState
    }
  }
}
