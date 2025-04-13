import os
import subprocess

def run(cmd):
    print(f"Ejecutando: {cmd}")
    subprocess.run(cmd, shell=True, check=True)

def instalar_apache():
    if os.path.exists("/etc/debian_version"):
        run("sudo apt update")
        run("sudo apt install -y apache2")
        run("sudo systemctl start apache2")
        run("sudo systemctl enable apache2")
    elif os.path.exists("/etc/redhat-release"):
        run("sudo yum install -y httpd")
        run("sudo systemctl start httpd")
        run("sudo systemctl enable httpd")
    else:
        print("Distro no soportada")

def obtener_numero_servidor():
    ruta = os.path.join(os.path.dirname(__file__), "server_counter.txt")
    if os.path.exists(ruta):
        with open(ruta, "r") as f:
            numero = int(f.read().strip()) + 1
    else:
        numero = 1
    with open(ruta, "w") as f:
        f.write(str(numero))
    return numero

def crear_pagina():
    numero = obtener_numero_servidor()

    html = f"""
    <!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Servidor Web {numero}</title>
    </head>
    <body>
        <h1>Servidor web de Linux {numero} por Pedro De León</h1>
    </body>
    </html>
    """

    with open("/tmp/index.html", "w", encoding="utf-8") as f:
        f.write(html)

    run("sudo mv /tmp/index.html /var/www/html/index.html")

if __name__ == "__main__":
    instalar_apache()
    crear_pagina()
