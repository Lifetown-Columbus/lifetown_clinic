# LifetownClinic
[blog describing docker build](https://blog.miguelcoba.com/deploying-a-phoenix-16-app-with-docker-and-elixir-releases)

build with `docker image build -t lifetown_clinic .`

migrate with `docker exec -it <container_id> bin/lifetown_clinic eval "LifetownClinic.Release.migrate"`


