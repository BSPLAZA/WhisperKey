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
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 60),
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
    @State private var audioLevel: Float = 0.0
    let onStop: () -> Void
    
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
            
            // Status text
            Text("Recording...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            // Audio level indicator
            AudioLevelView(level: audioLevel)
                .frame(width: 60, height: 16)
            
            // Stop button (for future use)
            /*
            Button(action: onStop) {
                Image(systemName: "stop.fill")
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            */
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
        }
    }
    
    func updateAudioLevel(_ level: Float) {
        audioLevel = level
    }
}

// MARK: - Audio Level View

struct AudioLevelView: View {
    let level: Float
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(0..<8) { index in
                    Rectangle()
                        .fill(barColor(for: index))
                        .frame(width: geometry.size.width / 10, height: geometry.size.height)
                        .opacity(shouldShowBar(index) ? 1.0 : 0.3)
                }
            }
        }
    }
    
    private func shouldShowBar(_ index: Int) -> Bool {
        let normalizedLevel = min(max(level, 0), 1)
        let threshold = Float(index) / 8.0
        return normalizedLevel > threshold
    }
    
    private func barColor(for index: Int) -> Color {
        if index < 3 {
            return .green
        } else if index < 6 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Menu Bar Recording Animation

extension MenuBarApp {
    func startRecordingAnimation() {
        recordingAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if let button = self.statusItem?.button {
                if button.image == self.recordingIcon {
                    button.image = self.defaultIcon
                } else {
                    button.image = self.recordingIcon
                }
            }
        }
    }
    
    func stopRecordingAnimation() {
        recordingAnimationTimer?.invalidate()
        recordingAnimationTimer = nil
        if let button = statusItem?.button {
            button.image = defaultIcon
        }
    }
}

// MARK: - Recording Indicator Manager

@MainActor
class RecordingIndicatorManager: ObservableObject {
    static let shared = RecordingIndicatorManager()
    
    private var indicatorWindow: RecordingIndicatorWindow?
    private var indicatorView: NSHostingView<RecordingIndicatorView>?
    
    private init() {}
    
    func showRecordingIndicator() {
        // Create window if needed
        if indicatorWindow == nil {
            indicatorWindow = RecordingIndicatorWindow()
            
            // Create and set content view
            let view = RecordingIndicatorView(onStop: { [weak self] in
                self?.hideRecordingIndicator()
            })
            let hostingView = NSHostingView(rootView: view)
            indicatorWindow?.contentView = hostingView
            indicatorView = hostingView
        }
        
        // Show the indicator
        indicatorWindow?.showIndicator()
    }
    
    func hideRecordingIndicator() {
        indicatorWindow?.hideIndicator()
    }
    
    func updateAudioLevel(_ level: Float) {
        // Update audio level in the view
        // This would require making the view observable
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