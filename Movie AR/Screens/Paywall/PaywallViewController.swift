//
//  PaywallViewController.swift
//  Movie AR
//
//  Created: December 2025
//  Subscription paywall UI for RevenueCat integration
//

import UIKit

// MARK: - PaywallViewController Delegate
protocol PaywallViewControllerDelegate: AnyObject {
    func paywallDidPurchase(_ paywall: PaywallViewController)
    func paywallDidRestore(_ paywall: PaywallViewController)
    func paywallDidCancel(_ paywall: PaywallViewController)
}

// MARK: - PaywallViewController
final class PaywallViewController: UIViewController {

    // MARK: - Properties
    weak var delegate: PaywallViewControllerDelegate?

    private var selectedPackageIndex = 1 // Default to yearly (best value)
    private let packages = SubscriptionPackageInfo.placeholder

    // MARK: - UI Elements

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = UIColor.white.withAlphaComponent(0.6)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.accessibilityLabel = "Close"
        button.accessibilityIdentifier = "paywallCloseButton"
        return button
    }()

    private lazy var heroImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "sparkles")
        imageView.tintColor = .systemYellow
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Unlock Premium"
        label.textColor = .white
        label.font = DesignTokens.Typography.largeTitle
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Get access to all AR features"
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.font = DesignTokens.Typography.body
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var featuresStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = DesignTokens.Spacing.md
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var packagesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = DesignTokens.Spacing.md
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var purchaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = DesignTokens.CornerRadius.md
        button.titleLabel?.font = DesignTokens.Typography.headline
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "paywallPurchaseButton"
        return button
    }()

    private lazy var restoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Restore Purchases", for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .normal)
        button.titleLabel?.font = DesignTokens.Typography.footnote
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "paywallRestoreButton"
        return button
    }()

    private lazy var termsLabel: UILabel = {
        let label = UILabel()
        label.text = "By continuing, you agree to our Terms of Service and Privacy Policy. Subscriptions automatically renew unless cancelled."
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = DesignTokens.Typography.caption1
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFeatures()
        setupPackages()
        trackPaywallView()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(closeButton)
        contentView.addSubview(heroImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(featuresStackView)
        contentView.addSubview(packagesStackView)
        contentView.addSubview(purchaseButton)
        contentView.addSubview(restoreButton)
        contentView.addSubview(termsLabel)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Close button
            closeButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: DesignTokens.Spacing.md),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignTokens.Spacing.md),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            // Hero image
            heroImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: DesignTokens.Spacing.xxl),
            heroImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            heroImageView.widthAnchor.constraint(equalToConstant: 80),
            heroImageView.heightAnchor.constraint(equalToConstant: 80),

            // Title
            titleLabel.topAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: DesignTokens.Spacing.lg),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignTokens.Spacing.screenMargin),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignTokens.Spacing.screenMargin),

            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DesignTokens.Spacing.xs),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignTokens.Spacing.screenMargin),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignTokens.Spacing.screenMargin),

            // Features
            featuresStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: DesignTokens.Spacing.xl),
            featuresStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignTokens.Spacing.screenMargin),
            featuresStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignTokens.Spacing.screenMargin),

            // Packages
            packagesStackView.topAnchor.constraint(equalTo: featuresStackView.bottomAnchor, constant: DesignTokens.Spacing.xl),
            packagesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignTokens.Spacing.screenMargin),
            packagesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignTokens.Spacing.screenMargin),

            // Purchase button
            purchaseButton.topAnchor.constraint(equalTo: packagesStackView.bottomAnchor, constant: DesignTokens.Spacing.xl),
            purchaseButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignTokens.Spacing.screenMargin),
            purchaseButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignTokens.Spacing.screenMargin),
            purchaseButton.heightAnchor.constraint(equalToConstant: 52),

            // Restore button
            restoreButton.topAnchor.constraint(equalTo: purchaseButton.bottomAnchor, constant: DesignTokens.Spacing.md),
            restoreButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            restoreButton.heightAnchor.constraint(equalToConstant: 44),

            // Terms label
            termsLabel.topAnchor.constraint(equalTo: restoreButton.bottomAnchor, constant: DesignTokens.Spacing.md),
            termsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignTokens.Spacing.screenMargin),
            termsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignTokens.Spacing.screenMargin),
            termsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DesignTokens.Spacing.xl),

            // Activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupFeatures() {
        let features = [
            ("checkmark.circle.fill", "Unlimited AR poster scanning"),
            ("checkmark.circle.fill", "Access to all movie trailers"),
            ("checkmark.circle.fill", "Detailed movie information"),
            ("checkmark.circle.fill", "No ads experience"),
            ("checkmark.circle.fill", "Priority support")
        ]

        for (icon, text) in features {
            let featureView = createFeatureView(icon: icon, text: text)
            featuresStackView.addArrangedSubview(featureView)
        }
    }

    private func createFeatureView(icon: String, text: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = .systemGreen
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = DesignTokens.Typography.body
        label.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(iconImageView)
        containerView.addSubview(label)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: DesignTokens.Spacing.md),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            label.topAnchor.constraint(equalTo: containerView.topAnchor),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            containerView.heightAnchor.constraint(equalToConstant: 32)
        ])

        return containerView
    }

    private func setupPackages() {
        for (index, package) in packages.enumerated() {
            let packageView = createPackageView(package: package, index: index)
            packagesStackView.addArrangedSubview(packageView)
        }

        // Select default package
        selectPackage(at: selectedPackageIndex)
    }

    private func createPackageView(package: SubscriptionPackageInfo, index: Int) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        containerView.layer.cornerRadius = DesignTokens.CornerRadius.md
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.clear.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.tag = index

        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(packageTapped(_:)))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true

        // Best value badge
        if package.isBestValue {
            let badgeLabel = UILabel()
            badgeLabel.text = "BEST VALUE"
            badgeLabel.textColor = .white
            badgeLabel.font = DesignTokens.Typography.caption2
            badgeLabel.backgroundColor = .systemGreen
            badgeLabel.layer.cornerRadius = 4
            badgeLabel.layer.masksToBounds = true
            badgeLabel.textAlignment = .center
            badgeLabel.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(badgeLabel)

            NSLayoutConstraint.activate([
                badgeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -8),
                badgeLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                badgeLabel.widthAnchor.constraint(equalToConstant: 80),
                badgeLabel.heightAnchor.constraint(equalToConstant: 18)
            ])
        }

        // Title
        let titleLabel = UILabel()
        titleLabel.text = package.title
        titleLabel.textColor = .white
        titleLabel.font = DesignTokens.Typography.headline
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Price
        let priceLabel = UILabel()
        priceLabel.text = package.price
        priceLabel.textColor = .white
        priceLabel.font = DesignTokens.Typography.title2
        priceLabel.translatesAutoresizingMaskIntoConstraints = false

        // Per month
        let perMonthLabel = UILabel()
        perMonthLabel.text = package.pricePerMonth.map { "\($0)/mo" } ?? ""
        perMonthLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        perMonthLabel.font = DesignTokens.Typography.footnote
        perMonthLabel.translatesAutoresizingMaskIntoConstraints = false

        // Radio button
        let radioImageView = UIImageView()
        radioImageView.image = UIImage(systemName: "circle")
        radioImageView.tintColor = UIColor.white.withAlphaComponent(0.5)
        radioImageView.contentMode = .scaleAspectFit
        radioImageView.translatesAutoresizingMaskIntoConstraints = false
        radioImageView.tag = 100 // Tag to identify

        containerView.addSubview(radioImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(perMonthLabel)

        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 80),

            radioImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: DesignTokens.Spacing.md),
            radioImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            radioImageView.widthAnchor.constraint(equalToConstant: 24),
            radioImageView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: radioImageView.trailingAnchor, constant: DesignTokens.Spacing.md),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: DesignTokens.Spacing.md),

            priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -DesignTokens.Spacing.md),
            priceLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -8),

            perMonthLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -DesignTokens.Spacing.md),
            perMonthLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 2)
        ])

        containerView.accessibilityLabel = "\(package.title), \(package.price)"
        containerView.accessibilityIdentifier = "package\(index)"
        containerView.isAccessibilityElement = true

        return containerView
    }

    private func selectPackage(at index: Int) {
        selectedPackageIndex = index

        for (i, view) in packagesStackView.arrangedSubviews.enumerated() {
            let isSelected = i == index
            view.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor

            if let radioImageView = view.viewWithTag(100) as? UIImageView {
                radioImageView.image = UIImage(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                radioImageView.tintColor = isSelected ? .systemBlue : UIColor.white.withAlphaComponent(0.5)
            }
        }

        let package = packages[index]
        purchaseButton.setTitle("Subscribe - \(package.price)", for: .normal)
    }

    private func trackPaywallView() {
        AnalyticsService.shared.trackPaywallView(source: "ar_feature")
    }

    // MARK: - Actions

    @objc private func closeButtonTapped() {
        DesignTokens.Haptics.selection()
        delegate?.paywallDidCancel(self)
        dismiss(animated: true)
    }

    @objc private func packageTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        DesignTokens.Haptics.selection()
        selectPackage(at: view.tag)
    }

    @objc private func purchaseButtonTapped() {
        DesignTokens.Haptics.medium()
        startPurchase()
    }

    @objc private func restoreButtonTapped() {
        DesignTokens.Haptics.selection()
        restorePurchases()
    }

    // MARK: - Purchase Flow

    private func startPurchase() {
        let package = packages[selectedPackageIndex]
        setLoading(true)

        AnalyticsService.shared.track(.purchaseStarted, properties: [
            "product_id": package.id
        ])

        Task {
            do {
                _ = try await SubscriptionService.shared.purchase(packageId: package.id)

                await MainActor.run {
                    setLoading(false)
                    DesignTokens.Haptics.success()
                    delegate?.paywallDidPurchase(self)
                    dismiss(animated: true)
                }
            } catch {
                await MainActor.run {
                    setLoading(false)
                    DesignTokens.Haptics.error()
                    showError(error)
                }
            }
        }
    }

    private func restorePurchases() {
        setLoading(true)

        AnalyticsService.shared.track(.restoreStarted)

        Task {
            do {
                let success = try await SubscriptionService.shared.restorePurchases()

                await MainActor.run {
                    setLoading(false)
                    if success {
                        DesignTokens.Haptics.success()
                        delegate?.paywallDidRestore(self)
                        dismiss(animated: true)
                    } else {
                        showNoSubscriptionFound()
                    }
                }
            } catch {
                await MainActor.run {
                    setLoading(false)
                    DesignTokens.Haptics.error()
                    showError(error)
                }
            }
        }
    }

    private func setLoading(_ loading: Bool) {
        purchaseButton.isEnabled = !loading
        restoreButton.isEnabled = !loading

        if loading {
            activityIndicator.startAnimating()
            purchaseButton.setTitle("Processing...", for: .normal)
        } else {
            activityIndicator.stopAnimating()
            let package = packages[selectedPackageIndex]
            purchaseButton.setTitle("Subscribe - \(package.price)", for: .normal)
        }
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Purchase Failed",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)

        AnalyticsService.shared.track(.purchaseFailed, properties: [
            "error": error.localizedDescription
        ])
    }

    private func showNoSubscriptionFound() {
        let alert = UIAlertController(
            title: "No Subscription Found",
            message: "We couldn't find any previous purchases to restore.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)

        AnalyticsService.shared.track(.restoreFailed, properties: [
            "reason": "no_subscription_found"
        ])
    }
}

// MARK: - Static Presentation
extension PaywallViewController {

    static func present(from viewController: UIViewController, delegate: PaywallViewControllerDelegate? = nil) {
        let paywall = PaywallViewController()
        paywall.delegate = delegate
        paywall.modalPresentationStyle = .fullScreen
        viewController.present(paywall, animated: true)
    }
}
