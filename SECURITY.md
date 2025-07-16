# Security Policy

## Supported Versions

Currently supported versions for security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

WhisperKey takes security seriously. If you discover a security vulnerability, please follow these steps:

### 1. Do NOT Create a Public Issue
Security vulnerabilities should not be reported through public GitHub issues.

### 2. Contact Us Privately
Use GitHub's private security advisory system at:
https://github.com/BSPLAZA/WhisperKey/security/advisories/new

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Your suggested fix (if any)

### 3. What to Expect
- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 5 business days
- **Fix Timeline**: Depends on severity
  - Critical: 1-3 days
  - High: 1 week
  - Medium: 2-3 weeks
  - Low: Next release

### 4. Disclosure Process
1. We'll work with you to understand and fix the issue
2. We'll credit you in the security advisory (unless you prefer anonymity)
3. We'll coordinate disclosure timing with you
4. Once fixed, we'll publish a security advisory

## Security Best Practices for Users

### Privacy by Design
- WhisperKey processes all audio locally
- No network connections during transcription
- No telemetry or analytics
- Audio is immediately discarded after transcription

### Permissions
- Only grant microphone access
- Only grant accessibility access
- Do not modify app permissions beyond what's requested

### Safe Usage
- Don't dictate sensitive information (passwords, credit cards)
- Be aware of your surroundings when dictating
- Review transcribed text before sending
- Use secure input detection warnings

## Security Features

### Built-in Protections
- Secure input field detection
- Memory clearing after transcription
- No persistent audio storage
- Sandboxed execution
- Code signing (coming in v1.1)

### Known Limitations
- Cannot prevent system sounds from being transcribed
- Clipboard fallback may expose text temporarily
- Accessibility API required for text insertion

## Vulnerability Rewards

While we don't have a formal bug bounty program, we deeply appreciate security researchers who help make WhisperKey safer. We'll acknowledge your contribution and may offer:
- Public recognition
- WhisperKey merchandise (when available)
- Priority feature requests

## Updates

This security policy may be updated periodically. Check back for the latest version.

Last updated: July 14, 2025