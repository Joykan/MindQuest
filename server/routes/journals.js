import { Router } from "express";
import { createJournal, getJournals } from "../controllers/journalController.js";

const router = Router();

router.post("/", createJournal);
router.get("/:userId", getJournals);

export default router;
