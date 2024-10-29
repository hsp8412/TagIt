//
//  BarcodeView.swift
//  TagIt
//
//  Created by Angi Shi on 2024-10-27.
//

import SwiftUI
import AVFoundation

struct BarcodeScannerView: View {
    @StateObject var viewModel = BarcodeScannerViewModel()

    var body: some View {
        ZStack {
            CameraPreview(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                if let barcode = viewModel.scannedBarcode {
                    Text("Scanned Barcode: \(barcode)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                } else {
                    Text("No barcode detected")
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
        .onDisappear {
            viewModel.scannedBarcode = nil
        }
    }
}

struct CameraPreview: UIViewControllerRepresentable {
    @ObservedObject var viewModel: BarcodeScannerViewModel

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = ScannerViewController()
        viewController.viewModel = viewModel
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
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
            metadataOutput.metadataObjectTypes = [.ean13, .qr]
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = view.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
    }

    private func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }

    private func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let barcode = readableObject.stringValue {
            viewModel?.scannedBarcode = barcode
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
    }
}


#Preview {
    BarcodeScannerView()
}
