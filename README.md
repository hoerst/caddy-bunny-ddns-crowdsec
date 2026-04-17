# Custom Caddy Docker Image (Bunny DNS + DDNS + CrowdSec)

This repository provides an automated build for a custom Caddy Docker image. The build process runs weekly via GitHub Actions and publishes the image to the GitHub Container Registry (GHCR).

## Integrated Modules
The image is compiled from the official `caddy:builder` using `xcaddy` and includes the following plugins:
* [caddy-dns/bunny](https://github.com/caddy-dns/bunny): DNS-01 challenge support for Bunny.net to automatically provision TLS certificates.
* [mholt/caddy-dynamicdns](https://github.com/mholt/caddy-dynamicdns): Dynamic DNS update capability directly within Caddy.
* [hslatman/caddy-crowdsec-bouncer/http](https://github.com/hslatman/caddy-crowdsec-bouncer): Integration of the CrowdSec Bouncer as a Caddy HTTP handler.

## Usage

### 1. Host Preparation
The `Caddyfile` must be created manually on the host system before starting the container to prevent the Docker daemon from creating a directory instead of a file.
```bash
mkdir -p /path/to/caddy/config
mkdir -p /path/to/caddy/data
touch /path/to/caddy/Caddyfile
````

### 2\. Docker Compose Configuration

The following `docker-compose.yml` serves as a standard deployment example.

```yaml
services:
  caddy:
    image: ghcr.io/<YOUR_GITHUB_USERNAME>/custom-caddy:latest
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /path/to/caddy/Caddyfile:/etc/caddy/Caddyfile
      - /path/to/caddy/data:/data
      - /path/to/caddy/config:/config
```

*The placeholder `<YOUR_GITHUB_USERNAME>` must be written entirely in lowercase.*

### 3\. Example Caddyfile

```caddyfile
{
    dynamic_dns {
        provider bunny <YOUR_BUNNY_API_KEY>
        domains {
            yourdomain.com @ sub
        }
    }
    
    crowdsec {
        api_url http://<CROWDSEC_HOST_IP>:<CROWDSEC_PORT>
        api_key <YOUR_CROWDSEC_BOUNCER_KEY>
    }
}

yourdomain.com {
    tls {
        dns bunny <YOUR_BUNNY_API_KEY>
    }
    crowdsec
    reverse_proxy <TARGET_IP>:<TARGET_PORT>
}
```

## Automated Updates

GitHub Actions rebuilds the image entirely from scratch (`no-cache: true`) every Sunday at 03:00 UTC to pull the latest module versions from their respective repositories. Automatic deployment of the updated image on the host system requires an external update tool, such as **Watchtower**, configured to monitor the running container and pull new image digests.

## License

This project is licensed under the [Apache License 2.0](https://www.google.com/search?q=LICENSE).

```
```
