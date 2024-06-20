# Arquitectura de balanceador de carga de aplicacion con EC2 conectados a EFS como almacenamiento en común 

![](https://github.com/GaboGrobier/Arquitectura_EFS/blob/main/Arquitectura%20ALB-EC2-EFS.png)

Arquitectura en AWS contruida con Terraform que esta pensado para una arquitectura simple de servidor de apache con redundancia, todas las conexiones ingresan por el balanceador de carga
y esta configurado para que los accesos solo se permitan por ahi publicamente .
Cada area tiene su propio grupo de seguridad con solo las reglas para que el area correspondiente pueda obtener conectividad 

