# Movie Picture Pipeline

You've been brought on as the DevOps resource for a development team that manages a web application that is a catalog of Movie Picture movies. They're in dire need of automating their development workflows in hopes of accelerating their release cycle. They'd like to use Github Actions to automate testing, building and deploying their applications to an existing Kubernetes cluster.

The team's project is comprised of 2 applications.

1. A frontend UI written in Typescript, using the React framework
2. A backend API written in Python using the Flask framework.

You'll find 2 folders, one named `frontend` and one named `backend`, where each application's source code is maintained. Your job is to use the team's [existing documentation](#frontend-development-notes) and create CI/CD pipelines to meet the teams' needs.

## Deliverables

### Frontend

1. A Continuous Integration workflow that:
   1. Runs on `pull_requests` against the `main` branch,only when code in the frontend application changes.
   2. Is able to be run on-demand (i.e. manually without needing to push code)
   3. Runs the following jobs in parallel:
      1. Runs a linting job that fails if the code doesn't adhere to eslint rules
      2. Runs a test job that fails if the test suite doesn't pass
   4. Runs a build job only if the lint and test jobs pass and successfully builds the application
2. A Continuous Deployment workflow that:
   1. Runs on `push` against the `main` branch, only when code in the frontend application changes.
   2. Is able to be run on-demand (i.e. manually without needing to push code)
   3. Runs the same lint/test jobs as the Continuous Integration workflow
   4. Runs a build job only when the lint and test jobs pass
      1. The built docker image should be tagged with the git sha
   5. Runs a deploy job that applies the Kubernetes manifests to the provided cluster.
      1. The manifest should deploy the newly created tagged image
      2. The tag applied to the image should be the git SHA of the commit that triggered the build

### Backend

1. A Continuous Integration workflow that:
   1. Runs on `pull_requests` against the `main` branch,only when code in the frontend application changes.
   2. Is able to be run on-demand (i.e. manually without needing to push code)
   3. Runs the following jobs in parallel:
      1. Runs a linting job that fails if the code doesn't adhere to eslint rules
      2. Runs a test job that fails if the test suite doesn't pass
   4. Runs a build job only if the lint and test jobs pass and successfully builds the application
2. A Continuous Deployment workflow that:
   1. Runs on `push` against the `main` branch, only when code in the frontend application changes.
   2. Is able to be run on-demand (i.e. manually without needing to push code)
   3. Runs the same lint/test jobs as the Continuous Integration workflow
   4. Runs a build job only when the lint and test jobs pass
      1. The built docker image should be tagged with the git sha
   5. Runs a deploy job that applies the Kubernetes manifests to the provided cluster.
      1. The manifest should deploy the newly created tagged image
      2. The tag applied to the image should be the git SHA of the commit that triggered the build


**⚠️ NOTE**
Once you begin work on Continuous Deployment, you'll need to first setup the AWS and Kubernetes environment. Follow [these instructions ](#setting-up-continuous-deployment-environment) only when you're ready to start testing your deployments.

## One-time setup instructions

The project assumes you'll be working in the Udacity workspace where all the necessary system dependencies are installed and setup, ready for use.
The following steps are required to be run only once to initialize and create your repository with all the files that you'll use for the project.
### Login
Launch the Udacity workspace and open the terminal in VSCode to start executing the following commands:
1. Start the login process with `gh`
```bash
gh auth login
```
   2. Select `Github.com`
   3. Select `HTTPS`
   4. Enter `Y` or just press **Enter** to authenticate with Github credentials
   5. Select **Login with a web browser**
   6. Highlight and copy the one-time code then press **Enter** to open the browser
   7. If VSCode pops-up with a warning, click **Open**
   8. Enter your Github credentials at the login page
      1. You may need to perform your 2FA step next
   9. Paste in the one-time code that was given on the CLI prompt and click **Continue**
      1. If you're prompted for authorizing access to any organizations, you don't have to do that. The `gh` cli for this course just needs to be able to create repos in your personal account.
   10. Click authorize to allow the Github CLI to access your repository information.
   11. You can close the Github window and go back to the Udacity workspace tab

### Configuration
Next you'll need to configure git to use your desired email.

If you already know what email you'd like to use, great! If you'd like to use the `noreply` email address that Github offers, follow [these instructions](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-email-preferences/setting-your-commit-email-address#setting-your-commit-email-address-on-github)

**Configure git with your email address**
```bash
git config --global user.email "YOUR_EMAIL"
```
   
Now we'll finish up by initializing the repository and using the `gh` command to push the files to a new repository under you Github account. The last command uses `udacity-build-cicd-project` as the repository name, but you can change this to be whatever you'd like that doesn't conflict with an existing repo name in your account.

**Initialize the workspace as a git repository**
```bash
git init
```
   
**Stage the workspace files for committing**
```bash
git add .
```
   
**Commit the workspace files**
```bash
git commit -m "initial"
```
   
**Create your public repository and push the initial changes (it needs to be public to allow Github Actions to run for free)**
```bash
gh repo create udacity-build-cicd-project --source=. --public --push
```

As you work on the project, you won't need to create or initialize the repo again. You'll just need to make changes to your workflows in the `.github/workflows` folder, and perform `git add .` `git commit` and `git push` commands to make the files available in your repository and view your actions in the Github Actions interface.


## Setting up Continuous Deployment environment

Only complete these steps once you've finished your Continuous Integration pipelines for the frontend and backend applications. This section is meant to create a Kubernetes environment for you to deploy the applications to and verify the deployment step.

First we need to prep the AWS account with the necessary infrastructure for deploying the frontend and backend applications. As the focus of this course is building the CI/CD pipelines, we won't be requiring you to setup all of the underlying AWS and Kubernetes infrastructure. This will be done for you with the provided Terraform and helper scripts. As there are costs associated with running this infrastucture, **REMEMBER** to destroy everything before stopping work. Everything can be recreated, and the pipeline work you'll be doing is all saved in this repository.

### Create AWS infrastructure with Terraform

1. Export your AWS credentials from the Cloud Gateway
2. Use the commands below to run the Terraform and type `yes` after reviewing the expected changes

```bash
cd setup/terraform
terraform apply
```

4. Take note of the Terraform outputs. You'll need these later as you work on the project. You can always retrieve these values later with this command

```bash
cd setup/terraform
terraform output
```

### Generate AWS access keys for Github Actions

1. Once everything is created, you'll need to generate AWS credentials for the IAM user account that Github Actions will use in order to interact with your AWS account.
2. Launch the Cloud Gateway and go to the IAM service.
3. Under users, you should only see the `github-action-user` user account
4. Click the account and go to `Security Credentials`
5. Under `Access keys`  select `Create access key`
6. Select `Application running outside AWS` and click `Next`, then `Create access key` to finish creating the keys
7. On the last page, make sure to copy/paste these keys for storing in Github Secrets
![image](https://user-images.githubusercontent.com/57732284/221991526-ec4af661-b200-48cd-9087-6f1b3b9820b3.png)

### Add Github Action user to Kubernetes

Now that the cluster and all AWS resources have been created, you'll need to add the `github-action-user` IAM user ARN to the Kubernetes configuration that will allow that user to execute `kubectl` commands against the cluster.

1. Run the `init.sh` helper script in the `setup` folder

```bash
cd setup
./init.sh
```

2. The script will download a tool, add the IAM user ARN to the authentication configuration, indicate a `Done` status, then it'll remove the tool

## Dependencies

We've provided the below list of dependencies to assist in the case you'd like to run any of the work locally. Local development issues, however, are not supported as we cannot control the environment as we can in the online workspace.

All of the tools below will be available in the workspace

* [docker](https://docs.docker.com/desktop/install/debian/) - Used to build the frontend and backend applications
* [kubectl](https://kubernetes.io/docs/tasks/tools/) - Used to apply the kubernetes manifests
* [pipenv](https://pipenv.pypa.io/en/latest/install/#pragmatic-installation-of-pipenv) - Used for mananging Python version and dependencies
* [nvm](https://github.com/nvm-sh/nvm#installing-and-updating) - Used for managing NodeJS versions
* [tfswitch](https://tfswitch.warrensbox.com/Install/) Used for managing Terraform versions
* [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/) Used for building the Kubernetes manifests dynamically in the CI environment
* [jq](https://stedolan.github.io/jq/download/) for parsing JSON more easily on the command line

## Frontend Development notes

### Running tests

While in the frontend directory, perform the following steps:

```bash
# Use correct NodeJS version
nvm use

# Install dependencies
npm ci

# Run the tests interactively. You'll need to press `a` to run the tests
npm test

# OR simulate running the tests in a CI environment
CI=true npm test


# Expected output
PASS src/components/__tests__/MovieList.test.js
PASS src/components/__tests__/App.test.js

Test Suites: 2 passed, 2 total
Tests:       3 passed, 3 total
Snapshots:   0 total
Time:        1.33 s
Ran all test suites.
```

To simulate a failure in the test coverage, which will be needed to ensure your CI/CD pipeline fails on bad tests, set the MOVIE_HEADING variable before the command like so:

```bash
FAIL_TEST=true CI=true npm test
```

As the test is expecting the heading to contain a certain value, we can simulate a failure by changing it with an inline or environment variable. If you use the environment variable, make sure to unset it when you're done testing

```bash
# Expect tests to fail with this set to anything except Movie List
export FAIL_TEST=true
CI=true npm test

# Expect tests to be passing again
unset MOVIE_HEADING
CI=true npm test
```

```bash
# Expected failure output
FAIL src/components/__tests__/App.test.js
  ● renders Movie List heading

    TestingLibraryElementError: Unable to find an element with the text: messed_up. This could be because the text is broken up by multiple elements. In this case, you can provide a function for your text matcher to make your matcher more flexible.

    Ignored nodes: comments, script, style
    <body>
      <div>
        <div>
          <h1>
            Movie List
          </h1>
          <ul />
        </div>
      </div>
    </body>

       8 | test('renders Movie List heading', () => {
       9 |   render(<App />);
    > 10 |   const linkElement = screen.getByText(movieHeading);
         |                              ^
      11 |   expect(linkElement).toBeInTheDocument();
      12 | });
      13 |

      at Object.getElementError (node_modules/@testing-library/react/node_modules/@testing-library/dom/dist/config.js:37:19)
      at allQuery (node_modules/@testing-library/react/node_modules/@testing-library/dom/dist/query-helpers.js:76:38)
      at query (node_modules/@testing-library/react/node_modules/@testing-library/dom/dist/query-helpers.js:52:17)
      at getByText (node_modules/@testing-library/react/node_modules/@testing-library/dom/dist/query-helpers.js:95:19)
      at Object.<anonymous> (src/components/__tests__/App.test.js:10:30)

PASS src/components/__tests__/MovieList.test.js
```

### Running linter

When there are no linting errors, the output won't return any errors

```bash
npm run lint

# Expected output
> frontend@1.0.0 lint
> eslint .
```

To simulate linting errors, you can run the linting command like so:

```bash
FAIL_LINT=true npm run lint

# Expected output
> frontend@1.0.0 lint
> eslint .


/home/kirby/udacity/ci-cd/project/solution/frontend/src/components/MovieDetails.js
  4:24  error  'movie' is missing in props validation     react/prop-types
  7:70  error  'movie.id' is missing in props validation  react/prop-types

✖ 2 problems (2 errors, 0 warnings)
```

### Build and run

For local development without docker, the developers use the following commands:

```bash
cd starter/frontend

# Install dependencies
npm ci

# Run local development server with hot reloading and point to the backend default
REACT_APP_MOVIE_API_URL=http://localhost:5000 npm start
```

To build the frontend application for a production deployment, they use the following commands:

```bash
# Build the image
# NOTE: Make sure the image is built with the URL of the backend system.
# The URL below would be the default backend URL when running locally
docker build --build-arg=REACT_APP_MOVIE_API_URL=http://localhost:5000 --tag=mp-frontend:latest .

docker run --name mp-frontend -p 3000:3000 -d mp-frontend]

# Open the browser to localhost:3000 and you should see the list of movies,
# provided the backend is already running and available on localhost:5000
```

### Deploy Kubernetes manifests

In order to build the Kubernetes manifests correctly, the team uses `kustomize` in the following way:

```bash
cd starter/frontend/k8s
# Make sure you're kubeconfig is configured for the EKS cluster, i.e.
# aws eks update-kubeconfig

# Set the image tag to the newer version
# ℹ️ Don't commit any changes to the manifests that this command introduces
kustomize edit set image frontend=<ECR_REPO_URL>:<NEW_TAG_HERE>

# Apply the manifests to the cluster
kustomize build | kubectl apply -f -
```

## Backend Development notes

### Running tests

While in the backend directory, perform the following steps:

```bash
# Install dependencies
pipenv install

# Run the tests
pipenv run test

# Expected output
================================================================== test session starts ==================================================================
platform linux -- Python 3.10.6, pytest-7.2.1, pluggy-1.0.0 -- /home/kirby/.local/share/virtualenvs/backend-AXGg_iGk/bin/python
cachedir: .pytest_cache
rootdir: /home/kirby/udacity/cd12354-build-ci-cd-pipelines-monitoring-and-logging/project/solution/backend
collected 3 items

test_app.py::test_movies_endpoint_returns_200 PASSED                                                                                              [ 33%]
test_app.py::test_movies_endpoint_returns_json PASSED                                                                                             [ 66%]
test_app.py::test_movies_endpoint_returns_valid_data PASSED                                                                                       [100%]
```

To simulate failing the backend tests, run the following command:

```bash
FAIL_TEST=true pipenv run test

# Expected output
==================================================================== test session starts ====================================================================
platform linux -- Python 3.10.6, pytest-7.2.1, pluggy-1.0.0 -- /home/kirby/.local/share/virtualenvs/backend-AXGg_iGk/bin/python
cachedir: .pytest_cache
rootdir: /home/kirby/udacity/ci-cd/project/solution/backend
collected 3 items

test_app.py::test_movies_endpoint_returns_200 FAILED                                                                                                  [ 33%]
test_app.py::test_movies_endpoint_returns_json PASSED                                                                                                 [ 66%]
test_app.py::test_movies_endpoint_returns_valid_data PASSED                                                                                           [100%]

========================================================================= FAILURES ==========================================================================
_____________________________________________________________ test_movies_endpoint_returns_200 ______________________________________________________________

    def test_movies_endpoint_returns_200():
        with app.test_client() as client:
            status_code = os.getenv("FAIL_TEST", 200)
            response = client.get("/movies/")
>           assert response.status_code == status_code
E           AssertionError: assert 200 == 'true'
E            +  where 200 = <WrapperTestResponse streamed [200 OK]>.status_code

test_app.py:9: AssertionError
================================================================== short test summary info ==================================================================
FAILED test_app.py::test_movies_endpoint_returns_200 - AssertionError: assert 200 == 'true'
================================================================ 1 failed, 2 passed in 0.11s ================================================================
```

### Running linter

When there are no linting errors, there won't be any output.

```bash
pipenv run lint
# No output
```

To simulate linting errors, you can run the linting command below. The command overrides our lint configuration and will error if any lines are over 88 characters.

```bash
pipenv run lint-fail

# Expected output
./movies/__init__.py:7:89: E501 line too long (120 > 88 characters)
./movies/__init__.py:9:89: E501 line too long (101 > 88 characters)
./movies/movies_api.py:7:89: E501 line too long (120 > 88 characters)
./movies/movies_api.py:9:89: E501 line too long (101 > 88 characters)
./movies/resources.py:16:89: E501 line too long (117 > 88 characters)
```

### Build and run

For local development without docker, the developers use the following commands to build and run the backend application:

```bash
cd starter/backend

# Install dependencies
pipenv install

# Run application
pipenv run serve
```

For production deployments, the team uses the following commands to build and run the Docker image.

```bash
cd starter/backend

# Build the image
docker build --tag mp-backend:latest .

# Run the image
docker run -p 5000:5000 --name mp-backend -d mp-backend

# Check the running application
curl http://localhost:5000/movies

# Review logs
docker logs -f mp-backend

# Expected output
{"movies":[{"id":"123","title":"Top Gun: Maverick"},{"id":"456","title":"Sonic the Hedgehog"},{"id":"789","title":"A Quiet Place"}]}

# Stop the application
docker stop
```

### Deploy Kubernetes manifests

In order to build the Kubernetes manifests correctly, the team uses `kustomize` in the following way:

```bash
cd starter/backend/k8s
# Make sure you're kubeconfig is configured for the EKS cluster, i.e.
# aws eks update-kubeconfig

# Set the image tag to the newer version
# ℹ️ Don't commit any changes to the manifests that this command introduces
kustomize edit set image backend=<ECR_REPO_URL>:<NEW_TAG_HERE>

# Apply the manifests to the cluster
kustomize build | kubectl apply -f -
```

## License

[License](LICENSE.md)
