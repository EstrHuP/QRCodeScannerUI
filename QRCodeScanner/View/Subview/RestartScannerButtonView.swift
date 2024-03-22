//
//  RestartScannerButtonView.swift
//  QRCodeScanner
//
//  Created by EstrHuP on 19/3/24.
//

import SwiftUI

struct RestartScannerButtonView: View {
    
    @ObservedObject var viewModel: ScannerViewModel
    
    let imageName: String
    
    var body: some View {
        Button {
            if !viewModel.scannedCode.isEmpty, viewModel.cameraPermission == .approved {
                viewModel.reactivateCamera()
                viewModel.startScannerAnimation()
            }
        } label:{
            Image(systemName: imageName)
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
    }
}
