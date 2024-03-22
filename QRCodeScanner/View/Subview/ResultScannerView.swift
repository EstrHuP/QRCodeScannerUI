//
//  ResultScannerView.swift
//  QRCodeScanner
//
//  Created by EstrHuP on 22/3/24.
//

import SwiftUI

struct ResultScannerView: View {
    @ObservedObject var viewModel: ScannerViewModel
    
    var body: some View {
        Text(viewModel.scannedCode)
    }
}
