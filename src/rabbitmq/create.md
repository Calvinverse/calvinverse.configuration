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
  * Name: logs

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

* Create a `vault_administrator` user which will be used by vault to create users and queues etc.
  * Name: `vault_administrator`
  * Password: Generate one ...
  * Tags: Administrator
* Grant `vault_administrator` access to the `logs` vhost
