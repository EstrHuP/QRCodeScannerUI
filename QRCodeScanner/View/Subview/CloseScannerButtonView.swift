//
//  CloseScannerButtonView.swift
//  QRCodeScanner
//
//  Created by EstrHuP on 21/3/24.
//

import SwiftUI

struct CloseScannerButtonView: View {
    
    @ObservedObject var viewModel: ScannerViewModel
    
    let closeImage: String
    let explainText1: String
    let explainText2: String
    
    var body: some View {
        Button {
            // MARK: - Reactivate camera or close the app
            viewModel.reactivateCamera()
        } label: {
            Image(systemName: closeImage)
                .font(.title3)
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity,
               alignment: .leading)
        
        Text(explainText1)
            .font(.title3)
            .foregroundColor(.gray.opacity(0.8))
            .padding(.top, 20)
        
        Text(explainText2)
            .font(.callout)
            .foregroundColor(.gray)
    }
}
