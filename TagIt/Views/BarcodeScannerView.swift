//
//  BarcodeScannerView.swift
//  TagIt
//
//  Created by Angi Shi on 2024-10-27.
//

import SwiftUI
import AVFoundation

struct BarcodeScannerView: View {
    @StateObject var viewModel = BarcodeScannerViewModel()
    @State private var navigateToItem = false

    var body: some View {
        NavigationView {
            ZStack {
                CameraPreview(viewModel: viewModel)
                    .ignoresSafeArea() // Updated to ignoresSafeArea()

                VStack {
                    Spacer()

                    if let barcode = viewModel.scannedBarcode {
                        Text("Scanned Barcode: \(barcode)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()

                        NavigationLink(
                            destination: ScannedItemView(barcode: barcode),
                            isActive: $navigateToItem
                        ) {
                            EmptyView()
                        }
                    } else {
                        Text("Scanning for barcodes...")
                            .foregroundColor(.white)
                            .padding()
                    }
                }
            }
            .onAppear {
                viewModel.scannedBarcode = nil
                navigateToItem = false
            }
            .onChange(of: viewModel.scannedBarcode) { newValue in
                if newValue != nil {
                    navigateToItem = true
                }
            }
        }
    }
}

struct CameraPreview: UIViewControllerRepresentable {
    @ObservedObject var viewModel: BarcodeScannerViewModel

    func makeUIViewController(context: Context) -> ScannerViewController {
        let viewController = ScannerViewController()
        viewController.viewModel = viewModel
        return viewController
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
}

// Custom UIViewController to manage the camera session
class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var viewModel: BarcodeScannerViewModel?
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }

    private func setupCaptureSession() {
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoInput) else { return }

        captureSession.addInput(videoInput)

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean13, .qr, .code128] // Include other barcode types if needed
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    func startSession() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }

    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let barcode = readableObject.stringValue {
            DispatchQueue.main.async {
                self.viewModel?.scannedBarcode = barcode
                self.stopSession() // Stop scanning after a barcode is found
            }
        }
    }
}

struct BarcodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeScannerView()
    }
}
