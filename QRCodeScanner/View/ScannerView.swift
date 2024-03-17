//
//  ScannerView.swift
//  QRCodeScanner
//
//  Created by EstrHuP on 17/3/24.
//

import SwiftUI

struct ScannerView: View {
    /// Properties
    @State private var isScanning: Bool = false
    
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
        .padding(15)
    }
    
    // MARK: - Activating Scanner Animation Method
    func activateScannerAnimation() {
        withAnimation(.easeInOut(duration: 0.85)
            .delay(0.1)
            .repeatForever(autoreverses: true)) {
                isScanning = true
            }
    }
}

#Preview {
    ScannerView()
}
