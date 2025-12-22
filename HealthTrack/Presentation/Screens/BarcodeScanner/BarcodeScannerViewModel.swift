//
//  BarcodeScannerViewModel.swift
//  HealthTrack
//

import Foundation
import AVFoundation

@Observable
final class BarcodeScannerViewModel: NSObject {

    // MARK: - Properties

    var isScanning = false
    var isLoading = false
    var scannedBarcode: String?
    var shouldDismiss = false

    let captureSession = AVCaptureSession()

    private let router: Router
    private let fetchFoodInfoUseCase: FetchFoodInfoUseCaseProtocol
    private let onFoodScanned: (FoodItemModel) -> Void
    private var hasScanned = false

    // MARK: - Init

    init(
        router: Router,
        fetchFoodInfoUseCase: FetchFoodInfoUseCaseProtocol,
        onFoodScanned: @escaping (FoodItemModel) -> Void
    ) {
        self.router = router
        self.fetchFoodInfoUseCase = fetchFoodInfoUseCase
        self.onFoodScanned = onFoodScanned
        super.init()
        setupCaptureSession()
    }

    // MARK: - Public Methods

    func startScanning() {
        guard !captureSession.isRunning else { return }
        hasScanned = false
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
            DispatchQueue.main.async {
                self?.isScanning = true
            }
        }
    }

    func stopScanning() {
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
        isScanning = false
    }

    func didTapCancel() {
        stopScanning()
        shouldDismiss = true
    }

    // MARK: - Private Methods

    private func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }

        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .upce, .code128, .code39]
        }
    }

    private func processBarcode(_ barcode: String) {
        guard !hasScanned else { return }
        hasScanned = true
        scannedBarcode = barcode
        isLoading = true

        Task { @MainActor in
            do {
                if let foodItem = try await fetchFoodInfoUseCase.execute(barcode: barcode) {
                    stopScanning()
                    onFoodScanned(foodItem)
                    shouldDismiss = true
                } else {
                    router.showAlert(
                        title: "Producto no encontrado",
                        message: "El codigo \(barcode) no se encontro en la base de datos. Puedes agregarlo manualmente."
                    )
                    hasScanned = false
                }
            } catch let error as AppError {
                router.showAlert(with: error)
                hasScanned = false
            } catch {
                router.showAlert(
                    title: "Error",
                    message: error.localizedDescription
                )
                hasScanned = false
            }
            isLoading = false
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension BarcodeScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else {
            return
        }

        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        processBarcode(stringValue)
    }
}
