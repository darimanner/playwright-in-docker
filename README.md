# Python Playwright with MetaMask and GUI using in Docker container

This project sets up Python Playwright with MetaMask using a GUI application in Docker container. The goal is to make it easy to start and run the application in a containerized environment, add GUI usage in Docker container, and make it possible to run the application on all platforms.

The test application in this repository, loads the MetaMask extension, creates a new wallet, displays the seed phrase of this wallet in the terminal and adds a test network (Polygon zkEVM Cardona Testnet) to the wallet.

## Files structure
- **Dockerfile**: The Dockerfile used to build the image for this application.
- **docker-compose.yml**: The Docker Compose file that defines the services and how they interact in the container.
- **start.sh**: A shell script to simplify the process of running the application and container environment.
- **README.md**: This file that explains how to set up and run the project.
- **/ubuntu-vnc**: Docker image with Ubuntu 24 and VNC. Default VNC port is 5900, you can change this port in Dockerfile.

## Usage

**Step 1:** Setting up your application

- Environments
- Application settings
- Other things

**Step 2:** Setting up `start.sh` and Docker Compose.

You need to specify the name of the file to start, and the path to it (if it is not in the Dockerfile folder) in the `start.sh` file.
```bash
exec python src/main.py
```
Create `.env` from `.env-example` before the first run: Compose passes it to the container and reads `CHANNEL` from it to pick the browser installed in the image. Directories you need inside the container go under `volumes` in the Compose file.

**Step 3:** Run the Application Using Docker Compose.

```bash
docker compose up
```
If you don't have an image with name "_playwright-img_", it will be built automatically. Image size was around ~2 gigabytes. It depends on the size of your application.

**Important note!** If you update application files, Dockerfile or `start.sh`, you need to rebuild Docker application image (_does not apply to those directories and files that are mounted into an already prepared image using Docker Compose_).
```bash
docker compose up --build
```

## Troubleshooting

If you encounter issues, try:
- Ensure that Docker and Docker Compose are running properly.
- Check your application logs.
- Check Docker Compose logs.
```bash
docker compose logs -f
```
- Try to use Chromium channel instead of Chrome: set `CHANNEL=chromium` in `.env` and rebuild the image. Google Chrome has no Linux ARM64 build, so on Apple Silicon use Chromium (or add `platform: linux/amd64` to the service).
- Try HEADLESS=True.
- Try to rebuild image (or fully).
```bash
docker compose up --build
```
- Try to run your application in VNC container.

If application doesn't start, ensure that Docker and Docker Compose are running properly.

## Container details

### Dockerfile
Creating Docker image with Python 3.12 on `slim-bookworm`, with 2 stages. The 1st stage creates the virtual environment with Poetry from `poetry.lock`. The 2nd stage copies only that virtual environment (Poetry itself does not get into the final image), installs Xvfb and the browser selected by the `BROWSER` build arg (`chrome` or `chromium`, Compose fills it from `CHANNEL`).

### docker-compose.yml
Docker Compose makes it easier to launch an application. Compose builds the image, passes `.env` as environment variables and mounts the directories needed to run the application. `init: true` runs a tiny init as PID 1 so Chrome child processes are reaped and `docker compose stop` works without waiting for the timeout.

| Volume              | Description                                                      |
|---------------------|------------------------------------------------------------------|
| `/extension`        | The directory where MetaMask extension is stored.                |

### start.sh
This is a script that removes a stale Xvfb lock left by a previous run (the container is restarted with `restart: on-failure`), starts Xvfb on display `:99` and then replaces itself with `python src/main.py`, so stop signals go straight to the application.