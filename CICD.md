# CI/CD Pipeline

Automated lint / test / build / deploy for the two Movie Picture applications, implemented with
GitHub Actions in [`.github/workflows/`](.github/workflows/).

## Workflows

| File | Workflow name | Trigger | Jobs |
|---|---|---|---|
| `frontend-ci.yaml` | Frontend Continuous Integration | PR to `main` touching `starter/frontend/**`, or manual | lint ∥ test → build |
| `frontend-cd.yaml` | Frontend Continuous Deployment | push to `main` touching `starter/frontend/**`, or manual | lint ∥ test → build+push → deploy |
| `backend-ci.yaml` | Backend Continuous Integration | PR to `main` touching `starter/backend/**`, or manual | lint ∥ test → build |
| `backend-cd.yaml` | Backend Continuous Deployment | push to `main` touching `starter/backend/**`, or manual | lint ∥ test → build+push → deploy |
| `notify-failure.yaml` | Notify Failure | called by the four above | failure report + tracking issue |

`lint` and `test` declare no `needs`, so they run **in parallel**; `build` declares
`needs: [lint, test]`, so it only starts once both are green. Every workflow also has
`workflow_dispatch`, so any of them can be run on demand from the Actions tab.

```
lint ─┐
      ├─> build ─(CD only)─> deploy ─┐
test ─┘                              ├─> notify  (if: failure())
```

## What each stage does

**Lint** — `npm run lint` (ESLint) for the frontend, `pipenv run lint` (flake8) for the backend.

**Test** — `CI=true npm run test` (Jest, 3 tests) for the frontend, `pipenv run test` (pytest,
3 tests) for the backend.

**Build** — builds the actual `Dockerfile`, so a broken Dockerfile is caught on the pull request
rather than during a deployment. The frontend build passes `REACT_APP_MOVIE_API_URL` as a
`--build-arg`, sourced from an environment variable rather than hardcoded in the command. On CD the
image is tagged with the triggering commit's git SHA, pushed to ECR, and then confirmed present with
`aws ecr describe-images`.

**Deploy** (CD only) — `kustomize edit set image <app>=<ecr-url>:<git-sha>`, then
`kustomize build | kubectl apply -f -` against the EKS cluster, then `kubectl rollout status`,
then `kubectl get deployment/pods/service`. The manifest edits happen in the ephemeral runner
checkout and are never committed back.

Dependency caching uses an explicit `actions/cache@v4` step in every lint, test and frontend build
job — `~/.npm` keyed on `package-lock.json`, `~/.cache/pip` keyed on `Pipfile.lock`.

## One-time setup

1. **Create the infrastructure**
   ```bash
   cd setup/terraform && terraform init && terraform apply
   terraform output
   ```
2. **Create access keys** for the `github-action-user` IAM user (IAM console → Users →
   `github-action-user` → Security credentials → Create access key → *Application running outside AWS*).
3. **Add repository secrets** under *Settings → Secrets and variables → Actions*.

   Required:

   | Secret | Value |
   |---|---|
   | `AWS_ACCESS_KEY_ID` | from step 2 |
   | `AWS_SECRET_ACCESS_KEY` | from step 2 |

   Optional — each already defaults to the value the Terraform in `setup/terraform` creates, so set
   one only if you changed the Terraform or want to override:

   | Secret | Default | Source |
   |---|---|---|
   | `AWS_REGION` | `us-east-1` | `setup/terraform/versions.tf` |
   | `EKS_CLUSTER_NAME` | `cluster` | `aws_eks_cluster.main` |
   | `ECR_FRONTEND_REPO` | `frontend` | `aws_ecr_repository.frontend` |
   | `ECR_BACKEND_REPO` | `backend` | `aws_ecr_repository.backend` |
   | `REACT_APP_MOVIE_API_URL` | auto-discovered from the `backend` Service | see below |

   The ECR registry host is taken from the `aws-actions/amazon-ecr-login` output, so it never needs
   to be configured.

4. **Grant that user access to the cluster** — without this every deploy fails with
   `error: You must be logged in to the server (Unauthorized)`:
   ```bash
   aws eks update-kubeconfig --name cluster --region us-east-1
   cd setup && ./init.sh
   kubectl get configmap aws-auth -n kube-system
   kubectl get nodes
   ```

Failure notifications need no secret — they use the built-in `GITHUB_TOKEN`.

## Deployment order matters

The frontend's API URL is baked into the bundle at **build** time (it is a Dockerfile `ARG`, not a
runtime env var). `frontend-cd.yaml` uses the `REACT_APP_MOVIE_API_URL` secret when it is set, and
otherwise reads the backend's LoadBalancer hostname off the cluster.

**Deploy the backend first.** If both run at once on a fresh cluster, re-run **Frontend Continuous
Deployment** from the Actions tab once the backend Service has an address.

## Verifying the deployment

Each CD run prints the deployed URL to its job summary. Or:

```bash
aws eks update-kubeconfig --name cluster --region us-east-1
kubectl get deployments
kubectl get pods
kubectl get services
```

**Backend:**

```bash
curl http://$(kubectl get svc backend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')/movies
```

Expected:

```json
{"movies":[{"id":"123","title":"Top Gun: Maverick"},{"id":"456","title":"Sonic the Hedgehog"},{"id":"789","title":"A Quiet Place"}]}
```

**Frontend:**

```bash
kubectl get svc frontend -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Open that hostname in a browser. Expected result:

> # Movie List
> - Top Gun: Maverick
> - Sonic the Hedgehog
> - A Quiet Place

Clicking a title reveals a **Movie Details** section. Three titles rendering means the frontend pod
is serving *and* successfully reaching the backend Service — the list is fetched from the API, not
hardcoded in the frontend.

**An empty list under the heading** means the image was built with the wrong API URL — check the
"Resolve the backend API URL" step in the Frontend CD build job, then re-run the workflow.

## Error handling

- Jobs fail fast: every multi-line step runs under `shell: bash` (`set -eo pipefail`).
- No `continue-on-error` anywhere, and no `|| true` on any required step.
- The build job verifies the AWS secrets exist — reading them through `env`, never interpolating
  them into the shell source — and exits with a readable message if they are missing.
- Frontend CD fails with an explicit message if the backend URL cannot be resolved, rather than
  silently shipping an image that renders an empty list.
- `aws ecr describe-images` confirms the pushed image really exists, rather than trusting the
  `docker push` exit code.
- `kubectl rollout status --timeout=180s` fails the deploy if pods don't become ready, and dumps
  pod status, `describe` output and container logs into the run before exiting.
- `concurrency` groups prevent two deployments racing onto the cluster (CD runs queue rather than
  cancel; CI runs cancel superseded PR pushes).
- On any failure, `notify-failure.yaml` writes a summary table to the run and — for `main` and
  manual runs — opens a `ci-failure` issue with the commit, actor and a link to the run. Pull
  request failures are not filed as issues, since the PR already shows a red check.

## Tearing down

```bash
cd setup/terraform && terraform destroy
```

The EKS cluster and the two LoadBalancers bill hourly, so destroy them when you stop working.

## Testing the failure paths

The applications have deliberate failure switches, useful for demonstrating that the pipeline
actually blocks bad code. Each must exit non-zero, which fails the job and — because `build`
declares `needs: [lint, test]` — leaves the build job skipped:

```bash
cd starter/frontend && FAIL_LINT=true npm run lint          # lint job fails
cd starter/frontend && FAIL_TEST=true CI=true npm run test  # test job fails
cd starter/backend  && pipenv run lint-fail                 # lint job fails
cd starter/backend  && FAIL_TEST=true pipenv run test       # test job fails
```

## Notes on the starter code

### `pipenv install` alone is not enough for linting

The backend development notes document `pipenv install` followed by `pipenv run lint`, but `flake8`
is declared under `[dev-packages]` in the Pipfile. With a plain `pipenv install` the lint command
fails:

```
/bin/sh: 1: flake8: not found      (exit 127)
```

The workflows therefore run **`pipenv install --dev`**. This uses the project's existing Pipfile —
only the dev dependency group is additionally installed.

### `starter/backend/Dockerfile` base image is pinned

Changed from `python:3.10-alpine` to `python:3.10-alpine3.17`.

`python:3.10-alpine` is a moving tag that now resolves to an Alpine release carrying GCC 15. Since
GCC 14, `-Werror=incompatible-pointer-types` is on by default, and `uwsgi` 2.0.x does not compile
under it:

```
core/master_utils.c:711:34: error: passing argument 2 of 'signal' from incompatible pointer type
ERROR: Failed building wheel for uwsgi
```

That failed `pipenv install --system --deploy`, so the image could not be built at all — on a
developer machine or in the build job. Pinning the tag restores a toolchain the pinned dependency
set compiles against, and makes the build reproducible rather than dependent on when it runs.

### Note for Windows developers

This repository stores text files with LF endings and has no `.gitattributes`. With
`core.autocrlf=true` (the Windows default) the working copy gets CRLF, and `npm run lint` then
reports `Delete ␍ prettier/prettier` on every line of every file. CI is unaffected — GitHub's Linux
runners check out LF. To lint locally on Windows, either set `git config core.autocrlf input` and
re-clone, or add a `.gitattributes` containing `* text=auto eol=lf`.

### `setup/terraform/terraform.tfstate` is tracked by git

It ships from the upstream Udacity repository and is currently empty. Once you run
`terraform apply` it will contain your live infrastructure details. Either keep it out of commits or
add it to `.gitignore` before committing — `.gitignore` currently covers `*.tfstate.backup` but not
`terraform.tfstate` itself.
