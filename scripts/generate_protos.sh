# Add the Go binary directory to PATH
export GOBIN=$(go env GOPATH)

# Check if protoc-gen-go is installed
if ! command -v protoc-gen-go &> /dev/null; then
    echo "Warning: protoc-gen-go not installed"
    echo "installing protoc-gen-go"
    sudo apt install -y protobuf-compilier
    if [ $? -ne 0 ]; then
        echo "Error: failed to install protoc-gen-go"
        exit 1
    fi
    echo "installed protoc-gen-go"
fi

protoc --version
which protoc-gen-go-grpc
