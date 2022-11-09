import UIKit

import Then
import RxSwift
import RxCocoa
import RxGesture
import SnapKit

final class ManageMyInfoViewController: BaseViewController {
  
  // MARK: - Properties
  
  private var scrollView: UIScrollView!
  private var contentView: UIView!
  
  private let profileImage = UIImageView(image: UIImage(named: "myProfileImage(MyPage)"))
  
  private var nickNameView: ManageMyInfoView!
  private var changePasswordView: ManageMyInfoView!
  private var emailView: ManageMyInfoView!
  private var versionView: ManageMyInfoView!
  
  private var separatorLine1: UIView!
  private var separatorLine2: UIView!
  
  private let withDrawLabel = UILabel().then {
    $0.text = "회원 탈퇴"
    $0.font = .init(name: MyFonts.regular.rawValue, size: 14)
    $0.textColor = .idorm_gray_300
  }
  
  private let viewModel = ManageMyInfoViewModel()
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    setupScrollView()
    setupComponents()
    super.viewDidLoad()
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
    // 화면 접속 시 UI 업데이트
    Observable.just(Void())
      .bind(onNext: { [unowned self] in
        self.updateUI()
      })
      .disposed(by: disposeBag)
    
    // 닉네임 버튼 클릭 이벤트
    nickNameView.rx.tapGesture()
      .map { _ in Void() }
      .bind(to: viewModel.input.nicknameButtonTapped)
      .disposed(by: disposeBag)
    
    // MARK: - Output
    
    // ChangeNickNameVC 보여주기
    viewModel.output.showChangeNicknameVC
      .bind(onNext: { [weak self] in
        let changeNicknameVC = ChangeNicknameViewController()
        self?.navigationController?.pushViewController(changeNicknameVC, animated: true)
      })
      .disposed(by: disposeBag)
    
    // 멤버 정보 변경되면 UI 업데이트
    MemberInfoStorage.shared.memberInfo
      .bind(onNext: { [unowned self] memberInfo in
        self.nickNameView.descriptionLabel.text = memberInfo.nickname
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  private func setupScrollView() {
    let scrollView = UIScrollView()
    scrollView.contentInsetAdjustmentBehavior = .never
    self.scrollView = scrollView
    
    let contentView = UIView()
    contentView.backgroundColor = .white
    self.contentView = contentView
  }
  
  private func setupComponents() {
    self.nickNameView = ManageMyInfoView(type: .both(description: "닉네임닉네임"), title: "닉네임")
    self.changePasswordView = ManageMyInfoView(type: .onlyArrow, title: "비밀번호 변경")
    self.emailView = ManageMyInfoView(type: .onlyDescription(description: "asdf@inu.ac.kr"), title: "이메일")
    self.versionView = ManageMyInfoView(type: .onlyDescription(description: "1.0.0"), title: "버전정보")
    
    self.separatorLine1 = MyPageUtilities.separatorLine()
    self.separatorLine2 = MyPageUtilities.separatorLine()
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    navigationItem.title = "내 정보 관리"
    view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    
    [profileImage, nickNameView, changePasswordView, emailView, separatorLine1, versionView, separatorLine2, withDrawLabel]
      .forEach { contentView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.bottom.leading.trailing.equalToSuperview()
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalTo(view.frame.width)
    }
    
    profileImage.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(24)
    }
    
    nickNameView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(profileImage.snp.bottom).offset(24)
      make.height.equalTo(45)
    }
    
    changePasswordView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(nickNameView.snp.bottom)
      make.height.equalTo(45)
    }
    
    emailView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(changePasswordView.snp.bottom)
      make.height.equalTo(45)
    }
    
    separatorLine1.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(emailView.snp.bottom).offset(32)
      make.height.equalTo(6)
    }
    
    versionView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(separatorLine1.snp.bottom).offset(24)
      make.height.equalTo(45)
    }
    
    separatorLine2.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(versionView.snp.bottom).offset(32)
      make.height.equalTo(6)
    }
    
    withDrawLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(separatorLine2.snp.bottom).offset(32)
      make.bottom.equalToSuperview()
    }
  }
  
  // MARK: - Helpers
  
  private func updateUI() {
    let memberInfo =  MemberInfoStorage.shared.memberInfo.value
    nickNameView.descriptionLabel.text = memberInfo.nickname ?? "닉네임"
    emailView.descriptionLabel.text = memberInfo.email
    // TODO: 프로필 이미지 설정해주기
  }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct ManageMyInfoVC_PreView: PreviewProvider {
  static var previews: some View {
    ManageMyInfoViewController().toPreview()
  }
}
#endif
