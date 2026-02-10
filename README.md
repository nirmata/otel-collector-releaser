# Nirmata OTel Collector Releaser

Mirrors the [Docker Hardened Image (DHI)](https://hub.docker.com/hardened-images/catalog/dhi/opentelemetry-collector/images) of OpenTelemetry Collector to `ghcr.io/nirmata/otel-collector`.

## Source Image

- **Registry:** `dhi.io/opentelemetry-collector`
- **Variant:** `contrib` (includes prometheus receiver, prometheusremotewrite exporter, etc.)
- **Compliance:** CIS (zero CVEs)
- **Architectures:** `linux/amd64`, `linux/arm64`
- **User:** `nonroot` (65532:65532)

## Target Image

```
ghcr.io/nirmata/otel-collector:nirmata-<version>
```

## Usage

### Trigger a release

1. Go to **Actions** → **Mirror DHI OpenTelemetry Collector to GHCR**
2. Click **Run workflow**
3. Enter the OTel version (e.g., `0.145.0`)
4. Select variant (`contrib` for most use cases)
5. Click **Run workflow**

### Pull the image

```bash
docker pull ghcr.io/nirmata/otel-collector:nirmata-0.145.0
```

## Required Secrets

| Secret | Description |
|--------|-------------|
| `DHI_USERNAME` | Docker Hub username (for `docker login dhi.io`) |
| `DHI_PASSWORD` | Docker Hub password or access token |

`GITHUB_TOKEN` is automatically available for pushing to GHCR.

## Why DHI?

- **Zero CVEs** — hardened by Docker, CIS-compliant
- **Multi-arch** — linux/amd64 + linux/arm64
- **No build step** — direct mirror preserves original manifests and layers
- **Free** — base CIS variants are available without Docker Business subscription
- **Contrib included** — has all community components (prometheus, prometheusremotewrite, etc.)
