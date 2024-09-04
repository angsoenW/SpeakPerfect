import fetch from 'node-fetch';

import parser from 'node-html-parser';

async function getURLPreview(url) {
  const types = ['og:url', 'og:title', 'og:image', 'og:description'];
  const typesBackUp = ['url', 'title', 'image', 'description', 'al:ios:app_store_id'];

  try {
    if (!url) {
      return createPreviewHtml(Error("Please provide an URL!"));
    }

    let response = await fetch(url);
    let pageText = await response.text();
    let htmlPage = parser.parse(pageText);
    let result = {
      url: url,
      title: '',
      image: '',
      description: '',
      'al:ios:app_store_id': ''
    };

    let elements = htmlPage.querySelectorAll('meta');

    elements.forEach(info => {
      for (let prop in info.attributes) {

        if (typesBackUp.includes(info.attributes[prop])) {
          if (info.attributes[prop] === 'image') {
            result[info.attributes[prop]] = url.replace(/\/+$/, '') + '/' + info.getAttribute('content').replace(/^\/+/, '');
          } else {
            result[info.attributes[prop]] = info.getAttribute('content');
          }
        }
      }
    })

    elements.forEach(info => {
      const property = info.getAttribute('property');
      if (types.includes(property)) {
        result[property.split(':')[1]] = info.getAttribute('content');
      }
    })

    if (!result.url) {
      result.url = url;
    }

    if (!result.title) {
      let titleInfo = htmlPage.querySelector('title');
      if (titleInfo) {
        result.title = titleInfo.text;
      } else {
        result.title = requestUrl;
      }
    }

    return createPreviewHtml(result);

  } catch (error) {
    return createPreviewHtml(error);
  }
}

function createPreviewHtml(result) {
  let html = '<div style="max-width: 300px; border: solid 1px #ddd; padding: 10px; text-align: center; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 20px; background-color: #fff;">';

  if (result.url) {
    html += '<a href="' + escapeHTML(result.url) + '">';
  }

  if (result.title) {
    html += '<p><strong>' + escapeHTML(result.title) + '</strong></p>';
  }

  if (result.image) {
    html += '<img src="' + escapeHTML(result.image) + '" style="max-height: 200px; max-width: 270px; display: block; margin: 0 auto 10px;">';
  }

  if (result.url) {
    html += '</a>';
  }

  if (result.description) {
    html += '<p style="font-size: 14px; color: #333;">' + escapeHTML(result.description) + '</p>';
  }

  if (result['al:ios:app_store_id']) {
    html += '<a href="https://apps.apple.com/us/app/id' + escapeHTML(result['al:ios:app_store_id']) + '">View it on Apple Store' + '</a>';
  }

  if (result instanceof Error) {
    html += '<p style="color: red;">' + result.toString() + '</p>';
  }

  html += '</div>';

  return html;
}

function escapeHTML(str) {
  return str.replace(/[&<>"']/g, function(match) {
      return {
          '&': '&amp;',
          '<': '&lt;',
          '>': '&gt;',
          '"': '&quot;',
          "'": '&#39;'
      }[match];
  });
}

export default getURLPreview;