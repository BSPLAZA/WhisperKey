//
//  ClipboardNotification.swift
//  WhisperKey
//
//  Purpose: Shows a temporary notification when text is copied to clipboard
//  
//  Created by Assistant on 2025-07-12.
//

import SwiftUI
import AppKit

class ClipboardNotificationManager: ObservableObject {
    static let shared = ClipboardNotificationManager()
    
    private var notificationWindow: NSWindow?
    
    private init() {}
    
    func showClipboardNotification(wordCount: Int) {
        Task { @MainActor in
            // Close any existing notification
            hideNotification()
            
            // Create the notification view
            let notificationView = ClipboardNotificationView(wordCount: wordCount)
            let hostingView = NSHostingView(rootView: notificationView)
            
            // Create window
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 320, height: 60),
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            
            window.contentView = hostingView
            window.isOpaque = false
            window.backgroundColor = .clear
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .stationary]
            window.isMovableByWindowBackground = false
            window.hasShadow = true
            window.isReleasedWhenClosed = false // Prevent premature release
            
            // Position at bottom center of screen
            if let screen = NSScreen.main {
                let screenFrame = screen.visibleFrame
                let windowWidth = window.frame.width
                
                let xPosition = screenFrame.midX - windowWidth / 2
                let yPosition = screenFrame.minY + 100 // 100 points from bottom
                
                window.setFrameOrigin(NSPoint(x: xPosition, y: yPosition))
            }
            
            // Store reference
            notificationWindow = window
            
            // Show window with fade in
            window.alphaValue = 0
            window.orderFront(nil)
            
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3
                window.animator().alphaValue = 1.0
            }
            
            // Auto-hide after 3 seconds
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                await MainActor.run {
                    self.hideNotification()
                }
            }
        }
    }
    
    private func hideNotification() {
        guard let window = notificationWindow else { return }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            window.animator().alphaValue = 0.0
        }, completionHandler: {
            window.orderOut(nil)
            self.notificationWindow = nil
        })
    }
}

struct ClipboardNotificationView: View {
    let wordCount: Int
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.on.clipboard.fill")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .symbolRenderingMode(.hierarchical)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Saved to Clipboard")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("\(wordCount) word\(wordCount == 1 ? "" : "s") • Press ⌘V to paste")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.85))
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Material.regular)
                )
        )
        .scaleEffect(isVisible ? 1 : 0.8)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
    }
}