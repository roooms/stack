job "go-http-echo" {
  datacenters = ["dc1"]

  update {
    stagger      = "5s"
    max_parallel = 1
  }

  group "http-echo" {
    count = 10

    task "server" {
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
        source = "https://github.com/hashicorp/http-echo/releases/download/v0.2.3/http-echo_0.2.3_linux_amd64.tar.gz"

        options {
          checksum = "sha256:e30b29b72ad5ec1f6dfc8dee0c2fcd162f47127f2251b99e47b9ae8af1d7b917"
        }
      }

      resources {
        network {
          port "http" {}
        }
      }

      service {
        name = "go-http-echo"
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
