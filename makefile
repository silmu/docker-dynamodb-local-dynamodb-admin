DYNAMO_ENDPOINT := http://dynamodb-local:8000
CONTAINER_NAME := dynamodb-local

.PHONY: up down create-tables seed-tables list-tables  logs

info:
	@echo "Usage: make [command]"
	@echo ""
	@echo "Commands:"
	@echo ""
	@echo "  up              Start the DynamoDB Local container"
	@echo "  down            Stop the DynamoDB Local container"
	@echo "  create-tables   Create tables in DynamoDB Local"
	@echo "  seed-tables     Seed tables in DynamoDB Local"
	@echo "  list-tables     List tables in DynamoDB Local"
	@echo "  logs            Show logs of the DynamoDB Local container"
	@echo ""

up:
		docker-compose up -d
		@echo "Verifying AWS CLI installation..."
		@docker exec $(CONTAINER_NAME) aws --version || (echo "AWS CLI not found in container. Rebuilding image..." && docker-compose build $(CONTAINER_NAME))
		@echo "AWS CLI verified."

down:
		docker-compose down

create-tables: up
		@echo "Creating tables..."
		@for file in models/*.json; do \
				table_name=$$(basename "$$file" .json); \
				container_file="/models/$$(basename "$$file")"; \
				docker exec $(CONTAINER_NAME) aws dynamodb create-table --endpoint-url $(DYNAMO_ENDPOINT) --cli-input-json file://$$container_file; \
				if [ $$? -eq 0 ]; then \
				        echo "  - Table $$table_name created successfully."; \
				else \
				        echo "  - Table $$table_name creation failed."; \
				fi; \
		done
		@echo "Tables creation completed."

seed-tables: up
	@echo "Seeding tables..."
	@for file in seeds/*.json; do \
		table_name=$$(basename "$$file" .json); \
		container_file="/seeds/$$(basename "$$file")"; \
		echo "Seeding table $$table_name..."; \
		output=$$(docker exec $(CONTAINER_NAME) aws dynamodb batch-write-item --endpoint-url $(DYNAMO_ENDPOINT) --request-items file://$$container_file --output json); \
		exit_code=$$?; \
		if [ $$exit_code -eq 0 ]; then \
			unprocessed_items=$$(echo "$$output" | jq -r '.UnprocessedItems | length'); \
			if [ $$unprocessed_items -eq 0 ]; then \
				echo "  - Table $$table_name seeded successfully."; \
			else \
				echo "  - Table $$table_name seeding partially failed. Unprocessed items: $$unprocessed_items"; \
				echo "  - UnprocessedItems: $$(echo "$$output" | jq '.UnprocessedItems')"; \
			fi; \
		else \
			echo "  - Table $$table_name seeding failed with exit code $$exit_code."; \
		fi; \
	done
	@echo "Tables seeding completed."

list-tables: up
		@echo "Listing tables..."
		@docker exec $(CONTAINER_NAME) aws dynamodb list-tables --endpoint-url $(DYNAMO_ENDPOINT)

logs:
		docker logs -f $(CONTAINER_NAME)