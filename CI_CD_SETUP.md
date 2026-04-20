# GitHub Actions CI/CD Setup Guide

## Overview

This guide helps you configure automatic testing, building, and deployment for MindQuest using GitHub Actions.

## Prerequisites

1. Push your code to GitHub
2. Go to your repository settings
3. Navigate to **Secrets and variables > Actions**

## Required Secrets

### Firebase Service Account (For Web Deployment)

**Get your Firebase credentials:**

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your MindQuest project
3. Go to **Project Settings → Service Accounts**
4. Click **Generate New Private Key**
5. Copy the entire JSON file content

**Add to GitHub:**
- Secret name: `FIREBASE_SERVICE_ACCOUNT`
- Value: Paste the entire JSON content

Example:
```json
{
  "type": "service_account",
  "project_id": "mindquest-app",
  "private_key_id": "...",
  "private_key": "...",
  ...
}
```

### Google Play Console (Optional, for Android Play Store)

If you want to auto-deploy to Google Play:

1. Go to [Google Play Console](https://play.google.com/console)
2. Create a service account with "Admin" role
3. Generate a JSON key

**Add to GitHub:**
- Secret name: `PLAY_STORE_JSON_KEY`
- Value: Paste the entire JSON

## Workflow Triggers

The CI/CD pipeline automatically runs on:

| Event | Trigger |
|-------|---------|
| Push to `main` | Tests + Web build + Web deploy |
| Push to `develop` | Tests + Web build (no deploy) |
| Create a version tag (v*.*.* ) | Tests + Android build + Release creation |
| Pull Request | Tests only |

## Manual Workflow Triggers

To manually trigger the workflow:

1. Go to your GitHub repository
2. Click **Actions** tab
3. Select "MindQuest CI/CD Pipeline"
4. Click **Run workflow**

## Creating Version Releases

To trigger a full release build and deployment:

```bash
# Tag your commit with a version
git tag -a v2.1.0 -m "Release version 2.1.0"

# Push the tag to GitHub
git push origin v2.1.0
```

This will automatically:
- ✅ Run all tests
- ✅ Build Android APK and AAB
- ✅ Build web version
- ✅ Create a GitHub Release with all artifacts
- ✅ Deploy web to Firebase

## Monitoring & Logs

**Check workflow status:**
1. Go to **Actions** tab in your repository
2. Click the workflow run to see detailed logs
3. Each job shows its output

**Common issues:**

| Issue | Solution |
|-------|----------|
| Build fails on test | Check test output in logs, fix code |
| Firebase deploy fails | Verify `FIREBASE_SERVICE_ACCOUNT` secret is set |
| APK artifact missing | Check Java/Gradle setup in logs |

## Next Steps

1. ✅ Commit and push this workflow file
2. ✅ Add the Firebase secret to GitHub
3. ✅ Create a version tag to test
4. ✅ Monitor the Actions tab for build status

## Deployment Targets

### Web (Automatic on `main` push)
- Deployed to: Firebase Hosting
- URL: `https://mindquest-app.web.app`

### Android (Automatic on version tag)
- Downloaded from: GitHub Releases
- Ready to upload to Google Play Console manually

### Future: Auto Play Store Upload
To enable automatic Play Store uploads:
```bash
# Install fastlane (optional)
sudo gem install fastlane
```

Then update the workflow to add:
```yaml
- name: Upload to Play Store
  env:
    PLAY_STORE_JSON_KEY: ${{ secrets.PLAY_STORE_JSON_KEY }}
  run: fastlane supply ...
```

---

Need help? Check the workflow file at `.github/workflows/deploy.yml`
