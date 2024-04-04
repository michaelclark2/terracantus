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


@task
def ecr(c):
    c.run(
        "aws ecr get-login-password --region us-east-1 | docker login \
    --username AWS --password-stdin \
    227557930319.dkr.ecr.us-east-1.amazonaws.com"
    )


@task(ecr)
def deploy(c):
    c.run(
        "docker build -t 227557930319.dkr.ecr.us-east-1.amazonaws.com/webapp -f Dockerfile.prod ."
    )
    c.run("docker push 227557930319.dkr.ecr.us-east-1.amazonaws.com/webapp:latest")


@task
def prod(c):
    c.run(
        "aws ecs update-service --cluster webapp-cluster --service webapp-django --force-new-deployment"
    )


@task
def createsuperuser(c):
    c.run(
        "aws ecs run-task --overrides file://./infra/overrides-createsuperuser.json --task-definition webapp --cluster webapp-cluster --launch-type FARGATE --network-configuration file://./infra/awsvpc.json"
    )


@task
def updatenginx(c):
    with c.cd("infra/nginx"):
        c.run(
            "docker build -t 227557930319.dkr.ecr.us-east-1.amazonaws.com/nginx:latest ."
        )
        c.run("docker push 227557930319.dkr.ecr.us-east-1.amazonaws.com/nginx:latest")
