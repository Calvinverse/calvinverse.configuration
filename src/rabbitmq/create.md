# Configure

## Health

* Create the `health` vhost
  * Name: health
* Create the `health` user
  * User name: health
  * Password: health
  * Tags: Management
* Grant `health` user access to the `health` vhost
  * read: '.*'
  * write: '.*'
  * configure: '.*'

## Logs

* Create the `logs` vhost
  * Name: `logs`
* Create the `syslog` queue
  * Name: `syslog`
  * Durability: `Durable`
  * Auto delete: `no`


## Builds

* Create the `builds` vhost
  * Name: `builds`
* Create the `builds` queue
  * Name: `builds`
  * Durability: `Durable`
  * Auto delete: `no`

## Metrics

* Create the `metrics` user
  * Name: metrics
  * Password: metrics
  * Tags: Monitoring
* Grant `metrics` user access to all the vhosts
  * read: '.*'
  * write: ''
  * configure: ''

## Vault

* Create a `user.vault` user which will be used by vault to create users and queues etc.
  * Name: `user.vault`
  * Password: Generate one ...
  * Tags: Administrator
* Grant `user.vault` access to the `logs` and the `builds` vhosts
