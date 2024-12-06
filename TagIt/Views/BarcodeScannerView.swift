import AVFoundation
import SwiftUI

/**
 `BarcodeScannerView` manages the barcode scanning process using the device camera.
 It displays the camera feed and handles the scanning of barcodes, updating the UI when a barcode is detected.
 */
struct BarcodeScannerView: View {
    @StateObject var viewModel = BarcodeScannerViewModel() // ViewModel to manage barcode scanning state
    @State private var navigateToReviews = false // Controls navigation to the reviews screen after scanning
    @State private var scannedBarcode: String = "" // Holds the barcode data after a successful scan

    var body: some View {
        ZStack {
            CameraPreview(viewModel: viewModel) // Camera preview showing the live camera feed
                .ignoresSafeArea()

            VStack {
                Spacer()

                // Display the scanned barcode or scanning status
                if let barcode = viewModel.scannedBarcode {
                    Text("Scanned Barcode: \(barcode)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                } else {
                    Text("Scanning for barcodes...")
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
        .onAppear {
            viewModel.scannedBarcode = nil // Reset barcode when the view appears
        }
        .onChange(of: viewModel.scannedBarcode) { _, newValue in
            // Trigger navigation once a barcode is scanned
            if let newValue {
                scannedBarcode = newValue
                navigateToReviews = true
            }
        }
        .background(
            NavigationLink(
                destination: ScannedItemView(barcode: scannedBarcode, productName: "this item"),
                isActive: $navigateToReviews
            ) {
                EmptyView() // Navigation action to go to the review page after scanning
            }
        )
    }
}

/**
 `CameraPreview` is a `UIViewControllerRepresentable` that integrates a UIKit view controller
 for displaying the camera feed and managing the AVCaptureSession.
 */
struct CameraPreview: UIViewControllerRepresentable {
    @ObservedObject var viewModel: BarcodeScannerViewModel

    func makeUIViewController(context _: Context) -> ScannerViewController {
        let viewController = ScannerViewController() // Instantiate the ScannerViewController to handle camera session
        viewController.viewModel = viewModel // Pass the viewModel to the view controller
        return viewController
    }

    func updateUIViewController(_: ScannerViewController, context _: Context) {
        // Nothing to update in this case
    }
}

/**
 `ScannerViewController` is a custom `UIViewController` that manages the camera session and barcode scanning.
 It uses `AVCaptureSession` to capture video and `AVCaptureMetadataOutput` to detect barcodes.
 */
class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var viewModel: BarcodeScannerViewModel? // Reference to the viewModel
    private let captureSession = AVCaptureSession() // Session to capture video and metadata
    private var previewLayer: AVCaptureVideoPreviewLayer? // Layer to display the camera feed

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession() // Setup the camera session
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSession() // Start the camera session when the view appears
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession() // Stop the camera session when the view disappears
    }

    // Sets up the camera capture session and metadata output for barcode scanning
    private func setupCaptureSession() {
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoInput) else { return }

        captureSession.addInput(videoInput)

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean13, .qr, .code128] // Types of barcodes to scan
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) // Preview layer to display camera feed
        previewLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!) // Add preview layer to the view
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds // Adjust the preview layer's frame to match the view's bounds
    }

    // Starts the capture session to begin scanning
    func startSession() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }

    // Stops the capture session
    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    // Handles detected metadata (barcodes) from the camera
    func metadataOutput(_: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from _: AVCaptureConnection) {
        if let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let barcode = readableObject.stringValue
        {
            DispatchQueue.main.async {
                self.viewModel?.scannedBarcode = barcode // Update the viewModel with the scanned barcode
                self.stopSession() // Stop scanning after a barcode is found
            }
        }
    }
}

/**
 `BarcodeScannerView_Previews` provides a preview of the `BarcodeScannerView` for SwiftUI previews.
 */
struct BarcodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeScannerView() // Preview the barcode scanner view
    }
}
