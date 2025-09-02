# 🔐 GitHub Secrets Setup Guide

This guide explains how to configure GitHub Secrets for the ANGA project's CI/CD pipeline to ensure secure handling of API keys, tokens, and sensitive configuration data.

## 🎯 Overview

GitHub Secrets allow you to store sensitive information securely and use it in your GitHub Actions workflows without exposing it in your code or logs.

## 🔑 Required Secrets

### **Core API Keys**

| Secret Name | Description | Required For | Example |
|-------------|-------------|--------------|---------|
| `GROQ_API_KEY` | Groq API key for AI assistant | Backend AI features | `gsk_...` |
| `OPENWEATHER_API_KEY` | OpenWeather API key | Weather data | `1234567890abcdef...` |

### **Database & Infrastructure**

| Secret Name | Description | Required For | Example |
|-------------|-------------|--------------|---------|
| `DATABASE_URL` | Production database connection | Backend deployment | `postgresql://user:pass@host:5432/db` |
| `REDIS_PASSWORD` | Redis cache password | Backend caching | `your_redis_password` |
| `SECRET_KEY` | Django/FastAPI secret key | Backend security | `your-secret-key-here` |
| `JWT_SECRET_KEY` | JWT token signing key | Authentication | `your-jwt-secret-key` |

### **Cloud & Deployment**

| Secret Name | Description | Required For | Example |
|-------------|-------------|--------------|---------|
| `AWS_ACCESS_KEY_ID` | AWS access key | Cloud deployment | `AKIA...` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | Cloud deployment | `your-aws-secret` |
| `DOCKER_HUB_USERNAME` | Docker Hub username | Container registry | `your-docker-username` |
| `DOCKER_HUB_TOKEN` | Docker Hub access token | Container registry | `your-docker-token` |

### **Monitoring & Analytics**

| Secret Name | Description | Required For | Example |
|-------------|-------------|--------------|---------|
| `SENTRY_DSN` | Sentry error tracking | Error monitoring | `https://...@sentry.io/...` |
| `MIXPANEL_TOKEN` | Mixpanel analytics | User analytics | `your-mixpanel-token` |
| `FIREBASE_SERVER_KEY` | Firebase server key | Push notifications | `your-firebase-key` |

### **Mobile App**

| Secret Name | Description | Required For | Example |
|-------------|-------------|--------------|---------|
| `ANDROID_KEYSTORE_BASE64` | Android keystore (base64) | Android signing | `base64-encoded-keystore` |
| `ANDROID_KEYSTORE_PASSWORD` | Android keystore password | Android signing | `your-keystore-password` |
| `ANDROID_KEY_ALIAS` | Android key alias | Android signing | `your-key-alias` |
| `ANDROID_KEY_PASSWORD` | Android key password | Android signing | `your-key-password` |
| `IOS_CERTIFICATE_BASE64` | iOS certificate (base64) | iOS signing | `base64-encoded-cert` |
| `IOS_CERTIFICATE_PASSWORD` | iOS certificate password | iOS signing | `your-cert-password` |

### **Third-Party Services**

| Secret Name | Description | Required For | Example |
|-------------|-------------|--------------|---------|
| `SLACK_WEBHOOK_URL` | Slack webhook for notifications | Team notifications | `https://hooks.slack.com/...` |
| `EMAIL_SMTP_PASSWORD` | Email SMTP password | Email notifications | `your-smtp-password` |
| `BACKUP_S3_BUCKET` | S3 bucket for backups | Data backup | `your-backup-bucket` |

## 🚀 How to Set Up GitHub Secrets

### **Step 1: Navigate to Repository Settings**

1. Go to your GitHub repository: `https://github.com/Josephnyingi/Anga`
2. Click on **Settings** tab
3. In the left sidebar, click on **Secrets and variables** → **Actions**

### **Step 2: Add Repository Secrets**

1. Click **New repository secret**
2. Enter the **Name** (exactly as shown in the table above)
3. Enter the **Secret** value
4. Click **Add secret**

### **Step 3: Add Environment-Specific Secrets**

For production and staging environments:

1. Go to **Environments** in the left sidebar
2. Click on **production** or **staging**
3. Click **Add secret**
4. Enter environment-specific values

## 🔧 Environment-Specific Configuration

### **Development Environment**
```bash
# Local development - use .env files
GROQ_API_KEY=your_dev_groq_key
OPENWEATHER_API_KEY=your_dev_weather_key
DATABASE_URL=postgresql://localhost:5432/anga_dev
```

### **Staging Environment**
```bash
# Staging secrets in GitHub
GROQ_API_KEY=your_staging_groq_key
OPENWEATHER_API_KEY=your_staging_weather_key
DATABASE_URL=postgresql://staging-db:5432/anga_staging
```

### **Production Environment**
```bash
# Production secrets in GitHub
GROQ_API_KEY=your_prod_groq_key
OPENWEATHER_API_KEY=your_prod_weather_key
DATABASE_URL=postgresql://prod-db:5432/anga_production
```

## 📝 Workflow Usage Examples

### **Using Secrets in GitHub Actions**

```yaml
- name: 🚀 Deploy to production
  run: |
    echo "Deploying with secrets..."
    docker run -e GROQ_API_KEY="${{ secrets.GROQ_API_KEY }}" \
               -e DATABASE_URL="${{ secrets.DATABASE_URL }}" \
               anga-backend:latest
```

### **Environment-Specific Secrets**

```yaml
- name: 🚀 Deploy to staging
  environment: staging
  run: |
    echo "Deploying to staging..."
    # Uses staging environment secrets automatically
```

## 🔒 Security Best Practices

### **✅ Do:**
- Use different API keys for different environments
- Rotate secrets regularly
- Use environment-specific secrets
- Limit secret access to necessary workflows
- Use least privilege principle

### **❌ Don't:**
- Commit secrets to code
- Use production secrets in development
- Share secrets in logs or outputs
- Use weak or default passwords
- Store secrets in plain text files

## 🛠️ Secret Management Tools

### **For Local Development:**
```bash
# Use python-dotenv for local development
pip install python-dotenv

# Create .env file (add to .gitignore)
echo "GROQ_API_KEY=your_local_key" > .env
```

### **For Production:**
- Use GitHub Secrets for CI/CD
- Use cloud provider secret managers (AWS Secrets Manager, Azure Key Vault)
- Use HashiCorp Vault for enterprise environments

## 🔄 Secret Rotation

### **Regular Rotation Schedule:**
- **API Keys**: Every 90 days
- **Database Passwords**: Every 180 days
- **JWT Secrets**: Every 365 days
- **SSL Certificates**: Before expiration

### **Emergency Rotation:**
- Immediately rotate if compromised
- Update all environments
- Notify team of changes
- Update documentation

## 📊 Monitoring Secret Usage

### **GitHub Actions Logs:**
- Secrets are automatically masked in logs
- No secret values will appear in output
- Only secret names are visible

### **Audit Trail:**
- GitHub provides audit logs for secret access
- Monitor who accesses secrets when
- Set up alerts for unusual access patterns

## 🚨 Troubleshooting

### **Common Issues:**

1. **Secret Not Found:**
   ```
   Error: Secret 'GROQ_API_KEY' not found
   ```
   **Solution:** Verify secret name and repository access

2. **Permission Denied:**
   ```
   Error: Permission denied to access secret
   ```
   **Solution:** Check repository permissions and environment access

3. **Environment Not Found:**
   ```
   Error: Environment 'production' not found
   ```
   **Solution:** Create environment in repository settings

### **Debug Steps:**
1. Check secret name spelling
2. Verify repository permissions
3. Check environment configuration
4. Review workflow syntax
5. Check GitHub Actions logs

## 📚 Additional Resources

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Environment Protection Rules](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [Security Best Practices](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)

---

*Proper secret management is crucial for maintaining the security and integrity of your CI/CD pipeline.*
