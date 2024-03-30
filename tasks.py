from invoke import task


@task
def dev(c):
    c.run("docker compose up", pty=True)


@task
def up(c):
    c.run("docker compose up -d", pty=True)


@task
def down(c):
    c.run("docker compose down", pty=True)


@task(down)
def build(c):
    c.run("docker compose build", pty=True)


@task(up)
def migrate(c):
    c.run(
        "docker compose exec -it web python manage.py migrate",
        pty=True,
    )


@task(up)
def makemigrate(c):
    c.run(
        "docker compose exec -it web python manage.py makemigrations",
        pty=True,
    )


@task(pre=[migrate], post=[down])
def init(c):
    c.run(
        "docker compose exec -it web python manage.py createsuperuser",
        pty=True,
    )
