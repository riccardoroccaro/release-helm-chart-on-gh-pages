# *release-helm-chart-on-gh-pages* Action
A GitHub action aiming at releasing an helm chart on a user-selected branch configured with GitHub Pages.

## Usage

### Pre-requisites

1. A GitHub repo containing a directory with your Helm charts (eg: `/helm`)
1. A GitHub branch to store the published charts and configured to be used with GitHub Pages.
1. Create a workflow `.yml` file in your `.github/workflows` directory. An [example workflow](#example-workflow) is available below.
  For more information, reference the GitHub Help Documentation for [Creating a workflow file](https://help.github.com/en/articles/configuring-a-workflow#creating-a-workflow-file)

### Inputs
- `src-folder`: The folder containing the Chart.yaml file (default: `helm`)
- `dest-branch`: The name of the branch to store the published charts and configured to be used with GitHub Pages (default: `gh-pages`)
- `dest-folder`: The folder in `dest-branch` which will contain the packages and the index.yml file (default `.`)
- `repo-url`: The GitHub Pages URL to the charts repo (default: `https://<owner>.github.io/<project>`)

### Example Workflow

Create a workflow (eg: `.github/workflows/release_chart.yml`):

```yaml
name: ReleaseChart

# Controls when the action will run. 
on:
  # Triggers the workflow on push events for any branch except `dest-branch`
  push:
    branches:
      - '**'
      - '!gh-pages' # Replace <gh-pages> with the chosen dest-branch and leave the "!" char

# The workflow run is made up of one job
jobs:
  # This workflow contains a single job called "create-and-publish-repository"
  create-and-publish-repository:
    # The type of runner that the job will run on
    runs-on: ubuntu-latest

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0

      # Create the helm package and publish it on the dest-branch
      - uses: riccardoroccaro/release-helm-chart-on-gh-pages@v1
        with:
          src-folder: "helm" #DO NOT ADD '/' CHAR BEFORE THE FOLDER NAME, just after if needed
          dest-branch: "gh-pages"
          dest-folder: "." #DO NOT ADD '/' CHAR BEFORE THE FOLDER NAME, just after if needed
          repo-url: "riccardoroccaro.github.io/test-helm"
```
