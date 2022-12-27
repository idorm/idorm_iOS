import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa
import Moya

final class HomeViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let bellButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    config.image = UIImage(named: "bell")
    $0.configuration = config
    $0.isHidden = true
  }
  
  private let mainLabel = UILabel().then {
    $0.text = """
              1학기 룸메이트 매칭
              아이돔과 함께해요.
              """
    $0.textColor = .idorm_gray_400
    $0.numberOfLines = 2
    $0.font = .init(name: MyFonts.medium.rawValue, size: 20)
    
    let attributedString = NSMutableAttributedString(string: $0.text!)
    attributedString.addAttributes([.foregroundColor: UIColor.idorm_blue,
                                    .font: UIFont.init(name: MyFonts.bold.rawValue, size: 20)!]
                                   ,range: ($0.text! as NSString).range(of: "1학기"))
    $0.attributedText = attributedString
  }
  
  private let startMatchingButton = UIButton().then {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .idorm_blue
    config.image = UIImage(named: "rightArrow")
    config.imagePlacement = .trailing
    config.imagePadding = 12
    
    var titleContainer = AttributeContainer()
    titleContainer.font = .init(name: MyFonts.medium.rawValue, size: 16)
    titleContainer.foregroundColor = UIColor.white
    config.attributedTitle = AttributedString("룸메이트 매칭 시작하기", attributes: titleContainer)
    
    $0.configuration = config
  }
  
  private let lionImageView = UIImageView(image: #imageLiteral(resourceName: "lion_with_circle"))
  
  private var scrollView: UIScrollView!
  private var contentView: UIView!
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    setupScrollView()
    super.viewDidLoad()
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .white
    navigationController?.isNavigationBarHidden = false
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bellButton)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    
    [mainLabel, lionImageView, startMatchingButton]
      .forEach { contentView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    scrollView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalTo(view.frame.width)
    }
    
    mainLabel.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.leading.equalToSuperview().inset(24)
    }
    
    lionImageView.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24)
      make.top.equalTo(mainLabel.snp.bottom).offset(-12)
    }
    
    startMatchingButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(lionImageView.snp.bottom).offset(-13.5)
      make.height.equalTo(52)
      make.bottom.equalToSuperview()
    }
  }
  
  private func setupScrollView() {
    let scrollView = UIScrollView()
    self.scrollView = scrollView
    
    let contentView = UIView()
    contentView.backgroundColor = .white
    self.contentView = contentView
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
//    // 매칭 시작 버튼 클릭 이벤트
//    startMatchingButton.rx.tap
//      .bind(to: viewModel.input.startMatchingButtonTapped)
//      .disposed(by: disposeBag)
    
    // MARK: - Output
    
//    // 매칭 페이지로 전환
//    viewModel.output.showMatchingPage
//      .bind(onNext: { [weak self] in
//        self?.tabBarController?.selectedIndex = 1
//      })
//      .disposed(by: disposeBag)
  }
}
