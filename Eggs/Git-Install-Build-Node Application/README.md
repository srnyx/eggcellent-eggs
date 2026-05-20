# Git-Node Application

This egg will clone a Git repository, install dependencies, optionally build the app, and then start it as a Node website

## Variables

- **Build Trigger:** When should the application be rebuilt on startup?
  - **Never:** Never rebuild the application
  - **Git changes detected:** Rebuild the application if changes are detected when pulling from git
  - **Always:** Always rebuild the application
- **Package Manager:** The package manager used to install dependencies and run scripts
- **Build Script:** The build script to run with package manager. Leave empty to never try building
- **Start Script:** The start script to run with package manager
- **Clone On Install:** Whether to clone the repository on install or not
- **Pull On Start:** Pull the latest files from git on startup
- **Git Repo Address:** Git repository to clone/pull (example: https://github.com/srnyx/srnyx-bot)
- **Git Repo Branch:** The branch of the application to install from git. Leave empty for default
- **Git Username:** Username to auth with git
- **Git Access Token:** Access token to use with git
  - **GitHub:** https://github.com/settings/tokens
  - **GitLab:** https://gitlab.com/-/profile/personal_access_tokens
