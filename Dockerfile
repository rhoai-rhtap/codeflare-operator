# Build the manager binary
FROM registry.access.redhat.com/ubi8/go-toolset@sha256:00a64493787c0839c221d320dbed90593cba5da93d1b8d16ca132de33b7cc1c6 as builder

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


FROM registry.access.redhat.com/ubi8/ubi-minimal:8.10-1018
WORKDIR /
COPY --from=builder /workspace/manager .

USER 65532:65532
ENTRYPOINT ["/manager"]
