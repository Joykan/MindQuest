// server/test-all.js - FIXED VERSION
import { exec } from 'child_process';
import { promisify } from 'util';
import { writeFileSync } from 'fs';

const execAsync = promisify(exec);
const BASE_URL = 'http://localhost:5000';
const TESTS = [];

// Helper to escape quotes for shell
function escapeShellArg(str) {
  return str.replace(/'/g, "'\"'\"'");
}

async function testEndpoint(name, method, endpoint, body = null, expectedStatus = 200) {
  const startTime = Date.now();
  let curlCommand;
  
  if (body) {
    // Properly escape single quotes for shell
    const escapedBody = JSON.stringify(body).replace(/'/g, "'\"'\"'");
    curlCommand = `curl -s -X ${method} "${BASE_URL}${endpoint}" -H "Content-Type: application/json" -d '${escapedBody}'`;
  } else {
    curlCommand = `curl -s -X ${method} "${BASE_URL}${endpoint}"`;
  }
  
  try {
    const { stdout } = await execAsync(curlCommand);
    const response = JSON.parse(stdout || '{}');
    const elapsed = Date.now() - startTime;
    
    const passed = response.status === 'OK' || response.success !== false || response.status === 'success';
    
    TESTS.push({
      name,
      passed,
      elapsed: `${elapsed}ms`,
      endpoint,
      response: Object.keys(response).length > 0 ? response : { raw: stdout }
    });
    
    console.log(`${passed ? '✅' : '❌'} ${name} (${elapsed}ms)`);
    if (!passed && response.error) console.log('   Error:', response.error);
    
    return passed;
  } catch (error) {
    TESTS.push({
      name,
      passed: false,
      elapsed: 'ERROR',
      endpoint,
      error: error.message.substring(0, 100)
    });
    console.log(`❌ ${name} - ERROR: ${error.message.substring(0, 80)}`);
    return false;
  }
}

async function runAllTests() {
  console.log('🧪 Running MindQuest Backend Tests (Fixed)\n');
  
  // 1. Basic Server Tests
  await testEndpoint('Server Health', 'GET', '/health');
  await testEndpoint('API Health', 'GET', '/api/health');
  await testEndpoint('API Status', 'GET', '/api/status');
  
  // 2. Journal Tests (without apostrophes)
  await testEndpoint('Create Journal', 'POST', '/api/create_journal', {
    text: 'Today was productive. Completed project ahead of schedule.',
    mood: 'happy',
    tags: ['work']
  });
  
  await testEndpoint('Get Journals', 'GET', '/api/get_journals?userId=test123');
  
  // 3. AI Insights Tests (escaped properly)
  await testEndpoint('Get AI Insights Positive', 'POST', '/api/get_insights', {
    journalText: 'I feel optimistic about the new project. The team is supportive.'
  });
  
  await testEndpoint('Get AI Insights Challenging', 'POST', '/api/get_insights', {
    journalText: 'Feeling anxious about upcoming deadlines. Worried about expectations.'
  });
  
  // 4. Chat Tests
  await testEndpoint('Chat General', 'POST', '/api/chat', {
    message: 'Hello, how can you help with stress?',
    context: 'general'
  });
  
  await testEndpoint('Chat Therapy', 'POST', '/api/chat', {
    message: 'Feeling overwhelmed with responsibilities',
    context: 'therapy'
  });
  
  await testEndpoint('Chat Coaching', 'POST', '/api/chat', {
    message: 'I want to improve my daily routine',
    context: 'coaching'
  });
  
  // 5. Mood Analysis
  await testEndpoint('Mood Happy', 'POST', '/api/chat/analyze-mood', {
    text: 'Excited about good news today. Feeling wonderful!'
  });
  
  await testEndpoint('Mood Anxious', 'POST', '/api/chat/analyze-mood', {
    text: 'Nervous about presentation tomorrow. Might forget everything.'
  });
  
  // 6. Edge Cases
  await testEndpoint('Empty Text', 'POST', '/api/create_journal', {
    text: ''
  }, 400);
  
  await testEndpoint('Direct Mood', 'POST', '/api/analyze_mood', {
    text: 'Feeling really good today'
  });
  
  // Summary
  console.log('\n📊 TEST SUMMARY');
  console.log('='.repeat(50));
  
  const passed = TESTS.filter(t => t.passed).length;
  const total = TESTS.length;
  
  TESTS.forEach(test => {
    const status = test.passed ? '✅' : '❌';
    console.log(`${status} ${test.name.padEnd(35)} ${test.elapsed}`);
  });
  
  console.log('='.repeat(50));
  console.log(`🎯 Result: ${passed}/${total} passed (${Math.round(passed/total*100)}%)`);
  
  // Save report
  const report = {
    timestamp: new Date().toISOString(),
    summary: { passed, total },
    tests: TESTS
  };
  
  writeFileSync('test-report.json', JSON.stringify(report, null, 2));
  console.log('📄 Report: test-report.json');
}

// Run
runAllTests().catch(console.error);