GO_MOD_DIRS := $(shell find . -type f -name 'go.mod' -exec dirname {} \; | grep -v './vendor' | sort)

LINT_TOOL := golangci-lint

MOCK_SCRIPT := ./scripts/generate_mocks.sh
PROTO_SCRIPT := ./scripts/generate_protos.sh
BUILD_SCRIPT := ./scripts/build/build-all.sh

DOCKER_RUNNING ?= $(shell docker ps >/dev/null 2>&1 && echo 1 || echo 0)

GO_VERSION := $(shell go version | cut -d " " -f 3 | cut -d. -f2)

.PHONY: lint gofmt staticcheck generate protos mocks

# test: lint
#     set -e; for dir in $(GO_MOD_DIRS); do \
# 		if echo "$${dir}" | grep -q "./example" && [ "$(GO_VERSION)" = "19" ]; then \
# 			echo "Skipping go test in $${dir} due to Go version 1.19 and dir contains ./example"; \
# 			continue; \
# 		fi; \
# 		echo "go test in $${dir}"; \
# 		if echo "$${dir}" | grep -q "./vendor"; then \
# 			echo "Skipping go test in $${dir} because it is a vendor directory"; \
# 			continue; \
# 		fi; \
# 		echo "go test in $${dir}"; \
# 		(cd "$${dir}" && \
# 			go mod tidy -compat=$(GO_VERSION) && \
# 			go test && \
# 			go test ./... -short -race && \
# 			go test ./... -run=NONE -bench=. -benchmem && \
# 			env GOOS=linux GOARCH=386 go test && \
# 			go vet); \
#     done

lint: check-lint gofmt staticcheck
	set -e; for dir in $(GO_MOD_DIRS); do \
		echo "Running golangci-lint in $${dir}"; \
		golangci-lint run "$${dir}"; \
	done

check-lint:
	@if ! command -v $(LINT_TOOL) &> /dev/null; then \
		echo "golangci-lint is not installed. Installing..."; \
		GO111MODULE=on go get github.com/golangci/golangci-lint/cmd/golangci-lint@latest; \
    fi

gofmt:
	@echo "Applying gofmt to all Go files..."
	@gofmt -s -w $(shell find . -type f -name '*.go' -not -path './vendor/*')

staticcheck: check-staticcheck
	@echo "Running staticcheck..."
	@echo $(GO_MOD_DIRS)
	set -e; for dir in $(GO_MOD_DIRS); do \
		echo $${dir}; \
		(cd $${dir} && \
		go test ./... ); \
	done

check-staticcheck:
	@if ! command -v staticcheck &> /dev/null; then \
		echo "staticcheck is not installed. Installing..."; \
		GO111MODULE=on go install honnef.co/go/tools/cmd/staticcheck@latest; \
		if [ $$? -eq 0 ]; then \
			echo "Staticcheck installed successfully."; \
		else \
			echo "Error: Failed to install Staticcheck."; \
			exit 1; \
		fi \
	fi

generate: protos mocks

protos: check-scripts($(PROTO_SCRIPT))
	@echo "Generating Protobuf files..."
	@$(PROTO_SCRIPT)

mocks: check-scripts($(MOCK_SCRIPT))
	@echo "Generating mocks..."
	@$(MOCK_SCRIPT)

check-scripts(%):
	@if [ ! -f "$($*)" ]; then \
		echo "Error: $($*) not found."; \
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
	ifeq ($(DOCKER_RUNNING), 1)
		@$(BUILD_SCRIPT)
	else
		@echo "Docker not installed or running. Skipping build run."
	endif
