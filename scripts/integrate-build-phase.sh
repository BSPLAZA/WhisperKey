#!/bin/bash
# Script to properly integrate library copying into Xcode build process
# This modifies the .pbxproj file to add a Run Script build phase

set -e

PROJECT_FILE="WhisperKey.xcodeproj/project.pbxproj"
SCRIPT_PATH='${SRCROOT}/copy-whisper-libraries.sh'

if [ ! -f "$PROJECT_FILE" ]; then
    echo "Error: Must be run from WhisperKey directory containing $PROJECT_FILE"
    exit 1
fi

# Create backup
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"

# Ruby script to modify the pbxproj file
ruby << 'EOF'
require 'xcodeproj'

project_path = 'WhisperKey.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main app target
target = project.targets.find { |t| t.name == 'WhisperKey' }
unless target
  puts "Error: Could not find WhisperKey target"
  exit 1
end

# Check if the build phase already exists
existing_phase = target.build_phases.find { |phase| 
  phase.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase) && 
  phase.name == 'Copy Whisper Libraries'
}

if existing_phase
  puts "Build phase 'Copy Whisper Libraries' already exists"
  exit 0
end

# Create new Run Script build phase
phase = project.new(Xcodeproj::Project::Object::PBXShellScriptBuildPhase)
phase.name = 'Copy Whisper Libraries'
phase.shell_script = '"${SRCROOT}/copy-whisper-libraries.sh"'
phase.show_env_vars_in_log = '0'
phase.always_out_of_date = '1'  # Equivalent to unchecking "Based on dependency analysis"

# Add input files
phase.input_paths = [
  '$(SRCROOT)/copy-whisper-libraries.sh',
  '${HOME}/Developer/whisper.cpp/build/bin/whisper-cli'
]

# Add output files  
phase.output_paths = [
  '$(BUILT_PRODUCTS_DIR)/$(WRAPPER_NAME)/Contents/Resources/whisper-cli',
  '$(BUILT_PRODUCTS_DIR)/$(WRAPPER_NAME)/Contents/Frameworks/'
]

# Find the position after Copy Bundle Resources
copy_resources_phase = target.build_phases.find { |p| 
  p.is_a?(Xcodeproj::Project::Object::PBXResourcesBuildPhase) 
}

if copy_resources_phase
  index = target.build_phases.index(copy_resources_phase) + 1
  target.build_phases.insert(index, phase)
else
  # If we can't find Copy Bundle Resources, add before the last phase
  target.build_phases.insert(-2, phase)
end

# Save the project
project.save

puts "✅ Successfully added 'Copy Whisper Libraries' build phase"
puts "   Position: After 'Copy Bundle Resources'"
puts "   Script: ${SRCROOT}/copy-whisper-libraries.sh"
puts ""
puts "The build phase is now integrated into Xcode!"
EOF

echo ""
echo "Integration complete! The library copying is now part of the Xcode build process."
echo "This means:"
echo "  - Libraries will be copied automatically on every build"
echo "  - Works for all developers without manual steps"
echo "  - Works with xcodebuild, Xcode GUI, and CI/CD"
echo ""
echo "Backup saved as: $PROJECT_FILE.backup"