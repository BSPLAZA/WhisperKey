# Contributing to WhisperKey

Thank you for your interest in contributing to WhisperKey! This guide will help you get started.

## Code of Conduct

Be respectful, inclusive, and constructive. We're all here to make dictation better for Mac users.

## How to Contribute

### Reporting Issues
1. Check existing issues first
2. Use our issue templates (Bug Report or Feature Request)
3. Include macOS version, WhisperKey version
4. Provide clear reproduction steps
5. Attach logs if relevant (no sensitive data!)

### Branch Structure
We follow a structured branching strategy:
- `main` - Stable releases only (protected)
- `develop` - Integration branch for new features
- `release/v*` - Release preparation and hotfixes
- `feature/*` - New features
- `fix/*` - Bug fixes
- `docs/*` - Documentation updates

### Submitting Pull Requests
1. Fork the repository
2. Create a branch from `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```
3. Make your changes
4. Test thoroughly (see Testing Guide)
5. Update documentation
6. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```
7. Submit PR to `develop` branch (not `main`)
8. Fill out the PR template completely
9. Wait for CI checks to pass

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

1. All PRs require at least one review
2. CI checks must pass:
   - Swift build succeeds
   - Tests pass (when available)
   - SwiftLint warnings addressed
3. Documentation must be updated
4. Branch must be up to date with target branch
5. For releases to `main`:
   - Must come from `develop` or `release/*`
   - Requires admin approval
   - Version tags will be created

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

## GitHub Workflow Tips

### Using Labels
- Add appropriate labels to your issues/PRs
- `good first issue` - Great for newcomers
- `help wanted` - Need community help
- `performance` - Performance improvements
- `audio` - Audio-related changes
- `UI/UX` - Interface improvements

### Milestones
- Check current milestones for version planning
- `v1.0.1` - Bug fixes and minor improvements
- `v1.1.0` - New features and major improvements

### Security Issues
- DO NOT report security issues publicly
- See SECURITY.md for reporting process

## Questions?

- Open an issue for questions
- Use GitHub Discussions for general topics
- Check docs/ folder for details
- Review existing code for patterns

Thank you for contributing to WhisperKey! 🎤