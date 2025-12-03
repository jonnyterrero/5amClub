# Vercel Deployment Guide

## Quick Deploy (5 minutes)

### Option 1: Deploy via Vercel Dashboard (Easiest)

1. **Go to [vercel.com](https://vercel.com)** and sign in
2. Click **"Add New..."** → **"Project"**
3. **Import your repository**:
   - If your code is in GitHub/GitLab/Bitbucket: Connect the repo and select it
   - If not: Click **"Deploy"** and drag & drop your project folder
4. **Configure** (usually auto-detected):
   - Framework Preset: **Other**
   - Root Directory: `.` (root)
   - Build Command: Leave empty
   - Output Directory: `.` (root)
5. Click **"Deploy"**
6. Wait ~30 seconds for deployment to complete
7. Your site is live! 🎉

### Option 2: Deploy via Vercel CLI

```bash
# Install Vercel CLI (if not already installed)
npm i -g vercel

# Navigate to your project folder
cd "jonny study"

# Deploy
vercel

# Follow the prompts:
# - Set up and deploy? Yes
# - Which scope? (your account)
# - Link to existing project? No
# - Project name? (press enter for default)
# - Directory? ./
# - Override settings? No
```

## Custom Domain Setup (Optional)

1. In Vercel dashboard, go to your project
2. Click **Settings** → **Domains**
3. Add your custom domain
4. Update your DNS records as shown in Vercel
5. Wait for DNS propagation (usually 5-10 minutes)

## Important Notes

- ✅ **Your data is safe**: All data is stored in browser localStorage, so it's not affected by deployment
- ✅ **Service Worker**: Configured to work with Vercel's routing
- ✅ **Version checking**: Will work automatically with Vercel
- ✅ **Auto-deployments**: If connected to Git, Vercel will auto-deploy on every push

## Troubleshooting

**Service Worker not updating?**
- Clear browser cache and hard refresh (Ctrl+Shift+R / Cmd+Shift+R)
- Check browser DevTools → Application → Service Workers

**Version not updating?**
- The `version.json` file is configured to never cache
- Check Network tab to ensure it's fetching fresh

**404 errors?**
- The `vercel.json` rewrites all routes to `index.html` (SPA routing)
- This should work automatically

## Migration from Netlify

If you were previously on Netlify:
1. Deploy to Vercel first (get it working)
2. Update your custom domain DNS (if applicable)
3. Once confirmed working, you can remove the Netlify deployment

---

**Need help?** Check [Vercel Docs](https://vercel.com/docs) or their support.

