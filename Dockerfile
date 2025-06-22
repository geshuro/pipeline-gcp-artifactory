# Etapa de construcción
FROM golang:1.19-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -o /go-api

# Etapa final
FROM alpine:latest

WORKDIR /

COPY --from=builder /go-api /go-api

EXPOSE 8080

ENTRYPOINT ["/go-api"] 