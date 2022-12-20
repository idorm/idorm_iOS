//
//  MemberDTO.swift
//  idorm
//
//  Created by 김응철 on 2022/12/20.
//

import Foundation

struct MemberDTO: Codable {}

extension MemberDTO {
  struct Retrieve: Codable {
    let id: Int
    let email: String
    var nickname: String
    var profilePhotoUrl: String?
    let matchingInfoId: Int?
    let loginToken: String?
  }
}
