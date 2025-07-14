# WhisperKey Repository Cleanup - Detailed Execution Plan

> Step-by-step guide to carefully streamline the repository
> Date: 2025-07-14

## 🎯 Goals
1. Preserve all unique content
2. Remove only true redundancy after verification
3. Archive inactive/planning documents
4. Clean build artifacts
5. Maintain rich documentation history

## 📋 Pre-Cleanup Checklist

### 1. Document Current State (Skip backup - git history is sufficient)
```bash
# Count current files
find . -type f -name "*.md" | wc -l  # Document count
find . -type f -name "*.swift" | wc -l
find . -type f -name "*.sh" | wc -l

# Save directory tree
tree -I 'build|build-output|.git' > REPO_STRUCTURE_BEFORE.txt
```

## 🔍 Step 1: Analyze Potential Duplicates

### 1.1 Compare Release Notes Files
```bash
# Check file sizes first
ls -la *RELEASE* docs/*RELEASE*

# Compare content
diff -u CHANGELOG.md RELEASE_NOTES_v1.0.0.md > diff_changelog_vs_releasenotes.txt
diff -u CHANGELOG.md docs/RELEASE_NOTES.md > diff_changelog_vs_docs_releasenotes.txt
diff -u docs/RELEASE_NOTES.md docs/RELEASE_NOTES_v1.0.0-beta.md > diff_release_versions.txt

# Check unique content in each
comm -23 <(sort RELEASE_NOTES_v1.0.0.md) <(sort CHANGELOG.md) > unique_in_release_notes.txt
```

**Decision Point**: 
- [ ] If files have significant unique content → Keep both
- [ ] If one is subset of other → Merge unique parts and archive original
- [ ] Document decision in commit message

### 1.2 Compare README Files
```bash
# Visual diff
diff -u README.md README_NEW.md > diff_readmes.txt

# Check for unique sections
grep "^##" README.md > sections_current.txt
grep "^##" README_NEW.md > sections_new.txt
diff sections_current.txt sections_new.txt

# Check for images/assets referenced
grep -E "\!\[.*\]|img src" README_NEW.md
```

**Decision Point**:
- [ ] Does README_NEW have valuable layout/images?
- [ ] Should we merge the best of both?
- [ ] Archive or integrate?

### 1.3 Compare Change Summaries
```bash
# Check if v2 is truly just an updated version
diff -u docs/CHANGES_SUMMARY_2025-07-10.md docs/CHANGES_SUMMARY_2025-07-10_v2.md

# Check file sizes
ls -la docs/CHANGES_SUMMARY_2025-07-10*.md
```

### 1.4 Find Other Potential Duplicates
```bash
# Find files with similar names
find . -name "*.md" | sort | awk -F'/' '{print $NF}' | sort | uniq -d

# Find test checklists
find . -name "*TEST_CHECKLIST*" -type f
```

## 🗂️ Step 2: Create Archive Structure

### 2.1 Create Directories
```bash
# Create archive structure
mkdir -p docs-archive/planning
mkdir -p docs-archive/development-journey
mkdir -p docs-archive/technical-explorations
mkdir -p scripts/archive
mkdir -p scripts/archive/test-scripts
mkdir -p scripts/archive/dev-tools
```

### 2.2 Create Archive README
```bash
cat > docs-archive/README.md << 'EOF'
# WhisperKey Documentation Archive

This directory contains historical documentation from the WhisperKey development process.

## Structure

- `planning/` - Original planning documents and strategies
- `development-journey/` - Day-by-day development logs and decisions
- `technical-explorations/` - Deep dives into technical challenges

## Why Archive?

These documents show the complete journey of building WhisperKey with AI assistance.
They're preserved here for transparency and as a case study for AI-assisted development.

## Key Documents

- `development-journey/TIMELINE.md` - Shows actual vs planned development velocity
- `development-journey/DAILY_LOG.md` - Day-by-day progress with AI
- `development-journey/DECISIONS.md` - All architectural decisions made
- `development-journey/ISSUES_AND_SOLUTIONS.md` - Problems faced and overcome
EOF
```

## 📦 Step 3: Archive Planning Documents

### 3.1 Move Planning Docs
```bash
# Move with git to preserve history
git mv docs/BETA_TESTING_PLAN.md docs-archive/planning/
git mv docs/BETA_TEST_RESULTS.md docs-archive/planning/
git mv docs/RELEASE_ACTION_PLAN.md docs-archive/planning/
git mv docs/RELEASE_STRATEGY.md docs-archive/planning/
git mv docs/SIMPLE_PLAN.md docs-archive/planning/
git mv docs/UI_LAYOUT_PLAN.md docs-archive/planning/
git mv RELEASE_ASSESSMENT.md docs-archive/planning/
git mv RELEASE_CHECKLIST.md docs-archive/planning/

# Verify moves
ls -la docs-archive/planning/
```

### 3.2 Move Development Journey Docs
```bash
# These tell the AI collaboration story
git mv docs/EXPERIMENT_LOG.md docs-archive/development-journey/
git mv docs/COMMIT_STRATEGY.md docs-archive/development-journey/

# Consider moving these (but they might be actively useful)
# git mv docs/DAILY_LOG.md docs-archive/development-journey/
# git mv docs/TIMELINE.md docs-archive/development-journey/
# git mv docs/DECISIONS.md docs-archive/development-journey/
# git mv docs/ISSUES_AND_SOLUTIONS.md docs-archive/development-journey/
```

### 3.3 Move Technical Explorations
```bash
git mv docs/MODEL_PATH_CONSIDERATIONS.md docs-archive/technical-explorations/
git mv docs/LANGUAGE_SUPPORT_PLAN.md docs-archive/technical-explorations/
git mv docs/ERROR_RECOVERY_IMPROVEMENTS.md docs-archive/technical-explorations/
git mv docs/UI_DIALOGS_EXPLANATION.md docs-archive/technical-explorations/
git mv docs/CURSOR_INTEGRATION.md docs-archive/technical-explorations/
git mv docs/RIGHT_OPTION_SETUP.md docs-archive/technical-explorations/
```

## 🔧 Step 4: Archive Test Scripts

### 4.1 Move Test Scripts
```bash
# Move all test scripts
git mv scripts/test-*.swift scripts/archive/test-scripts/
git mv scripts/test-*.sh scripts/archive/test-scripts/

# Move development tools
git mv scripts/log-issue.sh scripts/archive/dev-tools/
git mv scripts/new-decision.sh scripts/archive/dev-tools/
git mv scripts/update-timeline.sh scripts/archive/dev-tools/
git mv scripts/transition-to-menubar.sh scripts/archive/dev-tools/
git mv scripts/setup-right-option.sh scripts/archive/dev-tools/

# Verify
ls -la scripts/
ls -la scripts/archive/
```

### 4.2 Create Scripts Archive README
```bash
cat > scripts/archive/README.md << 'EOF'
# Archived Scripts

## test-scripts/
Development test scripts used during WhisperKey development.
Preserved for reference and debugging.

## dev-tools/
Internal development tools for documentation management.
These automated our documentation-first development approach.
EOF
```

## 🧹 Step 5: Clean Build Artifacts

### 5.1 Update .gitignore First
```bash
cat >> .gitignore << 'EOF'

# Build artifacts
*.dmg
build/
.build/
WhisperKey/build-output/
DerivedData/

# OS files
.DS_Store
.AppleDouble
.LSOverride

# Temporary files
*.tmp
*~
*.swp

# Test artifacts
test_keycodes
tests/
EOF
```

### 5.2 Remove Build Artifacts
```bash
# Remove build outputs (not tracked in git)
rm -rf WhisperKey/build-output/
rm -rf build/
rm -rf .build/  # Swift build directory
rm -f WhisperKey-1.0.0.dmg
rm -f dmg-background.png

# Remove all .DS_Store files
find . -name ".DS_Store" -type f -delete

# Remove any temporary files
find . -name "*~" -type f -delete
find . -name "*.swp" -type f -delete
find . -name "*.tmp" -type f -delete

# Verify DMG is available on GitHub releases
echo "DMG is available at: https://github.com/BSPLAZA/WhisperKey/releases/download/v1.0.0/WhisperKey-1.0.0.dmg"
```

## 🔄 Step 6: Handle Remaining Duplicates/Consolidations

### 6.1 Test Checklist Duplicate
```bash
# Verify it's a true duplicate
diff docs/TEST_CHECKLIST.md docs/troubleshooting/TEST_CHECKLIST.md

# If identical, remove the nested one
git rm docs/troubleshooting/TEST_CHECKLIST.md
```

### 6.2 Handle TEST_ERROR_UI.md
```bash
# Check content first
cat TEST_ERROR_UI.md

# If it's truly temporary/test file
git rm TEST_ERROR_UI.md
```

### 6.3 Clean Up Root Directory Test Files
```bash
# These test files belong in scripts/archive or should be removed
git mv test_accessibility.swift scripts/archive/test-scripts/
git mv test_audio_recording.swift scripts/archive/test-scripts/
git rm test_keycodes  # Binary file
git rm -r tests/  # Empty test directory
```

### 6.4 Remove Repository Cleanup Planning Files
```bash
# These temporary planning files shouldn't remain in the final repo
git rm REPOSITORY_CLEANUP_CHECKLIST.md
git rm REPOSITORY_CLEANUP_PLAN_v2.md
git rm REPOSITORY_CLEANUP_STREAMLINED.md
git rm REPOSITORY_CLEANUP_DETAILED_PLAN.md

# Keep one summary of what was done
echo "See git history and commit messages for cleanup details" > CLEANUP_NOTES.md
```

### 6.5 Consolidate Similar Documentation
```bash
# Check if troubleshooting subdirectory has unique content
ls -la docs/troubleshooting/

# Consider moving to main troubleshooting doc
# Or create a troubleshooting archive
```

## 📝 Step 7: Update References

### 7.1 Fix Links in Active Documentation
```bash
# Find all markdown links to moved files
grep -r "BETA_TESTING_PLAN\|RELEASE_STRATEGY\|planning/" docs/*.md

# Update docs/README.md to mention archives
# Add section about historical documentation
```

### 7.2 Update Main README
```bash
# Add note about documentation archives
# Mention the development journey is preserved
```

### 7.3 Verify No Broken Links
```bash
# Simple check for broken internal links
for file in docs/*.md; do
    echo "Checking $file..."
    grep -o '\[.*\]([^)]*\.md)' "$file" | while read link; do
        path=$(echo "$link" | sed 's/.*(\(.*\))/\1/')
        if [[ ! -f "$path" && ! -f "docs/$path" ]]; then
            echo "  Broken link: $path"
        fi
    done
done
```

## ✅ Step 8: Final Verification

### 8.1 Check Repository Size
```bash
# Before and after size
du -sh .
du -sh .git

# Check large files
find . -type f -size +1M -not -path "./.git/*" | head -20
```

### 8.2 Verify Critical Files Present
```bash
# Ensure nothing important was removed
test -f README.md && echo "✓ README.md"
test -f LICENSE && echo "✓ LICENSE"
test -f CONTRIBUTING.md && echo "✓ CONTRIBUTING.md"
test -f docs/USER_GUIDE.md && echo "✓ USER_GUIDE.md"
test -f docs/WHISPER_SETUP.md && echo "✓ WHISPER_SETUP.md"
test -f scripts/create-dmg.sh && echo "✓ create-dmg.sh"
```

### 8.3 Create Summary
```bash
# Count final files
echo "Final counts:"
find . -type f -name "*.md" | wc -l
find . -type f -name "*.swift" | wc -l
find . -type f -name "*.sh" | wc -l

# Save final structure
tree -I 'build|build-output|.git' > REPO_STRUCTURE_AFTER.txt
```

## 💾 Step 9: Commit Changes

### 9.1 Stage Changes in Logical Groups
```bash
# First commit: Create archive structure
git add docs-archive/
git add scripts/archive/
git commit -m "Structure: Create archive directories for historical documentation"

# Second commit: Archive planning documents
git add -A docs-archive/planning/
git commit -m "Archive: Move planning documents to preserve development history"

# Third commit: Archive development tools
git add -A scripts/archive/
git commit -m "Archive: Move test scripts and dev tools out of active directory"

# Fourth commit: Update .gitignore
git add .gitignore
git commit -m "Ignore: Add build artifacts and OS files to .gitignore"

# Fifth commit: Remove any true duplicates (after verification)
# git add -A
# git commit -m "Cleanup: Remove verified duplicate files and build artifacts"

# Final commit: Update documentation
git add -u docs/
git commit -m "Docs: Update references after reorganization"
```

## 🔍 Step 10: Post-Cleanup Audit

### 10.1 Verify Everything Works
```bash
# Try building the project
swift build

# Check documentation renders
# Open key docs and verify links work
```

### 10.2 Create Cleanup Summary
```bash
cat > CLEANUP_SUMMARY.md << 'EOF'
# Repository Cleanup Summary

Date: 2025-07-14

## What Changed
- Moved X planning documents to `docs-archive/planning/`
- Moved Y test scripts to `scripts/archive/`
- Removed Z build artifacts
- Updated .gitignore for better hygiene

## What's Preserved
- All development history in `docs-archive/`
- All unique documentation content
- Complete journey of AI-assisted development

## Result
- Cleaner active documentation
- Easier navigation for new users
- Rich history preserved for case studies
EOF
```

## ⚠️ Important Reminders

1. **Always verify before deleting** - When in doubt, archive
2. **Check file contents, not just names** - Similar names != duplicate content
3. **Preserve the journey** - The development history is valuable
4. **Test after each major step** - Ensure nothing breaks
5. **Commit in logical chunks** - Makes it easy to revert if needed

## 🎯 Success Criteria

- [ ] No unique content lost
- [ ] Repository easier to navigate
- [ ] Development history preserved
- [ ] All links still work
- [ ] Build still succeeds
- [ ] Documentation tells complete story

## 📋 Final Checklist of Files to Remove/Archive

### Delete Completely:
- [ ] All .DS_Store files
- [ ] WhisperKey-1.0.0.dmg (already on GitHub releases)
- [ ] build/, .build/, WhisperKey/build-output/ directories
- [ ] test_keycodes binary
- [ ] tests/ empty directory
- [ ] REPOSITORY_CLEANUP_*.md files (4 cleanup planning files)
- [ ] TEST_ERROR_UI.md (after verifying it's temporary)
- [ ] All *~ and *.swp temporary files

### Archive to scripts/archive/:
- [ ] All test-*.swift and test-*.sh files
- [ ] test_accessibility.swift, test_audio_recording.swift
- [ ] Development tool scripts (log-issue.sh, etc.)

### Archive to docs-archive/:
- [ ] Planning documents (BETA_*, RELEASE_*, etc.)
- [ ] Technical explorations
- [ ] Development journey docs (keep originals if actively useful)