import UIKit

import SnapKit
import RxSwift
import RxCocoa
import Then

final class MyPageSortHeaderView: UITableViewHeaderFooterView {
  
  // MARK: - Properties
  
  static let identifier = "MyPageSortHeaderView"
  
  private lazy var latestLabel = label("최신순")
  private lazy var pastLabel = label("과거순")
  
  lazy var latestButton = button()
  lazy var pastButton = button()
  
  var isLatest = BehaviorSubject<Bool>(value: true)
  private let disposeBag = DisposeBag()
  
  // MARK: - LifeCycle
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setupStyles()
    setupLayout()
    setupConstraints()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupStyles() {
    backgroundColor = .idorm_gray_100
    latestButton.isSelected = true
  }
  
  private func setupLayout() {
    [
      latestLabel,
      latestButton,
      pastLabel,
      pastButton
    ].forEach { addSubview($0) }
  }
  
  private func setupConstraints() {
    latestLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
    }
    
    latestButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalTo(latestLabel.snp.trailing).offset(8)
    }
    
    pastLabel.snp.makeConstraints { make in
      make.leading.equalTo(latestButton.snp.trailing).offset(16)
      make.centerY.equalToSuperview()
    }
    
    pastButton.snp.makeConstraints { make in
      make.leading.equalTo(pastLabel.snp.trailing).offset(8)
      make.centerY.equalToSuperview()
    }
  }
  
  // MARK: - Bind
  
  func bind() {
    latestButton.rx.tap
      .withUnretained(self)
      .do(onNext: { owner, _ in
        owner.latestButton.isSelected = true
        owner.pastButton.isSelected = false
      })
      .map { _ in true }
      .bind(to: isLatest)
      .disposed(by: disposeBag)
    
    pastButton.rx.tap
      .withUnretained(self)
      .do(onNext: { owner, _ in
        owner.latestButton.isSelected = false
        owner.pastButton.isSelected = true
      })
      .map { _ in false }
      .bind(to: isLatest)
      .disposed(by: disposeBag)
  }
}

// MARK: - Helpers

extension MyPageSortHeaderView {
  private func label(_ title: String) -> UILabel {
    let label = UILabel()
    label.textColor = .black
    label.text = title
    label.font = .init(name: IdormFont_deprecated.regular.rawValue, size: 14)
    
    return label
  }
  
  private func button() -> UIButton {
    let button = UIButton()
    button.setImage(#imageLiteral(resourceName: "circle_gray"), for: .normal)
    button.setImage(#imageLiteral(resourceName: "circle_blue"), for: .selected)
    
    return button
  }
}

