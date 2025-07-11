//
//  PermissionGuideView.swift
//  WhisperKey
//
//  Purpose: Interactive guide for setting up permissions
//  
//  Created by Author on 2025-07-11.
//

import SwiftUI
import AppKit
import AVFoundation

struct PermissionGuideView: View {
    @State private var microphonePermission = false
    @State private var accessibilityPermission = false
    @State private var isCheckingPermissions = false
    let dismiss: (() -> Void)?
    
    init(dismiss: (() -> Void)? = nil) {
        self.dismiss = dismiss
    }
    
    var allPermissionsGranted: Bool {
        microphonePermission && accessibilityPermission
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                
                Text("Permission Setup")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text("WhisperKey needs these permissions to work properly")
                    .foregroundColor(.secondary)
            }
            .padding(.top, 30)
            .padding(.bottom, 20)
            
            Divider()
            
            // Permissions list
            VStack(spacing: 20) {
                PermissionRowView(
                    icon: "mic.fill",
                    title: "Microphone Access",
                    description: "Required to hear your voice for transcription",
                    isGranted: microphonePermission,
                    action: openMicrophoneSettings
                )
                
                PermissionRowView(
                    icon: "keyboard",
                    title: "Accessibility Access",
                    description: "Required to insert transcribed text into any app",
                    isGranted: accessibilityPermission,
                    action: openAccessibilitySettings
                )
                
                if allPermissionsGranted {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.green)
                        
                        Text("All permissions granted!")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Text("You're ready to start using WhisperKey")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(30)
            
            Spacer()
            
            // Instructions (only show if permissions not granted)
            if !allPermissionsGranted {
                VStack(alignment: .leading, spacing: 12) {
                    Text("How to grant permissions:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("1. Click the button next to each permission")
                        Text("2. System Settings will open to the right page")
                        Text("3. Find WhisperKey in the list and enable it")
                        Text("4. Return here and click 'Check Again'")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
            
            Divider()
            
            // Footer
            HStack {
                Button("Check Again") {
                    checkPermissions()
                }
                .disabled(isCheckingPermissions)
                
                Spacer()
                
                if allPermissionsGranted {
                    Button("Continue") {
                        dismiss?()
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                } else {
                    Button("Skip for Now") {
                        dismiss?()
                    }
                }
            }
            .padding()
        }
        .frame(width: 500, height: 600)
        .onAppear {
            checkPermissions()
        }
    }
    
    func checkPermissions() {
        isCheckingPermissions = true
        
        // Check microphone
        if #available(macOS 14.0, *) {
            AVAudioApplication.shared.recordPermission == .granted ? (microphonePermission = true) : (microphonePermission = false)
        } else {
            AVCaptureDevice.authorizationStatus(for: .audio) == .authorized ? (microphonePermission = true) : (microphonePermission = false)
        }
        
        // Check accessibility
        accessibilityPermission = AXIsProcessTrusted()
        
        isCheckingPermissions = false
    }
    
    func openMicrophoneSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
            NSWorkspace.shared.open(url)
        }
    }
    
    func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}

struct PermissionRowView: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isGranted ? .green : .orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .fontWeight(.medium)
                    
                    if isGranted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !isGranted {
                Button("Grant Access") {
                    action()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

