# 🐳 ANGA Docker Infrastructure

This directory contains all Docker-related files for the ANGA Weather App in a centralized location.

## 📁 Directory Structure

```
infrastructure/docker/
├── 📋 docker-compose.yml          # Main development environment
├── 🔄 docker-compose.ci.yml       # CI/CD environment
├── 🔧 .env                        # Environment variables
├── 📚 README.md                   # This file
└── 🛠️ services/                   # Service-specific Dockerfiles
    ├── backend/
    │   └── Dockerfile             # Backend API service
    └── web/
        └── Dockerfile             # Web application service
```

## 🚀 Quick Start

### Development Environment
```bash
# Start all services
docker-compose up -d

# Start specific services
docker-compose up -d backend redis

# View logs
docker-compose logs -f backend

# Stop services
docker-compose down
```

### CI/CD Environment
```bash
# Run CI tests
docker-compose -f docker-compose.ci.yml up --build --abort-on-container-exit
```

## 🏗️ Services

### Backend API
- **Port**: 8000
- **Context**: `../../apps/backend`
- **Dockerfile**: `services/backend/Dockerfile`
- **Dependencies**: Redis, PostgreSQL

### Web Application
- **Port**: 3000
- **Context**: `../../apps/web`
- **Dockerfile**: `services/web/Dockerfile`
- **Dependencies**: Backend API

### Redis Cache
- **Port**: 6379
- **Image**: redis:7-alpine
- **Purpose**: Caching and session storage

### PostgreSQL Database
- **Port**: 5432
- **Image**: postgres:15-alpine
- **Purpose**: Primary data storage

### Nginx Reverse Proxy
- **Ports**: 80, 443
- **Image**: nginx:alpine
- **Purpose**: Load balancing and SSL termination

## 🔧 Configuration

### Environment Variables
Copy `../environments/env.template` to `.env` and configure:

```env
# API Keys
GROQ_API_KEY=your_groq_api_key_here
WEATHER_API_KEY=your_weather_api_key_here

# Database
DATABASE_URL=postgresql://anga_user:anga_password@postgres:5432/anga_weather

# Security
SECRET_KEY=your_secret_key_here
```

### Network Configuration
All services run on the `anga-network` bridge network for internal communication.

## 🧪 Development Workflow

1. **Start services**: `docker-compose up -d`
2. **View logs**: `docker-compose logs -f [service]`
3. **Restart service**: `docker-compose restart [service]`
4. **Rebuild service**: `docker-compose up --build [service]`
5. **Stop all**: `docker-compose down`

## 🔍 Troubleshooting

### Common Issues

1. **Port conflicts**: Check if ports 8000, 3000, 6379, 5432 are available
2. **Build failures**: Ensure all source code is in the correct locations
3. **Network issues**: Verify Docker network creation with `docker network ls`

### Debug Commands
```bash
# Check running containers
docker-compose ps

# Check logs
docker-compose logs [service]

# Execute commands in container
docker-compose exec [service] /bin/bash

# Check network
docker network inspect anga-network
```

## 📊 Monitoring

### Health Checks
- Backend: `http://localhost:8000/health`
- Web: `http://localhost:3000`
- Redis: `redis-cli ping`
- PostgreSQL: `pg_isready`

### Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend

# Last 100 lines
docker-compose logs --tail=100 backend
```

## 🔒 Security

- All services run as non-root users
- Environment variables are loaded from `.env` file
- Network isolation using Docker networks
- Health checks for service monitoring

## 📈 Performance

- Multi-stage builds for optimized images
- Volume mounts for development hot-reload
- Redis caching for improved performance
- Connection pooling for database access
