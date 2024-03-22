//
//  QRCodeScannerApp.swift
//  QRCodeScanner
//
//  Created by EstrHuP on 17/3/24.
//

import SwiftUI

@main
struct QRCodeScannerApp: App {
    var body: some Scene {
        WindowGroup {
            ScannerView(viewModel: ScannerViewModel(),
                        closeImg: "xmark",
                        explainText1: "Place the QR code inside the area",
                        explainText2: "Scanning will start automatically",
                        resetScannerImg: "qrcode.viewfinder",
                        goToSettingsText: "Go to settings")
        }
    }
}
