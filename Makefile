GO_MOD_DIRS := $(shell find . -type f -name 'go.mod' -exec dirname {} \; | grep -v './vendor' | sort)

LINT_TOOL := golint

MOCK_SCRIPT := ./scripts/generate_mocks.sh
PROTO_SCRIPT := ./scripts/generate_protos.sh
BUILD_SCRIPT := ./scripts/build/build-all.sh

DOCKER_RUNNING ?= $(shell docker ps >/dev/null 2>&1 && echo 1 || echo 0)

GO_VERSION := $(shell echo $(GOVERSION) | cut -d '.' -f 1.2)

.PHONY: lint gofmt generate protos mocks

test: lint gofmt
	set -e; for dir in $(GO_MOD_DIRS); do \
		echo "Running go test in $${dir}"; \
		(cd "$${dir}" && \
			go mod tidy -compat=$(GO_VERSION) && \
			go test -v ./... && \
			go test -v ./... -short -race && \
			go test -v ./... -run=NONE -bench=. -benchmem && \
			env GOOS=linux GOARCH=386 go test ./... && \
			go vet ./...); \
    done

lint: check-lint
	set -e; for dir in $(GO_MOD_DIRS); do \
		echo "Running golangci-lint in $${dir}"; \
		(cd "$${dir}" && \
		golint ./...); \
	done

check-lint:
	@if ! command -v $(LINT_TOOL) &> /dev/null; then \
		echo "golangci-lint is not installed. Installing..."; \
		go install golang.org/x/lint/golint@latest; \
    fi

gofmt:
	@echo "Applying gofmt to all Go files..."
	@gofmt -s -w $(shell find . -type f -name '*.go' -not -path './vendor/*')

generate: protos mocks
	@echo "Successfully generated all protobufs and mock files"

protos: check-scripts($(PROTO_SCRIPT))
	@echo "Generating Protobuf files..."
	@if [ -f "$(PROTO_SCRIPT)" ]; then \
		sudo apt install -y protobuf-compiler; \
		go install google.golang.org/protobuf/cmd/protoc-gen-go@latest; \
		go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest; \
		(protoc \
			--proto_path=./protos \
			--go_out=. \
			--go_opt=paths=source_relative \
			--go-grpc_out=. \
			--go-grpc_opt=paths=source_relative \
				protos/test.proto); \
	else \
		echo "Proto script not found. Skipping protobufs generation."; \
	fi

mocks: check-scripts($(MOCK_SCRIPT))
	@echo "Generating mocks..."
	@if [ -f "$(MOCK_SCRIPT)" ]; then \
		chmod +x $(MOCK_SCRIPT); \
		$(MOCK_SCRIPT); \
	else \
		echo "Mock script not found. Skipping mock generation."; \
	fi

check-scripts-%:
	@if [ ! -f "$*" ]; then \
		echo "Error: $* not found."; \
		exit 1; \
	fi

bench: testdeps
	go test ./... -test.run=NONE -test.bench=. -test.benchmem

go_mod_tidy:
	set -e; for dir in $(GO_MOD_DIRS); do \
		echo "go mod tidy in $${dir}"; \
		(cd "$${dir}" && \
		go get -u ./... && \
		go mod tidy -compat=$(GO_VERSION)); \
	done

build-all:
	@if [ "$(DOCKER_RUNNING)" = "1" ]; then \
		chmod +x $(BUILD_SCRIPT); \
		$(BUILD_SCRIPT); \
	else \
		echo "Docker not installed or running. Skipping build run."; \
	fi
