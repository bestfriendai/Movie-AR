//
//  OnboardingViewController.swift
//  Movie AR
//
//  Created: December 2025
//  First-launch onboarding experience
//

import UIKit

final class OnboardingViewController: UIViewController {

    // MARK: - Properties

    private var currentPage = 0
    private let pages: [OnboardingPage] = OnboardingPage.allPages

    // MARK: - UI Elements

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
        return pageControl
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = DesignTokens.CornerRadius.md
        button.titleLabel?.font = DesignTokens.Typography.headline
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "onboardingNextButton"
        return button
    }()

    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .normal)
        button.titleLabel?.font = DesignTokens.Typography.body
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "onboardingSkipButton"
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPages()
        setupAccessibility()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .black

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        view.addSubview(skipButton)

        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -DesignTokens.Spacing.lg),

            // Stack view
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),

            // Page control
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -DesignTokens.Spacing.lg),

            // Next button
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DesignTokens.Spacing.screenMargin),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DesignTokens.Spacing.screenMargin),
            nextButton.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -DesignTokens.Spacing.md),
            nextButton.heightAnchor.constraint(equalToConstant: 52),

            // Skip button
            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -DesignTokens.Spacing.md),
            skipButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupPages() {
        for (index, page) in pages.enumerated() {
            let pageView = createPageView(for: page, index: index)
            stackView.addArrangedSubview(pageView)
            pageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        }
    }

    private func createPageView(for page: OnboardingPage, index: Int) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: page.iconName)
        iconImageView.tintColor = page.iconColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = page.title
        titleLabel.textColor = .white
        titleLabel.font = DesignTokens.Typography.title1
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let descriptionLabel = UILabel()
        descriptionLabel.text = page.description
        descriptionLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        descriptionLabel.font = DesignTokens.Typography.body
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -80),
            iconImageView.widthAnchor.constraint(equalToConstant: 120),
            iconImageView.heightAnchor.constraint(equalToConstant: 120),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: DesignTokens.Spacing.xl),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: DesignTokens.Spacing.screenMargin),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -DesignTokens.Spacing.screenMargin),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DesignTokens.Spacing.md),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: DesignTokens.Spacing.screenMargin),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -DesignTokens.Spacing.screenMargin)
        ])

        // Accessibility
        containerView.isAccessibilityElement = true
        containerView.accessibilityLabel = "\(page.title). \(page.description)"
        containerView.accessibilityIdentifier = "onboardingPage\(index)"

        return containerView
    }

    private func setupAccessibility() {
        scrollView.accessibilityIdentifier = "onboardingScrollView"
        pageControl.accessibilityIdentifier = "onboardingPageControl"
    }

    // MARK: - Actions

    @objc private func nextButtonTapped() {
        DesignTokens.Haptics.selection()

        if currentPage < pages.count - 1 {
            currentPage += 1
            let offsetX = CGFloat(currentPage) * view.bounds.width
            scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
            updateUI()
        } else {
            completeOnboarding()
        }
    }

    @objc private func skipButtonTapped() {
        DesignTokens.Haptics.selection()
        completeOnboarding()
    }

    @objc private func pageControlChanged() {
        currentPage = pageControl.currentPage
        let offsetX = CGFloat(currentPage) * view.bounds.width
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        updateUI()
    }

    private func updateUI() {
        pageControl.currentPage = currentPage

        let isLastPage = currentPage == pages.count - 1
        let buttonTitle = isLastPage ? "Get Started" : "Next"

        UIView.animate(withDuration: DesignTokens.Animation.quick) {
            self.nextButton.setTitle(buttonTitle, for: .normal)
            self.skipButton.alpha = isLastPage ? 0 : 1
        }
    }

    private func completeOnboarding() {
        // Mark onboarding as complete
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)

        // Track analytics
        AnalyticsService.shared.track(.appLaunched, properties: [
            "onboarding_completed": true,
            "pages_viewed": currentPage + 1
        ])

        // Haptic feedback
        DesignTokens.Haptics.success()

        // Transition to main app
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let mainVC = storyboard.instantiateInitialViewController() else { return }

        // Animate transition
        guard let window = view.window else { return }

        UIView.transition(
            with: window,
            duration: DesignTokens.Animation.normal,
            options: .transitionCrossDissolve,
            animations: {
                window.rootViewController = mainVC
            }
        )
    }
}

// MARK: - UIScrollViewDelegate
extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / view.bounds.width)
        if page != currentPage {
            currentPage = page
            updateUI()
        }
    }
}

// MARK: - OnboardingPage Model
struct OnboardingPage {
    let iconName: String
    let iconColor: UIColor
    let title: String
    let description: String

    static var allPages: [OnboardingPage] {
        [
            OnboardingPage(
                iconName: "viewfinder",
                iconColor: .systemBlue,
                title: "Point & Discover",
                description: "Point your camera at any movie poster to unlock AR content"
            ),
            OnboardingPage(
                iconName: "play.rectangle.fill",
                iconColor: .systemRed,
                title: "Watch Trailers",
                description: "Instantly watch movie trailers right on the poster in augmented reality"
            ),
            OnboardingPage(
                iconName: "star.fill",
                iconColor: .systemYellow,
                title: "Ratings & Info",
                description: "See star ratings, cast information, and more at a glance"
            ),
            OnboardingPage(
                iconName: "camera.fill",
                iconColor: .systemGreen,
                title: "Camera Access",
                description: "We'll need access to your camera to detect movie posters. Your privacy is important to us."
            )
        ]
    }
}
