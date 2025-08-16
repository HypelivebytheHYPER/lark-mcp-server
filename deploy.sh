#!/bin/bash
set -e

echo "🚀 Lark MCP Server - Render Deployment Helper"
echo "=============================================="

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "❌ This is not a git repository. Run 'git init' first."
    exit 1
fi

# Check if we have the required files
required_files=("package.json" "server.js" "Dockerfile" "render.yaml")
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Missing required file: $file"
        exit 1
    fi
done

echo "✅ All required files found"

# Check if remote origin is set
if ! git remote get-url origin >/dev/null 2>&1; then
    echo "📝 Setting up GitHub repository..."
    echo ""
    echo "MANUAL STEP REQUIRED:"
    echo "1. Go to https://github.com/new"
    echo "2. Create repository: lark-mcp-server (public)"
    echo "3. Copy the repository URL"
    echo ""
    read -p "Enter your GitHub repository URL: " repo_url
    git remote add origin "$repo_url"
    echo "✅ Remote origin set to: $repo_url"
fi

# Push to GitHub
echo "📤 Pushing to GitHub..."
git add .
git commit -m "Deploy: Lark MCP Server ready for Render" 2>/dev/null || echo "No new changes to commit"
git branch -M main
git push -u origin main

echo ""
echo "✅ Code pushed to GitHub successfully!"
echo ""
echo "🌐 NEXT STEPS - RENDER DEPLOYMENT:"
echo "=================================="
echo ""
echo "1. 🔗 Go to: https://render.com/dashboard"
echo "   - Click 'New' → 'Web Service'"
echo "   - Connect GitHub and select your repository: lark-mcp-server"
echo ""
echo "2. 📋 Render will detect render.yaml automatically"
echo "   - Service Name: lark-mcp-server"
echo "   - Environment: Docker"
echo "   - Plan: Pro (required for no sleep)"
echo ""
echo "3. 🔐 Set Environment Variables (IMPORTANT!):"
echo "   - APP_ID: [Your Lark App ID] (mark as secret)"
echo "   - APP_SECRET: [Your Lark App Secret] (mark as secret)"
echo "   - LARK_MCP_TOOLS: preset.bitable.default"
echo "   - LARK_DOMAIN: https://open.larksuite.com (already set)"
echo ""
echo "4. 🚀 Click 'Create Web Service'"
echo ""
echo "5. ✅ After deployment, test health endpoint:"
echo "   curl -s https://your-app-name.onrender.com/health"
echo ""
echo "6. 🔗 Use your Render URL as MCP server in Claude:"
echo "   URL: https://your-app-name.onrender.com"
echo "   Transport: SSE"
echo ""
echo "📖 For detailed setup instructions, see README.md"