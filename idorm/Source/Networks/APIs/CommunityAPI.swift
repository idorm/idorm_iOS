//
//  CommunityAPI.swift
//  idorm
//
//  Created by 김응철 on 2023/01/14.
//

import UIKit

import Moya

enum CommunityAPI {
  case retrievePosts(dorm: Dormitory, page: Int)
  case retrieveTopPosts(Dormitory)
  case posting(CommunityDTO.Save)
}

extension CommunityAPI: TargetType {
  var baseURL: URL {
    return URL(string: APIService.baseURL)!
  }
  
  var path: String {
    switch self {
    case .retrievePosts(let dorm, _):
      return "/member/posts/\(dorm.rawValue)"
    case .retrieveTopPosts(let dorm):
      return "/member/posts/\(dorm.rawValue)/top"
    case .posting:
      return "/member/post"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .retrievePosts, .retrieveTopPosts:
      return .get
    case .posting:
      return .post
    }
  }
  
  var task: Moya.Task {
    switch self {
    case let .retrievePosts(_, page):
      return .requestParameters(parameters: [
        "page": page
      ], encoding: URLEncoding.queryString)
      
    case .retrieveTopPosts:
      return .requestPlain
      
    case .posting(let post):
      var multiFormDatas: [MultipartFormData] = []
      
      let titleData = MultipartFormData(provider: .data(post.title.data(using: .utf8)!), name: "title")
      let contentsData = MultipartFormData(provider: .data(post.content.data(using: .utf8)!), name: "content")
      let anonymousData = MultipartFormData(provider: .data(post.isAnonymous.description.data(using: .utf8)!), name: "isAnonymous")
      let dormNumData = MultipartFormData(provider: .data(post.dormNum.rawValue.data(using: .utf8)!), name: "dormNum")
      
      multiFormDatas = [titleData, contentsData, anonymousData, dormNumData]
      
      for i in 0..<post.assets.count {
        let image = post.assets[i].getImageFromPHAsset()
        let data = image.jpegData(compressionQuality: 0.1)!
        let imageData = MultipartFormData(provider: .data(data), name: "files", fileName: "\(i)", mimeType: "image/jpeg")
        multiFormDatas.append(imageData)
      }

      return .uploadMultipart(multiFormDatas)
    }
  }
  
  var headers: [String : String]? {
    switch self {
    case .posting:
      return APIService.multiPartHeader()
    default:
      return APIService.basicHeader()
    }
  }
}
