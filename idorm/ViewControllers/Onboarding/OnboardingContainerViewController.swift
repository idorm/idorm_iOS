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
    let viewModel = OnboardingListViewModel()
    let onboardingVC = OnboardingViewController()
    let onboardingDetailVC = OnboardingDetailViewController()
    
    var currentPage: Int = 0 {
        didSet {
            let direction: UIPageViewController.NavigationDirection = oldValue <= self.currentPage ? .forward : .reverse
            pageVC.setViewControllers([onboardingViewControllers[currentPage]], direction: direction, animated: true)
        }
    }
    
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
        button.setTitleColor(UIColor.mainColor, for: .normal)
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
        button.tintColor = .mainColor
        button.addTarget(self, action: #selector(didTapRightArrowButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var onboardingViewControllers: [UIViewController] = {
        onboardingVC.view.tag = 0
        onboardingDetailVC.view.tag = 1
        return [ onboardingVC, onboardingDetailVC ]
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 2
        pageControl.pageIndicatorTintColor = .gray
        pageControl.currentPageIndicatorTintColor = .mainColor
        pageControl.allowsContinuousInteraction = false
        pageControl.isUserInteractionEnabled = false
        pageControl.addTarget(self, action: #selector(pageControlDidChanged), for: .valueChanged)
        
        return pageControl
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    @objc private func didTapConfirmButton() {
        let onboardingImageVC = OnboardingImageViewController()
        navigationController?.pushViewController(onboardingImageVC, animated: true)
    }
    
    @objc private func didTapLeftArrowButton() {
        let prevPage = currentPage - 1
        pageVC.setViewControllers([onboardingViewControllers[prevPage]], direction: .reverse, animated: true)
        
        currentPage = pageVC.viewControllers!.first!.view.tag
        pageControl.currentPage = currentPage
        enabledBtn()
    }
    
    @objc private func didTapRightArrowButton() {
        let nextPage = currentPage + 1
        pageVC.setViewControllers([onboardingViewControllers[nextPage]], direction: .forward, animated: true)
        
        currentPage = pageVC.viewControllers!.first!.view.tag
        pageControl.currentPage = currentPage
        enabledBtn()
    }
    
    @objc private func pageControlDidChanged(_ sender: UIPageControl) {
        self.currentPage = sender.currentPage
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "내 정보 입력"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: confirmButton)
        navigationController?.navigationBar.tintColor = .black
        
//        confirmButton.isEnabled = false
        
        onboardingVC.delegate = self
        onboardingDetailVC.delegate = self
        
        addChild(pageVC)
        pageVC.didMove(toParent: self)
        if let firstVC = onboardingViewControllers.first {
            pageVC.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
        [ leftArrowButton, rightArrowButton, pageControl, pageVC.view ]
            .forEach { view.addSubview($0) }
        
        pageVC.view.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(pageControl.snp.top).offset(-4)
        }
        
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(32)
        }
        
        leftArrowButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(32)
            make.centerY.equalTo(pageControl)
        }
        
        rightArrowButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(32)
            make.centerY.equalTo(pageControl)
        }
    }
    
    private func enabledBtn() {
        if currentPage == 0 {
            leftArrowButton.tintColor = .gray
            rightArrowButton.tintColor = .mainColor
            leftArrowButton.isEnabled = false
            rightArrowButton.isEnabled = true
        } else {
            leftArrowButton.tintColor = .mainColor
            rightArrowButton.tintColor = .gray
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
        guard let viewController = pageViewController.viewControllers?[0] else { return }
        guard let index = onboardingViewControllers.firstIndex(of: viewController) else { return }
        
        currentPage = index
        pageControl.currentPage = index
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
//            confirmButton.isEnabled = true
        } else {
            confirmButton.setTitleColor(UIColor.gray, for: .normal)
//            confirmButton.isEnabled = false
        }
    }
}
