//
//  RecordingIndicator.swift
//  WhisperKey
//
//  Purpose: Visual feedback during recording with multiple display modes
//  
//  Created by Assistant on 2025-07-02.
//

import SwiftUI
import Cocoa

// MARK: - Recording Indicator Window

class RecordingIndicatorWindow: NSWindow {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 60),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        // Window configuration
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .statusBar
        self.collectionBehavior = [.canJoinAllSpaces, .stationary]
        self.isMovableByWindowBackground = false
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        
        // Make it appear on all spaces
        self.collectionBehavior.insert(.canJoinAllSpaces)
        
        // Disable mouse events
        self.ignoresMouseEvents = true
    }
    
    func showIndicator() {
        // Position at bottom center of screen
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let windowFrame = self.frame
            let x = screenFrame.midX - windowFrame.width / 2
            let y = screenFrame.minY + 40 // 40 points from bottom
            self.setFrameOrigin(NSPoint(x: x, y: y))
        }
        
        self.orderFront(nil)
        
        // Fade in animation
        self.alphaValue = 0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            self.animator().alphaValue = 1.0
        }
    }
    
    func hideIndicator() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            self.animator().alphaValue = 0.0
        }) {
            self.orderOut(nil)
        }
    }
}

// MARK: - Recording Indicator View

struct RecordingIndicatorView: View {
    @State private var isAnimating = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @ObservedObject var audioLevelMonitor: AudioLevelMonitor
    @AppStorage("maxRecordingDuration") private var maxRecordingDuration = 60.0
    let onStop: () -> Void
    
    private var timeRemaining: TimeInterval {
        max(0, maxRecordingDuration - elapsedTime)
    }
    
    private var isNearLimit: Bool {
        timeRemaining <= 10 && timeRemaining > 0
    }
    
    private var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var warningText: String? {
        if timeRemaining <= 10 && timeRemaining > 0 {
            return "Stopping in \(Int(timeRemaining))s"
        }
        return nil
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Recording icon with pulse animation
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.3))
                    .frame(width: 24, height: 24)
                    .scaleEffect(isAnimating ? 1.3 : 1.0)
                    .opacity(isAnimating ? 0.0 : 1.0)
                    .animation(
                        Animation.easeOut(duration: 1.0)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 12, height: 12)
            }
            
            // Status text with timer
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text("Recording")
                        .font(.system(size: 14, weight: .medium))
                        .fixedSize()  // Prevent truncation
                    Text(formattedTime)
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .fixedSize()  // Prevent truncation
                }
                .foregroundColor(.white)
                
                if let warning = warningText {
                    Text(warning)
                        .font(.system(size: 11))
                        .foregroundColor(isNearLimit ? .yellow : .white)
                }
            }
            
            Spacer()
            
            // Audio level indicator
            AudioLevelView(level: audioLevelMonitor.currentLevel)
                .frame(width: 120, height: 16)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .onAppear {
            isAnimating = true
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        // Ensure any existing timer is stopped first
        stopTimer()
        
        // Reset elapsed time
        elapsedTime = 0
        
        // Create new timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            elapsedTime += 0.1
            
            // Auto-stop at max duration
            if elapsedTime >= maxRecordingDuration {
                stopTimer()
                onStop()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Audio Level View

struct AudioLevelView: View {
    let level: Float
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(0..<10) { index in
                    Rectangle()
                        .fill(barColor(for: index))
                        .frame(width: geometry.size.width / 12, height: geometry.size.height)
                        .opacity(shouldShowBar(index) ? 1.0 : 0.2)
                        .cornerRadius(2)
                }
            }
        }
    }
    
    private func shouldShowBar(_ index: Int) -> Bool {
        let normalizedLevel = min(max(level, 0), 1)
        let threshold = Float(index) / 10.0
        return normalizedLevel > threshold
    }
    
    private func barColor(for index: Int) -> Color {
        if index < 4 {
            return .green
        } else if index < 7 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Menu Bar Recording Animation

extension AppDelegate {
    // These would need to be implemented in AppDelegate if menu bar animation is needed
    // For now, we're using the SwiftUI menu bar extra which handles this automatically
}

// MARK: - Audio Level Monitor

class AudioLevelMonitor: ObservableObject {
    @Published var currentLevel: Float = 0.0
}

// MARK: - Recording Indicator Manager

@MainActor
class RecordingIndicatorManager: ObservableObject {
    static let shared = RecordingIndicatorManager()
    
    private var indicatorWindow: RecordingIndicatorWindow?
    private var indicatorView: NSHostingView<RecordingIndicatorView>?
    private let audioLevelMonitor = AudioLevelMonitor()
    
    private init() {}
    
    func showRecordingIndicator() {
        // Create window if needed
        if indicatorWindow == nil {
            indicatorWindow = RecordingIndicatorWindow()
            
            // Create and set content view
            let view = RecordingIndicatorView(
                audioLevelMonitor: audioLevelMonitor,
                onStop: { [weak self] in
                    self?.hideRecordingIndicator()
                }
            )
            let hostingView = NSHostingView(rootView: view)
            indicatorWindow?.contentView = hostingView
            indicatorView = hostingView
        }
        
        // Show the indicator
        indicatorWindow?.showIndicator()
    }
    
    func hideRecordingIndicator() {
        indicatorWindow?.hideIndicator()
        // Reset audio level
        audioLevelMonitor.currentLevel = 0.0
    }
    
    func updateAudioLevel(_ level: Float) {
        // Normalize the level for better visualization - increased sensitivity
        let normalizedLevel = min(max(level * 30, 0), 1.0)
        audioLevelMonitor.currentLevel = normalizedLevel
    }
}

// MARK: - Integration Extensions

extension DictationService {
    func showRecordingFeedback() {
        Task { @MainActor in
            RecordingIndicatorManager.shared.showRecordingIndicator()
        }
    }
    
    func hideRecordingFeedback() {
        Task { @MainActor in
            RecordingIndicatorManager.shared.hideRecordingIndicator()
        }
    }
}