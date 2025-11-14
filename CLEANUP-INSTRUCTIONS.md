# Cleanup Instructions

## Remove Firebase/Genkit Packages

Since we've removed Firebase and Genkit from package.json, you need to clean up your node_modules:

### Option 1: Fresh Install (Recommended)
```bash
# Delete node_modules and package-lock.json
rm -rf node_modules package-lock.json

# Fresh install
npm install
```

### Option 2: Quick Cleanup
```bash
# Just reinstall
npm install
```

### Option 3: Manual Removal
```bash
# Remove specific packages
npm uninstall @genkit-ai/google-genai @genkit-ai/next genkit genkit-cli
```

## Verify Cleanup

After running the cleanup, verify everything is removed:

```bash
# Check if packages are gone
npm list | grep -i genkit
npm list | grep -i firebase

# Should return nothing
```

## Test the App

```bash
# Start development server
npm run dev

# Open browser to http://localhost:9002
# Check for:
# 1. New graduation cap favicon in browser tab
# 2. No console errors about missing modules
# 3. App loads correctly
```

## What Was Removed

### Dependencies:
- `@genkit-ai/google-genai` - Genkit AI integration
- `@genkit-ai/next` - Genkit Next.js adapter
- `genkit` - Genkit core library

### Dev Dependencies:
- `genkit-cli` - Genkit command line tools

### Scripts:
- `genkit:dev` - Genkit development server
- `genkit:watch` - Genkit watch mode

### Files:
- `src/ai/genkit.ts` - Genkit configuration
- `src/ai/dev.ts` - Genkit dev entry point
- `src/app/favicon.ico` - Old Firebase favicon

## Troubleshooting

### Error: Cannot find module 'genkit'
**Solution**: Run `npm install` to update dependencies

### Old favicon still showing
**Solution**: Clear browser cache (Ctrl+Shift+Delete) and hard reload (Ctrl+Shift+R)

### Build errors
**Solution**: Delete `.next` folder and rebuild:
```bash
rm -rf .next
npm run build
```

## Success Indicators

✅ No Genkit packages in node_modules
✅ No Firebase packages in node_modules  
✅ New graduation cap favicon displays
✅ App runs without errors
✅ Build completes successfully
✅ No console warnings about missing modules

## Next Steps

After cleanup is complete:
1. Test all features to ensure nothing broke
2. Commit the changes to git
3. Deploy to production if everything works

## Need Help?

If you encounter any issues:
1. Check the console for specific error messages
2. Verify package.json has no Firebase/Genkit references
3. Ensure node_modules was properly cleaned
4. Try a fresh install from scratch
