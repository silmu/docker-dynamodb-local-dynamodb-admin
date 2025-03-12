# Docker container with DynamoDB and Dynamodb Admin UI 🐳

This DynamoDB setup is ideal for local development, providing a seamless and efficient environment for testing and building applications.

Data is securely persisted in a Docker volume, ensuring that your tables and records remain intact even after stopping the container. You can safely shut down the container when it’s not in use without losing any data.

To streamline your workflow, use the make commands listed below to quickly create tables, seed data, and manage your local DynamoDB instance.

## Steps

1. Install [Docker](https://docs.docker.com/desktop/setup/install/mac-install/)
2. Clone repository: `git clone https://github.com/silmu/docker-dynamodb-local-dynamodb-admin.git`
3. Start container: `make up`

Optional:

4. Add tables definitions into `/models` using standart AWS DynamoDB JSON structure. The table name is taken from the file name, e.g. `users.json` will create `users` table.
5. Run `make create-tables` to create tables.
6. Add data into `/seeds`. Table name is taken from the first key in the file.

## Available Makefile commands:

- `make info` - show available commands
- `make up` - start the container
- `make down` - stop the container
- `make create-tables` - create tables from `/models` (See examples for campaigns and users tables in /models)
- `make seed-tables` - seed created tables from `/seeds` (See examples in /seeds)
- `make list-tables` - list created tables
- `make logs` - show logs

## Docker images used:

- amazon/dynamodb-local
- aaronshaf/dynamodb-admin
