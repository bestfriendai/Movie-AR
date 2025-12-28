//
//  UIViewController+Extensions.swift
//  Movie AR
//
//  Created: December 2025
//  UIViewController extensions for common operations
//

import UIKit

// MARK: - Alert Extensions
extension UIViewController {

    /// Show simple alert with OK button
    func showAlert(
        title: String,
        message: String,
        buttonTitle: String = "OK",
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }

    /// Show error alert
    func showError(_ error: Error, completion: (() -> Void)? = nil) {
        showAlert(
            title: "Error",
            message: error.localizedDescription,
            completion: completion
        )
    }

    /// Show error with custom message
    func showError(message: String, completion: (() -> Void)? = nil) {
        showAlert(title: "Error", message: message, completion: completion)
    }

    /// Show confirmation alert with cancel and confirm actions
    func showConfirmation(
        title: String,
        message: String,
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        confirmStyle: UIAlertAction.Style = .default,
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel) { _ in
            onCancel?()
        })

        alert.addAction(UIAlertAction(title: confirmTitle, style: confirmStyle) { _ in
            onConfirm()
        })

        present(alert, animated: true)
    }

    /// Show action sheet
    func showActionSheet(
        title: String? = nil,
        message: String? = nil,
        actions: [(title: String, style: UIAlertAction.Style, handler: () -> Void)],
        cancelTitle: String = "Cancel"
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

        for action in actions {
            alert.addAction(UIAlertAction(title: action.title, style: action.style) { _ in
                action.handler()
            })
        }

        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))

        // iPad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        present(alert, animated: true)
    }
}

// MARK: - Navigation Extensions
extension UIViewController {

    /// Dismiss to root view controller
    func dismissToRoot(animated: Bool = true, completion: (() -> Void)? = nil) {
        var presenting = presentingViewController
        while let parent = presenting?.presentingViewController {
            presenting = parent
        }
        presenting?.dismiss(animated: animated, completion: completion)
    }

    /// Pop to root if in navigation controller
    func popToRoot(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }

    /// Add child view controller
    func add(_ child: UIViewController, to containerView: UIView? = nil) {
        addChild(child)
        let targetView = containerView ?? view!
        targetView.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: targetView.topAnchor),
            child.view.leadingAnchor.constraint(equalTo: targetView.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: targetView.trailingAnchor),
            child.view.bottomAnchor.constraint(equalTo: targetView.bottomAnchor)
        ])
        child.didMove(toParent: self)
    }

    /// Remove from parent view controller
    func removeFromParentController() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

// MARK: - Keyboard Extensions
extension UIViewController {

    /// Add keyboard observers
    func addKeyboardObservers(
        willShow: @escaping (CGRect, TimeInterval) -> Void,
        willHide: @escaping (TimeInterval) -> Void
    ) {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
                return
            }
            willShow(frame, duration)
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
                return
            }
            willHide(duration)
        }
    }

    /// Dismiss keyboard on tap
    func hideKeyboardOnTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Loading Extensions
extension UIViewController {

    /// Show loading indicator
    func showLoading(message: String? = nil) {
        view.showLoadingOverlay(message: message)
    }

    /// Hide loading indicator
    func hideLoading() {
        view.hideLoadingOverlay()
    }
}

// MARK: - Toast Extensions
extension UIViewController {

    /// Show toast message at bottom of screen
    func showToast(_ message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = .white
        toastLabel.font = DesignTokens.Typography.body
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = DesignTokens.CornerRadius.md
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0
        toastLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(toastLabel)

        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -DesignTokens.Spacing.xl),
            toastLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: DesignTokens.Spacing.screenMargin),
            toastLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -DesignTokens.Spacing.screenMargin),
            toastLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])

        // Add padding
        toastLabel.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        UIView.animate(withDuration: 0.3) {
            toastLabel.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.3, animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}

// MARK: - Safe Area Extensions
extension UIViewController {

    var safeAreaTop: CGFloat {
        view.safeAreaInsets.top
    }

    var safeAreaBottom: CGFloat {
        view.safeAreaInsets.bottom
    }

    var safeAreaHeight: CGFloat {
        view.bounds.height - safeAreaTop - safeAreaBottom
    }
}
