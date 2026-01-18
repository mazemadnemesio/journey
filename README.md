# Senior DevOps Stack Setup

Este repositorio contiene todo lo necesario para desplegar un ambiente de Kubernetes profesional en GCP utilizando herramientas modernas de DevOps.

## Requisitos Previos

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) configurado (`gcloud auth login`).
- [Terraform](https://developer.hashicorp.com/terraform/downloads) instalado.
- [Flux CLI](https://fluxcd.io/flux/installation/) instalado.
- Un repositorio en GitHub para el GitOps.
- Un [GitHub Personal Access Token](https://github.com/settings/tokens) con permisos `repo`.

## Configuración de GitHub (User y Token)

Para que Flux CD pueda sincronizar tu código, necesitas configurar tus credenciales de GitHub:

### 1. Obtener tu Usuario
- Es tu handle de GitHub (ejemplo: `eldam`). Lo ves en tu perfil o en la URL `github.com/tu-usuario`.

### 2. Generar un Personal Access Token (PAT)
1. Ve a [GitHub Settings > Developer settings > Personal access tokens > Tokens (classic)](https://github.com/settings/tokens).
2. Haz clic en **Generate new token (classic)**.
3. Ponle un nombre (ejemplo: `flux-token`).
4. Selecciona el scope **`repo`** (completo).
5. Haz clic en **Generate token**.
6. **¡IMPORTANTE!** Copia el token de inmediato, no lo volverás a ver.

## Cómo Ejecutar

1. Clona este repositorio.
2. Configura tus variables de entorno:
   ```bash
   export GCP_PROJECT_ID="tu-proyecto-id"
   export GITHUB_USER="tu-usuario"
   export GITHUB_TOKEN="tu-token-de-acceso"
   ```
3. Otorga permisos de ejecución al script:
   ```bash
   chmod +x setup.sh
   ```
4. Ejecuta el script:
   ```bash
   ./setup.sh
   ```

## Componentes Incluidos

- **Terraform/GKE**: Cluster auto-gestionado con VPC dedicada.
- **Nginx App**: Página estática con Docker y Health Checks.
- **K8s Best Practices**: HPA, PDB, Probes, Resource Quotas.
- **Flux CD**: Sincronización automática vía GitOps.
- **GitHub Actions**: Pipeline de CI para build y test.
