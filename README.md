# Kanban Dashboard — Jenkins CI/CD on AWS

A Kanban Dashboard application deployed using Docker, Docker Hub, Jenkins CI/CD, and AWS EC2.

## 🚀 Project Overview

This project demonstrates an end-to-end CI/CD pipeline:

GitHub → Jenkins → Docker → Docker Hub → AWS EC2 → Live Application

A code push to the GitHub `main` branch automatically triggers Jenkins through a GitHub webhook. Jenkins builds and validates the application, creates a Docker image, pushes the versioned image to Docker Hub, deploys it on AWS EC2, and performs a container health check.

---

## 🏗️ Architecture

```text
Developer
    |
    | git push
    v
 GitHub
    |
    | Webhook
    v
 Jenkins
    |
    +--> Checkout
    |
    +--> Lint
    |
    +--> Docker Build
    |
    +--> Docker Hub Login
    |
    +--> Push Docker Image
    |
    +--> Deploy to EC2
    |
    +--> Health Check
    |
    v
 AWS EC2
    |
    v
 Docker Container
    |
    v
 Kanban Dashboard