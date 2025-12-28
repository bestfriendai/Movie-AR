//
//  UIView+Extensions.swift
//  Movie AR
//
//  Created: December 2025
//  UIView extensions for common operations
//

import UIKit

// MARK: - Animation Extensions
extension UIView {

    /// Fade in animation
    func fadeIn(duration: TimeInterval = DesignTokens.Animation.normal, completion: ((Bool) -> Void)? = nil) {
        alpha = 0
        isHidden = false
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
        }, completion: completion)
    }

    /// Fade out animation
    func fadeOut(duration: TimeInterval = DesignTokens.Animation.normal, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }, completion: { finished in
            self.isHidden = true
            completion?(finished)
        })
    }

    /// Spring animation
    func springAnimate(
        duration: TimeInterval = DesignTokens.Animation.normal,
        damping: CGFloat = DesignTokens.Animation.springDamping,
        velocity: CGFloat = DesignTokens.Animation.springVelocity,
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: [.curveEaseInOut],
            animations: animations,
            completion: completion
        )
    }

    /// Pulse animation
    func pulse(scale: CGFloat = 1.1, duration: TimeInterval = 0.15) {
        springAnimate(duration: duration) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        } completion: { _ in
            self.springAnimate(duration: duration * 2) {
                self.transform = .identity
            }
        }
    }

    /// Shake animation (for errors)
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.duration = 0.4
        animation.values = [-10, 10, -8, 8, -5, 5, -2, 2, 0]
        layer.add(animation, forKey: "shake")
    }
}

// MARK: - Constraint Extensions
extension UIView {

    /// Pin to all edges of superview
    func pinToSuperview(padding: CGFloat = 0) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: padding),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: padding),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -padding),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -padding)
        ])
    }

    /// Pin to safe area of superview
    func pinToSafeArea(padding: CGFloat = 0) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: padding),
            leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -padding)
        ])
    }

    /// Center in superview
    func centerInSuperview() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
    }

    /// Set size constraints
    func setSize(width: CGFloat? = nil, height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

// MARK: - Layer Extensions
extension UIView {

    /// Add rounded corners
    func roundCorners(_ corners: UIRectCorner = .allCorners, radius: CGFloat) {
        layer.cornerRadius = radius
        if corners != .allCorners {
            var cornerMask: CACornerMask = []
            if corners.contains(.topLeft) { cornerMask.insert(.layerMinXMinYCorner) }
            if corners.contains(.topRight) { cornerMask.insert(.layerMaxXMinYCorner) }
            if corners.contains(.bottomLeft) { cornerMask.insert(.layerMinXMaxYCorner) }
            if corners.contains(.bottomRight) { cornerMask.insert(.layerMaxXMaxYCorner) }
            layer.maskedCorners = cornerMask
        }
        layer.masksToBounds = true
    }

    /// Add shadow
    func addShadow(
        color: UIColor = .black,
        opacity: Float = 0.1,
        offset: CGSize = CGSize(width: 0, height: 2),
        radius: CGFloat = 4
    ) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }

    /// Add border
    func addBorder(color: UIColor, width: CGFloat = 1) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }

    /// Add gradient background
    func addGradient(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

// MARK: - Subview Extensions
extension UIView {

    /// Remove all subviews
    func removeAllSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }

    /// Find first responder in view hierarchy
    func findFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }
        for subview in subviews {
            if let firstResponder = subview.findFirstResponder() {
                return firstResponder
            }
        }
        return nil
    }

    /// Get parent view controller
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

// MARK: - Loading Overlay
extension UIView {

    private static var loadingOverlayTag = 999999

    /// Show loading overlay
    func showLoadingOverlay(message: String? = nil) {
        // Remove existing overlay if any
        hideLoadingOverlay()

        let overlay = UIView()
        overlay.tag = UIView.loadingOverlayTag
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        overlay.translatesAutoresizingMaskIntoConstraints = false

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        overlay.addSubview(activityIndicator)
        addSubview(overlay)

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: topAnchor),
            overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        ])

        if let message = message {
            let label = UILabel()
            label.text = message
            label.textColor = .white
            label.font = DesignTokens.Typography.body
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false

            overlay.addSubview(label)
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: DesignTokens.Spacing.md),
                label.centerXAnchor.constraint(equalTo: overlay.centerXAnchor)
            ])
        }

        overlay.alpha = 0
        overlay.fadeIn()
    }

    /// Hide loading overlay
    func hideLoadingOverlay() {
        if let overlay = viewWithTag(UIView.loadingOverlayTag) {
            overlay.fadeOut { _ in
                overlay.removeFromSuperview()
            }
        }
    }
}
