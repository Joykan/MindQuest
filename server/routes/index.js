import { Router } from "express";
import chatRoutes from "./chat.js";
import {
  createJournal,
  getJournals,
  getInsights,
  analyzeMood
} from "../controllers/journalController.js";

const router = Router();

// ==== CHAT ROUTES ====
router.use("/chat", chatRoutes);

// ==== JOURNAL ROUTES ====
router.post("/create_journal", createJournal);
router.get("/get_journals", getJournals); // GET method for fetching
router.post("/get_insights", getInsights);
router.post("/analyze_mood", analyzeMood);

// ==== HEALTH CHECK ====
router.get("/status", (req, res) => {
  res.json({
    status: "active",
    routes: ["/chat", "/create_journal", "/get_journals", "/get_insights", "/analyze_mood"],
    timestamp: new Date().toISOString()
  });
});

export default router;