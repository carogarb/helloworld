# Repo para EU - DevOps&Cloud - UNIR

Este repositorio incluye un proyecto sencillo para demostrar los conceptos de pruebas unitarias, pruebas de servicio, uso de Wiremock y pruebas de rendimiento
El objetivo es que el alumno entienda estos conceptos, por lo que el código y la estructura del proyecto son especialmente sencillos.
Este proyecto sirve también como fuente de código para el pipeline de Jenkins.

## Phase 1:

### Create the docker image from Dockerfile:
```
docker build --tag carogarb/jenkins-python:latest .
```

### Execute the container exposing ports:
```
docker run -d -p 8090:8080 -p 50000:50000 -v jenkins-python-data:/var/jenkins_home --name jenkins-python carogarb/jenkins-python:latest
```

### To open a terminal into the running container, execute:
```
docker exec -it jenkins-python bash
```

### Jenkins is available on http://localhost:8090/
