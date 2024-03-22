//
//  ImageCameraResultView.swift
//  QRCodeScanner
//
//  Created by EstrHuP on 21/3/24.
//

import SwiftUI

struct ImageCameraResultView: View {
    @ObservedObject var viewModel: ScannerViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if viewModel.scannedCode.isEmpty {
                    CameraView(frameSize: CGSize(width: geometry.size.width, height: geometry.size.width),
                               session: $viewModel.session)
                        .scaleEffect(AppConstants.Number.zeroNinetySeven)
                } else {
                    Image("oliver")
                        .resizable()
                        .scaledToFit()
                }
                CornerCamera()
            }
            /// Square shape
            .frame(width: geometry.size.width, 
                   height: geometry.size.width)
            
            /// Scanner animation
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(.red)
                    .frame(height: AppConstants.Number.twoFive)
                    .shadow(color: .black.opacity(AppConstants.Number.zeroEight),
                            radius: AppConstants.Number.eight,
                            x: .zero,
                            y: viewModel.isScanning ? AppConstants.Number.fifteen : -AppConstants.Number.fifteen)
                    .offset(y: viewModel.isScanning ? geometry.size.width : .zero)
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
        }
        .padding(.horizontal, AppConstants.Number.fourtyFive)
    }
}
