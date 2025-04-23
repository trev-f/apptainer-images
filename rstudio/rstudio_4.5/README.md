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
