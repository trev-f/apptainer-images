#!/bin/bash

#SBATCH --account=ACF-UTK0011
#SBATCH --partition=campus
#SBATCH --qos=campus
#SBATCH --cpus-per-task=4
#SBATCH --mem=16GB
#SBATCH --time=00-08:00:00
#SBATCH --job-name=rstudio_server_local_test
#SBATCH --error=job_logs/%j_-_%x.err
#SBATCH --output=/dev/null
#SBATCH --signal=USR2

################
# CONFIG
################
# URI for apptainer image
readonly rstudio_server_image="oras://oras://ghcr.io/trev-f/rstudio_4.5:latest"


################
# MAIN
################
# Create temporary directory to be populated with directories to bind-mount in the container
# where writable file systems are necessary. Adjust path as appropriate for your computing environment.
workdir=$(python3 -c 'import tempfile; print(tempfile.mkdtemp())')

mkdir -p -m 700 ${workdir}/run ${workdir}/tmp ${workdir}/var/lib/rstudio-server
cat > ${workdir}/database.conf <<END
provider=sqlite
directory=/var/lib/rstudio-server
END

# Set OMP_NUM_THREADS to prevent OpenBLAS (and any other OpenMP-enhanced
# libraries used by R) from spawning more threads than the number of processors
# allocated to the job.
#
# Set R_LIBS_USER to a path specific to rocker/rstudio to avoid conflicts with
# personal libraries from any R installation in the host environment

cat > ${workdir}/rsession.sh <<END
#!/bin/sh
export OMP_NUM_THREADS=${SLURM_JOB_CPUS_PER_NODE:-1}
export R_LIBS_USER="${HOME}/R/rocker-rstudio/4.5:/usr/local/lib/R/site-library:/usr/local/lib/R/library"
exec /usr/lib/rstudio-server/bin/rsession "\${@}"
END

chmod +x ${workdir}/rsession.sh

export APPTAINER_BIND="${workdir}/run:/run,${workdir}/tmp:/tmp,${workdir}/database.conf:/etc/rstudio/database.conf,${workdir}/rsession.sh:/etc/rstudio/rsession.sh,${workdir}/var/lib/rstudio-server:/var/lib/rstudio-server"

# Do not suspend idle sessions.
# Alternative to setting session-timeout-minutes=0 in /etc/rstudio/rsession.conf
# https://github.com/rstudio/rstudio/blob/v1.4.1106/src/cpp/server/ServerSessionManager.cpp#L126
export APPTAINERENV_RSTUDIO_SESSION_TIMEOUT=0

export APPTAINERENV_USER=$(id -un)
export APPTAINERENV_PASSWORD=$(openssl rand -base64 15)
# get unused socket per https://unix.stackexchange.com/a/132524
# tiny race condition between the python & APPTAINER commands
readonly PORT=$(python3 -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
cat 1>&2 <<END
1. SSH tunnel from your workstation using the following command:

    ssh -f -N -L 8787:${HOSTNAME}:${PORT} ${APPTAINERENV_USER}@login.isaac.utk.edu

    and point your web browser to http://localhost:8787

2. log in to RStudio Server using the following credentials:

    user: ${APPTAINERENV_USER}
    password: ${APPTAINERENV_PASSWORD}

When done using RStudio Server, terminate the job by:

1. Exit the RStudio Session ("power" button in the top right corner of the RStudio window)
2. Issue the following command on the login node:

    scancel -f ${SLURM_JOB_ID}
END

# run RStudio Server from apptainer image
apptainer exec --cleanenv "${rstudio_server_image}" \
    /usr/lib/rstudio-server/bin/rserver --www-port ${PORT} \
            --auth-none=0 \
            --auth-pam-helper-path=pam-helper \
            --server-user=$(whoami) \
            --auth-stay-signed-in-days=30 \
            --auth-timeout-minutes=0 \
            --rsession-path=/etc/rstudio/rsession.sh
printf 'rserver exited' 1>&2
