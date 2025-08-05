# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Phoenix 1.7 web application named Kanban, built with Elixir. It's configured for PostgreSQL database, TailwindCSS for styling, and includes Docker setup for development and deployment.

## Development Commands

### Setup and Dependencies
- `mix setup` - Complete project setup (deps, database, assets)
- `mix deps.get` - Install dependencies
- `mix ecto.setup` - Setup database (create, migrate, seed)
- `mix ecto.reset` - Drop and recreate database

### Running the Application
- `mix phx.server` - Start Phoenix server (http://localhost:4000)
- `iex -S mix phx.server` - Start server in interactive Elixir shell

### Testing
- `mix test` - Run all tests (includes database setup)
- `mix test --cover` - Run tests with coverage report

### Assets and Frontend
- `mix assets.setup` - Install Tailwind and esbuild if missing
- `mix assets.build` - Build assets for development
- `mix assets.deploy` - Build and minify assets for production

### Code Quality
- `mix dialyzer` - Run static analysis (Dialyzer PLT files in priv/plts/)
- `mix format` - Format Elixir code

### Docker Development
- `docker build -f Dockerfile.dev -t kanban-dev:latest .` - Build dev image
- `docker run -ti -p 4000:4000 -v $(pwd):/app kanban-dev:latest` - Run dev container

## Architecture

### Core Structure
- **Application**: Standard Phoenix/OTP application with supervision tree
- **Database**: PostgreSQL with Ecto as ORM
- **Web Layer**: Phoenix LiveView-ready with Bandit adapter
- **Assets**: TailwindCSS + esbuild pipeline, Heroicons integration
- **Infrastructure**: Terraform modules for AWS deployment

### Key Directories
- `lib/kanban/` - Core business logic and contexts
- `lib/kanban_web/` - Phoenix web layer (controllers, views, templates)
- `assets/` - Frontend assets (CSS, JS, Tailwind config)
- `priv/repo/` - Database migrations and seeds
- `test/` - Test files with support modules
- `config/` - Environment-specific configuration
- `modules/` - Terraform infrastructure modules
- `environments/` - Deployment-specific Terraform configs

### Database
- Uses PostgreSQL with Ecto
- UTC datetime timestamps configured
- Migrations in `priv/repo/migrations/`

### Frontend Stack
- TailwindCSS 3.4.3 with custom brand color (#FD4F00)
- esbuild for JavaScript bundling
- Heroicons integration via TailwindCSS plugin
- Phoenix LiveView utilities and loading states

### Infrastructure
- Terraform modules for AWS deployment
- Docker setup for both development and production
- SOPS for secrets management with age encryption
- Packer for building AMIs

## Development Environment

### Local Setup
The project uses standard Phoenix conventions. Database configuration is environment-specific.

### Development Routes
- `/dev/dashboard` - Phoenix LiveDashboard (dev only)
- `/dev/mailbox` - Swoosh email preview (dev only)

### Configuration
- Environment configs in `config/` directory
- Runtime configuration in `config/runtime.exs`
- Telemetry and monitoring configured via `KanbanWeb.Telemetry`

## Testing Strategy
- ExUnit for testing framework
- Test database automatically managed
- Support modules in `test/support/`
- Floki for HTML parsing in tests