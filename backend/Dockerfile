# Stage 1: build the project using Swift
FROM swift:6.0

# Install dependencies, including OpenSSL
RUN apt-get update && apt-get install -y \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy all project files into the container
COPY . .

# Build the project in release mode
RUN swift build --configuration release

