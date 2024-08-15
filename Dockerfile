# Build the manager binary
FROM registry.access.redhat.com/ubi8/go-toolset@sha256:fd5e3e4bd8d895704e45538462844abd50991bd0f7eb983a9788fdd3191a39e9 as builder

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
