# What?
  We need a postfacto automation process that will deploy postfacto and it's prerequisites: postgres and redis.
# Why?
  To have an idempotent infrastructure.
# How?
  We implemented a pipeline that would be able to create both the prerequisite services (postgres and redis) and then deploy the postfacto.

1. Since we need a specific ruby buildpack version and github is NOT accessible from the PCFHub infrastructure, we are creating our own Docker image containing all the postfacto dependencies.
2. After creating this image, we are uploading it to the harbor and use it to create a tarball that we are storing on S3.
3. At the time of deployment, we get the tarball as a concourse resource along with this postfacto deployment code and the rootfs image that contains all the packages required to deploy the application
4. We are creating CF services for postgres and redis (WIP).
5. There is also a job for deleting the postfacto application which will also remove the postgres and redis services (WIP)

# you could build your postfacto docker image by running the following in the postfacto-deployment root folder:
docker build --no-cache -t favoriteHarborRegistryHERE:v1 .
