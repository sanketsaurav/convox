.PHONY: generate mocks

generate:
	bash ../../vendor/k8s.io/code-generator/generate-groups.sh all \
		github.com/convox/convox/pkg/atom/pkg/client \
		github.com/convox/convox/pkg/atom/pkg/apis \
		atom:v1

mocks:
	rm -f mock_Interface.go
	go run ../../vendor/github.com/vektra/mockery/cmd/mockery/mockery.go -inpkg -name Interface