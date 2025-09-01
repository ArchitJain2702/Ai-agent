// services/n8nService.js
import fetch from 'node-fetch';

export async function processWithN8N(videoId, preferences) {
    try {
        const response = await fetch(`http://localhost:5678/webhook/youtube-description`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ videoId, preferences })
        });
        
        const result = await response.json();
        
        console.log("N8N raw response:", result);
        
        if (result.description) {
            return result.description;
        }
        
        return 'Generated description will appear here.';
    } catch (error) {
        console.error('N8N processing error:', error);
        return 'Sorry, I encountered an error generating the description. Please try again.';
    }
}