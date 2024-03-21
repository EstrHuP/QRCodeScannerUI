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
    @ObservedObject private var viewModel: ScannerViewModel = ScannerViewModel()
    @Environment(\.openURL) private var openURL
    
    var closeImg: String
    var explainText1: String
    var explainText2: String
    var resetScannerImg: String
    var goToSettingsText: String
    
    // MARK: - init
    init(viewModel: ScannerViewModel,
         closeImg: String,
         explainText1: String,
         explainText2: String,
         resetScannerImg: String,
         goToSettingsText: String) {
        self.viewModel = viewModel
        self.closeImg = closeImg
        self.explainText1 = explainText1
        self.explainText2 = explainText2
        self.resetScannerImg = resetScannerImg
        self.goToSettingsText = goToSettingsText
    }
    
    var body: some View {
        VStack(spacing: AppConstants.Number.eight) {
            // MARK: - Left top button
            CloseScannerButtonView(viewModel: viewModel,
                                   closeImage: closeImg,
                                   explainText1: explainText1,
                                   explainText2: explainText2)
            
            Spacer(minLength: .zero)
            
            // MARK: - Scanner
            ImageCameraResultView(viewModel: viewModel)
            
            // MARK: - Scanner result
            Text(viewModel.scannedCode)
            
            Spacer(minLength: AppConstants.Number.fifteen)
            
            // MARK: - Restart scanner
            RestartScannerButtonView(viewModel: viewModel,
                                     imageName: resetScannerImg)
            
            Spacer(minLength: AppConstants.Number.fifteen)
        }
        
        /// Permissions
        .onAppear(perform: viewModel.checkCameraPermission)
        .padding(AppConstants.Number.fifteen)
        
        .alert(viewModel.errorMessage, isPresented: $viewModel.isShowError) {
            if viewModel.cameraPermission == .denied {
                Button(goToSettingsText) {
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
