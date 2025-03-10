# Git-Python Application

This egg will clone a Git repository, install requirements with PIP, and then run it with Python

## Variables

- **Clone On Install:** Whether to clone the repository on install or not
- **Pull On Start:** Pull the latest files from git on startup
- **Build Trigger:** When should the application be rebuilt on startup?
  - **Never:** Never rebuild the application
  - **Git changes detected:** Rebuild the application if changes are detected when pulling from git
  - **Always:** Always rebuild the application
- **Start File:** The file that starts the application (example: app\/main.py) OR the directory the file is in (example: app)
  - If a directory is provided, the egg will search for the start file in the directory and use the first one found
- **Git Repo Address:** Git repository to clone/pull (example: https://github.com/srnyx/srnyx-bot)
- **Git Repo Branch:** The branch of the application to install from git. Leave empty for default
- **Git Username:** Username to auth with git
- **Git Access Token:** Access token to use with git
  - **GitHub:** https://github.com/settings/tokens
  - **GitLab:** https://gitlab.com/-/profile/personal_access_tokens
