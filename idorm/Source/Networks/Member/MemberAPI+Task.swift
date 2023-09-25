//
//  MemberAPI+Task.swift
//  idorm
//
//  Created by 김응철 on 2023/01/31.
//

import Foundation

import Moya

extension MemberAPI {
  func getTask() -> Task {
    switch self {
    case let .login(id, pw):
      return .requestParameters(parameters: [
        "email": id,
        "password": pw,
      ], encoding: JSONEncoding.default)
      
    case let .updatePassword(email, password):
      return .requestParameters(parameters: [
        "email": email,
        "password": password
      ], encoding: JSONEncoding.default)
      
    case let .register(id, pw, nickname):
      return .requestParameters(parameters: [
        "email": id,
        "nickname": nickname,
        "password": pw
        ], encoding: JSONEncoding.default)
      
    case .updateNickname(let nickname):
      return .requestParameters(parameters: [
        "nickname": nickname
      ], encoding: JSONEncoding.default)
      
    case .getUser, .deleteUser:
      return .requestPlain
      
    case .createProfilePhoto(let image):
      let multiPartData = MultipartFormData(
        provider: .data(image.jpegData(compressionQuality: 0.9)!),
        name: "file",
        fileName: "MyProfile",
        mimeType: "image/jpeg"
      )
      return .uploadMultipart([multiPartData])
      
    case .deleteProfilePhoto:
      return .requestPlain
      
    case .logout:
      return .requestPlain
      
    case .updateFCM:
      return .requestPlain
      
    }
  }
}
