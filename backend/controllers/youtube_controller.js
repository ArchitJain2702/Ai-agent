// controllers/youtubeController.js
import { 
    isValidYouTubeUrl, 
    extractVideoId, 
    addConversation, 
    findActiveConversation, 
    getConversations 
} from '../services/youtube_services.js';
import { processWithN8N } from '../services/n8n_services.js';

export const processMessage = async (req, res) => {
    try {
        const { messages } = req.body;
        
        if (isValidYouTubeUrl(messages)) {
            const videoId = extractVideoId(messages);
            if (!videoId) {
                return res.json({
                    response: "I couldn't extract the video ID from this YouTube link. Please check the URL and try again.",
                });
            }
            
            const conversationId = Date.now().toString();
            addConversation(conversationId, {
                videoId,
                url: messages,
                step: 'awaiting_preferences'
            });
            
            return res.json({
                response: "Awesome! I've got your YouTube video ready. Now tell me how you'd like the description to be:\n✨ Length – short & snappy, medium, or detailed?\n✨ Style – casual, professional, fun, or simple?\n✨ Focus – entertainment, educational, or promotional",
                conversationId
            });
        }
        
        const activeConversation = findActiveConversation();
        if (activeConversation && activeConversation.step === 'awaiting_preferences') {
            const description = await processWithN8N(
                activeConversation.videoId, 
                messages
            );

            activeConversation.step = 'completed';
            activeConversation.preferences = messages;
            activeConversation.result = description;

            return res.json({
                response: description,
                canCopy: true
            });
        }
        
        res.json({
            response: "Hi! Please share a YouTube video link to get started. I'll help you generate a description for it!"
        });
    } catch (error) {
        console.error('Error processing message:', error);
        res.status(500).json({
            response: "Sorry, there was an error processing your request. Please try again."
        });
    }
};

export const getChatHistory = (req, res) => {
    const conversations = getConversations();
    const MAX_CONVERSATIONS = 10;
    
    const history = conversations.slice(-MAX_CONVERSATIONS).map(conv => ({
        messages: [
            {
                id: conv.id + '_user',
                text: conv.url,
                isUser: true,
                timestamp: new Date(parseInt(conv.id)).toISOString()
            },
            {
                id: conv.id + '_bot',
                text: conv.result || 'Processing...',
                isUser: false,
                timestamp: new Date(parseInt(conv.id) + 1000).toISOString(),
                canCopy: !!conv.result
            }
        ]
    }));
    
    res.json(history);
};