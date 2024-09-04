async function init(){
    await loadIdentity();
    loadUserInfo();
}

async function updateUserInfo(){
    let city = document.getElementById('city').value;
    let job = document.getElementById('job').value;
    let bio = document.getElementById('bio').value;

    let responseJson = await fetchJSON(`api/${apiVersion}/userpage?user=${encodeURIComponent(myIdentity)}`, {
        method: "POST",
        body: {city: city, job: job, bio: bio}
    });

    if(responseJson) {
        loadUserInfo();
    } else {
        alert("Failed to save user info. Please try again.");
    }
}

async function addFriend() {
    let followedUserId = document.getElementById('friend_email').value;
    if (!followedUserId) {
        document.getElementById('searchResult').innerHTML = '<div class="alert alert-warning" role="alert">No user found!</div>';
        return;
    }
    let responseJson = await fetchJSON(`api/${apiVersion}/userpage?user=${encodeURIComponent(myIdentity)}`, {
        method: "POST",
        body: {followed: followedUserId}
    });
    if(responseJson) {
        document.getElementById('searchResult').innerHTML = responseJson.message
        loadUserInfo();
    }

}


async function loadUserInfo(){
    const urlParams = new URLSearchParams(window.location.search);
    const username = urlParams.get('user');
    if(username==myIdentity){
        document.getElementById("username-span").innerText= `You (${username})`;
        document.getElementById("user_info_new_div").classList.remove("d-none");
        
    }else{
        document.getElementById("username-span").innerText=username;
        document.getElementById("user_info_new_div").classList.add("d-none");
    }
    
    let responseJson = await fetchJSON(`api/${apiVersion}/userpage?user=${encodeURIComponent(username)}`, {
        method: "GET",
    });

    console.log(responseJson)

    if (responseJson && responseJson.length > 0) {
        console.log(responseJson);
        const user = responseJson[0];
        const following = Array.isArray(user.following) ? user.following.join(', ') : 'None';
        const follower = Array.isArray(user.follower) ? user.follower.join(', ') : 'None';
        
        let userInfoHTML = `
            <p>Username: ${user.username}</p>
            <p>City: ${user.city}</p>
            <p>Job: ${user.job}</p>
            <p>Bio: ${user.bio}</p>
            <p>Following: ${following}</p>
            <p>Follower: ${follower}</p>
        `;
        document.getElementById("user_info_div").innerHTML = userInfoHTML;
    } else {
        document.getElementById("user_info_div").innerHTML = '<p>No user information found.</p>';
    }
    
    loadUserInfoPosts(username)
}


async function loadUserInfoPosts(username){
    document.getElementById("posts_box").innerText = "Loading...";
    let postsJson = await fetchJSON(`api/${apiVersion}/posts?username=${encodeURIComponent(username)}`);
    let postsHtml = postsJson.map(postInfo => {
        return `
        <div class="post">
            ${escapeHTML(postInfo.description)}
            ${postInfo.htmlPreview}
            <div><a href="/userInfo.html?user=${encodeURIComponent(postInfo.username)}">${escapeHTML(postInfo.username)}</a>, ${escapeHTML(postInfo.created_date)}</div>
            <div class="post-interactions">
                <div>
                    <span title="${postInfo.likes? escapeHTML(postInfo.likes.join(", ")) : ""}"> ${postInfo.likes ? `${postInfo.likes.length}` : 0} likes </span> &nbsp; &nbsp; 
                </div>
                <br>
                <div><button onclick='deletePost("${postInfo.id}")' class="${postInfo.username==myIdentity ? "": "d-none"}">Delete</button></div>
            </div>
        </div>`
    }).join("\n");
    document.getElementById("posts_box").innerHTML = postsHtml;
}


async function deletePost(postID){
    let responseJson = await fetchJSON(`api/${apiVersion}/posts`, {
        method: "DELETE",
        body: {postID: postID}
    })
    loadUserInfo();
}