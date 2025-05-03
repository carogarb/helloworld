# Repo para EU - DevOps&Cloud - UNIR

Este repositorio incluye un proyecto sencillo para demostrar los conceptos de pruebas unitarias, pruebas de servicio, uso de Wiremock y pruebas de rendimiento
El objetivo es que el alumno entienda estos conceptos, por lo que el código y la estructura del proyecto son especialmente sencillos.
Este proyecto sirve también como fuente de código para el pipeline de Jenkins.

### Create the docker image from Dockerfile:
```
docker build --tag carogarb/jenkins-with-python .
```

### Execute the container exposing ports:
```
docker run -d -p 8090:8080 -p 50000:50000 -v jenkins-data:/var/jenkins_home --name jenkins-with-python carogarb/jenkins-with-python
```

### To open a terminal into the running container, execute:
```
docker exec -it jenkins-with-python bash
```

### Jenkins is available on http://localhost:8090/
