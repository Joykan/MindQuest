import { Router } from "express";
import { getChatResponse } from "../controllers/chatController.js";

const router = Router();

router.post("/", getChatResponse);

export default router;
