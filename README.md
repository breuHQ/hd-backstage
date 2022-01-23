# Backstage.io

## Getting Started
To deploy Backstage locally in development mode, a basic understanding of working on a Linux based OS using tools like npm, yarn, docker is required. 

## Quick Start
In main directory, run:
```bash  
docker-compose up
```

Now in a new terminal, run:
```bash
cd core
yarn build
yarn start 
```
When the command finishes running, it should open up a browser window displaying your app at http://localhost:3000. 

## Prerequisites 

### Node.js
First make sure you are using Node.js with an Active LTS Release, currently v14. This is made easy with a version manager such as nvm which allows for version switching.

```bash 
nvm --version
nvm install v14.17.6  
nvm use v14.17.6
```
or 
```bash 
nvm alias default 14.17.6
```

### Yarn 
Yarn is used to fetch our dependencies and run an initial build. Please refer to the [installation instructions for Yarn](https://classic.yarnpkg.com/en/docs/install/#mac-stable).

If yarn is installed, check the version by running: 
```bash
yarn --version 
```
Yarn version used is v1.22.17.

### PostgreSQL
Something that goes for all of these docker deployment strategies is that they are stateless, so for a production deployment you will want to set up and connect to an external PostgreSQL instance. 

### Docker 
We use Docker for few of our core features. So, you will need Docker installed locally to use features like Software Templates and TechDocs.  Please refer to the [installation instructions for Docker](https://docs.docker.com/engine/install/).

###  Ports
The following ports need to be opened: 3000, 7007. 

If the database is not hosted on the same server as the Backstage app, the PostgreSQL port needs to be accessible (the default is 5432 or 5433).

## Environment Variables
Before you get started, make sure the following environment variables are present.
You can set environment variables with the following commands in the main directory:

```bash
touch .env
```

Copy and paste the following: 
```ini 
BACKSTAGE_DB_HOST=localhost
BACKSTAGE_DB_PORT=5432
BACKSTAGE_DB_USER=backstage
BACKSTAGE_DB_PASS=backstage
BACKSTAGE_DB_NAME=backstage
```
---
| Variable	            | Description 	     |        Default Value 
| --------------------- | ------------------ | ----------------------- |
| BACKSTAGE_DB_HOST	    | Database Host Name | localhost
| BACKSTAGE_DB_PORT	    | Database port 	 | 5432
| BACKSTAGE_DB_USER	    | Database username  | backstage
| BACKSTAGE_DB_PASS 	| Database password	 | backstage 
| BACKSTAGE_DB_NAME 	| Database name 	 | backstage
---

## Deploying Backstage
Backstage provides tooling to build Docker images. This section describes how to build a Backstage App into a deployable Docker image. 


###	Host Build
The required steps in the host build are to install dependencies with `yarn install`, generate type definitions using `yarn tsc`, and build all packages with `yarn build`.

```bash
yarn install --frozen-lockfile
```

tsc outputs type definitions to dist-types/ in the repo root, which are then consumed by the build: 

```bash
yarn tsc
```

Build all packages and in the end bundle them all up into the packages/backend/dist folder.

```bash
yarn build
```

Once the host build is complete, we are ready to build our image. The following Dockerfile is included:

```ini
FROM node:14-buster-slim

WORKDIR /app
# This dockerfile builds an image for the backend package.
# It should be executed with the root of the repo as docker context.
#
# Before building this image, be sure to have run the following commands in the repo root:
#
# yarn install
# yarn tsc
# yarn build
#
# Once the commands have been run, you can build the image using `yarn build-image`

FROM node:14-buster-slim

WORKDIR /app

# Copy repo skeleton first, to avoid unnecessary docker cache invalidation.
# The skeleton contains the package.json of each package in the monorepo,
# and along with yarn.lock and the root package.json, that's enough to run yarn install.
ADD yarn.lock package.json packages/backend/dist/skeleton.tar.gz ./

RUN yarn install --frozen-lockfile --production --network-timeout 300000 && rm -rf "$(yarn cache dir)"

# Then copy the rest of the backend bundle, along with any other files we might want.
ADD packages/backend/dist/bundle.tar.gz app-config.yaml ./
CMD ["node", "packages/backend", "--config", "app-config.yaml"]
```

The Dockerfile is located at `packages/backend/Dockerfile` , but needs to be executed with the root of the repo as the build context, in order to get access to the root `yarn.lock` and `package.json`, along with any other files that might be needed.

With the project built, we are now ready to build the final image. From the root of the repo, execute the build:

```bash
docker image build . -f packages/backend/Dockerfile --tag backstage

docker run -it -p 7007:7007 backstage

docker-compose up
```
You should then start to get logs in your terminal, and then you can open your browser at http://localhost:7007. 

## Run the App
When the installation is complete and docker image is built, you can open the app folder and start the app.
```bash 
yarn start
```
When the command finishes running, it should open up a browser window displaying your app at http://localhost:3000. 
