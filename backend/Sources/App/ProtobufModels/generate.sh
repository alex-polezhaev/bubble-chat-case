#!/bin/bash

# Path to the folder with .proto files
PROTO_DIR="./Proto"
OUT_DIR="./Swift"

# Make sure the output directory exists
mkdir -p "$OUT_DIR"

echo "Generating Swift files from Protobuf..."

# Recursively find all .proto files
PROTO_FILES=$(find "$PROTO_DIR" -name "*.proto")

# Command to generate the Protobuf and gRPC files
protoc \
  --swift_out="$OUT_DIR" \
  --swift_opt=Visibility=Public \
  --grpc-swift_opt=Visibility=Public \
  --grpc-swift_out="$OUT_DIR" \
  -I "$PROTO_DIR" \
  $PROTO_FILES
  
# Check the command status
if [ $? -ne 0 ]; then
  echo "Protobuf generation failed."
  exit 1
fi

echo "Protobuf generation completed successfully."

# Continue push
exit 0
