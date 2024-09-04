import mongoose from 'mongoose';

let models = {};

main().catch(err => console.log(err))
async function main(){
    console.log('connecting to mongodb')
    await mongoose.connect('mongodb+srv://angsoen:BzwCjknLvhK2MPVr@cluster0.pzn6zqp.mongodb.net/?retryWrites=true')

    console.log('succesffully connected to mongodb!')

    const postSchema = new mongoose.Schema({
        url: String,
        description: String,
        username: String,
        likes: [String],
        rating: Number,
        created_date: String
    });

    models.Post = mongoose.model('webs', postSchema);

    const commentSchema = new mongoose.Schema({
        username: String,
        comment: String,
        post: {type: mongoose.Schema.Types.ObjectId, ref: "webs"},
        created_date: String
    });

    models.Comment = mongoose.model("Comment", commentSchema);

    const userSchema = new mongoose.Schema({
        username: String,
        city: String,
        job: String,
        bio: String,
        following: [String],
        follower: [String]
    });

    models.User = mongoose.model("User", userSchema);

    console.log('mongoose models created');
}

export default models;