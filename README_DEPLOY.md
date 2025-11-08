# Rawfade Clothing - Easy Deployment

## ONE CLICK DEPLOYMENT

Just double-click on **[one_click_deploy.bat](file:///c%3A/Users/arafa/umat/umat/one_click_deploy.bat)** and your website will be deployed automatically!

## What happens when you run it:

1. The system builds your website (this takes a few minutes)
2. It copies everything to your server at 89.116.20.32
3. It starts all services automatically
4. Your website will be available at http://89.116.20.32

## For your domain to work (ONE TIME SETUP):

To make your website available at https://rawfadeclothing.com, you need to do ONE manual step:

1. Log in to where you bought your domain name (rawfadeclothing.com)
2. Find the DNS settings
3. Create two "A records":
   - One that points `@` to `89.116.20.32`
   - One that points `www` to `89.116.20.32`

That's it! After 5-60 minutes, your website will be available at https://rawfadeclothing.com

## Troubleshooting

If the deployment fails:
1. Make sure you have internet connection
2. Make sure your VPS is running
3. Make sure you enter the correct password when prompted

If your website doesn't show at https://rawfadeclothing.com:
1. Make sure you set up the DNS records as described above
2. Wait a bit longer for DNS to update (sometimes up to 1 hour)

## Questions?

If you have any problems, just let me know what error message you see.