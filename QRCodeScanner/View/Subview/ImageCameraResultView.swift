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
    }
}
