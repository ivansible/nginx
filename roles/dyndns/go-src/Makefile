.PHONY: build
build:
	GOARCH=amd64 go build -o dyndns.amd64
	GOARCH=arm64 go build -o dyndns.arm64

.PHONY: lint
lint: build
	gofmt -w . && go mod tidy && golangci-lint run .

.PHONY: run
run: build lint
	./dyndns
