//
//  WebMailViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/17.
//

import Foundation
import WebKit
import SnapKit

class WebMailViewController: UIViewController {
    // MARK: - Properties
    let urlRequest: URLRequest
    
    let webView = WKWebView()
    
    // MARK: - LifeCycle
    init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
        super.init(nibName: nil, bundle: nil)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        view.addSubview(webView)
        
        webView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        webView.load(urlRequest)
    }
}
