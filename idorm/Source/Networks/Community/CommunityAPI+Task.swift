//
//  CommunityAPI+Task.swift
//  idorm
//
//  Created by 김응철 on 2023/01/27.
//

import Moya

extension CommunityAPI {
  func getTask() -> Task {
    switch self {
    case let .lookupPosts(_, page):
      return .requestParameters(parameters: [
        "page": page
      ], encoding: URLEncoding.queryString)
      
    case .lookupTopPosts:
      return .requestPlain
      
    case .lookupMyComments:
      return .requestPlain
      
    case .lookupMyPosts:
      return .requestPlain
      
    case .lookupMyLikedPosts:
      return .requestPlain
      
    case .savePost(let post):
      var multiFormDatas: [MultipartFormData] = []
      
      let titleData = MultipartFormData(provider: .data(post.title.data(using: .utf8)!), name: "title")
      let contentsData = MultipartFormData(provider: .data(post.content.data(using: .utf8)!), name: "content")
      let anonymousData = MultipartFormData(provider: .data(post.isAnonymous.description.data(using: .utf8)!), name: "isAnonymous")
      let dormNumData = MultipartFormData(provider: .data(post.dormCategory.rawValue.data(using: .utf8)!), name: "dormCategory")
      
      multiFormDatas = [titleData, contentsData, anonymousData, dormNumData]
      
      for i in 0..<post.images.count {
        let image = post.images[i]
        let data = image.jpegData(compressionQuality: 0.9)!
        let imageData = MultipartFormData(provider: .data(data), name: "files", fileName: "\(i)", mimeType: "image/jpeg")
        multiFormDatas.append(imageData)
      }
      
      return .uploadMultipart(multiFormDatas)
      
    case .lookupDetailPost:
      return .requestPlain
      
    case .saveComment(_, let comment):
      return .requestJSONEncodable(comment)
      
    case .editPostSympathy:
      return .requestPlain
      
    case .deleteComment:
      return .requestPlain
      
    case .deletePost:
      return .requestPlain
      
    case let .editPost(_, post, deletePostPhotos):
      var multiFormDatas: [MultipartFormData] = []
      
      let titleData = MultipartFormData(
        provider: .data(post.title.data(using: .utf8)!),
        name: "title"
      )
      let contentsData = MultipartFormData(
        provider: .data(post.content.data(using: .utf8)!),
        name: "content"
      )
      let anonymousData = MultipartFormData(
        provider: .data(post.isAnonymous.description.data(using: .utf8)!),
        name: "isAnonymous"
      )

      multiFormDatas = [titleData, contentsData, anonymousData]
      
      deletePostPhotos.forEach { index in
        let data = MultipartFormData(
          provider: .data(index.description.data(using: .utf8)!),
          name: "deletePostPhotoIds"
        )
        multiFormDatas.append(data)
      }
      
      for i in 0..<post.images.count {
        let image = post.images[i]
        let data = image.jpegData(compressionQuality: 0.9)!
        let imageData = MultipartFormData(
          provider: .data(data),
          name: "files",
          fileName: "\(i)",
          mimeType: "image/jpeg"
        )
        multiFormDatas.append(imageData)
      }
      
      return .uploadMultipart(multiFormDatas)
    }
  }
}
