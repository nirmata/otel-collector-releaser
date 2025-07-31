# Multi-stage Dockerfile for OpenTelemetry Collector with Nirmata customizations
ARG OTEL_VERSION=latest

# Use the official OpenTelemetry Collector as the base
FROM --platform=$TARGETPLATFORM otel/opentelemetry-collector:${OTEL_VERSION} AS base

# Build platform arguments for multi-arch support
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH

# Final stage - create the Nirmata-customized image
FROM --platform=${TARGETPLATFORM} gcr.io/distroless/static-debian12:nonroot

# Copy the otelcol binary from the official image
COPY --from=base /otelcol /otelcol

# Set metadata labels
LABEL org.opencontainers.image.title="Nirmata OpenTelemetry Collector" \
      org.opencontainers.image.description="Multi-architecture OpenTelemetry Collector with Nirmata customizations" \
      org.opencontainers.image.vendor="Nirmata" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.source="https://github.com/open-telemetry/opentelemetry-collector" \
      org.opencontainers.image.documentation="https://opentelemetry.io/docs/collector/"

# Use nonroot user for security
USER 65532:65532

# Expose the default OTLP receiver ports
EXPOSE 4317 4318

# Default entrypoint
ENTRYPOINT ["/otelcol"]
CMD ["--config=/etc/otelcol/config.yaml"] 