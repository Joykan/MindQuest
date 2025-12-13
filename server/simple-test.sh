#!/bin/bash
echo "1. Health:"
curl -s http://localhost:5000/api/health | jq '.status'

echo -e "\n2. Create Journal:"
curl -s -X POST http://localhost:5000/api/create_journal \
  -H "Content-Type: application/json" \
  -d '{"text":"Test entry","mood":"neutral"}' | jq '.status'

echo -e "\n3. Get Insights:"
curl -s -X POST http://localhost:5000/api/get_insights \
  -H "Content-Type: application/json" \
  -d '{"journalText":"Simple test without quotes"}' | jq '.status'

echo -e "\n4. Chat:"
curl -s -X POST http://localhost:5000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Hi","context":"general"}' | jq '.success'

echo -e "\n✅ All basic tests completed"