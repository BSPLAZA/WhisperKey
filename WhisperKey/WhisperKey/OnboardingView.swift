//
//  OnboardingView.swift
//  WhisperKey
//
//  Purpose: First-run onboarding experience
//  
//  Created by Assistant on 2025-07-02.
//

import SwiftUI
import AVFoundation

struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var hasAccessibilityPermission = false
    @State private var hasMicrophonePermission = false
    @State private var selectedModel = "base.en"
    @State private var isDownloading = false
    @Binding var showOnboarding: Bool
    
    @StateObject private var modelManager = ModelManager.shared
    
    private let steps = 4
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "mic.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.accentColor)
                Text("Welcome to WhisperKey")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .padding(.top, 20)
            
            // Progress indicator
            ProgressView(value: Double(currentStep + 1), total: Double(steps))
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
            
            // Content
            TabView(selection: $currentStep) {
                // Step 1: Welcome
                WelcomeStep()
                    .tag(0)
                
                // Step 2: Permissions
                PermissionsStep(
                    hasAccessibilityPermission: $hasAccessibilityPermission,
                    hasMicrophonePermission: $hasMicrophonePermission
                )
                .tag(1)
                
                // Step 3: Model Selection
                ModelSelectionStep(
                    selectedModel: $selectedModel,
                    isDownloading: $isDownloading
                )
                .tag(2)
                
                // Step 4: Ready to Go
                ReadyStep()
                    .tag(3)
            }
            .tabViewStyle(.automatic)
            .frame(height: 320)
            
            // Navigation buttons
            HStack {
                if currentStep > 0 {
                    Button("Previous") {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if currentStep < steps - 1 {
                    Button("Next") {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canProceed)
                } else {
                    Button("Get Started") {
                        completeOnboarding()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
        .frame(width: 500, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            checkPermissions()
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 1: // Permissions step
            return hasAccessibilityPermission && hasMicrophonePermission
        case 2: // Model step
            return !isDownloading && modelManager.isModelInstalled(selectedModel)
        default:
            return true
        }
    }
    
    private func checkPermissions() {
        hasAccessibilityPermission = AXIsProcessTrusted()
        
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            hasMicrophonePermission = true
        default:
            hasMicrophonePermission = false
        }
    }
    
    private func completeOnboarding() {
        // Save selected model
        UserDefaults.standard.set(selectedModel, forKey: "whisperModel")
        
        // Mark onboarding as complete
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Close onboarding
        showOnboarding = false
    }
}

// MARK: - Step Views

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
                .padding(.top, 20)
            
            Text("Privacy-First Dictation")
                .font(.title)
                .fontWeight(.semibold)
            
            Text("WhisperKey uses OpenAI's Whisper AI to transcribe your speech locally on your Mac. Your voice never leaves your device.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            VStack(alignment: .leading, spacing: 12) {
                Label("100% local processing", systemImage: "lock.shield.fill")
                Label("No internet required", systemImage: "wifi.slash")
                Label("Works in any app", systemImage: "app.badge")
            }
            .font(.callout)
            .padding(.top, 10)
        }
    }
}

struct PermissionsStep: View {
    @Binding var hasAccessibilityPermission: Bool
    @Binding var hasMicrophonePermission: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Required Permissions")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 20)
            
            Text("WhisperKey needs these permissions to work properly")
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                // Microphone permission
                PermissionRow(
                    icon: "mic.fill",
                    title: "Microphone Access",
                    description: "To record your voice for transcription",
                    isGranted: hasMicrophonePermission,
                    action: {
                        requestMicrophonePermission()
                    }
                )
                
                // Accessibility permission
                PermissionRow(
                    icon: "keyboard.fill",
                    title: "Accessibility Access",
                    description: "To insert text at your cursor position",
                    isGranted: hasAccessibilityPermission,
                    action: {
                        requestAccessibilityPermission()
                    }
                )
            }
            .padding(.horizontal, 40)
            
            if !hasAccessibilityPermission {
                Text("Note: You may need to restart WhisperKey after granting accessibility permission")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
    
    private func requestMicrophonePermission() {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                hasMicrophonePermission = granted
            }
        }
    }
    
    private func requestAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        hasAccessibilityPermission = AXIsProcessTrustedWithOptions(options)
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isGranted ? .green : .secondary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isGranted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Button("Grant") {
                    action()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ModelSelectionStep: View {
    @Binding var selectedModel: String
    @Binding var isDownloading: Bool
    @StateObject private var modelManager = ModelManager.shared
    
    let models = [
        ("base.en", "Base (141 MB)", "Fast, good for quick notes"),
        ("small.en", "Small (465 MB)", "Balanced speed and accuracy"),
        ("medium.en", "Medium (1.4 GB)", "Best accuracy, slower")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Your Model")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 20)
            
            Text("Select a Whisper model based on your needs")
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                ForEach(models, id: \.0) { model, name, description in
                    ModelRow(
                        model: model,
                        name: name,
                        description: description,
                        isSelected: selectedModel == model,
                        isInstalled: modelManager.isModelInstalled(model),
                        downloadProgress: modelManager.downloadProgress[model],
                        isDownloading: modelManager.isDownloading[model] ?? false,
                        onSelect: {
                            selectedModel = model
                        },
                        onDownload: {
                            isDownloading = true
                            modelManager.downloadModel(model)
                        }
                    )
                }
            }
            .padding(.horizontal, 40)
            
            Text("You can change models later in Preferences")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .onReceive(modelManager.$isDownloading) { newValue in
            // Update downloading state
            isDownloading = newValue.values.contains(true)
        }
    }
}

struct ModelRow: View {
    let model: String
    let name: String
    let description: String
    let isSelected: Bool
    let isInstalled: Bool
    let downloadProgress: Double?
    let isDownloading: Bool
    let onSelect: () -> Void
    let onDownload: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .accentColor : .secondary)
                .onTapGesture {
                    if isInstalled {
                        onSelect()
                    }
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isInstalled {
                Text("Installed")
                    .font(.caption)
                    .foregroundColor(.green)
            } else if isDownloading {
                ProgressView(value: downloadProgress ?? 0, total: 1.0)
                    .frame(width: 80)
            } else {
                Button("Download") {
                    onDownload()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.secondary.opacity(0.1))
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {
            if isInstalled {
                onSelect()
            }
        }
    }
}

struct ReadyStep: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .padding(.top, 20)
            
            Text("You're All Set!")
                .font(.title)
                .fontWeight(.semibold)
            
            Text("WhisperKey is ready to use. Here's how to get started:")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            VStack(alignment: .leading, spacing: 16) {
                HowToRow(
                    number: "1",
                    text: "Hold Right Option (⌥) to start recording"
                )
                HowToRow(
                    number: "2",
                    text: "Speak clearly and naturally"
                )
                HowToRow(
                    number: "3",
                    text: "Release to stop or wait for silence"
                )
                HowToRow(
                    number: "4",
                    text: "Your text appears at the cursor!"
                )
            }
            .padding(.horizontal, 60)
            
            Text("Click the menu bar icon 🎤 to access preferences")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 10)
        }
    }
}

struct HowToRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.accentColor))
            
            Text(text)
                .font(.callout)
        }
    }
}

// MARK: - Preview

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(showOnboarding: .constant(true))
    }
}