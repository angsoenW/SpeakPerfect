import express from 'express';

var router = express.Router();

import getURLPreview from '../utils/urlPreviews.js';

router.get("/preview", async (req, res) => {
    let inputUrl = req.query.url;
    let result = await getURLPreview(inputUrl);
    res.send(result);
});

export default router;