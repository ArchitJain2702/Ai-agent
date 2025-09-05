const axios = require('axios');

class RecomendationN8NServices{
    constructor(){
        this.workbookUrl = 'http://localhost:5678/webhook/video-recommendations';
    }
    async getVideoRecomendation(discription) {
       try {
        console.log('Sending to n8n:', discription);
        const responce = await axios.post(this.workbookUrl,{
           discription:discription
        },{
            timeout : 30000
        });
        console.log('Received from n8n:',responce.data);
        return responce.data;
       } catch (error) {
        console.error('N8N Service Error:', error.message);
        throw new Error('Failed to get recommendations from n8n');
       }
    }
}
module.exports = new RecomendationN8NServices();