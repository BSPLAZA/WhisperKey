//
//  ContentView.swift
//  WhisperKey
//
//  Created by Orion on 7/1/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var keyCaptureService: KeyCaptureService
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.circle.fill")
                .imageScale(.large)
                .font(.system(size: 60))
                .foregroundStyle(.tint)
            
            Text("WhisperKey")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Press F5 to start dictation")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Divider()
                .padding(.vertical)
            
            HStack {
                Text("Status:")
                    .fontWeight(.medium)
                Text(keyCaptureService.isListening ? "Listening" : "Not Listening")
                    .foregroundStyle(keyCaptureService.isListening ? .green : .red)
            }
            
            HStack {
                Text("F5 Press Count:")
                    .fontWeight(.medium)
                Text("\(keyCaptureService.keyPressCount)")
            }
            
            Button(action: {
                if keyCaptureService.isListening {
                    keyCaptureService.stopListening()
                } else {
                    keyCaptureService.startListening()
                }
            }) {
                Text(keyCaptureService.isListening ? "Stop Listening" : "Start Listening")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(width: 300, height: 400)
    }
}

#Preview {
    ContentView()
        .environmentObject(KeyCaptureService())
}
