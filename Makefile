
# ==================================================================================== #
# HELPERS
# ==================================================================================== #

## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

.PHONY: confirm
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

# ==================================================================================== #
# DEVELOPMENT
# ==================================================================================== #

## run/api: run the cmd/api application
.PHONY: run/api
api/run:
	@go run ./cmd/api

ifdef local
  ARGS = --endpoint-url http://localhost:8000
else
  ARGS =
endif

## dynamodb/delete-item: delete item from a dynamodb table
.PHONY: dynamodb/delete-item
dynamodb/delete-item:
	@echo 'Deleting user ${id}...'
	@aws dynamodb delete-item \
        --table-name ${name} \
        --key '{"ID":{"S":"${id}"}}'\
        $(local)
	@echo 'User ${id} is deleted'

## dynamodb/delete-table: delete a dynamodb table
.PHONY: dynamodb/delete-table
dynamodb/delete-table: confirm
	@echo 'Deleting table ${name}...'
	@aws dynamodb delete-table \
        --table-name ${name} \
        $(local)
	@echo 'Table ${name} is deleted'

# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #

.PHONY: audit
audit:
	@echo 'Tidying and verifying module dependencies...' go mod tidy
	go mod verify
	@echo 'Formatting code...'
	go fmt ./...
	@echo 'Vetting code...'
	go vet ./...
	staticcheck ./...
	@echo 'Running tests...'
	go test -race -vet=off ./...

## vendor: tidy and vendor dependencies
.PHONY: vendor
vendor:
	@echo 'Tidying and verifying module dependencies...' go mod tidy
	go mod verify
	@echo 'Vendoring dependencies...'
	go mod vendor