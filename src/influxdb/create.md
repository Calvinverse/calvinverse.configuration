# Configure

## Users

* Create an admin user
  * `CREATE USER "admin" WITH PASSWORD '<CREATE_A_PASSWORD>' WITH ALL PRIVILEGES`

* Create an vault user
  * `CREATE USER "user.vault" WITH PASSWORD '<CREATE_A_PASSWORD>' WITH ALL PRIVILEGES`

* Create the `user.system.write` user
  * `CREATE USER "user.system.write" WITH PASSWORD '<CREATE_A_PASSWORD>'`
  * `GRANT WRITE ON "system" TO "user.system.write"`

* Create the `user.services.write` user
  * `CREATE USER "user.services.write" WITH PASSWORD '<CREATE_A_PASSWORD>'`
  * `GRANT WRITE ON "services" TO "user.services.write"`

* Create the `user.system.read` user
  * `CREATE USER "user.system.read" WITH PASSWORD '<CREATE_A_PASSWORD>'`
  * `GRANT READ ON "system" TO "user.system.read"`

* Create the `user.services.read` user
  * `CREATE USER "user.services.read" WITH PASSWORD '<CREATE_A_PASSWORD>'`
  * `GRANT READ ON "services" TO "user.services.read"`
