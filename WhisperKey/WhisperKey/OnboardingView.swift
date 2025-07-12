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
import AppKit

struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var hasAccessibilityPermission = false
    @State private var hasMicrophonePermission = false
    @State private var selectedModel = "base.en"
    @State private var isDownloading = false
    @Binding var showOnboarding: Bool
    
    @StateObject private var modelManager = ModelManager.shared
    
    private let steps = 5
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with progress indicator
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.accentColor)
                    Text("Welcome to WhisperKey")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                // Progress indicator
                HStack(spacing: 12) {
                    ForEach(0..<steps, id: \.self) { step in
                        Circle()
                            .fill(step <= currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                            .scaleEffect(step == currentStep ? 1.3 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStep)
                    }
                }
            }
            .padding(.top, 30)
            
            // Content area with fixed height
            Group {
                switch currentStep {
                case 0:
                    WelcomeStep()
                case 1:
                    PermissionsStep(
                        hasAccessibilityPermission: $hasAccessibilityPermission,
                        hasMicrophonePermission: $hasMicrophonePermission
                    )
                case 2:
                    ModelSelectionStep(
                        selectedModel: $selectedModel,
                        isDownloading: $isDownloading
                    )
                case 3:
                    ClipboardSettingsStep()
                case 4:
                    ReadyStep()
                default:
                    EmptyView()
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal, 40)
            
            // Navigation buttons
            HStack {
                if currentStep > 0 {
                    Button("Previous") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep -= 1
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if currentStep < steps - 1 {
                    Button(nextButtonText) {
                        withAnimation(.easeInOut(duration: 0.3)) {
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
            .padding(.bottom, 30)
        }
        .frame(width: 700, height: 700)
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
            // Allow proceeding if the selected model is installed, regardless of other downloads
            return modelManager.isModelInstalled(selectedModel)
        default:
            return true
        }
    }
    
    private var nextButtonText: String {
        if currentStep == 2 && isDownloading {
            return "Continue (downloads in background)"
        }
        return "Next"
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
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
                // Animated icon
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 100, height: 100)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                }
                .onAppear { isAnimating = true }
                
                VStack(spacing: 8) {
                    Text("Transform Your Voice")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Privacy-first transcription on your Mac")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                
                // How to use
                VStack(alignment: .leading, spacing: 12) {
                    Label("Tap Right Option key (activation key) to start/stop recording", systemImage: "keyboard")
                }
                .font(.callout)
                .padding(16)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                
                // Feature cards
                VStack(spacing: 10) {
                    FeatureCard(icon: "lock.shield.fill", 
                               title: "100% Private",
                               description: "All processing happens locally")
                    
                    FeatureCard(icon: "bolt.fill",
                               title: "Lightning Fast", 
                               description: "Metal-accelerated transcription")
                    
                    FeatureCard(icon: "app.badge",
                               title: "Works Everywhere",
                               description: "Any text field, any app")
                }
            }
        }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct PermissionsStep: View {
    @Binding var hasAccessibilityPermission: Bool
    @Binding var hasMicrophonePermission: Bool
    @State private var permissionCheckTimer: Timer?
    
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
                VStack(spacing: 8) {
                    Text("Note: You may need to restart WhisperKey after granting accessibility permission")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .multilineTextAlignment(.center)
                    
                    Button("Open System Settings") {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .buttonStyle(.link)
                    .font(.caption)
                }
                .padding(.horizontal, 40)
            }
        }
        .onAppear {
            startPermissionChecking()
        }
        .onDisappear {
            stopPermissionChecking()
        }
    }
    
    private func startPermissionChecking() {
        // Check immediately
        checkPermissions()
        
        // Then check every 2 seconds
        permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            checkPermissions()
        }
    }
    
    private func stopPermissionChecking() {
        permissionCheckTimer?.invalidate()
        permissionCheckTimer = nil
    }
    
    private func checkPermissions() {
        // Check accessibility
        hasAccessibilityPermission = AXIsProcessTrusted()
        
        // Check microphone
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            hasMicrophonePermission = true
        default:
            hasMicrophonePermission = false
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
        _ = AXIsProcessTrustedWithOptions(options)
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
        ("base.en", "Base English (141 MB)", "Fast, good for quick notes"),
        ("small.en", "Small English (465 MB)", "Balanced speed and accuracy"),
        ("medium.en", "Medium English (1.4 GB)", "Best accuracy for English"),
        ("large-v3", "Large V3 (3.1 GB)", "State-of-the-art, multilingual")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Your Model")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 20)
            
            Text("Select a Whisper model based on your needs")
                .foregroundColor(.secondary)
            
            ScrollView {
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
            }
            .frame(maxHeight: 350)
            
            VStack(spacing: 4) {
                if isDownloading {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 12, height: 12)
                        Text("Downloads will continue in the background")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Text("You can change or download models later in Preferences")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
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

struct ClipboardSettingsStep: View {
    @AppStorage("alwaysSaveToClipboard") private var alwaysSaveToClipboard = true
    @State private var showExample = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Clipboard Backup")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 20)
            
            Text("Choose how WhisperKey handles your transcriptions")
                .foregroundColor(.secondary)
            
            // Main toggle
            VStack(alignment: .leading, spacing: 16) {
                Toggle(isOn: $alwaysSaveToClipboard) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Always save to clipboard")
                            .fontWeight(.medium)
                        Text("Your transcriptions are saved to clipboard as a safety net")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .toggleStyle(.switch)
                .padding(16)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(10)
                
                // Explanation
                VStack(alignment: .leading, spacing: 12) {
                    Label("When ON:", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("• Text is always in clipboard (⌘V) as backup\n• Perfect if you often switch between apps")
                        .font(.caption)
                        .padding(.leading, 28)
                    
                    Label("When OFF:", systemImage: "xmark.circle")
                        .foregroundColor(.orange)
                    Text("• Clipboard only used when not in text field\n• Keeps your clipboard clean")
                        .font(.caption)
                        .padding(.leading, 28)
                }
                .padding(16)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
            
            // Interactive example
            Button(action: { withAnimation { showExample.toggle() } }) {
                HStack {
                    Image(systemName: showExample ? "chevron.down" : "chevron.right")
                        .frame(width: 12)
                    Text("See how it works")
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.accentColor)
            
            if showExample {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Example Scenarios:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    HStack(alignment: .top, spacing: 8) {
                        Text("📝")
                        Text("In TextEdit → Text inserted at cursor + Glass sound")
                            .font(.caption)
                    }
                    
                    HStack(alignment: .top, spacing: 8) {
                        Text("🗂️")
                        Text("In Finder → Saved to clipboard + Pop sound")
                            .font(.caption)
                    }
                    
                    HStack(alignment: .top, spacing: 8) {
                        Text("🔒")
                        Text("Password field → Always clipboard for safety")
                            .font(.caption)
                    }
                }
                .padding(12)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(6)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            Spacer()
            
            Text("You can change this anytime in Settings")
                .font(.caption)
                .foregroundColor(.secondary)
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
                    text: "Tap Right Option (⌥) to start recording"
                )
                HowToRow(
                    number: "2",
                    text: "Speak clearly and naturally"
                )
                HowToRow(
                    number: "3",
                    text: "Tap again to stop or wait for silence"
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