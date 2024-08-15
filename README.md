# Template Repository

This repository intends to serve as a template for other repositories. It'll contain reusable files across multiple projects, e.g., docker-compose.yml file to create Synthesis and Simulation Images, and a primary CI Implementation pipeline.

## Pre-requisites:

### Install Docker & Docker Compose
Please go through the following link and install Docker in your local system: https://docs.docker.com/compose/install/

### Run
Execute the following script to run the main example using `docker-compose`

```shell
docker-compose up
```

### Next Steps:

For more reference related to development Tools, please read [GenAI Hardware Design Workflow Development Tools](https://docs.google.com/document/d/1N5Bh3639srsPZrac8migq8G5h7Zb9auUnG9DuTJsKcc).

Please go through the following list of videos to understand how to use this workflow for your own implementations
https://drive.google.com/drive/folders/1x-kZLWGxzdDlYSKwnE8PZms13K4a6NNy

### Debug on Windows

This repository contains another docker composer file, the `debug-windows.yml` file, which includes information on the debug service running on Windows machines.
The `\\wsl.localhost\Ubuntu<Version>` can change based on WSL instalations, so **it's possible that you need to change it**.

It’s recommended to directly open `\\wsl.localhost\` in the **File Explorer** and locate the necessary `/mnt/wlsg` folder inside your Linux Subsystem.
Then, you can map the correct location to the `debug-windows.yml` file by copying the folder directory path in the **File Explorer** window and mapping it at the corresponding Docker Volume.

Other than that, it's not necessary to open one WSL Terminal to run this docker compose `debug-windows.yml` file. You should run directly in one Windows Terminal:
```bash
docker-compose -f debug-windows.yml up debug
```
