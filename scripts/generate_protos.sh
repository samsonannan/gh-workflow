# Add the Go binary directory to PATH
export PATH=$PATH:$(go env GOPATH)/bin

# Check if protoc-gen-go is installed
if ! command -v protoc-gen-go &> /dev/null; then
    echo "Warning: protoc-gen-go not installed"
    echo "installing protoc-gen-go"
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
    if [ $? -ne 0 ]; then
        echo "Error: failed to install protoc-gen-go"
        exit 1
    fi
    echo "installed protoc-gen-go"
fi

echo $(shell protoc --version)
