# Minimal MongoDB image that does not reference any non-existent directories.
# This file avoids any cd into db_visualizer and keeps startup simple.

FROM mongo:6.0

# Create non-root user for safety (Mongo uses mongodb user by default in some variants)
# but keep defaults; do not enforce credentials here to avoid preview friction.

# Copy entrypoint script which gracefully handles no-op scenarios.
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose default MongoDB port
EXPOSE 27017

# Use our entrypoint which starts mongod by default
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command is to run mongod
CMD ["mongod", "--bind_ip_all"]
