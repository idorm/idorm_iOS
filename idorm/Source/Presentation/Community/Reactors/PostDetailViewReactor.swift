//
//  PostDetailViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2023/01/23.
//

import Foundation

import ReactorKit
import RxMoya

final class PostDetailViewReactor: Reactor {
  
  enum Action {
    case viewDidLoad
    case didChangeComment(String)
    case didTapSendButton
    case didTapReplyButton(Int)
  }
  
  enum Mutation {
    case setLoading(Bool)
    case setPost(CommunityResponseModel.Post)
    case setComment(String)
    case setComments([OrderedComment])
  }
  
  struct State {
    var isLoading: Bool = false
    var currentPost: CommunityResponseModel.Post?
    var currentComment: String = ""
    var currentComments: [OrderedComment] = []
    var isAnonymous: Bool = true
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
        saveComment()
      ])
      
    case .didTapReplyButton(let parentCommentId):
      return .concat([
        .just(.setLoading(true)),
        saveComment(parentCommentId)
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
    }
    
    return newState
  }
}

private extension PostDetailViewReactor {
  func retrievePost() -> Observable<Mutation> {
    return CommunityAPI.provider.rx.request(
      .retrievePost(postId: postId)
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
          
          let orderedComments = CommentUtils.registeredComments(post.comments)
          
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
          return owner.retrievePost()
        default:
          // TODO: 게시글 삭제 알럿 구현
          return .empty()
        }
      }
  }
}
