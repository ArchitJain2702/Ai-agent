// routes/notes.js
import express from 'express';
import { processNotes, uploadAndProcessPDF } from '../controllers/notes_controller.js';
import { uploadPDF, extractPDFText } from '../middleware /pdf_processor.js';

const router = express.Router();

// Process text-based notes (syllabus input)
// POST /api/notes/process
router.post('/process', processNotes);

// Upload PDF and process notes
// POST /api/notes/upload
router.post('/upload', 
  uploadPDF,           // Handle file upload
  extractPDFText,      // Extract text from PDF
  uploadAndProcessPDF  // Process the extracted text
);

// Health check for notes service
router.get('/health', (req, res) => {
  res.json({ 
    status: 'Notes service is running',
    features: ['Text processing', 'PDF upload', 'Custom formatting'],
    timestamp: new Date().toISOString()
  });
});

export default router;