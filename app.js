import express from 'express';
import path from 'path';
import cookieParser from 'cookie-parser';
import logger from 'morgan';
import parser from 'node-html-parser';
import fetch from 'node-fetch';
import sessions from 'express-session'
import favicon from 'serve-favicon';
import WebAppAuthProvider from 'msal-node-wrapper'

const authConfig = {
    auth: {
        clientId: "8017b637-f037-4234-8f28-14c47c565744",
        authority: "https://login.microsoftonline.com/f6b6dd5b-f02f-441a-99a0-162ac5060bd2",
        clientSecret: "A5Z8Q~VMcbCSEeCn~mmj8GViGCHFRqQO2CZpEb_v",
        redirectUri: "/redirect", //note: you can explicitly make this "localhost:3000/redirect" or "examplesite.me/redirect"
    },
    system: {
        loggerOptions: {
            loggerCallback(loglevel, message, containsPii) {
                console.log(message);
            },
            piiLoggingEnabled: false,
            logLevel: 3,
        }
    }
};

import models from './models.js'
import apiV3Router from './routes/api/v3/apiv3.js';

import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

var app = express();
app.enable('trust proxy');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

const oneDay = 1000 * 60 * 60 * 24;
app.use(sessions({
    secret: "this is some secret key I am making up v45v;lkjgdsal;nwqt49asglkn",
    saveUninitialized: true,
    cookie: {maxAge: oneDay},
    resave: false
}));

const authProvider = await WebAppAuthProvider.WebAppAuthProvider.initialize(authConfig);
app.use(authProvider.authenticate());

app.use((req, res, next) => {
    req.models = models;
    next();
});

app.use(favicon(path.join(__dirname, 'public', 'img', 'favicon.ico')));

app.use('/api/v3', apiV3Router);

app.get(
	'/signin',
	(req, res, next) => {
		return req.authContext.login({
			postLoginRedirectUri: "/", // redirect here after login
		})(req, res, next);
	}
);

app.get(
	'/signout',
	(req, res, next) => {
		return req.authContext.logout({
			postLogoutRedirectUri: "/", // redirect here after logout
		})(req, res, next);
	}
);

app.use(authProvider.interactionErrorHandler());

export default app;
