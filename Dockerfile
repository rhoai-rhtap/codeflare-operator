# Build the manager binary
#FROM registry.access.redhat.com/ubi8/go-toolset@sha256:09a49fc33f45e53b3233b6816e5b39ddb9eddd3238ff117d29915547523e6646 as builder

FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

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

#FROM registry.access.redhat.com/ubi8/ubi-minimal:8.10-1052.1724178568
WORKDIR /
COPY --from=builder /workspace/manager .

USER 65532:65532
ENTRYPOINT ["/manager"]
