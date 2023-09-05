//
//  Member.swift
//  idorm
//
//  Created by 김응철 on 9/1/23.
//

import Foundation

/// 멤버의 정보를 나타냅니다.
struct Member {
  /// 해당 멤버의 식별자
  let identifier: Int
  let email: String
  let nickname: String
  let profilePhotoURL: String?
  
  // MARK: - Initializer
  
  /// `MemberSingleResponseDTO` To `Member`
  init(_ responseDTO: MemberSingleResponseDTO) {
    self.identifier = responseDTO.memberId
    self.email = responseDTO.email
    self.nickname = responseDTO.nickname
    self.profilePhotoURL = responseDTO.profilePhotoUrl
  }
}
