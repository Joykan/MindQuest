import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';
import { User } from './User.js';
import { Question } from './Question.js';

const Score = sequelize.define('Score', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: User,
      key: 'id'
    }
  },
  questionId: {
    type: DataTypes.INTEGER,
    references: {
      model: Question,
      key: 'id'
    }
  },
  score: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  totalQuestions: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  category: {
    type: DataTypes.STRING
  },
  difficulty: {
    type: DataTypes.ENUM('easy', 'medium', 'hard')
  },
  timeSpent: {
    type: DataTypes.INTEGER // in seconds
  },
  createdAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: 'scores',
  timestamps: false
});

// Define associations
User.hasMany(Score, { foreignKey: 'userId' });
Score.belongsTo(User, { foreignKey: 'userId' });

Question.hasMany(Score, { foreignKey: 'questionId' });
Score.belongsTo(Question, { foreignKey: 'questionId' });

export { Score };