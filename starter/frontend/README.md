# Overview

This is the frontend application that you'll be deploying. Below you'll find the team's notes on what scripts or steps they perform in order to build, test and run their application. These will prove useful when building the pipeline for this application.

## Requirements

The team wants the following jobs in their CI pipeline:

* Lint
* Test
* Build

Lint and test should run in parallel

Build should only run after lint and test are completed

The team wants the

## Available Scripts

In the frontend directory, you can run:

### `npm ci`

Installs the project's dependencies

### `npm test`

Launches the test runner in the interactive watch mode.
See the section about [running tests](https://facebook.github.io/create-react-app/docs/running-tests) for more information.

### `npm run build`

Builds the app for production to the `build` folder.
It correctly bundles React in production mode and optimizes the build for the best performance.

REMEMBER! Set the environment variable `REACT_APP_MOVIE_API_URL=http://localhost:3001` BEFORE building. The app needs to know how to reach the backend so we need to pass this build time argument
Your app is ready to be deployed!

### `npm start`

Runs the app in the development mode.
Open [http://localhost:3000](http://localhost:3000) to view it in your browser.

The page will reload when you make changes.
You may also see any lint errors in the console.

### `npm run serve`

In a deployed environment, this will serve the app in Production mode

### `npm run clean`

Remove the dependencies and build artifacts to start from scratch
