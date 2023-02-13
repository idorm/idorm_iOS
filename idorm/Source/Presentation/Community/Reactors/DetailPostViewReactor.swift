//
//  PostDetailViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2023/01/23.
//

import Foundation

import ReactorKit
import RxMoya

final class DetailPostViewReactor: Reactor {
  
  enum Action {
    case viewDidLoad
    case didChangeComment(String)
    case didTapSendButton
    case didTapReplyButton(indexPath: Int, parentId: Int)
    case didTapBackground
    case didTapAnonymousButton(Bool)
    case didTapSympathyButton(Bool)
  }
  
  enum Mutation {
    case setLoading(Bool)
    case setAnonymous(Bool)
    case setSympathy(Bool)
    case setPost(CommunityResponseModel.Post)
    case setComment(String)
    case setComments([OrderedComment])
    case setFocusedComment(Int?)
    case setCellBackgroundColor(Bool, Int)
    case setAlert(Bool, String)
  }
  
  struct State {
    var isLoading: Bool = false
    var isSympathy: Bool = false
    var isPresentedAlert: (Bool, String) = (false, "")
    var currentPost: CommunityResponseModel.Post?
    var currentComment: String = ""
    var currentComments: [OrderedComment] = []
    var isAnonymous: Bool = true
    var currentFocusedComment: Int?
    var currentCellBackgroundColor: (Bool, Int) = (false, 0)
  }
  
  var initialState: State = State()
  let postId: Int
  
  init(_ postId: Int) {
    self.postId = postId
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidLoad:
      return .concat([
        .just(.setLoading(true)),
        retrievePost()
      ])
      
    case .didChangeComment(let comment):
      return .just(.setComment(comment))
      
    case .didTapSendButton:
      return .concat([
        .just(.setLoading(true)),
        saveComment(currentState.currentFocusedComment)
      ])
      
    case let .didTapReplyButton(indexPath, parentId):
      return .concat([
        .just(.setFocusedComment(parentId)),
        .just(.setCellBackgroundColor(true, indexPath)),
      ])
      
    case .didTapBackground:
      return .concat([
        .just(.setCellBackgroundColor(false, 0)),
        .just(.setFocusedComment(nil)),
      ])
      .subscribe(on: MainScheduler.asyncInstance)
      
    case .didTapAnonymousButton(let isSelected):
      return .just(.setAnonymous(isSelected))
      
    case .didTapSympathyButton(let isSympathy):
      return .concat([
        .just(.setLoading(true)),
        CommunityAPI.provider.rx.request(.editPostSympathy(postId: postId, isSympathy: isSympathy))
          .asObservable()
          .withUnretained(self)
          .flatMap { owner, response -> Observable<Mutation> in
            switch response.statusCode {
            case 200..<300:
              return .concat([
                .just(.setSympathy(isSympathy)),
                owner.retrievePost()
              ])
            case 409:
              return .concat([
                .just(.setLoading(false)),
                .just(.setAlert(true, "내 게시글은 공감할 수 없습니다.")),
                .just(.setAlert(false, ""))
              ])
            default:
              return .empty()
            }
          }
      ])
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .setLoading(let isLoading):
      newState.isLoading = isLoading
      
    case .setPost(let post):
      newState.currentPost = post
      
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
      
    case let .setAlert(isBlocked, title):
      newState.isPresentedAlert = (isBlocked, title)
    }
    
    return newState
  }
}

private extension DetailPostViewReactor {
  func retrievePost() -> Observable<Mutation> {
    return CommunityAPI.provider.rx.request(
      .lookupDetailPost(postId: postId)
    )
      .asObservable()
      .retry()
      .flatMap { response -> Observable<Mutation> in
        switch response.statusCode {
        case 200..<300:
          let post = CommunityAPI.decode(
            ResponseModel<CommunityResponseModel.Post>.self,
            data: response.data
          ).data
          
          let orderedComments = CommentUtils.newestOrderedComments(post.comments)
          
          return .concat([
            .just(.setLoading(false)),
            .just(.setComments(orderedComments)),
            .just(.setPost(post))
          ])

        default:
          // TODO: 게시글 삭제 알럿 구현
          return .empty()
        }
      }
  }
  
  func saveComment(_ parentId: Int? = nil) -> Observable<Mutation> {
    let comment = CommunityRequestModel.Comment(
      content: currentState.currentComment,
      isAnonymous: currentState.isAnonymous,
      parentCommentId: parentId
    )
    
    return CommunityAPI.provider.rx.request(
      .saveComment(
        postId: postId,
        body: comment)
    )
      .asObservable()
      .withUnretained(self)
      .flatMap { owner, response -> Observable<Mutation> in
        switch response.statusCode {
        case 200..<300:
          return .concat([
            owner.retrievePost(),
            .just(.setComment(""))
          ])
        default:
          // TODO: 게시글 삭제 알럿 구현
          return .empty()
        }
      }
  }
}
