//
//  OnboardingContainerViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/11.
//

import UIKit
import SnapKit

class OnboardingContainerViewController: UIViewController {
    // MARK: - Properties
    var currentPage = 0
    let viewModel = OnboardingListViewModel()
    let onboardingVC = OnboardingViewController()
    let onboardingDetailVC = OnboardingDetailViewController()
    
    lazy var pageVC: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.dataSource = self
        vc.delegate = self
        
        return vc
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("완료", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16.0, weight: .regular)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var leftArrowButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .gray
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapLeftArrowButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var rightArrowButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(didTapRightArrowButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var varLabel: UILabel = {
        let label = UILabel()
        label.textColor = .mainColor
        label.text = "1"
        
        return label
    }()
    
    lazy var slashLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.text = "/"
       
        return label
    }()
    
    lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.text = "2"
        
        return label
    }()
    
    lazy var onboardingViewControllers: [UIViewController] = {
        onboardingVC.view.tag = 0
        onboardingDetailVC.view.tag = 1
        return [ onboardingVC, onboardingDetailVC ]
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    @objc private func didTapConfirmButton() {
        
    }
    
    @objc private func didTapLeftArrowButton() {
        let prevPage = currentPage - 1
        pageVC.setViewControllers([onboardingViewControllers[prevPage]], direction: .reverse, animated: true)
        
        currentPage = pageVC.viewControllers!.first!.view.tag
        varLabel.text = "\(currentPage + 1)"
        enabledBtn()
    }
    
    @objc private func didTapRightArrowButton() {
        let nextPage = currentPage + 1
        pageVC.setViewControllers([onboardingViewControllers[nextPage]], direction: .forward, animated: true)
        
        currentPage = pageVC.viewControllers!.first!.view.tag
        varLabel.text = "\(currentPage + 1)"
        enabledBtn()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "내 정보 입력"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: confirmButton)
        
        confirmButton.isEnabled = false
        
        onboardingVC.delegate = self
        onboardingDetailVC.delegate = self
        
        addChild(pageVC)
        pageVC.didMove(toParent: self)
        if let firstVC = onboardingViewControllers.first {
            pageVC.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
        let pageStack = UIStackView(arrangedSubviews: [ varLabel, slashLabel, pageLabel ])
        pageStack.axis = .horizontal
        pageStack.spacing = 4.0
        
        [ leftArrowButton, rightArrowButton, pageStack, pageVC.view ]
            .forEach { view.addSubview($0) }
        
        pageVC.view.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(pageStack.snp.top).offset(-4)
        }
        
        pageStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        leftArrowButton.snp.makeConstraints { make in
            make.trailing.equalTo(pageStack.snp.leading).offset(-24)
            make.centerY.equalTo(pageStack)
        }
        
        rightArrowButton.snp.makeConstraints { make in
            make.leading.equalTo(pageStack.snp.trailing).offset(24)
            make.centerY.equalTo(pageStack)
        }
    }
    
    private func enabledBtn() {
        if currentPage == 0 {
            leftArrowButton.isEnabled = false
            rightArrowButton.isEnabled = true
        } else {
            leftArrowButton.isEnabled = true
            rightArrowButton.isEnabled = false
        }
    }
}

extension OnboardingContainerViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = onboardingViewControllers.firstIndex(of: viewController) else { return nil }
        let previousIndex = index - 1
        if previousIndex < 0 { return nil }
        return onboardingViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = onboardingViewControllers.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        if nextIndex == onboardingViewControllers.count {
            return nil
        }
        return onboardingViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        currentPage = pageViewController.viewControllers!.first!.view.tag
        varLabel.text = "\(currentPage + 1)"
        enabledBtn()
    }
}

extension OnboardingContainerViewController: OnboardingViewDelegate {
    func verifyConfirmButton(index: Int) {
        viewModel.onboardingVerifyArray[index] = true
        
        if viewModel.onboardingVerifyArray.allSatisfy({ $0 == true }),
           viewModel.onboardingDetailVerifyArray.allSatisfy({ $0 == true }) {
            confirmButton.setTitleColor(UIColor.mainColor, for: .normal)
            confirmButton.isEnabled = true
        } else {
            confirmButton.setTitleColor(UIColor.gray, for: .normal)
            confirmButton.isEnabled = false
        }
    }
}

extension OnboardingContainerViewController: OnboardingDetailViewDelegate {
    func detailVerifyConfirmButton(index: Int, result: Bool) {
        viewModel.onboardingDetailVerifyArray[index] = result
        
        if viewModel.onboardingVerifyArray.allSatisfy({ $0 == true }),
           viewModel.onboardingDetailVerifyArray.allSatisfy({ $0 == true }) {
            confirmButton.setTitleColor(UIColor.mainColor, for: .normal)
            confirmButton.isEnabled = true
        } else {
            confirmButton.setTitleColor(UIColor.gray, for: .normal)
            confirmButton.isEnabled = false
        }
    }
}
