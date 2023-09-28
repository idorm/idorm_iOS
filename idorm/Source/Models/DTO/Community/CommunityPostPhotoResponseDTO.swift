//
//  CommunityPostPhotoResponseDTO.swift
//  idorm
//
//  Created by 김응철 on 8/11/23.
//

import Foundation

struct CommunityPostPhotoResponseDTO: Codable, Hashable {
  let photoId: Int
  let photoUrl: String
}

//extension Array where Element == CommunityPostPhotoResponseDTO {
//  func toPostPhotos() -> [PostPhoto] {
//    return self.map { PostPhoto(photoID: $0.photoId, photoURL: $0.photoUrl) }
//  }
//}
