import UIKit

import SnapKit
import Then
import CHIOTPField
import RSKGrowingTextView
import RxSwift
import RxCocoa

enum OnboardingVCType {
  /// 회원가입 후 최초 온보딩 접근
  case firstTime
  /// 메인페이지 최초 접속 후 온보딩 접근
  case mainPage_FirstTime
  /// 온보딩 수정
  case update
}

final class OnboardingViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let titleLabel = OnboardingUtilities.descriptionLabel("룸메이트 매칭을 위한 기본정보를 알려주세요!")
  private let floatyBottomView = FloatyBottomView(.reset)
  
  // MARK: - ScrollView
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  
  // MARK: - Dorm
  private let dormLabel = OnboardingUtilities.titleLabel(text: "기숙사")
  private let dorm1Button = OnboardingUtilities.basicButton(title: "1 기숙사")
  private let dorm2Button = OnboardingUtilities.basicButton(title: "2 기숙사")
  private let dorm3Button = OnboardingUtilities.basicButton(title: "3 기숙사")
  private let dormLine = OnboardingUtilities.separatorLine()
  private var dormStack: UIStackView!
  
  // MARK: - Gender
  private let genderLabel = OnboardingUtilities.titleLabel(text: "성별")
  private let maleButton = OnboardingUtilities.basicButton(title: "남성")
  private let femaleButton = OnboardingUtilities.basicButton(title: "여성")
  private let genderLine = OnboardingUtilities.separatorLine()
  private var genderStack: UIStackView!
  
  // MARK: - Period
  private let periodLabel = OnboardingUtilities.titleLabel(text: "입사 기간")
  private let period16Button = OnboardingUtilities.basicButton(title: "16 주")
  private let period24Button = OnboardingUtilities.basicButton(title: "24 주")
  private let periodLine = OnboardingUtilities.separatorLine()
  private var periodStack: UIStackView!
  
  // MARK: - Habit
  private let habitDescriptionLabel = OnboardingUtilities.descriptionLabel("불호요소가 있는 내 습관을 미리 알려주세요.")
  private let habitLabel = OnboardingUtilities.titleLabel(text: "내 습관")
  private let snoreButton = OnboardingUtilities.basicButton(title: "코골이")
  private let grindingButton = OnboardingUtilities.basicButton(title: "이갈이")
  private let smokingButton = OnboardingUtilities.basicButton(title: "흡연")
  private let allowedFoodButton = OnboardingUtilities.basicButton(title: "실내 음식 섭취 함")
  private let allowedEarphoneButton = OnboardingUtilities.basicButton(title: "이어폰 착용 안함")
  private let habitLine = OnboardingUtilities.separatorLine()
  private var habitStack1: UIStackView!
  private var habitStack2: UIStackView!
  
  // MARK: - Age
  private let ageTextField = CHIOTPFieldTwo().then {
    $0.numberOfDigits = 2
    $0.borderColor = .idorm_gray_200
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14)
    $0.cornerRadius = 10
    $0.spacing = 2
  }
  
  private let ageDescriptionLabel = OnboardingUtilities.descriptionLabel("살")
  private let ageLabel = OnboardingUtilities.titleLabel(text: "나이")
  private let ageLine = OnboardingUtilities.separatorLine()
  
  // MARK: - WakeUp
  private let wakeUpInfoLabel = OnboardingUtilities.infoLabel("기상시간을 알려주세요.", isEssential: true)
  private let wakeUpTextField = OnboardingTextField(placeholder: "입력")
  
  // MARK: - CleanUp
  private let cleanUpInfoLabel = OnboardingUtilities.infoLabel("정리정돈은 얼마나 하시나요?", isEssential: true)
  private let cleanUpTextField = OnboardingTextField(placeholder: "입력")
  
  // MARK: - Shower
  private let showerInfoLabel = OnboardingUtilities.infoLabel("샤워는 주로 언제/몇 분 동안 하시나요?", isEssential: true)
  private let showerTextField = OnboardingTextField(placeholder: "입력")
  
  // MARK: - MBTI
  private let mbtiInfoLabel = OnboardingUtilities.infoLabel("MBTI를 알려주세요.", isEssential: false)
  private let mbtiTextField = OnboardingTextField(placeholder: "입력")
  
  // MARK: - OpenChat
  private let chatInfoLabel = OnboardingUtilities.infoLabel("룸메와 연락을 위한 개인 오픈채팅 링크를 알려주세요.", isEssential: false)
  private let chatTextField = OnboardingTextField(placeholder: "입력")
  
  // MARK: - WishText
  private let wishInfoLabel = OnboardingUtilities.infoLabel("미래의 룸메에게 하고 싶은 말은?", isEssential: false)
  private let wishTextView = RSKGrowingTextView().then {
    $0.attributedPlaceholder = NSAttributedString(string: "입력", attributes: [NSAttributedString.Key.font: UIFont.init(name: MyFonts.regular.rawValue, size: 14) ?? 0, NSAttributedString.Key.foregroundColor: UIColor.idorm_gray_300])
    $0.font = .init(name: MyFonts.regular.rawValue, size: 14)
    $0.textColor = .black
    $0.layer.cornerRadius = 10
    $0.layer.borderColor = UIColor.idorm_gray_300.cgColor
    $0.layer.borderWidth = 1
    $0.isScrollEnabled = false
    $0.keyboardType = .default
    $0.returnKeyType = .done
    $0.backgroundColor = .clear
    $0.textContainerInset = UIEdgeInsets(top: 15, left: 9, bottom: 15, right: 9)
  }
  
  private let letterNumLabel = UILabel().then {
    $0.textColor = .idorm_gray_300
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14)
  }
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    setupStackView()
    super.viewDidLoad()
  }
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    view.addSubview(scrollView)
    view.addSubview(floatyBottomView)
    scrollView.addSubview(contentView)
    
    [titleLabel, dormLabel, dormStack, dormLine, genderLabel, genderStack, genderLine, periodLabel, periodStack, periodLine, habitLabel, habitStack1, habitStack2, habitLine, habitDescriptionLabel, ageLabel, ageDescriptionLabel, ageTextField, ageLine, wakeUpInfoLabel, wakeUpTextField, cleanUpInfoLabel, cleanUpTextField, showerInfoLabel, showerTextField, mbtiInfoLabel, mbtiTextField, chatInfoLabel, chatTextField, wishInfoLabel, wishTextView, letterNumLabel]
      .forEach { contentView.addSubview($0) }
  }
  
  override func setupStyles() {
    super.setupStyles()
    contentView.backgroundColor = .white
    view.backgroundColor = .white
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    floatyBottomView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
      make.height.equalTo(76)
    }
    
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalTo(view.frame.width)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalToSuperview().inset(20)
    }
    
    dormLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
    }
    
    dormStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(dormLabel.snp.bottom).offset(10)
    }
    
    dormLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(dormStack.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    genderLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(dormLine.snp.bottom).offset(16)
    }
    
    genderStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(genderLabel.snp.bottom).offset(10)
    }
    
    genderLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(genderStack.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    periodLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(genderLine.snp.bottom).offset(16)
    }
    
    periodStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(periodLabel.snp.bottom).offset(10)
    }
    
    periodLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(periodStack.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    habitLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(periodLine.snp.bottom).offset(16)
    }
    
    habitDescriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(habitLabel.snp.bottom)
      make.leading.equalToSuperview().inset(25)
    }
    
    habitStack1.snp.makeConstraints { make in
      make.top.equalTo(habitDescriptionLabel.snp.bottom).offset(12)
      make.leading.equalToSuperview().inset(25)
    }
    
    habitStack2.snp.makeConstraints { make in
      make.top.equalTo(habitStack1.snp.bottom).offset(10)
      make.leading.equalToSuperview().inset(25)
    }
    
    habitLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(habitStack2.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    ageLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(habitLine.snp.bottom).offset(16)
    }
    
    ageTextField.snp.makeConstraints { make in
      make.top.equalTo(ageLabel.snp.bottom).offset(10)
      make.leading.equalToSuperview().inset(25)
      make.width.equalTo(90)
      make.height.equalTo(33)
    }
    
    ageDescriptionLabel.snp.makeConstraints { make in
      make.centerY.equalTo(ageTextField)
      make.leading.equalTo(ageTextField.snp.trailing).offset(8)
    }
    
    ageLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(ageTextField.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    wakeUpInfoLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(ageLine.snp.bottom).offset(16)
    }
    
    wakeUpTextField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(wakeUpInfoLabel.snp.bottom).offset(8)
      make.height.equalTo(50)
    }
    
    cleanUpInfoLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(wakeUpTextField.snp.bottom).offset(32)
    }
    
    cleanUpTextField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(cleanUpInfoLabel.snp.bottom).offset(8)
      make.height.equalTo(50)
    }
    
    showerInfoLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(cleanUpTextField.snp.bottom).offset(32)
    }
    
    showerTextField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(showerInfoLabel.snp.bottom).offset(8)
      make.height.equalTo(50)
    }
    
    mbtiInfoLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(showerTextField.snp.bottom).offset(32)
    }
    
    mbtiTextField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(mbtiInfoLabel.snp.bottom).offset(8)
      make.height.equalTo(50)
    }
    
    chatInfoLabel.snp.makeConstraints { make in
      make.top.equalTo(mbtiTextField.snp.bottom).offset(32)
      make.leading.equalToSuperview().inset(25)
    }
    
    chatTextField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(chatInfoLabel.snp.bottom).offset(8)
      make.height.equalTo(50)
    }
    
    wishInfoLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(chatTextField.snp.bottom).offset(32)
    }
    
    wishTextView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(wishInfoLabel.snp.bottom).offset(8)
      make.bottom.equalToSuperview().inset(90)
    }
    
    letterNumLabel.snp.makeConstraints { make in
      make.centerY.equalTo(wishInfoLabel)
      make.trailing.equalToSuperview().inset(25)
    }
  }
  
  private func setupStackView() {
    let dormStack = UIStackView(arrangedSubviews: [ dorm1Button, dorm2Button, dorm3Button ])
    dormStack.spacing = 12
    self.dormStack = dormStack
    
    let genderStack = UIStackView(arrangedSubviews: [ maleButton, femaleButton ])
    genderStack.spacing = 12
    self.genderStack = genderStack

    let periodStack = UIStackView(arrangedSubviews: [ period16Button, period24Button ])
    periodStack.spacing = 12
    self.periodStack = periodStack

    let habitStack1 = UIStackView(arrangedSubviews: [ snoreButton, grindingButton, smokingButton ])
    let habitStack2 = UIStackView(arrangedSubviews: [ allowedFoodButton, allowedEarphoneButton ])
    habitStack1.spacing = 12
    habitStack2.spacing = 12
    self.habitStack1 = habitStack1
    self.habitStack2 = habitStack2
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // MARK: - Input

    // 텍스트뷰 글자수 제한
    wishTextView.rx.text
      .orEmpty
      .scan("") { previous, new in
        if new.count > 100 {
          return previous
        } else {
          return new
        }
      }
      .bind(to: wishTextView.rx.text)
      .disposed(by: disposeBag)
    
    // 텍스트뷰 반응 -> 글자수 레이블 반응
    wishTextView.rx.text
      .orEmpty
      .bind(onNext: { [unowned self] text in
        self.letterNumLabel.text = "\(text.count)/100pt"
        let attributedString = NSMutableAttributedString(string: "\(text.count)/100pt")
        attributedString.addAttribute(.foregroundColor, value: UIColor.idorm_blue, range: ("\(text.count)/100pt" as NSString).range(of: "\(text.count)"))
        self.letterNumLabel.attributedText = attributedString
//        self.onChangedTextSubject.onNext((text, self.type))
      })
      .disposed(by: disposeBag)
    
    // MARK: - Output
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct OnboardingViewController_PreView: PreviewProvider {
  static var previews: some View {
    OnboardingViewController().toPreview()
  }
}
#endif

