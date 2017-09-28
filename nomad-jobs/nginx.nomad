job "nginx" {
  datacenters = ["dc1"]
  group "nginx" {
    count = 1
    task "nginx" {
      driver = "docker"
      config {
        image = "nginx:alpine"
        command = "nginx"
        args = [
          "-v",
          "/some/content:/usr/share/nginx/html:ro",
          "-d",
          "nginx",
        ]
      }
      resources {
        network {
          port "http" {}
        }
      }
    }
  }
}
