//
//  UIImage+.swift
//  idorm
//
//  Created by 김응철 on 7/8/23.
//

import UIKit

enum iDormIcon: String {
  case left
  
  case right
  
  case block
  
  case community
  case calendar
  case cancel
  case closedEye
  case checkCircle
  
  case domi
  case domi_sad
  case domiWithBackgrond
  case dormitory
  case deselect
  case down
  
  case gear

  case option
  case openedEye
  
  case pencil
  case pencil2
  
  case speechBubble
  case share
  case squareRight
  
  case photo
  
  case select
  
  case remove
  case repetition
  case reply
  case right_quotation_marks
  
  case home
  case human
  case human_fill
  case heart
  
  case thumb
  case trashcan
  
  case filter
  
  case kakao
  
  case note
  
  case left_quotation_marks
  
  case inu
  case idorm
  
  case mailBox
  case matching
  
  case x_circle_mono
  
  // MatchingMate
  case matchingMate_like
  case matchingMate_like_highlighted
  case matchingMate_dislike
  case matchingMate_dislike_highlighted
  case matchingMate_reverse
  case matchingMate_reverse_highlighted
  case matchingMate_message
  case matchingMate_message_highlighted
}

enum iDormText: String {
  case inviteRoommate
}

enum iDormImage: String {
  case deselect
  case dislike_circle
  case domi
  case domi_sad
  case domi_background
  
  case select
  
  case photo_circle
  
  case like_circle
  
  case pencil_circle
  
  case thumb_circle
  
  case speechbubble_circle
  
  case human
  
  case matchingMate_background
}

extension UIImage {
  /// `UIImage` 타입인 아이콘을 추출합니다.
  ///
  /// - Parameters:
  ///  - icon: 원하는 아이콘의 케이스
  ///
  /// - returns:
  /// 원하는 아이콘의 `UIimage`
  static func iDormIcon(_ icon: iDormIcon) -> UIImage? {
    return UIImage(named: "ic_\(icon.rawValue)")
  }
  
  /// `UIImage` 타입인 텍스트(이미지)를 추출합니다.
  ///
  /// - Parameters:
  ///  - text: 원하는 텍스트 이미지
  ///
  /// - returns:
  /// 원하는 텍스트 이미지의 `UIImage`
  static func iDormText(_ text: iDormText) -> UIImage? {
    return UIImage(named: "txt_\(text.rawValue)")
  }
  
  /// `UIImage` 타입인 배경이 있는 이미지를 추출합니다.
  ///
  /// - Parameters:
  ///    - image: 원하는 배경이 있는 이미지
  ///
  /// - returns:
  /// 원하는 배경이 있는 이미지의 `UIImage`
  static func iDormImage(_ image: iDormImage) -> UIImage? {
    return UIImage(named: "img_\(image.rawValue)")
  }
  
  /// 이미지의 사이즈를 재설정합니다.
  ///
  /// - Parameters:
  ///   - newSize: 새롭게 정의되는 사이즈 값
  ///
  /// - Returns: 새로운 사이즈로 만들어진 `UIImage?`
  func resize(newSize: CGFloat) -> UIImage? {
    let newSize = CGSize(width: newSize, height: newSize)
    let renderer = UIGraphicsImageRenderer(size: newSize)
    let renderedImage = renderer.image { _ in
      self.draw(in: CGRect(origin: .zero, size: newSize))
    }
    return renderedImage
  }
}
