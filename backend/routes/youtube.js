// routes/youtube.js
import express from 'express';
import { 
    processMessage, 
    getChatHistory 
} from '../controllers/youtube_controller.js';

const router = express.Router();

// Process chat messages for YouTube description generation
router.post('/process_messages', processMessage);

// Get chat history
router.get('/chat_history', getChatHistory);

export default router;