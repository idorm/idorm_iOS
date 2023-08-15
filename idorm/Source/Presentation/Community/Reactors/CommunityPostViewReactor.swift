//
//  PostDetailViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2023/01/23.
//

import UIKit

import ReactorKit
import RxMoya
import Kingfisher

import KakaoSDKShare
import KakaoSDKTemplate
import KakaoSDKCommon

final class CommunityPostViewReactor: Reactor {
  
  enum Action {
    case viewDidLoad
    case commentDidChange(String)
    case sendButtonDidTap
    case replyButtonDidTap(index: IndexPath, commendID: Int)
    case backgroundDidTap
    case anonymousButtonDidTap(Bool)
    case sympathyButtonDidTap(Bool)
    case deleteCommentButtonDidTap(commentId: Int)
    case pullToRefresh
    case deletePostButtonDidTap
    case editPostButtonDidTap
    case photoCellDidTap(index: Int)
  }
  
  enum Mutation {
    case setPost(Post)
    
    case setAnonymous(Bool)
    case setSympathy(Bool)
    case setComment(String)
    case setComments([Comment])
    case setFocusedComment(Int?)
    case setCellBackgroundColor(Bool, IndexPath)
    case setEndEditing(Bool)
    case setEndRefresh(Bool)
    
    // Presentation
    case setPopping(Bool)
    case setCommunityPosting
    case setImageSlide(index: Int)
  }
  
  struct State {
    // Data
    var post: Post
    
    var isSympathy: Bool = false
    var isPresentedAlert: (Bool, String) = (false, "")
    var currentComment: String = ""
    var currentComments: [Comment] = []
    var isAnonymous: Bool = true
    var currentFocusedComment: Int?
    var currentCellBackgroundColor: (Bool, IndexPath) = (false, IndexPath())
    var endEditing: Bool = false
    var endRefresh: Bool = false
    
    // Presentation
    @Pulse var isPopping: Bool = false
    @Pulse var navigateToCommunityPosting: Post?
    @Pulse var presentImageSlide: (photosURL: [String], index: Int)?

    // UI
    var items: [[CommunityPostSectionItem]] = []
    var sections: [CommunityPostSection] = []
  }
  
  // MARK: - Properties
  
  private let apiManager = APIManager<CommunityAPI>()
  var initialState: State

  // MARK: - Initializer
  
  init(_ post: Post) {
    self.initialState = State(post: post)
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return .empty()
      
    case .commentDidChange(let comment):
      return .just(.setComment(comment))
      
    case .sendButtonDidTap:
      let indexPath = currentState.currentCellBackgroundColor.1
      let requestDTO = CommunityCommentRequestDTO(
        content: self.currentState.currentComment,
        isAnonymous: self.currentState.isAnonymous,
        parentCommentId: self.currentState.currentFocusedComment
      )
      
      return .concat([
        .just(.setCellBackgroundColor(false, indexPath)),
        .just(.setFocusedComment(nil)),
        self.apiManager.requestAPI(to: .saveComment(
          postId: self.currentState.post.identifier,
          body: requestDTO
        ))
        .flatMap { _ in
          return Observable<Mutation>.concat([
            self.getSinglePost(),
            .just(.setEndEditing(true)),
            .just(.setEndEditing(false))
          ])
        }
      ])
      
    case let .replyButtonDidTap(indexPath, parentId):
      return .concat([
        .just(.setFocusedComment(parentId)),
        .just(.setCellBackgroundColor(true, indexPath)),
      ])
      
    case .backgroundDidTap:
      let indexPath = currentState.currentCellBackgroundColor.1
      return .concat([
        .just(.setCellBackgroundColor(false, indexPath)),
        .just(.setFocusedComment(nil)),
      ])
      .subscribe(on: MainScheduler.asyncInstance)
      
    case .anonymousButtonDidTap(let isSelected):
      return .just(.setAnonymous(isSelected))
      
    case .sympathyButtonDidTap(let isSympathy):
      return self.apiManager.requestAPI(to: .editPostSympathy(
        postId: self.currentState.post.identifier,
        isSympathy: isSympathy
      )).flatMap { _ in self.getSinglePost() }
      
    case .deleteCommentButtonDidTap(let commentID):
      return self.apiManager.requestAPI(to: .deleteComment(
        postId: self.currentState.post.identifier,
        commentId: commentID
      )).flatMap { _ in return self.getSinglePost() }
      
    case .pullToRefresh:
      return self.getSinglePost()
      
    case .deletePostButtonDidTap:
      return self.apiManager.requestAPI(to: .deletePost(postId: self.currentState.post.identifier))
        .flatMap { _ in return Observable<Mutation>.just(.setPopping(true)) }
      
    case .editPostButtonDidTap:
      return .just(.setCommunityPosting)
      
    case .photoCellDidTap(let index):
      return .just(.setImageSlide(index: index))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setPost(let post):
      newState.post = post
      
    case .setComment(let comment):
      newState.currentComment = comment
      
    case .setComments(let comments):
      newState.currentComments = comments
      
    case let .setFocusedComment(commentId):
      newState.currentFocusedComment = commentId
      
    case let .setCellBackgroundColor(isBlocked, indexPath):
      newState.currentCellBackgroundColor = (isBlocked, indexPath)
      
    case .setAnonymous(let isSelected):
      newState.isAnonymous = isSelected
      
    case .setSympathy(let isSympathy):
      newState.isSympathy = isSympathy
      
    case .setEndEditing(let state):
      newState.endEditing = state
      
    case .setEndRefresh(let state):
      newState.endRefresh = state
      
    case .setPopping(let isPopping):
      newState.isPopping = isPopping
      
    case .setCommunityPosting:
      newState.navigateToCommunityPosting = state.post
      
    case .setImageSlide(let index):
      newState.presentImageSlide = (state.post.photos.map { $0.photoURL }, index)
    }
    
    return newState
  }
  
  func transform(state: Observable<State>) -> Observable<State> {
    return state.map { state in
      var newState = state
      
      var items: [[CommunityPostSectionItem]] = []
      var sections: [CommunityPostSection] = []
      
      // Content
      sections.append(.contents)
      items.append([.content(state.post)])
      
      // Photos
      if state.post.photos.isNotEmpty {
        sections.append(.photos)
        items.append(state.post.photos.map { CommunityPostSectionItem.photo($0.photoURL) })
      }
      
      // MultiBox
      sections.append(.multiBox)
      items.append([.multiBox(state.post)])
      
      // Comment
      sections.append(.comments)
      if state.post.comments.isEmpty {
        items.append([.emptyComment])
      } else {
        items.append(state.post.comments.map { CommunityPostSectionItem.comment($0) })
      }
      
      newState.sections = sections
      newState.items = items
      
      return newState
    }
  }
}

// MARK: - Privates

private extension CommunityPostViewReactor {
  /// 단일 게시글을 서버에서 불러옵니다.
  func getSinglePost() -> Observable<Mutation> {
    return self.apiManager.requestAPI(to: .lookupDetailPost(postId: self.currentState.post.identifier))
      .map(ResponseDTO<CommunitySinglePostResponseDTO>.self)
      .flatMap { return Observable<Mutation>.just(.setPost($0.data.toPost())) }
  }
}
