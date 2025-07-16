//
//  MemoryMonitor.swift
//  WhisperKey
//
//  Purpose: Monitor system memory pressure and warn users
//  
//  Created by Assistant on 2025-07-02.
//

import Foundation
import Combine

@MainActor
class MemoryMonitor: ObservableObject {
    static let shared = MemoryMonitor()
    
    @Published var isUnderMemoryPressure = false
    @Published var currentMemoryUsage: Double = 0.0 // MB
    @Published var availableMemory: Double = 0.0 // MB
    
    private var timer: Timer?
    private let checkInterval: TimeInterval = 30.0 // Check every 30 seconds
    private let memoryPressureThreshold: Double = 90.0 // Warn when 90% of memory is used
    
    // Memory thresholds for different models (in MB)
    private let modelMemoryRequirements: [String: Double] = [
        "base.en": 300,    // ~300MB for base model processing
        "small.en": 500,   // ~500MB for small model
        "medium.en": 1500, // ~1.5GB for medium model
        "large-v3-turbo": 3000 // ~3GB for large model
    ]
    
    private init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        // Initial check
        checkMemoryStatus()
        
        // Set up periodic checks
        timer = Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkMemoryStatus()
            }
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    func checkMemoryStatus() {
        let memoryInfo = getMemoryInfo()
        
        currentMemoryUsage = memoryInfo.used
        availableMemory = memoryInfo.available
        
        // Calculate memory pressure percentage
        let memoryPressurePercentage = (memoryInfo.used / memoryInfo.total) * 100
        
        // Update pressure status
        isUnderMemoryPressure = memoryPressurePercentage > memoryPressureThreshold
        
        if isUnderMemoryPressure {
            DebugLogger.log("MemoryMonitor: High memory pressure detected (\(Int(memoryPressurePercentage))% used)")
        }
    }
    
    func canRunModel(_ modelName: String) -> Bool {
        let requiredMemory = modelMemoryRequirements[modelName] ?? 500
        return availableMemory > requiredMemory
    }
    
    func recommendedModel() -> String {
        // Check available memory and recommend appropriate model
        if availableMemory > 3000 {
            return "medium.en" // Can run medium comfortably
        } else if availableMemory > 1000 {
            return "base.en" // Default to base model
        } else {
            return "base.en" // Fall back to base
        }
    }
    
    private func getMemoryInfo() -> (total: Double, used: Double, available: Double) {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        _ = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        // Get system memory info
        let pageSize = vm_kernel_page_size
        var vmStats = vm_statistics64()
        var vmStatsSize = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<natural_t>.size)
        
        let hostPort = mach_host_self()
        let kr = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(vmStatsSize)) {
                host_statistics64(hostPort, HOST_VM_INFO64, $0, &vmStatsSize)
            }
        }
        
        if kr == KERN_SUCCESS {
            let totalMemory = Double(ProcessInfo.processInfo.physicalMemory) / 1024 / 1024 // Convert to MB
            let freeMemory = Double(vmStats.free_count) * Double(pageSize) / 1024 / 1024
            let activeMemory = Double(vmStats.active_count) * Double(pageSize) / 1024 / 1024
            let inactiveMemory = Double(vmStats.inactive_count) * Double(pageSize) / 1024 / 1024
            let wiredMemory = Double(vmStats.wire_count) * Double(pageSize) / 1024 / 1024
            
            let usedMemory = activeMemory + wiredMemory
            let availableMemory = freeMemory + inactiveMemory
            
            return (total: totalMemory, used: usedMemory, available: availableMemory)
        }
        
        // Fallback if system stats fail
        let totalMemory = Double(ProcessInfo.processInfo.physicalMemory) / 1024 / 1024
        return (total: totalMemory, used: totalMemory * 0.5, available: totalMemory * 0.5)
    }
    
    deinit {
        timer?.invalidate()
    }
}

// MARK: - Memory Pressure Notifications

extension MemoryMonitor {
    func notifyMemoryPressure() {
        Task { @MainActor in
            ErrorHandler.shared.handle(.memoryPressure)
        }
    }
    
    func checkBeforeRecording() -> Bool {
        // Quick memory check before recording
        checkMemoryStatus()
        
        if isUnderMemoryPressure {
            notifyMemoryPressure()
            return false
        }
        
        // Check if current model can run
        let currentModel = UserDefaults.standard.string(forKey: "whisperModel") ?? "base.en"
        if !canRunModel(currentModel) {
            // Suggest a smaller model
            let recommended = recommendedModel()
            DebugLogger.log("MemoryMonitor: Not enough memory for \(currentModel), recommending \(recommended)")
            
            // Could auto-switch to recommended model here if desired
            return false
        }
        
        return true
    }
}