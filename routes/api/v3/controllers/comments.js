import express from 'express';

var router = express.Router();

router.get("/", async (req, res) => {
    try {
        let postId = req.query.postID;
        let userComments = await req.models.Comment.find({ post: postId });
        res.json(userComments);
    } catch (err) {
        console.log("error: ", err)
        res.status(500).json({status: "error"})
    }
});

router.post("/", async(req, res) => {
    try{
        if (!req.session.isAuthenticated) {
            return res.status(401).json({
                status: "error",
                error: "not logged in"
            });
        }

        let username = req.session.account.username;
        let comment = req.body.newComment;
        let post = req.body.postID;

        let newComment = new req.models.Comment({
            username: username,
            comment: comment,
            post: post,
            created_date: new Date()
        })

        await newComment.save();

        res.json({status: "success"});

    } catch(err) {
        console.log("error: ", err)
        res.status(500).json({status: "error"})
    }
});
export default router;