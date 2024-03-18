//
//  ScannerViewModel.swift
//  QRCodeScanner
//
//  Created by EstrHuP on 18/3/24.
//

import SwiftUI
import AVKit
import Combine

class ScannerViewModel: ObservableObject {
    // MARK: - Properties
    @Published var scannedCode: String = ""
    @Published var errorMessage: String = ""
    @Published var isScanning: Bool = false
    @Published var isShowError: Bool = false
    
    var session: AVCaptureSession = .init()
    var qrOutput: AVCaptureMetadataOutput = .init()
    var qrDelegate = QRScannerDelegate()
    var cameraPermission: CameraPermission = .idle
    
    private var cancellables = Set<AnyCancellable>()
    
    static let deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInWideAngleCamera, .builtInUltraWideCamera]
    static let metadataTypes: [AVMetadataObject.ObjectType] = [.qr, .microQR, .ean13]
    
    init() {
        qrDelegate.objectWillChange.sink { [weak self] _ in
            self?.handleQRCodeReaded()
        }.store(in: &cancellables)
    }
    
    // MARK: - Animation Methods
    func startScannerAnimation() {
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.85)
                .delay(0.1)
                .repeatForever(autoreverses: true)) {
                    self.isScanning = true
                }
        }
    }
    
    func stopScannerAnimation() {
        withAnimation(.easeInOut(duration: 0.85)) {
            self.isScanning = false
        }
    }
    
    // MARK: - New session to scan
    func reactivateCamera() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }
    
    // MARK: - Check camera permission
    func checkCameraPermission() {
        Task {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: handleAuthorizedPermission()
            case .notDetermined: await requestCameraPermission()
            case .denied, .restricted: handleDeniedPermission()
            default: break
            }
        }
    }
    
    // MARK: - Set up camera
    func setupCamera(deviceTypes: [AVCaptureDevice.DeviceType], metadataTypes: [AVMetadataObject.ObjectType]) {
        do {
            /// finding back camera
            guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes,
                                                                mediaType: .video,
                                                                position: .back).devices.first else {
                presentError("Unkown DEVICE error")
                return
            }
            /// camera input
            let input = try AVCaptureDeviceInput(device: device)
            
            /// checking wheter input and output can be added to the session
            guard session.canAddInput(input), session.canAddOutput(qrOutput) else {
                presentError("Unkown INPUT/OUTPUT error")
                return
            }
            
            /// adding input and output to camera session
            session.beginConfiguration()
            session.addInput(input)
            session.addOutput(qrOutput)
            
            /// setting output configuration to read QR codes
            qrOutput.metadataObjectTypes = metadataTypes
            
            /// adding delegate to retreive the fetched QR code from camera
            qrOutput.setMetadataObjectsDelegate(qrDelegate,
                                                queue: .main)
            session.commitConfiguration()
            
            /// note session must be started on Background Thread
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
            
            /// start the animation
            startScannerAnimation()
            
        } catch {
            presentError(error.localizedDescription)
        }
    }
    
    // MARK: - Code Readed
    /// Reset values if the code is readed
    func handleQRCodeReaded() {
        if let codeReaded = qrDelegate.scannedCode {
            DispatchQueue.main.async {
                self.scannedCode = codeReaded
                self.stopScannerAnimation()
                self.session.stopRunning()
                self.qrDelegate.scannedCode = nil
            }
        }
    }
    
    // MARK: - Presenting error
    func presentError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.isShowError.toggle()
        }
    }
    
    private func handleAuthorizedPermission() {
        cameraPermission = .approved
        if session.inputs.isEmpty {
            setupCamera(deviceTypes: ScannerViewModel.deviceTypes, 
                        metadataTypes: ScannerViewModel.metadataTypes)
        } else {
            session.startRunning()
        }
    }
    
    private func requestCameraPermission() async {
        if await AVCaptureDevice.requestAccess(for: .video) {
            self.handleAuthorizedPermission()
        } else {
            self.handleDeniedPermission()
        }
    }
    
    private func handleDeniedPermission() {
        cameraPermission = .denied
        presentError("Please provide access to the camera for scanning codes.")
    }
}
