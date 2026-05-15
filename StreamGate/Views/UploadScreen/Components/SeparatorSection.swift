//
//  SeparatorSection.swift
//  StreamGate
//
//  Created by Shivansh Chouhan on 14/05/26.
//

import SwiftUI

struct SeparatorSection: View {
    var body: some View {
        HStack(spacing: 20) {
            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(height: 1)

            Text("or")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.45))

            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(height: 1)
        }
        .padding(.top, 8)
    }
}
