# What?
  We need a postfacto automation process that will deploy postfacto and it's prerequisites: PostgresSQL and Redis.
# Why?
  To have an idempotent infrastructure.
# How?
  We implemented a pipeline that would be able to create both the prerequisite services (postgres and redis) and then deploy the postfacto.

1. Since we need a specific ruby buildpack version and github is NOT accessible from the PCFHub infrastructure, we are creating our own Docker image containing all the postfacto dependencies.
   ```docker build --no-cache -t <favoriteHarborRegistryHERE>:<image-tag> .```
2. After creating this image, we are uploading it to the harbor and use it as a base to create a postfacto tarball that we are storing on S3.
   In order to upload the image we need to login into Harbor Registry using ```docker login```
   After that we are pushing the image using ```docker push <imange-name>:<image-tag>```
3. We are using semver resource when we are deploying the tarball to S3 in order to have versioning on the tarball itself.
4. At the time of deployment, we get the tarball as a concourse resource along with this postfacto deployment code and the rootfs image that contains all the packages required to deploy the application
5. We are creating CF services for postgres and redis (WIP).
6. There is also a job for deleting the postfacto application which will also remove the postgres and redis services (WIP)
