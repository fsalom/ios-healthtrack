//
//  BarcodeScannerView.swift
//  HealthTrack
//

import SwiftUI
import AVFoundation

struct BarcodeScannerView: View {

    // MARK: - Properties

    @State var viewModel: BarcodeScannerViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ZStack {
            CameraPreviewView(session: viewModel.captureSession)
                .ignoresSafeArea()

            // Darkened overlay with cutout
            scanOverlay

            VStack {
                Spacer()

                // Scan area indicator
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 280, height: 140)
                    .overlay {
                        if viewModel.isScanning && !viewModel.isLoading {
                            scanningIndicator
                        }
                    }

                Spacer()

                // Instructions
                VStack(spacing: 8) {
                    Text("Escanea el codigo de barras")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("Alinea el codigo dentro del recuadro")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))

                    if let barcode = viewModel.scannedBarcode {
                        Text(barcode)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                            .padding(.top, 4)
                    }
                }
                .padding(.bottom, 60)
            }

            // Loading overlay
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .navigationTitle("Escanear")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.stopScanning()
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.startScanning()
        }
        .onDisappear {
            viewModel.stopScanning()
        }
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
    }

    // MARK: - Subviews

    private var scanOverlay: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .mask {
                Rectangle()
                    .ignoresSafeArea()
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .frame(width: 280, height: 140)
                            .blendMode(.destinationOut)
                    }
            }
    }

    private var scanningIndicator: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 2)
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)

                Text("Buscando producto...")
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Camera Preview

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.session = session
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {}
}

final class CameraPreviewUIView: UIView {
    var session: AVCaptureSession? {
        didSet {
            guard let session = session else { return }
            previewLayer.session = session
        }
    }

    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer()
        layer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(layer)
        return layer
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
}
