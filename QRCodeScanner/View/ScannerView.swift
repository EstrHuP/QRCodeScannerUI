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
    @StateObject private var viewModel: ScannerViewModel = ScannerViewModel()
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(spacing: 8) {
            Button {
                // MARK: - Reactivate camera or close the app
                viewModel.reactivateCamera()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity,
                   alignment: .leading)
            
            Text("Place the QR code inside the area")
                .font(.title3)
                .foregroundColor(.gray.opacity(0.8))
                .padding(.top, 20)
            
            Text("Scanning will start automatically")
                .font(.callout)
                .foregroundColor(.gray)
            
            Spacer(minLength: .zero)
            
            // MARK: - Scanner
            GeometryReader {
                let size = $0.size
                
                ZStack {
                    CameraView(frameSize: CGSize(width: size.width,
                                                 height: size.width),
                               session: $viewModel.session)
                    .scaleEffect(0.97)
                    
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
                        .fill(.red)
                        .frame(height: 2.5)
                        .shadow(color: .black.opacity(0.8),
                                radius: 8,
                                x: .zero,
                                y: viewModel.isScanning ? 15 : -15)
                        .offset(y: viewModel.isScanning ? size.width : .zero)
                }
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity)
            }
            .padding(.horizontal, 45)
            
            Text(viewModel.scannedCode)
            
            Spacer(minLength: 15)
            Button {
                if !viewModel.session.isRunning, viewModel.cameraPermission == .approved {
                    viewModel.reactivateCamera()
                    viewModel.startScannerAnimation()
                }
            } label: {
                Image(systemName: "qrcode.viewfinder")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
            
            Spacer(minLength: 15)
        }
        
        /// Permissions
        .onAppear(perform: viewModel.checkCameraPermission)
        .padding(15)
        .alert(viewModel.errorMessage, isPresented: $viewModel.isShowError) {
            if viewModel.cameraPermission == .denied {
                Button("Settings") {
                    let settingsString = UIApplication.openSettingsURLString
                    if let settingsURL = URL(string: settingsString) {
                        openURL(settingsURL)
                    }
                }
                Button("Cancel", role: .cancel) {
                    // TODO: cancel option
                }
            }
        }
    }
}

#Preview {
    ScannerView()
}
