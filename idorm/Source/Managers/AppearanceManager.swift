//
//  AppearanceManager.swift
//  idorm
//
//  Created by 김응철 on 9/30/23.
//

import UIKit

final class AppearanceManager {
  
  // MARK: - Functions
  
  static func tabBarAppearance() {
    let appearance = UITabBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = .white
    appearance.backgroundImage = UIImage()
    appearance.shadowImage = UIImage()
    appearance.shadowColor = .clear
    UITabBar.appearance().scrollEdgeAppearance = appearance
    UITabBar.appearance().standardAppearance = appearance
  }
  
  static func navigationAppearance() {
    let appearance = UINavigationBarAppearance()
    // BackButton
    let backButtonAppearance = UIBarButtonItemAppearance()
    let backButtonImage: UIImage? = .iDormIcon(.left)?
      .withRenderingMode(.alwaysOriginal)
      .withTintColor(.black)
      .withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -12, bottom: -5, right: 0))
    backButtonAppearance.normal.titleTextAttributes = [
      .foregroundColor: UIColor.clear,
      .font: UIFont.systemFont(ofSize: 0)
    ]
    appearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
    appearance.backButtonAppearance = backButtonAppearance
    // Title
    appearance.titleTextAttributes = [
      .foregroundColor: UIColor.black,
      .font: UIFont.iDormFont(.regular, size: 16.0)
    ]
    // Shadow
    appearance.shadowColor = nil
    appearance.shadowImage = UIImage()
    
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
  }}
