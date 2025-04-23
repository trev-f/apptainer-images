# RStudio v4.5

Ann Apptainer container image based on `rocker/rstudio`.

Run RStudio server v4.5 with Python v3.12 and Quarto v1.6 available.

## Usage

### Basic

Usage is very similar to that covered in the [Rocker Project's Singularity docs](https://rocker-project.org/use/singularity.html).

> [!NOTE]  
> I prefer using the `apptainer` commands and `APPTAINER_`-prefixed environment variables in place of Singularity.

```bash
apptainer pull oras://oras://ghcr.io/trev-f/rstudio_4.5:latest
```

> [!CAUTION]  
> Here and in the sample job submission script discussed below I have set the command to use the container image tagged `lastest`.
> Best practice dictates that a specifically tagged container image version should be used.
> So please use a tagged container version!

### ISAAC-NG

I have written a comprehensive Slurm job submission script for usage on the ISAAC-NG HPC at the Univeristy of Tennessee.
The job script can be incoprorated into the Open OnDemand Job Composer for easy launching from a web interface or submitted to the schedule as usual with the `sbatch` command.

After submitting the job, go to the proper `job_logs` sub directory and look for the `.err` file belonging to the RStudio server job you submitted.
This file will have instructions for how you can log into your RStudio server instance through an SSH tunnel.
In essence, you have to tunnel through the ISAAC login node to the compute node that your RStudio server is running on.
It's simple, you just have to get it right.
Luckily this is as straightforward as copying the `ssh` command from the `.err` file for your job into a terminal on your local machine, then navigating to the right website which is also located in the same `.err` file.

View the script at [rstudio-server.sh](./rstudio-server.sh).
Make your own copy and tune the `#SBATCH` headers as needed for your jobs!
