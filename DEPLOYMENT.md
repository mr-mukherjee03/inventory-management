# Deploying to Render

This guide walks you through deploying the Inventory Management System to Render's free tier.

## Prerequisites

- A [Render account](https://render.com) (free, no credit card required)
- Your code pushed to a GitHub repository
- Basic familiarity with Git

## Architecture Overview

The deployment consists of three services:
1. **PostgreSQL Database** - Stores inventory data
2. **Phoenix Backend** - Elixir/Phoenix API server
3. **React Frontend** - Static site serving the UI

## Step-by-Step Deployment

### 1. Prepare Your Repository

Ensure all deployment files are committed and pushed to GitHub:
```bash
git add .
git commit -m "Add Render deployment configuration"
git push origin main
```

### 2. Create a Render Account

1. Go to [render.com](https://render.com)
2. Sign up with your GitHub account
3. Authorize Render to access your repositories

### 3. Deploy Using render.yaml (Recommended)

Render can automatically create all services from the `render.yaml` file:

1. From your Render dashboard, click **"New +"** → **"Blueprint"**
2. Connect your GitHub repository
3. Render will detect `render.yaml` and show all services
4. Click **"Apply"** to create all services

**Important:** After deployment, update the `VITE_API_URL` environment variable in the frontend service with your actual backend URL.

### 4. Manual Deployment (Alternative)

If you prefer to create services manually:

#### A. Create PostgreSQL Database

1. Click **"New +"** → **"PostgreSQL"**
2. Configure:
   - **Name:** `inventory-db`
   - **Database:** `inventory_prod`
   - **User:** `postgres`
   - **Region:** Choose closest to you
   - **Plan:** Free
3. Click **"Create Database"**
4. **Save the Internal Database URL** (you'll need it for the backend)

#### B. Deploy Backend

1. Click **"New +"** → **"Web Service"**
2. Connect your repository
3. Configure:
   - **Name:** `inventory-backend`
   - **Region:** Same as database
   - **Branch:** `main`
   - **Root Directory:** `backend`
   - **Environment:** `Elixir`
   - **Build Command:** `chmod +x ./build.sh && ./build.sh`
   - **Start Command:** `MIX_ENV=prod mix phx.server`
   - **Plan:** Free

4. Add Environment Variables:
   ```
   MIX_ENV=prod
   SECRET_KEY_BASE=<click "Generate" to create>
   DATABASE_URL=<paste Internal Database URL from step A>
   PHX_HOST=<your-backend-url>.onrender.com
   PORT=4000
   POOL_SIZE=10
   ```

5. Click **"Create Web Service"**
6. Wait for deployment (first build takes 5-10 minutes)
7. **Copy your backend URL** (e.g., `https://inventory-backend.onrender.com`)

#### C. Deploy Frontend

1. Click **"New +"** → **"Static Site"**
2. Connect your repository
3. Configure:
   - **Name:** `inventory-frontend`
   - **Region:** Same as backend
   - **Branch:** `main`
   - **Root Directory:** `frontend`
   - **Build Command:** `npm install && npm run build`
   - **Publish Directory:** `dist`
   - **Plan:** Free

4. Add Environment Variable:
   ```
   VITE_API_URL=<your-backend-url-from-step-B>
   ```
   Example: `VITE_API_URL=https://inventory-backend.onrender.com`

5. Click **"Create Static Site"**

### 5. Verify Deployment

1. **Test Backend:**
   - Visit `https://your-backend.onrender.com/api/items`
   - Should return JSON: `{"data": []}`

2. **Test Frontend:**
   - Visit your frontend URL
   - Try creating an item
   - Verify it appears in the list

## Environment Variables Reference

### Backend (`inventory-backend`)

| Variable | Description | Example |
|----------|-------------|---------|
| `MIX_ENV` | Elixir environment | `prod` |
| `SECRET_KEY_BASE` | Phoenix secret key | Generate via Render |
| `DATABASE_URL` | PostgreSQL connection string | From database service |
| `PHX_HOST` | Backend hostname | `inventory-backend.onrender.com` |
| `PORT` | Server port | `4000` |
| `POOL_SIZE` | Database connection pool size | `10` |

### Frontend (`inventory-frontend`)

| Variable | Description | Example |
|----------|-------------|---------|
| `VITE_API_URL` | Backend API URL | `https://inventory-backend.onrender.com` |

## Important Notes

### Free Tier Limitations

⚠️ **Database Expiration:** PostgreSQL free tier expires after **90 days**

⚠️ **Cold Starts:** Services spin down after 15 minutes of inactivity. First request after inactivity takes 30-60 seconds.

### CORS Configuration

The backend is already configured to accept requests from any origin in development. For production, you may want to restrict CORS to your frontend domain.

## Updating Your Deployment

### Update Backend Code
```bash
git add backend/
git commit -m "Update backend"
git push origin main
```
Render auto-deploys on push.

### Update Frontend Code
```bash
git add frontend/
git commit -m "Update frontend"
git push origin main
```
Render auto-deploys on push.

### Update Environment Variables
1. Go to your service in Render dashboard
2. Click **"Environment"** tab
3. Update variables
4. Service will automatically redeploy

## Troubleshooting

### Backend won't start
- Check logs in Render dashboard
- Verify `DATABASE_URL` is correct
- Ensure `SECRET_KEY_BASE` is set
- Check that migrations ran successfully

### Frontend can't connect to backend
- Verify `VITE_API_URL` matches your backend URL
- Check backend is running (visit `/api/items`)
- Look for CORS errors in browser console
- Ensure backend URL uses `https://` (not `http://`)

### Database connection errors
- Verify `DATABASE_URL` format: `postgresql://user:password@host:port/database`
- Check database service is running
- Ensure backend and database are in same region

### Cold start is too slow
- This is expected on free tier
- Consider upgrading to paid tier for always-on services
- Or use a service like UptimeRobot to ping your app every 5 minutes

## Next Steps

- Set up a custom domain (available on free tier)
- Monitor your app with Render's built-in metrics
- Set up log drains for better debugging
- Consider upgrading to paid tier for production use

## Support

- [Render Documentation](https://render.com/docs)
- [Render Community](https://community.render.com)
- [Phoenix Deployment Guide](https://hexdocs.pm/phoenix/deployment.html)
