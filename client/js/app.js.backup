import express from "express";
import cors from "cors";
import dotenv from "dotenv";

dotenv.config();

import chatRoutes from "./routes/chatRoutes.js";

const app = express();

// ==== MIDDLEWARE ====
app.use(cors());
app.use(express.json({ limit: "2mb" }));

// ==== ROUTES ====
app.use("/api", chatRoutes);

// Health check
app.get("/health", (req, res) => {
  res.status(200).json({ status: "OK", message: "Server is running" });
});

// ==== START SERVER ====
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`🔥 Server running on port ${PORT}`);
});
