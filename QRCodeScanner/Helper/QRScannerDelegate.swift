//
//  QRScannerDelegate.swift
//  QRCodeScanner
//
//  Created by EstrHuP on 17/3/24.
//

import SwiftUI
import AVKit

class QRScannerDelegate: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    
    @Published var codeValue: String?
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if let metaObject = metadataObjects.first {
            guard let readableObject = metaObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let codeReaded = readableObject.stringValue else { return }
            codeValue = codeReaded
        }
    }
}
