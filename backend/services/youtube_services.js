// services/youtubeService.js
let conversations = [];
const MAX_CONVERSATIONS = 10;

export function isValidYouTubeUrl(url) {
    const regex = /^https?:\/\/(www\.)?(youtube\.com\/watch\?v=|youtu\.be\/)/;
    return regex.test(url);
}

export function extractVideoId(url) {
    const regex = /(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)/;
    const match = url.match(regex);
    return match ? match[1] : null;
}

export function addConversation(id, data) {
    conversations.push({ id, ...data });
    if (conversations.length > MAX_CONVERSATIONS) {
        conversations.shift();
    }
}

export function findActiveConversation() {
    return conversations.find(conv => conv.step !== 'completed');
}

export function getConversations() {
    return conversations;
}