GOCMD=go
GOTEST=$(GOCMD) test
BIN_DIR:=bin

.PHONY: pre clean build format lint-go lint-yaml goconvey test coverage help
.DEFAULT_GOAL := help

##################################### Binary #####################################
pre: ## Create the bin directory
	mkdir -p $(BIN_DIR)

clean: ## Clean the bin directory
	rm -rf $(BIN_DIR)
	rm -f ./checkstyle-report.xml checkstyle-report.xml yamllint-checkstyle.xml

build: pre ## Create the main binary
	CGO_ENABLED=0 $(GOCMD) build -ldflags="-s -w" -o bin/dnstrace .

##################################### Beautify #####################################

format: ## Format the source code
	find . -name '*.go' -not -path './vendor/*' | xargs -n1 go fmt

lint-go: ## Lint Go source code
ifeq ($(EXPORT_RESULT), TRUE)
	$(eval OUTPUT_OPTIONS = $(shell [ "${EXPORT_RESULT}" == "TRUE" ] && echo "--out-format checkstyle ./... | tee /dev/tty > checkstyle-report.xml" || echo "" ))
endif
	docker run --rm -v $(shell pwd):/app -w /app golangci/golangci-lint:latest-alpine golangci-lint run --deadline=65s $(OUTPUT_OPTIONS)

lint-yaml: ## Lint YAML files
ifeq ($(EXPORT_RESULT), TRUE)
	$(GOCMD) install github.com/thomaspoignant/yamllint-checkstyle@latest
	$(eval OUTPUT_OPTIONS = | tee /dev/tty | yamllint-checkstyle > yamllint-checkstyle.xml)
endif
	docker run --rm -it -v $(shell pwd):/data cytopia/yamllint -f parsable $(shell git ls-files '*.yml' '*.yaml') $(OUTPUT_OPTIONS)

##################################### Test #####################################

goconvey: ## Run goconvey
	go install github.com/smartystreets/goconvey@latest
	goconvey -port 1234

test: ## Run the tests
ifeq ($(EXPORT_RESULT), TRUE)
	$(GOCMD) install github.com/jstemmer/go-junit-report/v2@latest
	$(eval OUTPUT_OPTIONS = | go-junit-report -iocopy -set-exit-code -out junit-report.xml)
endif
	$(GOCMD) clean -testcache
	$(GOTEST) -v -race ./... $(OUTPUT_OPTIONS)

coverage: $(wildcard **/**/*.go) ## Run the tests and generate the coverage reports
	$(GOTEST) -cover -covermode=count -coverprofile=coverage.out ./...
ifeq ($(EXPORT_RESULT), TRUE)
	$(GOCMD) install github.com/axw/gocov/gocov@latest
	$(GOCMD) install github.com/AlekSi/gocov-xml@latest
	$(GOCMD) tool cover -html=coverage.out -o coverage.html
	gocov convert coverage.out | gocov-xml > coverage.xml
	rm -f coverage.out
endif

##################################### Help #####################################

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
