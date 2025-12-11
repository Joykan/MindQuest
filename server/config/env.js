import dotenv from "dotenv";
dotenv.config();

export default {
  PORT: process.env.PORT || 5000,
  MONGO_URI: process.env.MONGO_URI || "mongodb://localhost:27017/mindquest",
  GEMINI_API_KEY: process.env.GEMINI_API_KEY || "",
  JWT_SECRET: process.env.JWT_SECRET || "supersecretkey"
};
