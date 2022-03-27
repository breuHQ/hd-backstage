# DevEx

[Breu's](https://breu.io) Developer Experience and Productivity Platform based on top of [backstage](https://backstage.io).

## Getting Started

### Pre Requisites

To run locally, you system needs to have

- docker
- node, version 16
- yarn, the node package manager

### Quick Start

First set the environment variables, as shown the environment variables sections below, then
In main directory, run:

```bash
docker-compose up
```

Open a second term

```bash
yarn dev
```

When the command finishes running, it should open up a browser window displaying your app at <http://localhost:3000>

### Environment Variables

Before you get started, make sure the following environment variables are present.
You can set environment variables with the following commands in the main directory:

```bash
touch .env
```

Copy and paste the following:

```sh
APP_BASE_URL=http://localhost:3000
BACKEND_BASE_URL=http://localhost:7007
DB_HOST=localhost
DB_PORT=5432
DB_USER=backstage
DB_PASS=backstage
DB_NAME=backstage
GITLAB_DISCOVERY_URL=<CONSULT MANAGER>
GITLAB_TOKEN=<CONSULT MANAGER>
ONELOGIN_CLIENT_ID=<CONSULT MANAGER>
ONELOGIN_CLIENT_SECRET=<CONSULT MANAGER>
ONELOGIN_ISSUER=<CONSULT MANAGER>
```

| Variable               | Description                                                                               | Default Value                                         |
| ---------------------- | ----------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| DB_HOST                | Database Host Name                                                                        | localhost                                             |
| DB_PORT                | Database port                                                                             | 5432                                                  |
| DB_USER                | Database username                                                                         | backstage                                             |
| DB_PASS                | Database password                                                                         | backstage                                             |
| DB_NAME                | Database name                                                                             | backstage                                             |
| GITLAB_DISCOVERY_URL   | Gitlab Discovery URL. See [docs](https://backstage.io/docs/integrations/gitlab/discovery) | <https://gitlab.com/devexp_/blob/*/catalog-info.yaml> |
| GITLAB_TOKEN           | Gitlab's personal access token                                                            |                                                       |
| ONELOGIN_CLIENT_ID     | Onelogin Client ID                                                                        |                                                       |
| ONELOGIN_CLIENT_SECRET | Onelogin Client Secret                                                                    |                                                       |
| ONELOGIN_ISSUER        | Onelogin Issuer                                                                           |                                                       |

## Infrastructure

The project infrastructure is setup using `terraform`. Before running terraform, you must be authenticated with `gcloud` and with right credentials.
