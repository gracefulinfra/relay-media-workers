# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e
# Bootstrap smoke image (P0-01). Base images are pinned by digest; Renovate keeps them current.
FROM --platform=$BUILDPLATFORM golang:1.27.3-trixie@sha256:c65ecfe613b539ac74c62a4c3b2c27e8f8a6076384c8f27e8a3c0f3be17cc385 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
ARG TARGETOS TARGETARCH VERSION=dev COMMIT=unknown
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -trimpath \
      -ldflags "-s -w -X github.com/gracefulinfra/relay-media-workers/internal/buildinfo.Version=$VERSION -X github.com/gracefulinfra/relay-media-workers/internal/buildinfo.Commit=$COMMIT" \
      -o /out/relay-media-workers ./cmd/relay-media-workers

FROM gcr.io/distroless/static-debian13:nonroot@sha256:18f4cc26c9ffa7f20a359298be7deadac5c607c8e03a02b8119f1a5fc2f82c99
COPY --from=build /out/relay-media-workers /relay-media-workers
USER nonroot:nonroot
ENTRYPOINT ["/relay-media-workers"]
