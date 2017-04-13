job "traefik" {
  datacenters = ["dc1"]
  type        = "system"

  update {
    stagger      = "5s"
    max_parallel = 1
  }

  group "traefik" {
    task "traefik" {
      driver = "exec"

      config {
        command = "traefik"
        args    = ["--consul"]
      }

      artifact {
        source = "https://github.com/containous/traefik/releases/download/v1.2.2/traefik"

        options {
          checksum = "sha256:b82a53261f60c6de2cac84a82af332e69ce27e56c86c88b68173032316eee427"
        }
      }

      service {
        name = "consul-ui"
        port = "consul_ui"

        check {
          type     = "tcp"
          port     = "consul_ui"
          interval = "10s"
          timeout  = "2s"
        }
      }

      service {
        name = "traefik-ui"
        port = "traefik_ui"

        check {
          type     = "tcp"
          port     = "traefik_ui"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 500
        memory = 64

        network {
          mbits = 1

          port "consul_ui" {
            static = 8080
          }

          port "traefik_ui" {
            static = 8081
          }
        }
      }
    }
  }
}
