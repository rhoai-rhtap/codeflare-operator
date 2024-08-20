# Build the manager binary
FROM registry.access.redhat.com/ubi8/go-toolset@sha256:6b52c59dcdd640c39d5b72c23864820c5639f530bb024bf7baa01946eca9df73 as builder
#test
#restets
WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
RUN go mod download

# Copy the Go sources
COPY main.go main.go
COPY pkg/ pkg/

# Build
USER root
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -tags strictfipsruntime -a -o manager main.go

FROM registry.access.redhat.com/ubi8/ubi-minimal:8.10-1052
WORKDIR /
COPY --from=builder /workspace/manager .

USER 65532:65532
ENTRYPOINT ["/manager"]
