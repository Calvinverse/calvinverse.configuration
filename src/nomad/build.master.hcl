# This declares a job named "docs". There can be exactly one
# job declaration per job file.
job "build.master" {
  constraint {
      attribute = "${attr.kernel.name}"
      value     = "linux"
  }

  # Specify this job should run in the region named "us". Regions
  # are defined by the Nomad servers' configuration.
  region = "calvinverse"

  # Spread the tasks in this job between us-west-1 and us-east-1.
  datacenters = ["calvinverse-01"]

  # Run this job as a "service" type. Each job type has different
  # properties. See the documentation below for more examples.
  type = "service"

  # A group defines a series of tasks that should be co-located
  # on the same client (host). All tasks within a group will be
  # placed on the same host.
  group "build" {
    # Specify the number of these tasks we want.
    count = 1

    # Create an individual task (unit of work). This particular
    # task utilizes a Docker container to front a web application.
    task "master" {
      # Specify the driver to be "docker". Nomad supports
      # multiple drivers.
      driver = "docker"

      # Configuration is specific to each driver.
      config {
        image = "read-qa-docker.artefacts.service.consulverse:5010/calvinverse/resource.build.master:0.1.0"
        auth {
          username = "nomad.container.pull"
          password = "nomad.container.pull"
        }
        network_mode = "docker_macvlan"
        force_pull = true
      }

      # It is possible to set environment variables which will be
      # available to the job when it runs.
      env {
          "CONSUL_BIND_INTERFACE" = "eth0"
          "CONSUL_DATACENTER_NAME" = "calvinverse-01"
          "CONSUL_DOMAIN_NAME" = "consulverse"
          "CONSUL_SERVER_IPS" = "192.168.2.11"
          "CONSUL_ENCRYPT" = "n0LlbThdjJqROGokprQDpw=="
      }

      # Specify the maximum resources required to run the job,
      # include CPU, memory, and bandwidth.
      resources {
        cpu    = 1500 # MHz
        memory = 1024 # MB

        network {
          mbits = 250

          # This requests a dynamic port named "http". This will
          # be something like "46283", but we refer to it via the
          # label "http".
          # port "http" {}
        }
      }
    }
  }
}
