# Contributing to WhisperKey

Thank you for your interest in contributing to WhisperKey! This guide will help you get started.

## Code of Conduct

Be respectful, inclusive, and constructive. We're all here to make dictation better for Mac users.

## How to Contribute

### Reporting Issues
1. Check existing issues first
2. Include macOS version, WhisperKey version
3. Provide clear reproduction steps
4. Attach logs if relevant (no sensitive data!)

### Submitting Pull Requests
1. Fork the repository
2. Create a feature branch (`feature/your-feature-name`)
3. Make your changes
4. Test thoroughly (see Testing Guide)
5. Update documentation
6. Submit PR with clear description

## Development Setup

### Prerequisites
- macOS 13.0+
- Xcode 15+
- whisper.cpp installed
- 8GB RAM recommended

### Getting Started
```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/WhisperKey.git
cd WhisperKey

# Open in Xcode
open WhisperKey/WhisperKey.xcodeproj

# Add HotKey package dependency
# File → Add Package Dependencies
# https://github.com/soffes/HotKey

# Build and run
# Cmd+R
```

## Code Style

### Swift Guidelines
- Use SwiftLint rules (included in project)
- Follow Apple's Swift API Design Guidelines
- Prefer `@MainActor` for UI code
- Use `async/await` for asynchronous code
- Document public APIs

### Commit Messages
Follow our format:
```
Component: Brief description

TESTED ✅: What was tested
- Change detail 1
- Change detail 2

STATUS: Ready for review
```

## Testing

### Before Submitting
- [ ] Test in Debug and Release builds
- [ ] Test on Intel and Apple Silicon if possible
- [ ] Run through TEST_CHECKLIST.md scenarios
- [ ] Verify no memory leaks
- [ ] Check permissions flow

### Key Test Areas
1. Audio recording quality
2. Text insertion accuracy
3. Permission handling
4. Error recovery
5. UI responsiveness

## Documentation

### Update These Files
- API_REFERENCE.md - For new APIs
- DECISIONS.md - For architectural changes
- ISSUES_AND_SOLUTIONS.md - For bugs fixed
- CHANGELOG.md - For all changes

## Review Process

1. All PRs require review
2. Tests must pass
3. Documentation must be updated
4. No decrease in code coverage

## Areas We Need Help

### High Priority
- Testing on different macOS versions
- Accessibility improvements
- Performance optimization
- Multi-language support

### Feature Ideas
- Custom vocabulary support
- Keyboard shortcuts editor
- Advanced audio processing
- Integration with text expanders

## Questions?

- Open an issue for questions
- Check docs/ folder for details
- Review existing code for patterns

Thank you for contributing to WhisperKey! 🎤