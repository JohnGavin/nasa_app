# install.packages(c("gert", "gh"))

# Load libraries
library(gert)
library(gh)

repo_name <- "nasa_app"
# INPUT local directory
local_dir <- paste0(
  "~/docs_gh/", repo_name
)

# Initialize local Git repository
git_init(local_dir)

# Add all files to the repository
git_add(".", repo = local_dir)

# Commit the changes
git_commit("Initial commit", repo = local_dir)

# Authenticate with GitHub (you might need to set up a personal access token)
(gh_data <- gh::gh_whoami())
gh_username <- gh_data$login

# Create a new repository on GitHub
gh::gh("POST /user/repos", name = repo_name)

# Set the remote URL
(remote_url <- paste0("https://github.com/", gh_username, "/", repo_name, ".git"))
git_remote_add("origin", remote_url, repo = local_dir)
# git remote add origin https://github.com/johngavin/blogs.git


# Push the local repository to GitHub
git_push(remote = "origin", repo = local_dir)
