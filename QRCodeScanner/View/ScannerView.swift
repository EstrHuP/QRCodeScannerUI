//
//  ScannerView.swift
//  QRCodeScanner
//
//  Created by EstrHuP on 17/3/24.
//

import SwiftUI
import AVKit

struct ScannerView: View {
    // MARK: - Properties
    @State private var isScanning: Bool = false
    @State private var session: AVCaptureSession = .init()
    @State private var cameraPermission: CameraPermission = .idle
    /// QR Scanner AV Output
    @State private var qrOutput: AVCaptureMetadataOutput = .init()
    /// Error
    @State private var errorMessage: String = ""
    @State private var isShowError: Bool = false
    /// Navigate inside app
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(spacing: 8) {
            Button {
                
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity,
                   alignment: .leading)
            
            Text("Place the QR code inside the area")
                .font(.title3)
                .foregroundColor(.black.opacity(0.8))
                .padding(.top, 20)
            
            Text("Scanning will start automatically")
                .font(.callout)
                .foregroundColor(.gray)
            
            Spacer(minLength: .zero)
            
            // MARK: - Scanner
            GeometryReader {
                let size = $0.size
                
                ZStack {
                    CameraView(frameSize: size, session: $session)
                    ForEach(0...4, id: \.self) { index in
                        let rotation = Double(index) * 90
                        
                        RoundedRectangle(cornerRadius: 2, style: .circular)
                        /// Trimming to get Scanner like Edges
                            .trim(from: 0.61, to: 0.64)
                            .stroke(.blue,
                                    style: StrokeStyle(lineWidth: 5,
                                                       lineCap: .round,
                                                       lineJoin: .round))
                            .rotationEffect(.init(degrees: rotation))
                    }
                }
                /// Sqaure shape
                .frame(width: size.width,
                       height: size.width)
                
                /// Scanner animation
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(.blue)
                        .frame(height: 2.5)
                        .shadow(color: .black.opacity(0.8),
                                radius: 8,
                                x: .zero,
                                y: isScanning ? 15 : -15)
                        .offset(y: isScanning ? size.width : .zero)
                }
                
                /// Center
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity)
            }
            .padding(.horizontal, 45)
            
            
            Spacer(minLength: 15)
            Button {
                
            } label: {
                Image(systemName: "qrcode.viewfinder")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
            
            Spacer(minLength: 15)
        }
        .onAppear(perform: checkCameraPermission )
        .padding(15)
        .alert(errorMessage, isPresented: $isShowError) {
            if cameraPermission == .denied {
                Button("Settings") {
                    let settingsString = UIApplication.openSettingsURLString
                    if let settingsURL = URL(string: settingsString) {
                        openURL(settingsURL)
                    }
                }
                Button("Cancel", role: .cancel) {
                    
                }
            }
        }
    }
    
    // MARK: - Activating Scanner Animation Method
    func activateScannerAnimation() {
        withAnimation(.easeInOut(duration: 0.85)
            .delay(0.1)
            .repeatForever(autoreverses: true)) {
                isScanning = true
            }
    }
    
    // MARK: - Check camera permission
    func checkCameraPermission() {
        Task {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: 
                cameraPermission = .approved
                setupCamera()
            case .notDetermined:
                if await AVCaptureDevice.requestAccess(for: .video) {
                    cameraPermission = .approved
                    setupCamera()
                }  else {
                    cameraPermission = .denied
                    presentError("Please provide access to camera for scanning codes")
                }
            case .denied, .restricted: 
                cameraPermission = .denied
                presentError("Please provide access to camera for scanning codes")
            default: break
            }
        }
    }
    
    // MARK: - Set up camera
    func setupCamera() {
        do {
            // finding back camera
            guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInUltraWideCamera],
                                                                mediaType: .video,
                                                                position: .back).devices.first 
            else {
                presentError("Unkown error")
                return
            }
            // camera input
            let input = try AVCaptureDeviceInput(device: device)
            // checking wheter input and output can be added to the session
            guard session.canAddInput(input), session.canAddOutput(qrOutput) else {
                presentError("Unkown error")
                return
            }
            
            // adding input and output to camera session
            session.beginConfiguration()
            session.addInput(input)
            session.addOutput(qrOutput)
            // setting output configuration to read QR codes
            qrOutput.metadataObjectTypes = [.qr, .microQR]
            // adding delegate to retreive the fetched QR code from camera
            
            
        } catch {
            presentError(error.localizedDescription)
        }
    }
    
    // MARK: - Presenting error
    func presentError(_ message: String) {
        errorMessage = message
        isShowError.toggle()
    }
}

#Preview {
    ScannerView()
}
