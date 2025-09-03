// controllers/notes_controller.js
import { processNotesWithN8N } from '../services/n8n_notesservice.js';

export const processNotes = async (req, res) => {
  try {
    const { 
      content,           // Either syllabus text or extracted PDF text
      preferences,       // User requirements like "5 pages", "summarize", etc.
      contentType       // "syllabus" or "pdf"
    } = req.body;

    console.log('📝 Processing notes request:', { 
      contentType, 
      contentLength: content?.length,
      preferences 
    });

    // Validate input
    if (!content || !preferences) {
      return res.status(400).json({ 
        error: 'Content and preferences are required' 
      });
    }

    // Process with N8N
    const processedNotes = await processNotesWithN8N(content, preferences, contentType);

    res.json({ 
      success: true,
      notes: processedNotes,
      contentType: contentType
    });

  } catch (error) {
    console.error('❌ Notes processing error:', error);
    res.status(500).json({ 
      error: 'Failed to process notes request',
      details: error.message 
    });
  }
};

export const uploadAndProcessPDF = async (req, res) => {
  try {
    // This will handle the PDF file upload
    if (!req.file) {
      return res.status(400).json({ error: 'No PDF file uploaded' });
    }

    const { preferences } = req.body;
    
    if (!preferences) {
      return res.status(400).json({ error: 'Preferences are required' });
    }

    console.log('📄 PDF uploaded:', req.file.originalname);

    // Extract text from PDF
    const pdfText = req.pdfText; // This will be set by our PDF middleware

    // Process with N8N
    const processedNotes = await processNotesWithN8N(pdfText, preferences, 'pdf');

    res.json({ 
      success: true,
      notes: processedNotes,
      fileName: req.file.originalname,
      contentType: 'pdf'
    });

  } catch (error) {
    console.error('❌ PDF processing error:', error);
    res.status(500).json({ 
      error: 'Failed to process PDF',
      details: error.message 
    });
  }
};