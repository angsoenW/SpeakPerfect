import express from 'express';

var router = express.Router();

import getURLPreview from '../utils/urlPreviews.js';

router.post('/', async function (req, res, next) {
    try {
        const { url, description, rating } = req.body;
        if (rating < 0 || rating > 10) { 
            return res.status(400).json({ "status": "error", "error": "Rating must be between 1 and 10" });
        }
        const newPost = new req.models.Post({
            url,
            description,
            rating,
            created_date: new Date()
        });

        await newPost.save();

        res.json({ "status": "success" });
    } catch (error) {
        console.log(error);
        res.status(500).json({ "status": "error", "error": error })
    }
});

router.get('/', async function (req, res, next) {
    try {
        let allPosts = await req.models.Post.find();

        let postData = await Promise.all(allPosts.map(async post => {
            try {
                const htmlPreview = await getURLPreview(post.url);
                return {
                    description: post.description,
                    rating: post.rating,
                    htmlPreview: htmlPreview
                };
            } catch (error) {
                return {
                    description: post.description,
                    rating: post.rating,
                    htmlPreview: `Error generating preview: ${error.message}`
                };
            }
        }));

        res.json(postData);

    } catch (error) {
        console.log(error);
        res.status(500).json({ status: 'error', error: error.toString() }); // Send back error status and message
    }
});

export default router;