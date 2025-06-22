# Etapa de construcción
FROM golang:1.19-alpine AS builder

WORKDIR /app

# Copiar go.mod primero
COPY go.mod ./

# Descargar dependencias y generar go.sum si no existe
RUN go mod download && go mod tidy

# Copiar el código fuente
COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -o /go-api

# Etapa final
FROM alpine:latest

WORKDIR /

COPY --from=builder /go-api /go-api

EXPOSE 8080

ENTRYPOINT ["/go-api"] 