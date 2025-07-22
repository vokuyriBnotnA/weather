//
//  PrecipitationView.swift
//  backgroundGraphics
//
//  Created by Anton on 05.02.2025.
//

import SwiftUI

struct PrecipitationView: View {
    var rain: Bool
    var snow: Bool
    
    var body: some View {
        if rain {
            RainView()
        } else if snow {
            SnowView()
        }
    }
}

