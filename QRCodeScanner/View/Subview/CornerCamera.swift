//
//  CornerCamera.swift
//  QRCodeScanner
//
//  Created by EstrHuP on 26/3/24.
//

import SwiftUI

struct CornerCamera: View {
    var body: some View {
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
}
