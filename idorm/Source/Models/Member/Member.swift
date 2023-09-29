//
//  Member.swift
//  idorm
//
//  Created by 김응철 on 9/1/23.
//

import Foundation

/// 멤버의 정보를 나타냅니다.
struct Member: Codable {
  /// 해당 멤버의 식별자
  let identifier: Int
  var email: String
  var nickname: String
  var profilePhotoURL: String?
  
  // MARK: - Initializer
  
  init() {
    self.identifier = -1
    self.email = ""
    self.nickname = ""
    self.profilePhotoURL = nil
  }

  /// `MemberSingleResponseDTO` To `Member`
  init(_ responseDTO: MemberSingleResponseDTO) {
    self.identifier = responseDTO.memberId
    self.email = responseDTO.email
    self.nickname = responseDTO.nickname
    self.profilePhotoURL = responseDTO.profilePhotoUrl
  }
}
