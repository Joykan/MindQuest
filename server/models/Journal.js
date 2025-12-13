import mongoose from 'mongoose';

const journalSchema = new mongoose.Schema({
  text: {
    type: String,
    required: true
  },
  userId: {
    type: String,
    required: true
  },
  mood: {
    type: String,
    enum: ['happy', 'sad', 'anxious', 'calm', 'excited', 'neutral']
  },
  tags: [String],
  insights: {
    emotionalTone: String,
    keyThemes: [String],
    summary: String
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

export default mongoose.model('Journal', journalSchema);