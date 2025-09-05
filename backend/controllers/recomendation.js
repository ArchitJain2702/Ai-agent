const RecomendationServices = require ('../services/n8n_recomendation');
class RecomendationController{
    async getRecomendation(req,res){
     try {
        const {discription} = req.body;
        if (!description) {
        return res.status(400).json({
          success: false,
          message: 'Description is required'
        });
      }
      const recomendation = await RecomendationServices.getVideoRecomendation(discription);
      return res.status(200).json({
        success: true,
        data: recomendation
      });
     } catch (error) {
         console.error('Error getting recommendations:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to get recommendations',
        error: error.message
      });
     }
    }
}
module.exports = new RecomendationController();