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
        GeometryReader {
            let size = $0.size
            
            ZStack {
                if viewModel.scannedCode.isEmpty {
                    CameraView(frameSize: CGSize(width: size.width,
                                                 height: size.width),
                               session: $viewModel.session)
                    .scaleEffect(AppConstants.Number.zeroNinetySeven)
                }
                
                ForEach(0...4, id: \.self) { index in
                    let rotation = Double(index) * AppConstants.Number.ninety
                    
                    RoundedRectangle(cornerRadius: AppConstants.Number.two,
                                     style: .circular)
                    /// Trimming to get Scanner like Edges
                    .trim(from: AppConstants.Number.zeroSixtyOne,
                          to: AppConstants.Number.zeroSixtyFour)
                    .stroke(.blue,
                            style: StrokeStyle(lineWidth: AppConstants.Number.five,
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
                    .frame(height: AppConstants.Number.twoFive)
                    .shadow(color: .black.opacity(AppConstants.Number.zeroEight),
                            radius: AppConstants.Number.eight,
                            x: .zero,
                            y: viewModel.isScanning ? AppConstants.Number.fifteen : -AppConstants.Number.fifteen)
                    .offset(y: viewModel.isScanning ? size.width : .zero)
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
        }
        .padding(.horizontal, AppConstants.Number.fourtyFive)
    }
}
