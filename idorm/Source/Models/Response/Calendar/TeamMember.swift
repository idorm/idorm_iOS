//
//  Target.swift
//  idorm
//
//  Created by 김응철 on 7/11/23.
//

import Foundation

struct TeamMember: Decodable, Hashable {
  let memberId: Int
  let nickname: String
  let order: Int
  let profilePhotoUrl: String
}
