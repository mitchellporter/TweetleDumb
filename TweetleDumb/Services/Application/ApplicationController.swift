//
//  ApplicationController.swift
//  TweetleDumb
//
//  Created by Ian Keen on 2017-06-13.
//  Copyright © 2017 Mustard. All rights reserved.
//

import Foundation
import UIKit

final class ApplicationController {
    // MARK: - Private Properties
    private let environment: Environment
    fileprivate let navigationController: UINavigationController

    // MARK: - Public Properties
    private(set) lazy var authenticationController: AuthenticationController = AuthenticationController(
        api: self.api,
        storage: self.environment.keyValueStore,
        authenticators: self.environment.authenticators
    )
    private(set) lazy var api: API = API(
        network: self.environment.network,
        baseURL: self.environment.baseURL
    )

    // MARK: - Lifecycle
    init(environment: Environment, rootNavigationController: UINavigationController) {
        self.environment = environment
        self.navigationController = rootNavigationController
    }

    // MARK: - Public
    func start() {
        authenticationController.delegates.add(self)
        authenticationController.notifyDelegate()
    }
}

// MARK: - Error Handling
private extension ApplicationController {
    func handle(error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        ))
        navigationController.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Routing
private extension ApplicationController {
    func showLogin() {
        let viewModel = LoginViewModel(dependencies: self)
        let viewController = LoginViewController(viewModel: viewModel)

        UIView.animate(withDuration: navigationController.shouldAnimate ? 0.35 : 0) {
            UIView.setAnimationCurve(.easeInOut)

            self.navigationController.setViewControllers([viewController], animated: self.navigationController.shouldAnimate)
            self.navigationController.setNavigationBarHidden(true, animated: self.navigationController.shouldAnimate)

            UIView.setAnimationTransition(.flipFromLeft, for: self.navigationController.view, cache: false)
        }

    }
    func showTweets() {
        let viewModel = TweetsViewModel(dependencies: self)
        viewModel.delegate.add(self)
        let viewController = TweetsViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: navigationController.shouldAnimate)
        navigationController.setNavigationBarHidden(false, animated: navigationController.shouldAnimate)
    }
    func showCompose(target: TweetsViewModel) {
        print("Compose Tweet")
    }
}

// MARK: - TweetsViewModelDelegate
extension ApplicationController: TweetsViewModelDelegate {
    func tweetsViewModelUpdated(_ viewModel: TweetsViewModel) {
        //
    }
    func tweetsViewModel(_ viewModel: TweetsViewModel, error: Error) {
        handle(error: error)
    }
    func tweetsViewModelCompose(_ viewModel: TweetsViewModel) {
        showCompose(target: viewModel)
    }
}

// MARK: - AuthenticationControllerDelegate
extension ApplicationController: AuthenticationControllerDelegate {
    func authenticationError(controller: AuthenticationController, error: Error) {
        handle(error: error)
    }
    func authenticationLogin(controller: AuthenticationController, authentication: Authentication) {
        showTweets()
    }
    func authenticationLogout(controller: AuthenticationController) {
        showLogin()
    }
}
