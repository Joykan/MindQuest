#!/bin/bash
echo "🔐 COMPREHENSIVE SECURITY AUDIT"
echo "================================"

echo "1. CURRENT GIT STATUS:"
git status

echo -e "\n2. TRACKED FILES (should NOT show .env):"
git ls-files | grep -E "\.env" || echo "✅ No .env files tracked"

echo -e "\n3. ALL FILES IN REPO (including untracked):"
find . -name "*.env*" -type f 2>/dev/null | grep -v node_modules | grep -v ".git"

echo -e "\n4. GITIGNORE CHECK:"
if [ -f .gitignore ]; then
    grep -E "^\.env$|^\*\.env\*" .gitignore && echo "✅ .gitignore properly configured" || echo "⚠️  .env not in .gitignore"
else
    echo "❌ No .gitignore file!"
fi

echo -e "\n5. FILE PERMISSIONS:"
if [ -f .env ]; then
    perms=$(stat -c %a .env)
    if [ "$perms" = "600" ]; then
        echo "✅ .env permissions: $perms (secure)"
    else
        echo "⚠️  .env permissions: $perms (should be 600)"
    fi
else
    echo "ℹ️  No .env file found (this is OK for fresh clone)"
fi

echo -e "\n6. GIT HISTORY SCAN (last 10 commits):"
git log --oneline -10 | grep -i env || echo "✅ No env-related commits in recent history"

echo -e "\n7. ENVIRONMENT TEMPLATE:"
if [ -f .env.example ]; then
    echo "✅ .env.example exists"
    # Check if it contains real keys
    if grep -q "your_actual\|your_gemini\|REPLACE_ME" .env.example; then
        echo "✅ .env.example uses placeholders"
    else
        echo "⚠️  Check .env.example for real secrets!"
    fi
else
    echo "❌ Missing .env.example"
fi

echo -e "\n8. HARDCODED SECRETS SCAN:"
echo "   Scanning for API keys in code..."
found=$(grep -r "AIzaSy\|sk-\|ghp_" . --include="*.js" --include="*.json" --include="*.ts" --include="*.py" 2>/dev/null | grep -v ".env.example" | grep -v node_modules | head -5)
if [ -n "$found" ]; then
    echo "❌ POTENTIAL HARDCODED SECRETS FOUND:"
    echo "$found"
else
    echo "✅ No hardcoded secrets detected"
fi

echo -e "\n================================"
echo "SUMMARY:"
echo "If .env is NOT in 'git ls-files' output, it's NOT tracked."
echo "If 'git status' shows .env as 'untracked', it's safe."
