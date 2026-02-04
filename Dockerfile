# Multi-stage Dockerfile for OpenTelemetry Collector with CVE fixes
# Builds from source to ensure Go stdlib and dependency CVEs are patched

ARG OTEL_VERSION=0.144.0
ARG GO_VERSION=1.24.11

# Stage 1: Build the collector from source
FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-alpine AS builder

ARG OTEL_VERSION
ARG TARGETARCH
ARG TARGETOS

# Install build dependencies
RUN apk add --no-cache ca-certificates curl git

# Download and install ocb (OpenTelemetry Collector Builder)
RUN curl --proto '=https' --tlsv1.2 -fL -o /usr/local/bin/ocb \
    "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/cmd%2Fbuilder%2Fv${OTEL_VERSION}/ocb_${OTEL_VERSION}_linux_amd64" && \
    chmod +x /usr/local/bin/ocb

WORKDIR /build

# Copy builder configuration
COPY builder-config.yaml /build/builder-config.yaml

# Generate the builder config with version substitution
RUN sed -i "s/\${OTEL_VERSION}/${OTEL_VERSION}/g" /build/builder-config.yaml

# Build the collector
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    ocb --config=/build/builder-config.yaml

# Ensure binary is executable and strip if possible
RUN chmod +x /build/otelcol/otelcol-nirmata

# Stage 2: Create minimal runtime image
FROM --platform=${TARGETPLATFORM} gcr.io/distroless/static-debian12:nonroot

ARG OTEL_VERSION

# Copy the built binary
COPY --from=builder /build/otelcol/otelcol-nirmata /otelcol

# Set metadata labels
LABEL org.opencontainers.image.title="Nirmata OpenTelemetry Collector" \
      org.opencontainers.image.description="Multi-architecture OpenTelemetry Collector built from source with CVE fixes" \
      org.opencontainers.image.vendor="Nirmata" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.source="https://github.com/open-telemetry/opentelemetry-collector" \
      org.opencontainers.image.documentation="https://opentelemetry.io/docs/collector/" \
      org.opencontainers.image.version="${OTEL_VERSION}" \
      nirmata.go.version="${GO_VERSION}"

# Use nonroot user for security
USER 65532:65532

# Expose the default OTLP receiver ports
EXPOSE 4317 4318

# Default entrypoint
ENTRYPOINT ["/otelcol"]
CMD ["--config=/etc/otelcol/config.yaml"]
