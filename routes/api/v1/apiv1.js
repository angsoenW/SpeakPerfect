import parser from 'node-html-parser';
import express from 'express';
import fetch from 'node-fetch';

var router = express.Router();

router.get("/urls/preview", async (req, res) => {
  let inputUrl = req.query.url;
  const types = ['og:url', 'og:title', 'og:image', 'og:description'];
  const typesBackUp = ['url', 'title', 'image', 'description', 'al:ios:app_store_id'];

  try {
    if (!inputUrl) {
      return res.status(400).send(createPreviewHtml(error));
    }

    let response = await fetch(inputUrl);
    let pageText = await response.text();
    let htmlPage = parser.parse(pageText);
    let result = {
      url: inputUrl,
      title: '',
      image: '',
      description: '',
      'al:ios:app_store_id': ''
    };

    let elements = htmlPage.querySelectorAll('meta');

    elements.forEach(info => {
      for (let prop in info.attributes) {
        if (typesBackUp.includes(info.attributes[prop])) {
          result[info.attributes[prop]] = inputUrl.replace(/\/+$/, '') + '/' + info.getAttribute('content').replace(/^\/+/, '');
        }
      }

      const property = info.getAttribute('property');
      if (types.includes(property)) {
        result[property.split(':')[1]] = info.getAttribute('content');
      }
    })

    if (!result.url) {
      result.url = inputUrl;
    }

    if (!result.title) {
      let titleInfo = htmlPage.querySelector('title');
      if (titleInfo) {
        result.title = titleInfo.text;
      } else {
        result.title = requestUrl;
      }
    }

    res.send(createPreviewHtml(result));

  } catch (error) {
    res.status(500).send(createPreviewHtml(error));
  }

});

function createPreviewHtml(result) {
  let html = '<div style="max-width: 300px; border: solid 1px #ddd; padding: 10px; text-align: left; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 20px; background-color: #fff;">';

  if (result.url) {
    html += '<a href="' + result.url + '">';
  }

  if (result.title) {
    html += '<p><strong>' + result.title + '</strong></p>';
  }

  if (result.image) {
    html += '<img src="' + result.image + '" style="max-height: 200px; max-width: 270px; display: block; margin: 0 auto 10px;">';
  }

  if (result.url) {
    html += '</a>';
  }

  if (result.description) {
    html += '<p style="font-size: 14px; color: #333;">' + result.description + '</p>';
  }

  if (result['al:ios:app_store_id']) {
    html += '<p>' + result['al:ios:app_store_id'] + '</p>';
  }

  if (result instanceof Error) {
    html += '<p style="color: red;">' + result.toString() + '</p>';
  }

  html += '</div>';

  return html;
}

export default router;