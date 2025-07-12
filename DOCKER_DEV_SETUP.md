# Docker Development Setup

This document explains how to use the `Dockerfile.dev` for local development of the Kanban application.

## Prerequisites

- Docker installed on your system
- The project files in your current directory

## Building the Development Image

First, build the development Docker image from the `Dockerfile.dev`:

```bash
docker build -f Dockerfile.dev -t kanban-dev:latest .
```

This command:
- Uses the `Dockerfile.dev` file (specified with `-f`)
- Tags the image as `kanban-dev:latest`
- Builds from the current directory (`.`)

## Running the Development Container

Once the image is built, run the development container:

```bash
docker run -ti -p 4000:4000 -v $(pwd):/app kanban-dev:latest
```

### Command Breakdown

- `-ti`: Run in interactive mode with a TTY (allows you to see logs and interact with the container)
- `-p 4000:4000`: Maps port 4000 from the host to port 4000 in the container
- `-v $(pwd):/app`: Mounts the current directory to `/app` in the container for live code changes
- `kanban-dev:latest`: The image to run

## What Happens When You Run This

1. **Container starts**: The container will start and run `mix phx.server`
2. **Dependencies**: Mix dependencies will be installed automatically when the volume is mounted
3. **Live reloading**: Since your local directory is mounted, any changes you make to the code will be reflected in the running application
4. **Access**: The Phoenix server will be available at `http://localhost:4000`

## Development Workflow

1. Make changes to your code in your local editor
2. The changes are automatically reflected in the container due to the volume mount
3. Phoenix will automatically reload when it detects changes
4. View your changes at `http://localhost:4000`

## Stopping the Container

To stop the development server, press `Ctrl+C` in the terminal where the container is running, or run:

```bash
docker stop <container_id>
```

## Troubleshooting

### Port Already in Use
If port 4000 is already in use, you can map to a different port:

```bash
docker run -ti -p 4001:4000 -v $(pwd):/app kanban-dev:latest
```

Then access the application at `http://localhost:4001`

### Permission Issues
If you encounter permission issues with the volume mount, you may need to adjust file permissions or use Docker's user mapping features.

### Dependencies Not Installing
If dependencies aren't installing properly, you can manually install them by running:

```bash
docker run -ti -p 4000:4000 -v $(pwd):/app kanban-dev:latest mix deps.get
```

Then start the server:

```bash
docker run -ti -p 4000:4000 -v $(pwd):/app kanban-dev:latest mix phx.server
```

## Environment Variables

The development container is configured with these environment variables:
- `MIX_ENV=dev`: Sets the Mix environment to development
- `PHX_HOST=0.0.0.0`: Allows Phoenix to bind to all interfaces
- `PORT=4000`: Sets the port to 4000
- `PHX_SERVER_IP=0.0.0.0`: Forces Phoenix to bind to all interfaces for Docker access

These settings ensure the Phoenix server is accessible from outside the container. 