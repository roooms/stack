job "docker-http-echo" {
  datacenters = ["dc1"]

  group "http-echo" {
    task "server" {
      driver = "docker"

      config {
        image = "hashicorp/http-echo:0.2.3"
        args  = [
          "-listen", ":80",
          "-text", "hello world",
        ]
      }

      resources {
        network {
          mbits = 10
          port "http" {
            static = 80
          }
        }
      }

      service {
        name = "docker-http-echo"
        port = "http"

        check {
          type     = "http"
          path     = "/health"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
