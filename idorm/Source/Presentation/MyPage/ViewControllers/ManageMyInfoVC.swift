import UIKit
import PhotosUI

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import RxGesture
import Kingfisher

final class ManageMyInfoViewController: BaseViewController, View {
  
  // MARK: - Properties
  
  private let scrollView = UIScrollView().then {
    $0.contentInsetAdjustmentBehavior = .never
  }
  
  private let contentView = UIView().then {
    $0.backgroundColor = .white
  }
  
  private let withDrawLabel = UILabel().then {
    $0.text = "회원 탈퇴"
    $0.font = .init(name: IdormFont_deprecated.regular.rawValue, size: 14)
    $0.textColor = .idorm_gray_300
  }
  
  private let logoutButton = OldiDormButton("로그아웃")
  private let nickNameView = ManageMyInfoView(.both(title: "닉네임"))
  private let changePWView = ManageMyInfoView(.onlyArrow(title: "비밀번호 변경"))
  private let emailView = ManageMyInfoView(.onlyDescription(title: "이메일"))
  private let versionView = ManageMyInfoView(.onlyDescription(description: .version ,title: "버전정보"))
  private let termsView = ManageMyInfoView(.onlyArrow(title: "서비스 약관 자세히 보기"))
  
  private let profileImage: UIImageView = {
    let iv = UIImageView(image: #imageLiteral(resourceName: "sqaure_human"))
    iv.contentMode = .scaleToFill
    iv.layer.cornerRadius = 12
    iv.layer.masksToBounds = true
    return iv
  }()
  
  private lazy var separatorLine1 = separatorLine()
  private lazy var separatorLine2 = separatorLine()
  
  // MARK: - Bind
  
  func bind(reactor: ManageMyInfoViewReactor) {
    
    // MARK: - Action
    
    rx.viewWillAppear
      .map { _ in ManageMyInfoViewReactor.Action.viewWillAppear}
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 닉네임 버튼 클릭
    nickNameView.rx.tapGesture()
      .skip(1)
      .map { _ in ManageMyInfoViewReactor.Action.didTapNicknameButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 비밀번호 변경 버튼 클릭
    changePWView.rx.tapGesture()
      .skip(1)
      .map { _ in ManageMyInfoViewReactor.Action.didTapChangePwButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 회원탈퇴 버튼 클릭
    withDrawLabel.rx.tapGesture()
      .skip(1)
      .map { _ in ManageMyInfoViewReactor.Action.didTapWithDrawalButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 로그아웃 버튼 클릭
    logoutButton.rx.tap
      .map { ManageMyInfoViewReactor.Action.didTapLogoutButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    termsView.rx.tapGesture()
      .skip(1)
      .bind { _ in UIApplication.shared.open(URL(string: "https://idorm.notion.site/e5a42262cf6b4665b99bce865f08319b")!) }
      .disposed(by: disposeBag)
    
    profileImage.rx.tapGesture()
      .skip(1)
      .withUnretained(self)
      .bind { $0.0.didTapProfileImageView() }
      .disposed(by: disposeBag)
    
    // MARK: - State
    
    // 회원탈퇴 페이지로 이동
    reactor.state
      .map { $0.isOpenedWithDrawVC }
      .distinctUntilChanged()
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let viewController = WithdrawalViewController()
        viewController.reactor = WithDrawalViewReactor()
        owner.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: disposeBag)
    
    // ChangeNickNameVC 보여주기
    reactor.state
      .map { $0.isOpenedNicknameVC }
      .distinctUntilChanged()
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let changeNicknameVC = NicknameViewController(.modify)
        changeNicknameVC.reactor = NicknameViewReactor(.modify)
        owner.navigationController?.pushViewController(changeNicknameVC, animated: true)
      }
      .disposed(by: disposeBag)
    
    // ConfirmPwVC 이동
    reactor.state
      .map { $0.isOpenedConfirmPwVC }
      .distinctUntilChanged()
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let viewController = EmailViewController(.changePw)
        viewController.reactor = EmailViewReactor()
        owner.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: disposeBag)
    
    // LoginVC로 이동
    reactor.state
      .map { $0.isOpenedLoginVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let loginVC = LoginViewController()
        loginVC.reactor = LoginViewReactor()
        let navVC = UINavigationController(rootViewController: loginVC)
        navVC.modalPresentationStyle = .fullScreen
        owner.present(navVC, animated: true)
      }
      .disposed(by: disposeBag)
        
    // 닉네임 변경
    reactor.state
      .map { $0.currentNickname }
      .distinctUntilChanged()
      .bind(to: nickNameView.descriptionLabel.rx.text)
      .disposed(by: disposeBag)
    
    // 이메일 변경
    reactor.state
      .map { $0.currentEmail }
      .distinctUntilChanged()
      .bind(to: emailView.descriptionLabel.rx.text)
      .disposed(by: disposeBag)
    
    reactor.state.map { $0.profileImageURL }
      .bind(with: self) { owner, url in
        if let url = url {
          owner.profileImage.kf.setImage(
            with: URL(string: url),
            options: [.processor(RoundCornerImageProcessor(cornerRadius: 20))]
          )
        } else {
          owner.profileImage.image = #imageLiteral(resourceName: "sqaure_human")
        }
      }
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    navigationController?.setNavigationBarHidden(false, animated: true)
    navigationItem.title = "내 정보 관리"
    view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    
    [
      profileImage,
      nickNameView,
      changePWView,
      emailView,
      separatorLine1,
      versionView,
      termsView,
      separatorLine2,
      withDrawLabel,
      logoutButton
    ].forEach { contentView.addSubview($0) }
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
      make.width.height.equalTo(68.0)
      make.top.equalToSuperview().inset(24)
    }
    
    nickNameView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(profileImage.snp.bottom).offset(24)
      make.height.equalTo(45)
    }
    
    changePWView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(nickNameView.snp.bottom)
      make.height.equalTo(45)
    }
    
    emailView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(changePWView.snp.bottom)
      make.height.equalTo(45)
    }
    
    separatorLine1.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(emailView.snp.bottom).offset(32)
      make.height.equalTo(6)
    }
    
    termsView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(separatorLine1.snp.bottom).offset(24)
      make.height.equalTo(45)
    }

    versionView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(termsView.snp.bottom)
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
    }
    
    logoutButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(withDrawLabel.snp.bottom).offset(36)
      make.height.equalTo(52)
      make.bottom.equalToSuperview()
    }
  }
  
  // MARK: - Helpers
  
  private func separatorLine() -> UIView {
    let line = UIView()
    line.backgroundColor = .idorm_gray_100
    return line
  }
  
  private func presentImagePickerVC() {
    let cropVC = CropViewController()
    cropVC.modalPresentationStyle = .overFullScreen
    present(cropVC, animated: true)
    
    cropVC.completion = { [weak self] image in
      self?.reactor?.action.onNext(.didPickProfileImage(image))
    }
  }
  
  // 프로필 사진을 클릭했을 때의 로직입니다.
  private func didTapProfileImageView() {
    if UserStorage.shared.member?.profilePhotoUrl != nil {
      let deleteAction = UIAlertAction(
        title: "프로필 사진 삭제",
        style: .destructive
      ) { [weak self] _ in
        self?.reactor?.action.onNext(.deleteProfileImage)
      }
      let addAction = UIAlertAction(title: "프로필 사진 변경", style: .default) { [weak self] _ in
        self?.presentImagePickerVC()
      }
      let cancelAction = UIAlertAction(title: "취소", style: .cancel)
      let alertController = UIAlertController()
      alertController.addAction(addAction)
      alertController.addAction(deleteAction)
      alertController.addAction(cancelAction)
      present(alertController, animated: true)
    } else {
      presentImagePickerVC()
    }
  }
}
