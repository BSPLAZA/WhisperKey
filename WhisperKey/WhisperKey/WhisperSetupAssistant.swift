//
//  WhisperSetupAssistant.swift
//  WhisperKey
//
//  Purpose: Interactive setup assistant for whisper.cpp installation
//  Note: This is shown when whisper.cpp is missing during usage,
//        while OnboardingView is shown on first launch
//  
//  Created by Author on 2025-07-10.
//

import SwiftUI
import AppKit

struct WhisperSetupAssistant: View {
    @State private var currentStep = 0
    @State private var isCheckingInstallation = false
    @State private var installationStatus: InstallStatus = .notChecked
    @State private var selectedInstallMethod: InstallMethod = .homebrew
    @State private var customPath = ""
    @State private var isSelectingPath = false
    
    @ObservedObject private var whisperService = WhisperService.shared
    @Environment(\.dismiss) private var dismiss
    
    enum InstallStatus: Equatable {
        case notChecked
        case checking
        case found(path: String)
        case notFound
        case error(String)
    }
    
    enum InstallMethod {
        case homebrew
        case manual
        case custom
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "waveform")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                
                Text("WhisperKey Setup Assistant")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text("Let's get whisper.cpp set up so you can start dictating")
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            Divider()
            
            // Content
            ScrollView {
                VStack(spacing: 20) {
                    switch currentStep {
                    case 0:
                        welcomeStep
                    case 1:
                        checkInstallationStep
                    case 2:
                        installMethodStep
                    case 3:
                        installInstructionsStep
                    case 4:
                        verifyInstallationStep
                    default:
                        successStep
                    }
                }
                .padding(30)
            }
            
            Divider()
            
            // Footer
            HStack {
                if currentStep > 0 && currentStep < 5 {
                    Button("Back") {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                }
                
                Spacer()
                
                if currentStep < 5 {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                Button(action: nextStep) {
                    Text(nextButtonTitle)
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!canProceed)
            }
            .padding()
        }
        .frame(width: 600, height: 500)
    }
    
    var welcomeStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Welcome to WhisperKey Setup")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("WhisperKey uses whisper.cpp for fast, private speech recognition. Everything runs locally on your Mac.")
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(alignment: .leading, spacing: 12) {
                Label("Fast transcription using Metal acceleration", systemImage: "cpu")
                Label("Complete privacy - no internet required", systemImage: "lock.shield")
                Label("Support for multiple languages", systemImage: "globe")
                Label("Works in any application", systemImage: "app.dashed")
            }
            .padding(.vertical)
            
            Text("This assistant will help you:")
                .fontWeight(.medium)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("1. Check if whisper.cpp is already installed")
                Text("2. Guide you through installation if needed")
                Text("3. Download the required AI models")
                Text("4. Verify everything is working")
            }
            .foregroundColor(.secondary)
        }
    }
    
    var checkInstallationStep: some View {
        VStack(spacing: 20) {
            Text("Checking for whisper.cpp")
                .font(.title2)
                .fontWeight(.semibold)
            
            if isCheckingInstallation {
                ProgressView("Searching common installation locations...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.2)
                    .padding()
            } else {
                switch installationStatus {
                case .found(let path):
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.green)
                        
                        Text("Great! Whisper.cpp found at:")
                            .font(.headline)
                        
                        Text(path)
                            .font(.system(.body, design: .monospaced))
                            .padding(8)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(4)
                        
                        Text("You can proceed to download models.")
                            .foregroundColor(.secondary)
                    }
                    
                case .notFound:
                    VStack(spacing: 12) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        
                        Text("Whisper.cpp not found")
                            .font(.headline)
                        
                        Text("Don't worry! We'll help you install it.")
                            .foregroundColor(.secondary)
                        
                        Text("Searched locations:")
                            .font(.caption)
                            .padding(.top)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(["~/.whisperkey/bin", "~/Developer/whisper.cpp", "/usr/local/bin", "/opt/homebrew/bin"], id: \.self) { path in
                                HStack {
                                    Image(systemName: "folder")
                                        .foregroundColor(.secondary)
                                    Text(path)
                                        .font(.system(.caption, design: .monospaced))
                                }
                            }
                        }
                        .padding(8)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(4)
                    }
                    
                default:
                    EmptyView()
                }
            }
        }
        .onAppear {
            checkForWhisper()
        }
    }
    
    var installMethodStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Choose Installation Method")
                .font(.title2)
                .fontWeight(.semibold)
            
            RadioButton(
                title: "Install with Homebrew (Recommended)",
                description: "Easiest method if you have Homebrew installed",
                isSelected: selectedInstallMethod == .homebrew,
                action: { selectedInstallMethod = .homebrew }
            )
            
            RadioButton(
                title: "Manual Installation",
                description: "Build from source for best performance",
                isSelected: selectedInstallMethod == .manual,
                action: { selectedInstallMethod = .manual }
            )
            
            RadioButton(
                title: "I've Already Installed It",
                description: "Browse to select the whisper.cpp location",
                isSelected: selectedInstallMethod == .custom,
                action: { selectedInstallMethod = .custom }
            )
            
            if selectedInstallMethod == .custom {
                HStack {
                    TextField("Path to whisper-cli", text: $customPath)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Browse...") {
                        selectCustomPath()
                    }
                }
                .padding(.top)
            }
        }
    }
    
    var installInstructionsStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(selectedInstallMethod == .homebrew ? "Homebrew Installation" : "Manual Installation")
                .font(.title2)
                .fontWeight(.semibold)
            
            if selectedInstallMethod == .homebrew {
                homebrewInstructions
            } else {
                manualInstructions
            }
            
            Button("Copy Commands") {
                copyInstallCommands()
            }
            .padding(.top)
        }
    }
    
    var homebrewInstructions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Open Terminal and run these commands:")
                .fontWeight(.medium)
            
            CodeBlock("""
            # Install Homebrew if you don't have it
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            
            # Install whisper.cpp
            brew install whisper-cpp
            """)
            
            Text("This will install whisper.cpp with Metal acceleration enabled.")
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
    
    var manualInstructions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("For best performance with Metal acceleration:")
                .fontWeight(.medium)
            
            CodeBlock("""
            # Clone the repository
            git clone https://github.com/ggerganov/whisper.cpp.git
            cd whisper.cpp
            
            # Build with Metal support
            WHISPER_METAL=1 make -j
            
            # Create WhisperKey directory
            mkdir -p ~/.whisperkey/bin
            cp build/bin/whisper-cli ~/.whisperkey/bin/
            """)
            
            Text("This builds whisper.cpp optimized for your Mac's GPU.")
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
    
    var verifyInstallationStep: some View {
        VStack(spacing: 20) {
            Text("Verifying Installation")
                .font(.title2)
                .fontWeight(.semibold)
            
            Button("Check Installation") {
                checkForWhisper()
            }
            .buttonStyle(.borderedProminent)
            
            if case .found(let path) = installationStatus {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    
                    Text("Success! Whisper.cpp is installed at:")
                        .font(.headline)
                    
                    Text(path)
                        .font(.system(.body, design: .monospaced))
                        .padding(8)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(4)
                }
            }
        }
    }
    
    var successStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)
            
            Text("Setup Complete!")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Whisper.cpp is installed and ready to use.")
                .foregroundColor(.secondary)
            
            Text("Next, you'll need to download AI models in the Settings.")
                .padding(.top)
            
            Button("Open Settings") {
                dismiss()
                if let appDelegate = NSApp.delegate as? AppDelegate {
                    appDelegate.showPreferences()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // Helper Views
    struct RadioButton: View {
        let title: String
        let description: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                        .foregroundColor(isSelected ? .accentColor : .secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(12)
                .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    struct CodeBlock: View {
        let code: String
        
        init(_ code: String) {
            self.code = code
        }
        
        var body: some View {
            Text(code)
                .font(.system(.body, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    // Helper Properties
    var nextButtonTitle: String {
        switch currentStep {
        case 0:
            return "Get Started"
        case 4:
            return "Finish"
        case 5:
            return "Done"
        default:
            return "Next"
        }
    }
    
    var canProceed: Bool {
        switch currentStep {
        case 1:
            return installationStatus != .checking
        case 2:
            if selectedInstallMethod == .custom {
                return !customPath.isEmpty
            }
            return true
        case 4:
            if case .found = installationStatus {
                return true
            }
            return false
        default:
            return true
        }
    }
    
    // Helper Methods
    func nextStep() {
        withAnimation {
            if currentStep == 5 {
                // Done - close the window
                dismiss()
            } else if currentStep == 1, case .found = installationStatus {
                // Skip to success if already installed
                currentStep = 5
            } else if currentStep == 2 && selectedInstallMethod == .custom {
                // Verify custom path
                if FileManager.default.fileExists(atPath: customPath) {
                    whisperService.setCustomPaths(whisper: customPath, models: nil)
                    currentStep = 5
                } else {
                    installationStatus = .error("File not found at specified path")
                }
            } else {
                currentStep += 1
            }
        }
    }
    
    func checkForWhisper() {
        isCheckingInstallation = true
        installationStatus = .checking
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let path = whisperService.whisperPath {
                installationStatus = .found(path: path)
            } else {
                installationStatus = .notFound
            }
            isCheckingInstallation = false
        }
    }
    
    func selectCustomPath() {
        let panel = NSOpenPanel()
        panel.prompt = "Select whisper-cli"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK, let url = panel.url {
            customPath = url.path
        }
    }
    
    func copyInstallCommands() {
        let commands = selectedInstallMethod == .homebrew ?
            """
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            brew install whisper-cpp
            """ :
            """
            git clone https://github.com/ggerganov/whisper.cpp.git
            cd whisper.cpp
            WHISPER_METAL=1 make -j
            mkdir -p ~/.whisperkey/bin
            cp build/bin/whisper-cli ~/.whisperkey/bin/
            """
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(commands, forType: .string)
    }
}

// Preview
struct WhisperSetupAssistant_Previews: PreviewProvider {
    static var previews: some View {
        WhisperSetupAssistant()
    }
}