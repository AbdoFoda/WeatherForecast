import UIKit
import WeatherCore

extension LocationWeatherViewController {
    func setupUI() {
        configureSubviews()
        assembleViewHierarchy()
        activateLayoutConstraints()
    }

    private func configureSubviews() {
        view.backgroundColor = .clear
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.accessibilityIdentifier = AccessibilityIdentifier.Detail.scroll
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        topView.translatesAutoresizingMaskIntoConstraints = false
        graphView.translatesAutoresizingMaskIntoConstraints = false
        tilesView.translatesAutoresizingMaskIntoConstraints = false
        attributionLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        permissionView.translatesAutoresizingMaskIntoConstraints = false
        offlineBanner.translatesAutoresizingMaskIntoConstraints = false
        permissionView.isHidden = true
        offlineBanner.isHidden = true
        loadingView.stopAnimating()

        attributionLabel.text = AppL10n.attribution
        attributionLabel.font = WeatherDesignSystem.Typography.preferred(.caption2)
        attributionLabel.textColor = .tertiaryLabel
        attributionLabel.textAlignment = .center

        scrollView.delaysContentTouches = false
        configureRefreshControl()
        configureTileCallbacks()
    }

    private func assembleViewHierarchy() {
        view.addSubview(backgroundView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(topView)
        contentView.addSubview(graphView)
        contentView.addSubview(tilesView)
        contentView.addSubview(attributionLabel)
        view.addSubview(loadingView)
        view.addSubview(permissionView)
        view.addSubview(offlineBanner)
        view.addSubview(refreshSpinner)
    }

    private func activateLayoutConstraints() {
        let graphHeight = graphView.heightAnchor.constraint(
            equalToConstant: WeatherDesignSystem.Layout.graphHeight
        )
        graphHeightConstraint = graphHeight
        let tilesHeight = tilesView.heightAnchor.constraint(
            equalToConstant: WeatherDesignSystem.Layout.tilesInitialHeight
        )
        tilesHeightConstraint = tilesHeight

        NSLayoutConstraint.activate(
            scrollLayoutConstraints()
                + sectionLayoutConstraints(graphHeight: graphHeight, tilesHeight: tilesHeight)
                + overlayLayoutConstraints()
        )

        let summaryTop = topView.topAnchor.constraint(
            equalTo: contentView.topAnchor,
            constant: WeatherDesignSystem.Layout.summaryTopInset
        )
        summaryTopConstraint = summaryTop
        summaryTop.isActive = true
    }

    private func scrollLayoutConstraints() -> [NSLayoutConstraint] {
        [
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),
            contentView.heightAnchor.constraint(
                greaterThanOrEqualTo: scrollView.heightAnchor,
                constant: 1
            ),

            topView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]
    }

    private func sectionLayoutConstraints(
        graphHeight: NSLayoutConstraint,
        tilesHeight: NSLayoutConstraint
    ) -> [NSLayoutConstraint] {
        [
            graphView.topAnchor.constraint(
                equalTo: topView.bottomAnchor,
                constant: WeatherDesignSystem.Layout.sectionSpacing
            ),
            graphView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            graphView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            graphHeight,

            tilesView.topAnchor.constraint(
                equalTo: graphView.bottomAnchor,
                constant: WeatherDesignSystem.Layout.sectionSpacing
            ),
            tilesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tilesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tilesHeight,

            attributionLabel.topAnchor.constraint(
                greaterThanOrEqualTo: tilesView.bottomAnchor,
                constant: WeatherDesignSystem.Layout.attributionBottomInset
            ),
            attributionLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: WeatherDesignSystem.Layout.screenHorizontalInset
            ),
            attributionLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -WeatherDesignSystem.Layout.screenHorizontalInset
            ),
            attributionLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -WeatherDesignSystem.Layout.attributionBottomInset
            )
        ]
    }

    private func overlayLayoutConstraints() -> [NSLayoutConstraint] {
        [
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            permissionView.topAnchor.constraint(equalTo: view.topAnchor),
            permissionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            permissionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            permissionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            offlineBanner.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: WeatherDesignSystem.Layout.screenHorizontalInset
            ),
            offlineBanner.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -WeatherDesignSystem.Layout.screenHorizontalInset
            ),
            offlineBanner.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -WeatherDesignSystem.Layout.offlineBannerBottomInset
            ),

            refreshSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            refreshSpinner.centerYAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: WeatherDesignSystem.Layout.summarySafeAreaExtra
            )
        ]
    }

    func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        scrollView.refreshControl = refreshControl
        refreshControl.tintColor = .clear
        refreshSpinner.translatesAutoresizingMaskIntoConstraints = false
        refreshSpinner.hidesWhenStopped = true
        refreshSpinner.color = .white
        refreshSpinner.layer.shadowColor = UIColor.black.cgColor
        refreshSpinner.layer.shadowOpacity = 0.25
        refreshSpinner.layer.shadowRadius = 3
        refreshSpinner.layer.shadowOffset = .zero
    }

    func configureTileCallbacks() {
        tilesView.onOrderChanged = { [weak self] order in
            self?.viewModel.saveTileOrder(order)
        }
        tilesView.onDragStateChanged = { [weak self] isDragging in
            guard let self else { return }
            self.scrollView.panGestureRecognizer.isEnabled = !isDragging
            self.onTileDragStateChanged?(isDragging)
        }
        tilesView.onTileMenuRequested = { [weak self] kind, sourceView in
            self?.presentTileMenu(for: kind, from: sourceView)
        }
    }

    func updateTilesHeight() {
        tilesView.setNeedsLayout()
        tilesView.layoutIfNeeded()
        tilesHeightConstraint?.constant = tilesView.intrinsicContentSize.height
    }

    func setBackgroundAnimationsActive(_ active: Bool) {
        if active {
            backgroundView.resumeAnimations()
        } else {
            backgroundView.pauseAnimations()
        }
    }

    func refreshLayoutAfterExternalTransition() {
        lastTilesLayoutBounds = .zero
        graphView.invalidateGraphLayout()
        tilesView.prepareForContainerSizeChange()
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    func updateTilesLayoutForAvailableSpace() {
        contentView.layoutIfNeeded()

        let visibleHeight = scrollView.bounds.height
        let visibleWidth = scrollView.bounds.width
        let boundsSize = CGSize(width: visibleWidth, height: visibleHeight)

        let fixedHeight =
            (summaryTopConstraint?.constant ?? 0)
            + topView.bounds.height
            + WeatherDesignSystem.Layout.sectionSpacing
            + (graphHeightConstraint?.constant ?? WeatherDesignSystem.Layout.graphHeight)
            + WeatherDesignSystem.Layout.sectionSpacing
            + attributionLabel.bounds.height
            + WeatherDesignSystem.Layout.attributionBottomInset * 2

        let availableForTiles = max(0, visibleHeight - fixedHeight)
        let boundsChanged =
            abs(boundsSize.width - lastTilesLayoutBounds.width) > 0.5
            || abs(boundsSize.height - lastTilesLayoutBounds.height) > 0.5
        let targetHeightChanged = abs(tilesView.layoutTargetHeight - availableForTiles) > 0.5
        guard boundsChanged || targetHeightChanged else { return }

        lastTilesLayoutBounds = boundsSize
        tilesView.layoutTargetHeight = availableForTiles
        if boundsChanged {
            tilesView.prepareForContainerSizeChange()
        }
        tilesView.invalidateIntrinsicContentSize()
        updateTilesHeight()
    }
}
