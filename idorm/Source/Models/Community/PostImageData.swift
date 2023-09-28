//
//  PostImage.swift
//  idorm
//
//  Created by 김응철 on 9/28/23.
//

import UIKit

struct PostImageData: Hashable {
  var identifier: Int
  var imageURL: String
  var image: UIImage?
  
  init(identifier: Int, imageURL: String, image: UIImage? = nil) {
    self.identifier = identifier
    self.imageURL = imageURL
    self.image = image
  }
  
  init(_ responseDTO: CommunityPostPhotoResponseDTO) {
    self.identifier = responseDTO.photoId
    self.imageURL = responseDTO.photoUrl
    self.image = nil
  }
}
