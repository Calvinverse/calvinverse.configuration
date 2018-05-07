# Configure

## Health

* Create the `vhost.health` vhost
  * Name: `vhost.health`
* Create the `user.health` user
  * User name: `user.health`
  * Password: health
  * Tags: Management
* Grant `user.health` user access to the `vhost.health` vhost
  * read: '.*'
  * write: '.*'
  * configure: '.*'

## Logs

* Create the `vhost.logs` vhost
  * Name: `vhost.logs`
* Create the `syslog` queue
  * Name: `syslog`
  * Durability: `Durable`
  * Auto delete: `no`


## Builds

* Create the `vhost.builds` vhost
  * Name: `vhost.builds`
* Create the `builds` queue
  * Name: `builds`
  * Durability: `Durable`
  * Auto delete: `no`

## Metrics

* Create the `user.metrics` user
  * Name: `user.metrics`
  * Password: `metrics`
  * Tags: Monitoring
* Grant `user.metrics` user access to all the vhosts
  * read: '.*'
  * write: ''
  * configure: ''

## Vault

* Create a `user.vault` user which will be used by vault to create users and queues etc.
  * Name: `user.vault`
  * Password: Generate one ...
  * Tags: Administrator
* Grant `user.vault` access to the `logs` and the `builds` vhosts
