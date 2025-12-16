// test-connection.js
import sequelize from './config/database.js';

async function test() {
  try {
    await sequelize.authenticate();
    console.log('✅ Connected to MariaDB successfully!');
    
    // Test if database exists
    const [result] = await sequelize.query("SELECT DATABASE() as current_db");
    console.log('Current database:', result[0].current_db);
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Connection failed:', error.message);
    process.exit(1);
  }
}

test();