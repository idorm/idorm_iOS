//
//  MemberResponseModel.swift
//  idorm
//
//  Created by 김응철 on 2023/01/27.
//

import Foundation

enum MemberResponseModel {}

extension MemberResponseModel {
  struct Member: Codable {
    let memberId: Int
    let email: String
    var nickname: String
    var profilePhotoUrl: String?
  }
}
