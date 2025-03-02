from bottle import get, post, request, route, run, static_file, template, view
from loguru import logger
from os import path
from rq import Queue
from rq.registry import StartedJobRegistry, FailedJobRegistry, FinishedJobRegistry

from tools import insert_function

import redis

ROOT = path.abspath(path.dirname(__file__))
r = redis.Redis(host="redis", port=6379)
q = Queue(connection=r)
started_registry = StartedJobRegistry(queue=q)
failed_registry = FailedJobRegistry(queue=q)
finished_registry = FinishedJobRegistry(queue=q)


@route("/static/<filepath>")
def server_static(filepath):
    return static_file(filepath, root="./static/")
    # return static_file(filepath, root=path.join(ROOT, "static"))


@route("htmx.js")
def serve_htmx():
    return static_file("htmx.js", root="./static/")


@get("/")
@view("templates/template")
def new():
    pass


@post("/submit")
def submit():
    job_data = request.forms.get("job_data")
    submissions = job_data.split()
    if len(submissions) == 1:
        logger.debug(f"job submitted: {job_data = }")
        job = q.enqueue(
            insert_function,  # INSERT_FUNCTION_HERE
            job_id=None,
            kwargs={},
            job_timeout=600,  # 10min
            result_ttl=(60 * 60 * 24),  # 24h
            failure_ttl=(60 * 60 * 24),  # 24h
        )
        return f"Job submitted with ID: {job.id}"
    elif len(submissions) > 1:
        logger.debug(f"multiple jobs submitted, split request data: {submissions = }")
        for submission in submissions:
            logger.debug(f"queuing {submission = }")
            job = q.enqueue(
                insert_function,  # INSERT_FUNCTION_HERE
                job_id=None,
                kwargs={},
                job_timeout=600,  # 10min
                result_ttl=(60 * 60 * 24),  # 24h
                failure_ttl=(60 * 60 * 24),  # 24h
            )
            yield template("templates/submitted_item.tpl", id=job.id)


@route("/queued")
def queued():
    jobs = q.jobs
    return template(
        "templates/queued_items.tpl",
        jobs=jobs,
    )


@route("/completed")
def completed():
    registry = finished_registry
    job_ids = registry.get_job_ids()
    completed_jobs = [q.fetch_job(job_id) for job_id in job_ids]
    return template(
        "templates/completed_items.tpl",
        jobs=completed_jobs,
    )


@route("/failed")
def failed():
    registry = failed_registry
    job_ids = registry.get_job_ids()
    failed_jobs = [q.fetch_job(job_id) for job_id in job_ids]
    return template(
        "templates/failed_items.tpl",
        jobs=failed_jobs,
    )


@route("/running")
def running():
    registry = started_registry
    job_ids = registry.get_job_ids()
    running_jobs = [q.fetch_job(job_id) for job_id in job_ids]
    return template(
        "templates/running_items.tpl",
        jobs=running_jobs,
    )


if __name__ == "__main__":
    run(host="0.0.0.0", port=8080, debug=True, reloader=True)
