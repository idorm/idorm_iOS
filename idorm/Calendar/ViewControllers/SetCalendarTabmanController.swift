//
//  CalendarPostDetailViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/08/03.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import PanModal
import Pageboy
import Tabman

class SetCalendarTabmanController: TabmanViewController {
  // MARK: - Properties
  var viewControllers: [UIViewController] = []
  
  lazy var tabmanBar: TMBar.ButtonBar = {
    let bar = TMBar.ButtonBar()
    bar.layout.separatorColor = .black
    bar.layout.contentMode = .fit
    bar.indicator.tintColor = .black
    bar.indicator.weight = .custom(value: 1)
    bar.backgroundColor = .white
    
    return bar
  }()
  
  lazy var startSetCalendarVC = SetCalendarViewController(type: .start, viewModel: viewModel)
  lazy var endSetCalendarVC = SetCalendarViewController(type: .end, viewModel: viewModel)
  
  let viewModel = SetCalendarViewModel()
  let disposeBag = DisposeBag()
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bind()
  }
  
  // MARK: - Bind
  private func bind() {
    /// 하루종일 버튼 클릭시 동기화
    viewModel.output.onChangedAllDayButtonState
      .bind(onNext: { [weak self] isSelected in
        self?.startSetCalendarVC.allDayButton.isSelected = isSelected
        self?.endSetCalendarVC.allDayButton.isSelected = isSelected
      })
      .disposed(by: disposeBag)
    
    
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    viewControllers.append(startSetCalendarVC)
    viewControllers.append(endSetCalendarVC)
    
    tabmanBar.buttons.customize { button in
      button.selectedTintColor = .black
      button.tintColor = .idorm_gray_200
      button.font = .init(name: Font.regular.rawValue, size: 14)!
      button.selectedFont = .init(name: Font.regular.rawValue, size: 14)!
      button.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }
    
    self.dataSource = self
    addBar(tabmanBar, dataSource: self, at: .top)
  }
}

extension SetCalendarTabmanController: PageboyViewControllerDataSource, TMBarDataSource {
  func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
    viewControllers.count
  }
  
  func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
    viewControllers[index]
  }
  
  func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
    return nil
  }
  
  func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
    if index == 0 {
      let item = TMBarItem(title: "시작")
      return item
    } else {
      let item = TMBarItem(title: "종료")
      return item
    }
  }
}

extension SetCalendarTabmanController: PanModalPresentable {
  var panScrollable: UIScrollView? {
    return nil
  }
  
  var shortFormHeight: PanModalHeight {
    return PanModalHeight.contentHeight(710)
  }
  
  var longFormHeight: PanModalHeight {
    return PanModalHeight.contentHeight(710)
  }
}
