#!/usr/bin/env ruby
# Script to add a Run Script build phase to copy whisper libraries

require 'xcodeproj'

# Path to the project
project_path = File.expand_path('../WhisperKey/WhisperKey.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)

# Find the main app target
target = project.targets.find { |t| t.name == 'WhisperKey' && t.product_type == 'com.apple.product-type.application' }

unless target
  puts "Error: Could not find WhisperKey app target"
  exit 1
end

# Check if build phase already exists
existing_phase = target.build_phases.find { |phase| 
  phase.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase) && 
  phase.name == 'Copy Whisper Libraries'
}

if existing_phase
  puts "Build phase 'Copy Whisper Libraries' already exists, updating it..."
  target.build_phases.delete(existing_phase)
end

# Create new Run Script build phase
script_phase = target.new_shell_script_build_phase('Copy Whisper Libraries')

# Set the script
script_phase.shell_script = '"${SRCROOT}/copy-whisper-libraries.sh"'
script_phase.show_env_vars_in_log = '0'
script_phase.run_only_for_deployment_postprocessing = '0'

# Add input/output files for better build performance
script_phase.input_paths = [
  '$(SRCROOT)/copy-whisper-libraries.sh',
  '${HOME}/Developer/whisper.cpp/build/bin/whisper-cli'
]

script_phase.output_paths = [
  '$(BUILT_PRODUCTS_DIR)/$(WRAPPER_NAME)/Contents/Resources/whisper-cli',
  '$(BUILT_PRODUCTS_DIR)/$(WRAPPER_NAME)/Contents/Frameworks/'
]

# Move the script phase after "Copy Bundle Resources" but before code signing
resources_phase = target.build_phases.find { |phase| phase.is_a?(Xcodeproj::Project::Object::PBXResourcesBuildPhase) }
if resources_phase
  target.build_phases.move(script_phase, target.build_phases.index(resources_phase) + 1)
end

# Save the project
project.save

puts "✅ Successfully added 'Copy Whisper Libraries' build phase to WhisperKey target"
puts "📝 The build phase will run: ${SRCROOT}/copy-whisper-libraries.sh"
puts "🔧 Make sure whisper.cpp is built at ~/Developer/whisper.cpp before building the app"