# Jobs Template

## For Beginners and Basic Projects

This is a template project for when you need something that runs background jobs. It's designed to be fairly lean. It uses pretty well-documented tools that have sane defaults.

* It uses `htmx` and `bottle` (1 file dependencies that are easily managed)
* It has basic templates in place, with the default view showing basic job info
* It is based on `alpine` containers for reasonably low overhead
* The default config uses `uv` so it's fairly fast
* It uses `loguru` for 0-config logging to the container, so `docker logs -f web` will show your messages


The project makes the following assumptions about the user:
  * You're deploying using `docker compose` (or running docker containers manually)
  * You're fine with using Redis as a job queue
  * [RQ](https://python-rq.org/docs/) is sufficient for your needs for running jobs
  * [rq-dashboard](https://python-rq.org/docs/monitoring/) is useful to you for debugging job data in development
  * [Bottle](https://bottlepy.org/docs/dev/tutorial.html) is sufficient as a web framework
  * You're using `uv` (default) or `pip` (check comments) for package management
    * `pip` has a slight advantage in that it can compile wheels for arm on alpine (libmusl compatibility)
    * `uv` can't do that yet, but it may come eventually. Switch to a non-alpine container for arm compilation compatibility.
  * You're fine with using the latest python version (13 at time of writing) in an alpine container
    * This is easy enough to change by changing which container you use and changing `.python-version` and running `uv sync`
  * You have your task in a separate module that you can import and define in `tools.py` or directly in `server.py`
  * You like `loguru` for simple and quick logging

## Caveats

**All of this is, ultimately, subjective.** If you're more opinionated, feel free to use this as a template with your own choice of tools instead.

Additionally, this is meant to run on your localhost or internal homelab - I run mine with the only access available via WireGuard/NetMaker. It doesn't have any real security considerations at the moment! It's _certainly_ nowhere in the same timezone as "considerable for production."
I make no claims as to reliability, and I am not liable for anything that may (and likely will) go wrong.

## Code

### Web Framework: Bottle

[Bottle](https://bottlepy.org/docs/dev/tutorial.html) is a lean and fairly lightweight web framework for python that's mostly familiar performant for small projects. It eschews scalability for simplicity, which is fine for small, personal tools and prototypes.

The core logic and routes are in [`server.py`](https://github.com/debitkarma/jobs_template/blob/main/server.py), where you can specify what to do with the submitted data and which function to call for queuing up a background job.

The main page template is in [templates/template.tpl](https://github.com/debitkarma/jobs_template/blob/main/templates/template.tpl), and here you'll find the basic `htmx` post request to submit job(s) and the polling of specific end points to show the job data.

Other templates in [templates/](https://github.com/debitkarma/jobs_template/blob/main/templates/) are there to show the info of each job as it gets sorted into these discrete statuses:
  * **submitted** - individual jobs that were submitted and read from the post request
  * **running** - the currently running job(s)
  * **queued** - jobs waiting in a queue for proecessing
  * **completed** - finished jobs and their returned statuses
  * **failed** - failed jobs and their exceptions

The main application can be found (by default) on [localhost, port 8080](http://localhost:8080/).

### Jobs

Jobs leverage [`rq`'s jobs system](https://python-rq.org/docs/jobs/). This uses redis on the back-end for the actual queue.

If you have logic you need to create, import whatever you need into `tools.py` and build your functions there. You can test them individually by running this module and providing logic at the bottom, in python's famous `if __name__ == "__main__":` block.

Once this is figured out, you can then import those functions in `server.py`, and then change `insert_function` with your import. You can specify a job_id manually by changing the `job_id=None` to be a unique identifier of some kind. Be careful, though, as improper formatting can cause the job to just not enqueue. If you submit jobs and nothing happens, this is something to check. The default of `None` will cause `rq` to auto-assign a UUID-esque id which should not fail.

### Job Debugging

To help debug your jobs, `rq-dashboard` is running in its own container as part of the `docker-compose.yml` configuration, by default on[localhost, port 9181](http://localhost:9181/)

### Using Developer Dependencies

You can specify a local install of a package as a developer dependency in `uv`.

## Docker Image and Containers

### Docker Compose During Development

**Build and Run**

This is designed to be run via `docker compose` commands.

For development:
```
docker compose build web
docker compose up --watch
```

You can use [docker compose's watch ability](https://docs.docker.com/compose/how-tos/file-watch/) during development to rebuild the container. By default, it's set to watch the `uv.lock` file (or `requirements.txt` for pip users), so it will only rebuild when the dependencies change.

It does, however, sync files in the root directory of the repo to the `/app/` folder inside the container. `Bottle` is set to hot-reload on changes as well.

### Docker Compose and Docker Build

**Deploy**

To deploy, there are comments in the `Dockerfile` on suggestions of changes for deployments, particularly if you're using a private repo as a dependency.

Your final build command for deployment is likely similar to:
`docker build --no-cache -t image-name:version -t image-name:latest . --build-arg GIT_PAT=git_pat_token_for_private_repo`

You can copy the local image around without uploading it to a registry if you need.

To dump:
`docker save -o image_filename.tar image_name:tag`

To load:
`docker load -i image_filename.tar`

There are other considerations in the comments, especially if you are going to clean install a private dependency for deployment (instead of a sync with the local version during build/testing).

### Image Notes

This is designed to use the same image for both the `web` and `worker` containers. In some circumstances, you may want to create entirely separate containers for the web app and for the worker/task.

If you do so, the main thing to note is that you will want to separate out a new `Dockerfile` for the other image (and you can use `-f path/to/OtherDockerfile` in your docker commands), as well as install `rq` in the other container. You'll still want the worker container to run the `rq worker` command as listed in the default `docker-compose.yml`.

Your `web` image should have all the `enqueue()` calls and `registry` information for serving up jobs and their metadata, so you'll still need `rq` installed and imported in there.

You can run multiple worker containers and each with take the queued jobs as they do. Just copy the `worker` service block in `docker-compose.yml` and paste it, giving the new service and container new names. That's it!
