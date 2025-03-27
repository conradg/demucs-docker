# Final stage: use a lightweight container
FROM python:3.12-slim

# Install runtime dependencies only (ffmpeg)
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Copy installed Python dependencies from builder
COPY --from=builder /usr/local /usr/local

# Set up working directory
WORKDIR /app

# Copy our entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# (Re)create the cache directory for Demucs models
RUN mkdir -p /root/.cache/torch/hub/checkpoints /app/dummy && \
    echo " " > /app/dummy/silent.wav && \
    timeout 300 demucs /app/dummy/silent.wav || true

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

