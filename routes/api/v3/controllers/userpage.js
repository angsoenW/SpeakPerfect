import express from 'express';

var router = express.Router();

router.get("/", async function (req, res, next) {
    try {
        let userInfo;

        if (req.query.user) {
            userInfo = await req.models.User.find({ username: req.query.user });
            let userData = userInfo.map(user => ({
                username: user.username,
                city: user.city,
                job: user.job,
                bio: user.bio,
                following: user.following,
                follower: user.follower
            }));
    
            res.json(userData);
        } else {
            res.status(401).json({
                status: "No User Found"
            })
        }

        

    } catch (error) {
        console.log(error);
        res.status(500).json({ status: 'error', error: error.toString() }); // Send back error status and message
    }

});


router.post('/', async function (req, res, next) {
    try {
        if (req.session.isAuthenticated) {
            const identity = req.session.account.username;
            const username = req.query.user;

            if (identity !== username) {
                return res.status(500).json({ "status": "error", "message": "No access." });
            }

            if (req.body.user) {
                let user = await req.models.User.find({username: username})
                if (JSON.stringify(user) === "[]") {
                    const newUser = new req.models.User({
                        username: req.body.user
                    })
                    await newUser.save();
                }

                res.json({ "status": "success" });
            }
            else if (req.body.city || req.body.job || req.body.bio) {
                // Update user information
                await req.models.User.updateOne({ username: username }, {
                    $set: {
                        city: req.body.city,
                        job: req.body.job,
                        bio: req.body.bio
                    }
                });
                return res.json({ "status": "success", "message": "User info updated successfully." });
            
            } else if (req.body.followed) {
                let followedId = req.body.followed;
                let findUser = await req.models.User.find({"username": followedId})
                if (JSON.stringify(findUser) !== "[]") {
                    await req.models.User.updateOne({ username: req.query.user }, {
                        $addToSet: { following: followedId }
                    });
        
                    await req.models.User.updateOne({"username": followedId}, {
                        $addToSet: { follower: req.query.user }
                    });
                    return res.json({ "status": "success", "message": "Friend added successfully." });
                } else {
                    return res.json({ "status": "success", "message": "No User Found." });
                }
    
                
            } else {
                return res.status(400).json({ "status": "error", "message": "Invalid input." });
            }
        }
    } catch (error) {
        console.log(error);
        res.status(500).json({ "status": "error", "error": error })
    }
});


export default router;