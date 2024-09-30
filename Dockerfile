# Use the official Golang image as the build stage
FROM golang:1.22.5 AS base

# Set the working directory inside the container
WORKDIR /app

# Copy the go.mod and go.sum files explicitly from the build context
COPY go.mod go.sum ./

# Download all dependencies
RUN go mod download

# Copy the rest of the application source code
COPY . .

# Build the application binary for Linux
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .

#######################################################
# Use a distroless image for a smaller final image
FROM gcr.io/distroless/base

# Copy the binary and static files from the build stage
COPY --from=base /app/main /app/main
COPY --from=base /app/static /app/static

# Expose the application port
EXPOSE 8080

# Run the Go application
CMD ["/app/main"]
