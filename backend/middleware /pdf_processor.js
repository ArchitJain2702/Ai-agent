// middleware/pdf_processor.js
import multer from 'multer';
// Fix: Use createRequire for CommonJS modules in ES6 environment
import { createRequire } from 'module';
const require = createRequire(import.meta.url);
const pdfParse = require('pdf-parse');

// Configure multer for file uploads
// Using memory storage to keep it simple and free
const storage = multer.memoryStorage();

const fileFilter = (req, file, cb) => {
  // Only allow PDF files
  if (file.mimetype === 'application/pdf') {
    cb(null, true);
  } else {
    cb(new Error('Only PDF files are allowed'), false);
  }
};

// Create multer upload middleware
export const uploadPDF = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit to keep it reasonable
  }
}).single('pdf'); // 'pdf' is the field name for the file

// Middleware to extract text from uploaded PDF
export const extractPDFText = async (req, res, next) => {
  try {
    if (!req.file) {
      return next(); // No file uploaded, continue
    }

    console.log('📄 Extracting text from PDF:', req.file.originalname);
    
    // Parse PDF buffer
    const pdfData = await pdfParse(req.file.buffer);
    
    // Extract text content
    const extractedText = pdfData.text;
    
    console.log(`✅ PDF text extracted: ${extractedText.length} characters`);
    
    // Add extracted text to request object
    req.pdfText = extractedText;
    
    // Add some metadata
    req.pdfInfo = {
      pages: pdfData.numpages,
      fileName: req.file.originalname,
      fileSize: req.file.size
    };
    
    next();
    
  } catch (error) {
    console.error('❌ PDF extraction error:', error);
    res.status(500).json({ 
      error: 'Failed to extract text from PDF',
      details: error.message 
    });
  }
};