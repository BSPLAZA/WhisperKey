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
        VStack(spacing: 24) {
            // Header with progress indicator
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.accentColor.opacity(0.2), Color.accentColor.opacity(0.1)], 
                                               startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "mic.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.accentColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Welcome to WhisperKey")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Step \(currentStep + 1) of \(steps)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 40)
                
                // Progress indicator with labels
                HStack(spacing: 0) {
                    ForEach(0..<steps, id: \.self) { step in
                        HStack(spacing: 0) {
                            // Progress dot
                            ZStack {
                                Circle()
                                    .fill(step <= currentStep ? Color.accentColor : Color.gray.opacity(0.2))
                                    .frame(width: 12, height: 12)
                                
                                if step < currentStep {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.white)
                                } else if step == currentStep {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 6, height: 6)
                                }
                            }
                            .scaleEffect(step == currentStep ? 1.2 : 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
                            
                            // Progress line
                            if step < steps - 1 {
                                Rectangle()
                                    .fill(step < currentStep ? Color.accentColor : Color.gray.opacity(0.2))
                                    .frame(height: 2)
                                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                            }
                        }
                    }
                }
                .padding(.horizontal, 60)
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
            
            // Navigation buttons with enhanced styling
            HStack(spacing: 16) {
                if currentStep > 0 {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep -= 1
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .medium))
                            Text("Previous")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(NSColor.controlBackgroundColor))
                                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                if currentStep < steps - 1 {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep += 1
                        }
                    }) {
                        HStack(spacing: 6) {
                            Text(nextButtonText)
                                .font(.system(size: 14, weight: .semibold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(canProceed ? Color.accentColor : Color.gray)
                                .shadow(color: canProceed ? Color.accentColor.opacity(0.3) : Color.clear, 
                                      radius: 6, x: 0, y: 3)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!canProceed)
                    .animation(.easeInOut(duration: 0.2), value: canProceed)
                } else {
                    Button(action: completeOnboarding) {
                        HStack(spacing: 8) {
                            Text("Get Started")
                                .font(.system(size: 15, weight: .semibold))
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 18))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(LinearGradient(colors: [Color.green, Color.green.opacity(0.8)],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing))
                                .shadow(color: Color.green.opacity(0.4), radius: 8, x: 0, y: 4)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
        .frame(width: 700, height: 700)
        .background(
            ZStack {
                Color(NSColor.windowBackgroundColor)
                
                // Subtle gradient background
                LinearGradient(
                    colors: [
                        Color.accentColor.opacity(0.03),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
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
    @State private var showFeatures = false
    
    var body: some View {
        VStack(spacing: 24) {
                // Animated icon with multiple layers
                ZStack {
                    // Outer pulse
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.2 : 0.9)
                        .opacity(isAnimating ? 0 : 0.3)
                        .animation(.easeOut(duration: 2).repeatForever(autoreverses: false), value: isAnimating)
                    
                    // Middle ring
                    Circle()
                        .stroke(LinearGradient(colors: [Color.accentColor, Color.accentColor.opacity(0.5)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 3)
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: isAnimating)
                    
                    // Inner circle
                    Circle()
                        .fill(LinearGradient(colors: [Color.accentColor.opacity(0.2), Color.accentColor.opacity(0.1)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                         startPoint: .top, endPoint: .bottom)
                        )
                }
                .onAppear { 
                    isAnimating = true
                    withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                        showFeatures = true
                    }
                }
                
                VStack(spacing: 8) {
                    Text("Transform Your Voice")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Privacy-first transcription powered by AI")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Feature cards with staggered animation
                VStack(spacing: 12) {
                    FeatureCard(icon: "lock.shield.fill", 
                               title: "100% Private",
                               description: "All processing happens locally")
                        .opacity(showFeatures ? 1 : 0)
                        .offset(y: showFeatures ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: showFeatures)
                    
                    FeatureCard(icon: "bolt.fill",
                               title: "Lightning Fast", 
                               description: "Metal-accelerated transcription")
                        .opacity(showFeatures ? 1 : 0)
                        .offset(y: showFeatures ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: showFeatures)
                    
                    FeatureCard(icon: "app.badge",
                               title: "Works Everywhere",
                               description: "Any text field, any app")
                        .opacity(showFeatures ? 1 : 0)
                        .offset(y: showFeatures ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: showFeatures)
                }
                .padding(.horizontal, 40)
            }
        }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(colors: [Color.accentColor.opacity(0.15), Color.accentColor.opacity(0.08)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 44, height: 44)
                    .shadow(color: Color.accentColor.opacity(0.2), radius: isHovered ? 8 : 4, x: 0, y: 2)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.accentColor)
                    .scaleEffect(isHovered ? 1.1 : 1.0)
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isHovered)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.08), radius: isHovered ? 6 : 3, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.accentColor.opacity(isHovered ? 0.2 : 0), lineWidth: 1)
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct PermissionsStep: View {
    @Binding var hasAccessibilityPermission: Bool
    @Binding var hasMicrophonePermission: Bool
    @State private var permissionCheckTimer: Timer?
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header with icon
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color.orange.opacity(0.2), Color.orange.opacity(0.1)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(colors: [Color.orange, Color.orange.opacity(0.8)],
                                         startPoint: .top, endPoint: .bottom)
                        )
                }
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: showContent)
                
                VStack(spacing: 8) {
                    Text("Required Permissions")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("WhisperKey needs these permissions to work properly")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 10)
                .animation(.easeOut(duration: 0.4).delay(0.2), value: showContent)
            }
            
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
            withAnimation {
                showContent = true
            }
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
                self.hasMicrophonePermission = granted
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
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isGranted ? Color.green.opacity(0.15) : Color.secondary.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: isGranted ? "checkmark.\(icon)" : icon)
                    .font(.system(size: 22))
                    .foregroundColor(isGranted ? .green : .secondary)
                    .symbolRenderingMode(.hierarchical)
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isGranted)
            
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
                    .font(.system(size: 20))
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                    action()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPressed = false
                    }
                }) {
                    Text("Grant")
                        .font(.system(size: 13, weight: .medium))
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .scaleEffect(isPressed ? 0.95 : 1.0)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isGranted ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.3), value: isGranted)
    }
}

struct ModelSelectionStep: View {
    @Binding var selectedModel: String
    @Binding var isDownloading: Bool
    @StateObject private var modelManager = ModelManager.shared
    @State private var showContent = false
    
    let models = [
        ("base.en", "Base English (141 MB)", "Fast, good for quick notes"),
        ("small.en", "Small English (465 MB)", "Balanced speed and accuracy"),
        ("medium.en", "Medium English (1.4 GB)", "Best accuracy for English"),
        ("large-v3", "Large V3 (3.1 GB)", "State-of-the-art, multilingual")
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header with icon
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color.purple.opacity(0.2), Color.purple.opacity(0.1)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "cpu")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(colors: [Color.purple, Color.purple.opacity(0.8)],
                                         startPoint: .top, endPoint: .bottom)
                        )
                }
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: showContent)
                
                VStack(spacing: 8) {
                    Text("Choose Your Model")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Select a Whisper model based on your needs")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 10)
                .animation(.easeOut(duration: 0.4).delay(0.2), value: showContent)
            }
            
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
        .onAppear {
            withAnimation {
                showContent = true
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
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header with icon
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.1)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8)],
                                         startPoint: .top, endPoint: .bottom)
                        )
                }
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: showContent)
                
                VStack(spacing: 8) {
                    Text("Clipboard Backup")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Choose how WhisperKey handles your transcriptions")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 10)
                .animation(.easeOut(duration: 0.4).delay(0.2), value: showContent)
            }
            
            // Main toggle with enhanced styling
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Always save to clipboard")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Your transcriptions are saved to clipboard as a safety net")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer(minLength: 20)
                    
                    Toggle("", isOn: $alwaysSaveToClipboard)
                        .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                        .labelsHidden()
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(colors: [Color.accentColor.opacity(0.12), Color.accentColor.opacity(0.08)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: Color.accentColor.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
                )
                
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
            
            // Interactive example with better styling
            Button(action: { 
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { 
                    showExample.toggle() 
                } 
            }) {
                HStack(spacing: 6) {
                    Image(systemName: showExample ? "chevron.down.circle.fill" : "chevron.right.circle")
                        .font(.system(size: 16))
                    Text("See how it works")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.accentColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.accentColor.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
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
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
    }
}

struct ReadyStep: View {
    @State private var showContent = false
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Success animation
            ZStack {
                // Outer pulse
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 140, height: 140)
                    .scaleEffect(pulseAnimation ? 1.3 : 0.9)
                    .opacity(pulseAnimation ? 0 : 0.4)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: false), value: pulseAnimation)
                
                // Middle ring
                Circle()
                    .fill(LinearGradient(colors: [Color.green.opacity(0.2), Color.green.opacity(0.1)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(colors: [Color.green, Color.green.opacity(0.8)],
                                     startPoint: .top, endPoint: .bottom)
                    )
                    .scaleEffect(showContent ? 1 : 0.5)
                    .rotationEffect(.degrees(showContent ? 0 : -90))
            }
            .opacity(showContent ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: showContent)
            .onAppear {
                pulseAnimation = true
            }
            
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
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
    }
}

struct HowToRow: View {
    let number: String
    let text: String
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 28, height: 28)
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Text(number)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .scaleEffect(isVisible ? 1 : 0.5)
            .opacity(isVisible ? 1 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(Double(number)! * 0.1), value: isVisible)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .opacity(isVisible ? 1 : 0)
                .offset(x: isVisible ? 0 : -20)
                .animation(.easeOut(duration: 0.4).delay(Double(number)! * 0.1 + 0.1), value: isVisible)
        }
        .onAppear {
            isVisible = true
        }
    }
}

// MARK: - Preview

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(showOnboarding: .constant(true))
    }
}