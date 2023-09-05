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
  
  struct Photo: Equatable {
    let image: UIImage
    let index: Int
  }
  
  enum Action {
    case didTapPictIv
    case didTapCompleteBtn
    case didPickedImages([UIImage])
    case didTapDeleteBtn(Int)
    case didChangeTitle(String)
    case didChangeContent(String)
    case didTapAnonymousBtn(Bool)
    case viewDidLoad
  }
  
  enum Mutation {
    case setGalleryVC(Bool)
    case setImages([Photo])
    case deleteImages(Int)
    case setTitle(String)
    case setContents(String)
    case setCompleteBtn
    case setAnonymous(Bool)
    case setLoading(Bool)
    case setPopVC(Bool)
    case setDeletePostPhotoIds(Int)
  }
  
  struct State {
    var showsGalleryVC: Bool = false
    var currentImages: [Photo] = []
    var deletePostPhotoIds: [Int] = []
    var currentTitle: String = ""
    var currentContents: String = ""
    var isEnabledCompleteBtn: Bool = false
    var isAnonymous: Bool = true
    var isLoading: Bool = false
    var popVC: Bool = false
  }
  
  enum PostingType {
    case new
    case edit(Post)
  }
  
  private let currentDorm: Dormitory
  var post: Post?
  var initialState: State = State()
  let postingType: PostingType
  
  /// 네트워킹을 할 수 있는 `CommunityAPI`가 Warpping되어 있는 `APIManager`입니다.
  private let apiManager = NetworkService<CommunityAPI>()
  
  init(
    _ postingType: PostingType,
    dorm: Dormitory
  ) {
    self.currentDorm = dorm
    self.postingType = postingType
    switch postingType {
    case .new:
      break
    case .edit(let post):
      self.post = post
    }
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      switch postingType {
      case .new:
        return .empty()
      case .edit:
        guard let post = post else { return .empty() }
        var photos: [Photo] = []
        
        post.photos.forEach { [weak self] in
          var image: UIImage?
          self?.downloadImage(
            from: URL(string: $0.photoURL)!
          ) {
            image = $0
          }
          photos.append(Photo(image: image!, index: $0.photoID))
        }
        
        return .concat([
          .just(.setTitle(post.title)),
          .just(.setContents(post.content)),
          .just(.setImages(photos)),
          .just(.setAnonymous(post.isAnonymous))
        ])
      }
      
    case .didTapPictIv:
      return .concat([
        .just(.setGalleryVC(true)),
        .just(.setGalleryVC(false))
      ])
      
    case .didTapCompleteBtn:
      switch postingType {
      case .edit:
        guard let post = post else { return .empty() }
        let photos = currentState.currentImages
          .filter { $0.index < 0 }
          .map { $0.image }
        
        let newPost = CommunityRequestModel.Post(
          content: currentState.currentContents,
          title: currentState.currentTitle,
          dormCategory: .no1,
          images: photos,
          isAnonymous: currentState.isAnonymous
        )
        
        return .concat([
          .just(.setLoading(true)),
          CommunityAPI.provider.rx.request(.editPost(
            postId: post.identifier,
            post: newPost,
            deletePostPhotos: currentState.deletePostPhotoIds)
          )
          .asObservable()
          .flatMap { response -> Observable<Mutation> in
            switch response.statusCode {
            case 200..<300:
              return .concat([
                .just(.setLoading(false)),
                .just(.setPopVC(true))
              ])
            default:
              fatalError()
            }
          }
        ])
        
      case .new:
        var images: [UIImage] = []
        currentState.currentImages.forEach {
          images.append($0.image)
        }
        let newPost = CommunityRequestModel.Post(
          content: currentState.currentContents,
          title: currentState.currentTitle,
          dormCategory: currentDorm,
          images: images,
          isAnonymous: currentState.isAnonymous
        )
        return self.apiManager.requestAPI(to: .savePost(newPost))
          .flatMap { _ in return Observable<Mutation>.just(.setPopVC(true)) }
      }
      
    case .didPickedImages(let images):
      var photos: [Photo] = []
      images.forEach {
        photos.append(Photo(image: $0, index: -1))
      }
      return .just(.setImages(photos))
      
    case .didTapDeleteBtn(let index):
      switch postingType {
      case .new:
        return .just(.deleteImages(index))
      case .edit:
        guard let post = post else { return .empty() }
        let photo = currentState.currentImages[index]
        let deleteIndex = post.photos.first(where: { $0.photoID == photo.index })?.photoID
        if deleteIndex != nil {
          return .concat([
            .just(.deleteImages(index)),
            .just(.setDeletePostPhotoIds(deleteIndex!))
          ])
        }
        return .just(.deleteImages(index))
      }
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
      
    case .setDeletePostPhotoIds(let id):
      newState.deletePostPhotoIds.append(id)
    }
    
    return newState
  }
}

extension CommunityPostingViewReactor {
  // 이미지를 다운로드하고 이를 UIImage로 변환하는 함수
  func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
    KingfisherManager.shared.retrieveImage(with: url) { result in
      switch result {
      case .success(let imageResult):
        completion(imageResult.image)
      case .failure(let error):
        print("Error: \(error.localizedDescription)")
        completion(nil)
      }
    }
  }
}
