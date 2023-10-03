//
//  TeamMember.swift
//  idorm
//
//  Created by 김응철 on 10/1/23.
//

import Foundation

struct TeamMember: Hashable {
  /// 멤버의 식별자
  let identifier: Int
  let nickname: String
  let order: Int
  let profilePhotoURL: String?
  let isSleepover: Bool
  
  init() {
    self.identifier = -1
    self.nickname = ""
    self.order = 0
    self.profilePhotoURL = nil
    self.isSleepover = false
  }
  
  init(_ responseDTO: TeamCalendarSingleMemberResponseDTO) {
    self.identifier = responseDTO.memberId
    self.nickname = responseDTO.nickname
    self.order = responseDTO.order
    self.profilePhotoURL = responseDTO.profilePhotoUrl
    self.isSleepover = responseDTO.sleepoverYn
  }
}
