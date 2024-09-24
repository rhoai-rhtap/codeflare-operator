# Build the manager binary


#test-automerger

FROM registry.access.redhat.com/ubi8/go-toolset@sha256:88338f9b485c7b3d3267dda3a7c70d71ff940b6361e6418ddcaa8848080c4069 as builder


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


FROM registry.access.redhat.com/ubi8/ubi-minimal:8.10-1052.1724178568
WORKDIR /
COPY --from=builder /workspace/manager .

USER 65532:65532
ENTRYPOINT ["/manager"]
