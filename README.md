# The Pipeline

## What is this?

This is a monorepo for and hobby/demo/template project combining a bunch of my favorite tech for a smooth CI-experience.

TODO:
- Deploy lambda using Terraform and Github actions
- Deploy PSQL and connect lambda to it


The tools:

- [Terraform](https://www.terraform.io/) for Infra as Code
- [Github Actions](https://docs.github.com/en/actions) for pipeline
- AWS for back-end infra (RDS, Lambda etc)
- (TBA) Vercel[https://vercel.com/dashboard] for front-end hosting and CDN
- (TBA) [Playwright](https://playwright.dev/) for testing. Running in a per-pipeline instance for the relevant infra.

### Setup:

