// services/n8n_notes_service.js
import fetch from 'node-fetch';

export async function processNotesWithN8N(content, preferences, contentType) {
    try {
        console.log(`🔍 Sending to N8N notes processor...`);
        console.log(`📊 Content type: ${contentType}, Length: ${content.length} chars`);
        console.log(`⚙️ User preferences: ${preferences}`);

        const response = await fetch(`http://localhost:5678/webhook/notes-processor`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                content: content,
                preferences: preferences,
                contentType: contentType,
                timestamp: new Date().toISOString()
            }),
            timeout: 30000 // 30 second timeout for longer processing
        });

        console.log(`📈 N8N Response status: ${response.status}`);

        if (!response.ok) {
            throw new Error(`N8N returned status ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();
        console.log("📥 Raw N8N result:", JSON.stringify(result, null, 2));

        // Extract the inner object
        const inner = Object.values(result)[0];

        if (inner && inner.notes) {
            console.log("✅ Notes found:", inner.notes.slice(0, 200) + "...");
            return inner.notes;
        } else {
            console.log("⚠️ No notes field found in response");
        }

        // Fallback response
        return 'Notes will be generated here. Please ensure N8N workflow is properly configured.';

    } catch (error) {
        console.error('❌ N8N notes processing error:', error.message);

        // Provide helpful error messages
        if (error.code === 'ECONNREFUSED') {
            return 'N8N service is not available. Please make sure N8N is running on port 5678.';
        }

        if (error.message.includes('timeout')) {
            return 'Notes processing is taking longer than expected. Please try with shorter content.';
        }

        return `Sorry, I encountered an error processing your notes: ${error.message}. Please try again.`;
    }
}