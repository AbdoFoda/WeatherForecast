import UIKit
import WeatherCore

extension LocationWeatherViewController {
    func startReachabilityMonitoring() {
        reachabilityMonitor.onConnectionRestored = { [weak self] in
            self?.handleConnectionRestored()
        }
        reachabilityMonitor.startMonitoring()
    }

    func apply(notice: UserNotice?) {
        switch notice {
        case .offline:
            presentNoticeBanner(message: L10n.Notice.offline)
        case .unavailable:
            presentNoticeBanner(message: L10n.Notice.unavailable)
        case nil:
            clearNoticeBanner()
        }
    }

    private func presentNoticeBanner(message: String) {
        cancelBackOnlineNotice()
        isShowingNotice = true
        offlineBanner.setMessage(message)
        offlineBanner.setHidden(false, animated: false)
        scheduleReconnectRetry()
    }

    private func clearNoticeBanner() {
        cancelReconnectRetry()
        if isShowingNotice {
            isShowingNotice = false
            presentBackOnlineNotice()
        } else if !isShowingBackOnlineNotice {
            offlineBanner.setHidden(true, animated: false)
        }
    }

    func setOfflineBannerVisible(_ visible: Bool) {
        if !visible {
            isShowingNotice = false
            cancelReconnectRetry()
            cancelBackOnlineNotice()
        }
        offlineBanner.setHidden(!visible, animated: false)
    }

    private func handleConnectionRestored() {
        guard isViewLoaded, isShowingNotice else { return }
        attemptReconnectRefresh()
    }

    private func scheduleReconnectRetry() {
        guard reconnectRetryTask == nil else { return }
        reconnectRetryTask = Task { [weak self] in
            guard let interval = self?.reconnectRetryInterval else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                guard !Task.isCancelled, let self else { return }
                self.attemptReconnectRefresh()
            }
        }
    }

    private func cancelReconnectRetry() {
        reconnectRetryTask?.cancel()
        reconnectRetryTask = nil
    }

    func attemptReconnectRefresh() {
        if let lat = currentLatitude, let lon = currentLongitude {
            weatherTask?.cancel()
            weatherTask = Task { [weak self] in
                await self?.viewModel.refresh(lat: lat, lon: lon)
            }
        } else if case .device = locationSource {
            deviceLocationManager?.requestLocation()
        }
    }

    private func presentBackOnlineNotice() {
        isShowingBackOnlineNotice = true
        offlineBanner.setMessage(L10n.Notice.backOnline)
        offlineBanner.setHidden(false, animated: true)

        backOnlineDismissWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self, self.isShowingBackOnlineNotice else { return }
            self.isShowingBackOnlineNotice = false
            self.offlineBanner.setHidden(true, animated: true)
        }
        backOnlineDismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + WeatherDesignSystem.Banner.backOnlineDisplayDuration,
            execute: workItem
        )
    }

    private func cancelBackOnlineNotice() {
        isShowingBackOnlineNotice = false
        backOnlineDismissWorkItem?.cancel()
        backOnlineDismissWorkItem = nil
    }

    @objc func appDidBecomeActive() {
        if isShowingNotice {
            attemptReconnectRefresh()
        }
        guard case .device = locationSource else { return }
        deviceLocationManager?.requestLocation()
    }

    func presentTileMenu(for kind: TileKind, from sourceView: UIView) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        sheet.addAction(UIAlertAction(title: L10n.Tiles.remove, style: .destructive) { [weak self] _ in
            self?.viewModel.hideTile(kind)
        })
        if viewModel.hasHiddenTiles {
            sheet.addAction(UIAlertAction(title: L10n.Tiles.showAll, style: .default) { [weak self] _ in
                self?.viewModel.showAllTiles()
            })
        }
        sheet.addAction(UIAlertAction(title: AppL10n.cancel, style: .cancel))

        if let popover = sheet.popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
        }
        present(sheet, animated: true)
    }

    @objc func handleRefresh() {
        guard let lat = currentLatitude, let lon = currentLongitude else {
            deviceLocationManager?.requestLocation()
            refreshControl.endRefreshing()
            return
        }
        refreshSpinner.startAnimating()
        weatherTask?.cancel()
        weatherTask = Task { [weak self] in
            await self?.viewModel.refresh(lat: lat, lon: lon)
        }
    }
}
