import { Router } from "express";
import chatRoutes from "./chat.js";

const router = Router();

router.use("/chat", chatRoutes);

export default router;
