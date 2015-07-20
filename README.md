# Rundeck for CI only

Sets up a Rundeck instance with a pre-setup database and a simple test project with job(s) loaded from `JOB_LOCATION`.

This instance also hosts a MySQL instance, currently there is no way to specify a link to a MySQL container.

The instance is mostly intended for API based access, so there's no guarantee that the web UI works nicely. Rundeck often likes to use an absolute URL to redirect to, so you'll probably find it redirecting to localhost - you'll have to (re-)enter Rundeck's IP/hostname to make it work. Sorry.

# Environment variables

Ones you might want to change:
 - `SERVER_URL`: the user-facing URL that Rundeck will be on, default: http://0.0.0.0:4440 (this is vital as Rundeck 'conveniently' uses it for lots of pages)
 - `RUNDECK_APITOKEN`: API token to auto-enable. Note, this will have admin access, default: pFLdEn0FVkIIdTHvpbu19Wq3XttqfAj3
 - `JOB_LOCATION`: File to use to auto-import a set of jobs into the test project, default: /tmp/noop_rundeck_job.yml
 - `RUNDECK_VERSION`: version of Rundeck to install, default: 2.3.2-1-GA

 Ones you probably won't want to change:
 - `INIT_WAITTIME_IN_S`: Time to wait for Rundeck to come up prior to setting up the database, default: 240
 - `RUNDECK_PASSWORD`: Rundeck DB user password, default: auto-generated password
 - `DEBIAN_SYS_MAINT_PASSWORD`: Password for the 'debian system maintenance' user, default: auto-generated password
 - `DEBIAN_FRONTEND`: For APT, probably not needed, don't change, default: noninteractive
