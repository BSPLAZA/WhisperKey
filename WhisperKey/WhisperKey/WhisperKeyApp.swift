//
//  WhisperKeyApp.swift
//  WhisperKey
//
//  Created by Orion on 7/1/25.
//

import SwiftUI

@main
struct WhisperKeyApp: App {
    @StateObject private var keyCaptureService = KeyCaptureService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(keyCaptureService)
                .onAppear {
                    keyCaptureService.startListening()
                }
        }
    }
}
