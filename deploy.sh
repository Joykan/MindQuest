#!/bin/bash

set -e

echo "🚀 MindQuest Deployment Script"
echo "================================"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_requirements() {
    echo "Checking requirements..."
    
    if ! command -v railway &> /dev/null; then
        echo -e "${RED}❌ Railway CLI not found${NC}"
        echo "Install it with: npm install -g @railway/cli"
        exit 1
    fi
    
    if ! command -v vercel &> /dev/null; then
        echo -e "${RED}❌ Vercel CLI not found${NC}"
        echo "Install it with: npm install -g vercel"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All requirements met${NC}"
    echo ""
}

deploy_backend() {
    echo "Deploying backend to Railway..."
    
    railway whoami &> /dev/null || {
        echo -e "${YELLOW}Please login to Railway:${NC}"
        railway login
    }
    
    railway up || {
        echo -e "${RED}❌ Backend deployment failed${NC}"
        exit 1
    }
    
    BACKEND_URL=$(railway domain)
    echo -e "${GREEN}✅ Backend deployed to: $BACKEND_URL${NC}"
    echo ""
    
    echo "$BACKEND_URL" > .backend_url
}

deploy_frontend() {
    echo "Deploying frontend to Vercel..."
    
    vercel whoami &> /dev/null || {
        echo -e "${YELLOW}Please login to Vercel:${NC}"
        vercel login
    }
    
    if [ -f ".backend_url" ]; then
        BACKEND_URL=$(cat .backend_url)
        vercel env add VITE_API_URL production <<< "$BACKEND_URL" 2>/dev/null || true
    fi
    
    cd frontend
    vercel --prod || {
        echo -e "${RED}❌ Frontend deployment failed${NC}"
        exit 1
    }
    cd ..
    
    echo -e "${GREEN}✅ Frontend deployed${NC}"
    echo ""
}

main() {
    echo "Select deployment option:"
    echo "1. Full deployment (Backend + Frontend)"
    echo "2. Backend only"
    echo "3. Frontend only"
    read -p "Enter choice (1-3): " choice
    echo ""
    
    check_requirements
    
    case $choice in
        1)
            deploy_backend
            deploy_frontend
            echo -e "${GREEN}🎉 Deployment Complete!${NC}"
            ;;
        2)
            deploy_backend
            echo -e "${GREEN}✅ Backend deployment complete${NC}"
            ;;
        3)
            deploy_frontend
            echo -e "${GREEN}✅ Frontend deployment complete${NC}"
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            exit 1
            ;;
    esac
}

main

trap "rm -f .backend_url" EXIT

