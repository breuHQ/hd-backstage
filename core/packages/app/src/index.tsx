import '@backstage/cli/asset-types';
import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';

/**
 * Firebase App Initialization
 * https://firebase.google.com/docs/web/setup#initialize_the_sdk
 **/

// Import the functions you need from the SDKs you need
import { initializeApp } from 'firebase/app';
import { getAnalytics } from 'firebase/analytics';
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: 'AIzaSyC3zVI0TnzIg3S3mZu_v2ZW8GnV4DR6ABI',
  authDomain: 'hd-backstage-poc-28107.firebaseapp.com',
  projectId: 'hd-backstage-poc-28107',
  storageBucket: 'hd-backstage-poc-28107.appspot.com',
  messagingSenderId: '658501036953',
  appId: '1:658501036953:web:7ff7b31f8420de42c38108',
  measurementId: 'G-HMY1H500CK',
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);

/**
 * React App Initialization
 */
ReactDOM.render(<App />, document.getElementById('root'));
