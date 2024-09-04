import express from 'express';

var router = express.Router();

import getURLPreview from '../utils/urlPreviews.js';

router.get('/', async function (req, res, next) {
    try {
        let allPosts;

        if (req.query.username) {
            allPosts = await req.models.Post.find({ username: req.query.username });
        } else {
            allPosts = await req.models.Post.find();
        }

        let postData = await Promise.all(allPosts.map(async post => {
            try {
                // const htmlPreview = await getURLPreview(post.url, post.rating);
                const htmlPreview = await getURLPreview(post.url);

                return {
                    id: post._id,
                    description: "Description: " + post.description,
                    htmlPreview: htmlPreview,
                    likes: post.likes,
                    username: post.username, 
                    created_date: post.created_date
                };
            } catch (error) {
                return {
                    description: post.description,
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

router.post('/', async function (req, res, next) {
    try {
        if (req.session.isAuthenticated) {

            const { url, description } = req.body;
            const username = req.session.account.username;


            const newPost = new req.models.Post({
                url,
                description,
                username,
                //rating,
                created_date: new Date()
            });

            await newPost.save();

            res.json({ "status": "success" });
        } else {
            req.status(401).json({
                status: "error",
                error: "not logged in"
            })
        }

    } catch (error) {
        console.log(error);
        res.status(500).json({ "status": "error", "error": error })
    }
});

router.post("/like", async(req, res) => {
    try{
        if (!req.session.isAuthenticated) {
            return res.status(401).json({
                status: "error",
                error: "not logged in"
            });
        }
        let postId = req.body.postID;
        let post = await req.models.Post.findById(postId);

        if (!post.likes.includes(req.session.account.username)) {
            post.likes.push(req.session.account.username);
            await post.save();
        }

        res.json({status: "success"});
        
    } catch(err) {
        console.log("error: ", err)
        res.status(500).json({status: "error"})
    }
});

router.post("/unlike", async(req, res) => {
    try{
        if (!req.session.isAuthenticated) {
            return res.status(401).json({
                status: "error",
                error: "not logged in"
            });
        }
        let postId = req.body.postID;
        let post = await req.models.Post.findById(postId);

        let index = post.likes.indexOf(req.session.account.username);
        if (index > -1) {
            post.likes.splice(index, 1);
            await post.save();
        }

        res.json({status: "success"});
        
    } catch(err) {
        console.log("error: ", err)
        res.status(500).json({status: "error"})
    }
});

router.delete("/", async(req, res) => {
    try{
        if (!req.session.isAuthenticated) {
            return res.status(401).json({
                status: "error",
                error: "not logged in"
            });
        }

        let postId = req.body.postID;
        let post = await req.models.Post.findById(postId);

        console.log(post);

        if (post.username !== req.session.account.username) {
            return res.status(401).json({
                status: 'error',
                error: "you can only delete your own posts"
            });
        }

        await req.models.Comment.deleteMany({post: postId});
        await req.models.Post.deleteOne({_id: postId});

        res.json({status: "success"});
        
    } catch(err) {
        console.log("error: ", err)
        res.status(500).json({status: "error"})
    }
});

export default router;