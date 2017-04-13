job "http-echo" {
  datacenters = ["dc1"]

  update {
    stagger      = "5s"
    max_parallel = 1
  }

  group "http-echo" {
    count = 10

    task "http-echo" {
      driver = "exec"

      config {
        command = "http-echo"

        args = [
          "-text",
          "hello world",
          "-listen",
          ":${NOMAD_PORT_http}",
        ]
      }

      artifact {
        source = "https://github.com/hashicorp/http-echo/releases/download/v0.2.1/http-echo_0.2.1_linux_amd64.tgz"

        options {
          checksum = "sha256:3cf1689e3cf3f1dc92386b934ab2af7616377435d2fdc20df6ce22590afb3fdf"
        }
      }

      resources {
        network {
          port "http" {}
        }
      }

      service {
        name = "http-echo"
        port = "http"

        check {
          type     = "tcp"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
