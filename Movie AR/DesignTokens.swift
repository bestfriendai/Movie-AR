//
//  DesignTokens.swift
//  Movie AR
//
//  Created: December 2025
//  A centralized design system for consistent UI across the app.
//

import UIKit

// MARK: - Design Tokens
/// Centralized design system tokens for consistent UI throughout the app.
/// Based on Apple Human Interface Guidelines and modern iOS design patterns.
enum DesignTokens {

    // MARK: - Colors

    /// Color palette for the app
    enum Colors {
        // Primary brand colors
        static let primary = UIColor.systemBlue
        static let primaryVariant = UIColor.systemIndigo

        // Semantic colors
        static let success = UIColor.systemGreen
        static let error = UIColor.systemRed
        static let warning = UIColor.systemOrange
        static let info = UIColor.systemCyan

        // Background colors
        static let backgroundPrimary = UIColor.systemBackground
        static let backgroundSecondary = UIColor.secondarySystemBackground
        static let backgroundTertiary = UIColor.tertiarySystemBackground
        static let backgroundOverlay = UIColor.black.withAlphaComponent(0.6)
        static let backgroundOverlayDark = UIColor.black.withAlphaComponent(0.85)

        // Text colors
        static let textPrimary = UIColor.label
        static let textSecondary = UIColor.secondaryLabel
        static let textTertiary = UIColor.tertiaryLabel
        static let textOnDark = UIColor.white
        static let textOnPrimary = UIColor.white

        // AR-specific colors
        static let scanningOverlay = UIColor.black.withAlphaComponent(0.6)
        static let arFeedback = UIColor.systemGreen
    }

    // MARK: - Typography

    /// Typography scale following iOS conventions
    enum Typography {
        static let largeTitle = UIFont.systemFont(ofSize: 34, weight: .bold)
        static let title1 = UIFont.systemFont(ofSize: 28, weight: .bold)
        static let title2 = UIFont.systemFont(ofSize: 22, weight: .bold)
        static let title3 = UIFont.systemFont(ofSize: 20, weight: .semibold)
        static let headline = UIFont.systemFont(ofSize: 17, weight: .semibold)
        static let body = UIFont.systemFont(ofSize: 17, weight: .regular)
        static let callout = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let subheadline = UIFont.systemFont(ofSize: 15, weight: .regular)
        static let footnote = UIFont.systemFont(ofSize: 13, weight: .regular)
        static let caption1 = UIFont.systemFont(ofSize: 12, weight: .regular)
        static let caption2 = UIFont.systemFont(ofSize: 11, weight: .regular)

        // Monospace for technical info
        static let monospace = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)

        // Dynamic Type support
        static func preferredFont(forTextStyle style: UIFont.TextStyle) -> UIFont {
            return UIFont.preferredFont(forTextStyle: style)
        }
    }

    // MARK: - Spacing

    /// Consistent spacing scale (based on 4pt grid)
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64

        // Specific use cases
        static let buttonPadding: CGFloat = 16
        static let cardPadding: CGFloat = 16
        static let screenMargin: CGFloat = 20
        static let listItemSpacing: CGFloat = 12
    }

    // MARK: - Corner Radius

    /// Corner radius scale
    enum CornerRadius {
        static let none: CGFloat = 0
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 28
        static let pill: CGFloat = 9999 // For pill-shaped buttons
    }

    // MARK: - Shadows

    /// Shadow configurations
    enum Shadows {
        static let none = ShadowConfig(opacity: 0, radius: 0, offset: .zero)
        static let sm = ShadowConfig(opacity: 0.08, radius: 4, offset: CGSize(width: 0, height: 2))
        static let md = ShadowConfig(opacity: 0.12, radius: 8, offset: CGSize(width: 0, height: 4))
        static let lg = ShadowConfig(opacity: 0.16, radius: 16, offset: CGSize(width: 0, height: 8))
        static let xl = ShadowConfig(opacity: 0.20, radius: 24, offset: CGSize(width: 0, height: 12))
    }

    struct ShadowConfig {
        let opacity: Float
        let radius: CGFloat
        let offset: CGSize

        func apply(to layer: CALayer, color: UIColor = .black) {
            layer.shadowColor = color.cgColor
            layer.shadowOpacity = opacity
            layer.shadowRadius = radius
            layer.shadowOffset = offset
        }
    }

    // MARK: - Animation

    /// Animation timing and duration constants
    enum Animation {
        // Durations
        static let instant: TimeInterval = 0.1
        static let quick: TimeInterval = 0.2
        static let normal: TimeInterval = 0.3
        static let slow: TimeInterval = 0.5
        static let verySlow: TimeInterval = 0.8

        // Spring configuration
        static let springDamping: CGFloat = 0.7
        static let springVelocity: CGFloat = 0.5
        static let springDampingBouncy: CGFloat = 0.5
        static let springVelocityBouncy: CGFloat = 0.8

        /// Standard spring animation
        static func spring(
            duration: TimeInterval = normal,
            damping: CGFloat = springDamping,
            velocity: CGFloat = springVelocity,
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

        /// Standard ease animation
        static func ease(
            duration: TimeInterval = normal,
            animations: @escaping () -> Void,
            completion: ((Bool) -> Void)? = nil
        ) {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: [.curveEaseInOut],
                animations: animations,
                completion: completion
            )
        }
    }

    // MARK: - Haptics

    /// Haptic feedback generators
    enum Haptics {
        private static let impactLight = UIImpactFeedbackGenerator(style: .light)
        private static let impactMedium = UIImpactFeedbackGenerator(style: .medium)
        private static let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        private static let notification = UINotificationFeedbackGenerator()
        private static let selection = UISelectionFeedbackGenerator()

        static func prepareAll() {
            impactLight.prepare()
            impactMedium.prepare()
            impactHeavy.prepare()
            notification.prepare()
            selection.prepare()
        }

        static func light() {
            impactLight.impactOccurred()
        }

        static func medium() {
            impactMedium.impactOccurred()
        }

        static func heavy() {
            impactHeavy.impactOccurred()
        }

        static func success() {
            notification.notificationOccurred(.success)
        }

        static func warning() {
            notification.notificationOccurred(.warning)
        }

        static func error() {
            notification.notificationOccurred(.error)
        }

        static func selection() {
            selection.selectionChanged()
        }
    }

    // MARK: - Icon Sizes

    /// Standard icon sizes
    enum IconSize {
        static let xs: CGFloat = 16
        static let sm: CGFloat = 20
        static let md: CGFloat = 24
        static let lg: CGFloat = 32
        static let xl: CGFloat = 48
        static let xxl: CGFloat = 64
        static let huge: CGFloat = 80
    }

    // MARK: - Button Sizes

    /// Standard button configurations
    enum ButtonSize {
        case small
        case medium
        case large

        var height: CGFloat {
            switch self {
            case .small: return 36
            case .medium: return 44
            case .large: return 52
            }
        }

        var font: UIFont {
            switch self {
            case .small: return Typography.footnote
            case .medium: return Typography.body
            case .large: return Typography.headline
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .small: return CornerRadius.sm
            case .medium: return CornerRadius.md
            case .large: return CornerRadius.lg
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return Spacing.sm
            case .medium: return Spacing.md
            case .large: return Spacing.lg
            }
        }
    }
}

// MARK: - UIView Extensions

extension UIView {
    /// Apply shadow configuration to view
    func applyShadow(_ config: DesignTokens.ShadowConfig) {
        config.apply(to: layer)
    }

    /// Apply corner radius with optional masking
    func applyCornerRadius(_ radius: CGFloat, corners: CACornerMask? = nil) {
        layer.cornerRadius = radius
        if let corners = corners {
            layer.maskedCorners = corners
        }
        layer.masksToBounds = corners == nil
    }
}

// MARK: - CACornerMask Convenience

extension CACornerMask {
    static let top: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    static let bottom: CACornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    static let left: CACornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    static let right: CACornerMask = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    static let all: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                     .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
}
