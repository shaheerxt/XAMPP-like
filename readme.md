# XAMPP-like Docker Environment

This project sets up a XAMPP-like environment using Docker, providing a web server with PHP, MariaDB, and phpMyAdmin. It's designed to offer a quick and easy way to set up a local development environment for PHP-based web applications.

## Components

1. **Web Server (Apache + PHP)**
2. **MariaDB**
3. **phpMyAdmin**

## Docker Compose Configuration

The `docker-compose.yml` file defines the following services:

### Web Service
- Built from the local Dockerfile
- Container name: `xampp_web`
- Volumes:
  - `./src:/var/www/html`: Mounts the local `src` directory to the container's web root
  - `./apache_config:/etc/apache2/sites-enabled`: Mounts local Apache configuration
- Port mapping: `8080:80` (Access the web server at `http://localhost:8080`)
- Depends on the `db` service

### MariaDB Service
- Uses MariaDB 11.2 image
- Container name: `xampp_mariadb`
- Environment variables set for root password, database, user, and user password
- Persistent volume for database data: `./mysql_data:/var/lib/mysql`
- Port mapping: `3306:3306` (Access MariaDB at `localhost:3306`)

### phpMyAdmin Service
- Uses the official phpMyAdmin image
- Container name: `xampp_phpmyadmin`
- Configured to connect to the MariaDB service (`PMA_HOST: db`)
- Port mapping: `8081:80` (Access phpMyAdmin at `http://localhost:8081`)
- Depends on the `db` service

## Dockerfile Details

The Dockerfile sets up the PHP environment with Apache. Here are the key features:

- Based on `php:7.4-apache` image
- Installs Apache 2.4.54 from Debian Bullseye repository
- Installs necessary dependencies and PHP extensions, including:
  - GD (with freetype, jpeg, xpm, and webp support)
  - MySQL/MariaDB support
  - cURL, ZIP, Intl, and many other common extensions
- Installs additional extensions via PECL:
  - Redis
  - ImageMagick
  - igbinary
- Enables Apache mod_rewrite
- Configures PHP OpCache for better performance
- Verifies installed PHP modules

## Usage

1. Clone this repository
2. Place your PHP application files in the `src` directory
3. Run `docker-compose up -d` to start the environment
4. Access your web application at `http://localhost:8080`
5. Access phpMyAdmin at `http://localhost:8081`

## Customization

- Modify the `docker-compose.yml` file to change port mappings, add services, or adjust environment variables
- Edit the Dockerfile to add or remove PHP extensions or change Apache configurations

## Notes

- The MariaDB data is persisted in the `./mysql_data` directory
- All services are connected through the `xampp_network` Docker network
- The `PMA_HOST` environment variable in the phpMyAdmin service is set to `db`, allowing phpMyAdmin to connect to the MariaDB service using its service name as the hostname
- The web service depends on the database service, ensuring the database is ready before the web server starts
- The Dockerfile includes a step to verify installed PHP modules, which can be helpful for debugging

This setup provides a flexible and portable development environment that closely mimics a traditional XAMPP stack, with the added benefits of containerization and easy configuration management.
