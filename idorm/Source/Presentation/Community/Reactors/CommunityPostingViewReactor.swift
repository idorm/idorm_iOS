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
    
    
    
    
    
    case didTapPictIv
    case didTapCompleteBtn
    case didPickedImages([UIImage])
    case didTapDeleteBtn(Int)
    case didChangeTitle(String)
    case didChangeContent(String)
    case didTapAnonymousBtn(Bool)
  }
  
  enum Mutation {
    case setAnonymous
    case setTitle(String)
    case setContent(String)
    case setImagePickerVC
    case setImagesData([PostImageData])
    case removeImagesData(CommunityPostingSectionItem)
    
    
    case setGalleryVC(Bool)
    case deleteImages(Int)
    case setCompleteBtn
    case setLoading(Bool)
    case setPopVC(Bool)
    case setDeletePostPhotoIds(Int)
  }
  
  struct State {
    var post: Post
    var sections: [CommunityPostingSection] = []
    var items: [[CommunityPostingSectionItem]] = []
    var isEnabledConfirmButton: Bool = false
    var isAnonymous: Bool = true
    @Pulse var presentToImagePickerVC: Int = 0
    
    var showsGalleryVC: Bool = false
    var deletePostPhotoIds: [Int] = []
    var popVC: Bool = false
  }
  
  // MARK: - Properties
  
  var initialState: State
  private let viewType: ViewType
  private let communityService = NetworkService<CommunityAPI>()
  
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
      
//    case .viewDidLoad:
//      switch postingType {
//      case .new:
//        return .empty()
//      case .edit:
//        guard let post = post else { return .empty() }
//        var photos: [Photo] = []
//        
//        post.photos.forEach { [weak self] in
//          var image: UIImage?
//          self?.downloadImage(
//            from: URL(string: $0.photoURL)!
//          ) {
//            image = $0
//          }
//          photos.append(Photo(image: image!, index: $0.photoID))
//        }
//        
//        return .concat([
//          .just(.setTitle(post.title)),
//          .just(.setContents(post.content)),
//          .just(.setImages(photos)),
//          .just(.setAnonymous(post.isAnonymous))
//        ])
//      }
//      
//    case .didTapPictIv:
//      return .concat([
//        .just(.setGalleryVC(true)),
//        .just(.setGalleryVC(false))
//      ])
//      
//    case .didTapCompleteBtn:
//      switch postingType {
//      case .edit:
//        guard let post = post else { return .empty() }
//        let photos = currentState.currentImages
//          .filter { $0.index < 0 }
//          .map { $0.image }
//        
//        let newPost = CommunityRequestModel.Post(
//          content: currentState.currentContents,
//          title: currentState.currentTitle,
//          dormCategory: .no1,
//          images: photos,
//          isAnonymous: currentState.isAnonymous
//        )
//        
//        return .concat([
//          .just(.setLoading(true)),
//          CommunityAPI.provider.rx.request(.editPost(
//            postId: post.identifier,
//            post: newPost,
//            deletePostPhotos: currentState.deletePostPhotoIds)
//          )
//          .asObservable()
//          .flatMap { response -> Observable<Mutation> in
//            switch response.statusCode {
//            case 200..<300:
//              return .concat([
//                .just(.setLoading(false)),
//                .just(.setPopVC(true))
//              ])
//            default:
//              fatalError()
//            }
//          }
//        ])
//        
//      case .new:
//        var images: [UIImage] = []
//        currentState.currentImages.forEach {
//          images.append($0.image)
//        }
//        let newPost = CommunityRequestModel.Post(
//          content: currentState.currentContents,
//          title: currentState.currentTitle,
//          dormCategory: currentDorm,
//          images: images,
//          isAnonymous: currentState.isAnonymous
//        )
//        return self.apiManager.requestAPI(to: .savePost(newPost))
//          .flatMap { _ in return Observable<Mutation>.just(.setPopVC(true)) }
//      }
//      
//    case .didPickedImages(let images):
//      var photos: [Photo] = []
//      images.forEach {
//        photos.append(Photo(image: $0, index: -1))
//      }
//      return .just(.setImages(photos))
//      
//    case .didTapDeleteBtn(let index):
//      switch postingType {
//      case .new:
//        return .just(.deleteImages(index))
//      case .edit:
//        guard let post = post else { return .empty() }
//        let photo = currentState.currentImages[index]
//        let deleteIndex = post.photos.first(where: { $0.photoID == photo.index })?.photoID
//        if deleteIndex != nil {
//          return .concat([
//            .just(.deleteImages(index)),
//            .just(.setDeletePostPhotoIds(deleteIndex!))
//          ])
//        }
//        return .just(.deleteImages(index))
//      }
//    case .didChangeTitle(let title):
//      return .concat([
//        .just(.setTitle(title)),
//        .just(.setCompleteBtn)
//      ])
//    case .didChangeContent(let contents):
//      return .concat([
//        .just(.setContents(contents)),
//        .just(.setCompleteBtn)
//      ])
//    case .didTapAnonymousBtn(let isSelected):
//      return .just(.setAnonymous(isSelected))
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
    
//    case .setGalleryVC(let isOpened):
//      newState.showsGalleryVC = isOpened
//      
//    case .setImages(let images):
//      newState.currentImages += images
//      
//    case .deleteImages(let index):
//      var images = currentState.currentImages
//      images.remove(at: index)
//      newState.currentImages = images
//      
//    case .setTitle(let title):
//      newState.currentTitle = title
//      
//    case .setContents(let contents):
//      newState.currentContents = contents
//      
//    case .setCompleteBtn:
//      if !currentState.currentTitle.isEmpty,
//         !currentState.currentContents.isEmpty
//      {
//        newState.isEnabledCompleteBtn = true
//      } else {
//        newState.isEnabledCompleteBtn = false
//      }
//      
//    case .setAnonymous(let isSelected):
//      newState.isAnonymous = isSelected
//      
//    case .setLoading(let isLoading):
//      newState.isLoading = isLoading
//      
//    case .setPopVC(let state):
//      newState.popVC = state
//      
//    case .setDeletePostPhotoIds(let id):
//      newState.deletePostPhotoIds.append(id)
//    }
    
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
