# Build arguments
ARG SOURCE_CODE=.
#test-2.13-1

FROM registry.access.redhat.com/ubi8/go-toolset:1.22@sha256:5c10b78538a4a301ee2c38f35c49fcc20363343dfe5cd94cf51bd4128357efc8 AS builder

WORKDIR /workspace

# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source
COPY . .

# Copy the Go sources
COPY main.go main.go
COPY pkg/ pkg/

RUN git config --global --add safe.directory /workspace

# Build
USER root

RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -tags strictfipsruntime -a -o manager main.go

FROM registry.access.redhat.com/ubi8/ubi-minimal@sha256:cf095e5668919ba1b4ace3888107684ad9d587b1830d3eb56973e6a54f456e67
WORKDIR /
COPY --from=builder /workspace/manager .

USER 65532:65532
ENTRYPOINT ["/manager"]

LABEL com.redhat.component="odh-codeflare-operator-container" \
      name="managed-open-data-hub/odh-codeflare-operator-container-rhel8" \
      version="${CI_CONTAINER_VERSION}" \
      git.url="${CI_CODEFLARE_OPERATOR_UPSTREAM_URL}" \
      git.commit="${CI_CODEFLARE_OPERATOR_UPSTREAM_COMMIT}" \
      summary="odh-codeflare-operator-container" \
      io.openshift.expose-services="" \
      io.k8s.display-name="odh-codeflare-operator-container" \
      maintainer="['managed-open-data-hub@redhat.com']" \
      description="Manages lifecycle of MCAD and InstaScale custom resources and associated Kubernetes resources" \
      com.redhat.license_terms="https://www.redhat.com/licenses/Red_Hat_Standard_EULA_20191108.pdf"
