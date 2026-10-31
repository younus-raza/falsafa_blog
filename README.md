# Falsafa Blog

A Hugo site using the same Zen theme and structure as `tech_blog`.

## Run locally

```sh
hugo server
```

## Build

```sh
hugo --minify
```

## Deploy to Hostinger

Add `blog.falsafa.pro` in Hostinger hPanel and set its document root to
`~/domains/blog.falsafa.pro/public_html/`. From the repository root, deploy with:

```sh
./scripts/deploy.sh
```

The script uses `~/.ssh/moha0902` and key-only SSH by default. Set `SSH_KEY` to
use a different private key. It excludes the unrelated theme screenshot and
macOS `.DS_Store` files from uploads.

The Hostinger domain entry, DNS record, and SSL certificate must be configured
before the site is available at its HTTPS URL.

## Domains

The canonical site URL is `https://blog.falsafa.pro/`. The other owned hostname is
`https://blog.falsafa.club/`. Configure both as custom domains for the same site
with the hosting provider and point each hostname's DNS records to that provider.
This repository does not configure DNS or redirects. Hugo's canonical URLs and
sitemap use `blog.falsafa.pro`.