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
    
    let deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInWideAngleCamera, .builtInUltraWideCamera]
    let metadataTypes: [AVMetadataObject.ObjectType] = [.dataMatrix]
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        qrDelegate.$codeValue
            .sink { [weak self] codeValue in
                self?.handleQRCodeReaded(codeUpdated: codeValue)
                print(codeValue ?? "")
            }.store(in: &cancellables)
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Animation Methods
    func startScannerAnimation() {
        withAnimation(.easeInOut(duration: 0.85)
            .delay(0.1)
            .repeatForever(autoreverses: true)) {
                self.isScanning = true
            }
    }
    
    func stopScannerAnimation() {
        withAnimation(.easeInOut(duration: 0.85)) {
            DispatchQueue.main.async {
                self.session.stopRunning()
            }
            isScanning = false
        }
    }
    
    // MARK: - New session to scan
    func reactivateCamera() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
        self.startScannerAnimation()
        self.scannedCode = ""
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
    func setupCamera(deviceTypes: [AVCaptureDevice.DeviceType],
                     metadataTypes: [AVMetadataObject.ObjectType]) {
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
    func handleQRCodeReaded(codeUpdated: String?) {
        stopScannerAnimation()
        guard let codeReaded = codeUpdated else { return }
        scannedCode = codeReaded
    }
    
    // MARK: - Presenting error
    func presentError(_ message: String) {
        errorMessage = message
        isShowError.toggle()
    }
    
    private func handleAuthorizedPermission() {
        cameraPermission = .approved
        DispatchQueue.main.async {
            if self.session.inputs.isEmpty {
                self.setupCamera(deviceTypes: self.deviceTypes,
                                 metadataTypes: self.metadataTypes)
            } else {
                self.session.startRunning()
            }
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
