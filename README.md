# GPT-PINN Z24

Research code and computational artifacts for **A Greedy GPT-PINN Reduced-Order Digital Twin for Identifiability-Aware Modal Updating of the Z24 Bridge**.

**Authors:** Abdellah Riyahi, Mohammed Mestari, and Bouchra Bouihi  
**Affiliation:** 2IACS Laboratory, ENSET Mohammedia, Hassan II University of Casablanca, Morocco  
**Corresponding author:** [Abdellah Riyahi](mailto:a.riyahi@enset-media.ac.ma)

| Item | Details |
| --- | --- |
| Journal | IEEE Access |
| Submission status | **Under Review** |
| Manuscript ID | **Access-2026-55644** |
| Submitted | 28 October 2026 |
| Submission started | 27 October 2026 |
| Software archive DOI | [10.5281/zenodo.23712373](https://doi.org/10.5281/zenodo.23712373) |
| Computational release | [v1.0-ieee-access-submission](https://github.com/AbdellahRiyahi/GPT_PINN_Z24/releases/tag/v1.0-ieee-access-submission) |

The manuscript is under review. The DOI above identifies the software archive and should be cited separately from the manuscript.

## Overview

This study investigates rapid modal updating of the Z24 Bridge along a controlled pier-settlement sequence. Ambient-vibration measurements are linked to a three-span Euler–Bernoulli model with two effective coordinates representing local rigidity and support restraint. A four-mode variational physics-informed neural network (Full-PINN) supplies modal snapshots for a greedy reduced-basis Ritz operator.

Three selected Full-PINN states produce a rank-12 reduced space. The reduced operator supports repeated covariance-aware inverse updates and uncertainty propagation. The analysis examines both forward accuracy and practical parameter ambiguity, followed by conditional leave-one-severity-out (LOSO) evaluation and an ambient-to-forced-vibration (AVT-to-FVT) assessment.

The reference progression coordinate is ξ = δ/(95 mm), where δ is the imposed settlement. Reported coordinate errors are dimensionless.

GPT-PINN here means **generative pre-trained physics-informed neural network**. This implementation combines PINN-generated modal snapshots through variational projection; online evaluation solves a small eigenproblem.

## Main reported results

| Assessment | Reported result |
| --- | --- |
| Reduced basis | 3 selected parameter states; rank 12 |
| Numerical verification | 64 modal comparisons at 16 unseen parameter points against FE-116 |
| Maximum relative frequency error | 0.0958% |
| Minimum displacement modal assurance criterion (MAC) | 0.999945 |
| Maximum weak residual indicator | 1.293% |
| Median modal-query time | GPT-PINN: 0.133 ms; FE-116: 9.317 ms |
| Measured query speedup | 70.03× over the tested FE-116 implementation |
| Selected snapshot-training time | 921.47 s |
| Conditional LOSO coordinate MAE | 0.04950 across four nonhealthy-state folds |
| FVT coordinate MAE | 0.05325, with preserved state ordering |
| Maximum FVT modal-ratio RMSE | 2.9994%, exceeding the 2.5% criterion |

Timing was measured on a MARWAN CPU compute node with eight threads. FE-116 reassembles dense matrices and computes six eigenpairs, whereas the reduced solver returns four. Snapshot-training time excludes preprocessing, greedy scans, assembly, and other offline work.

### Interpretation and limits

- Free two-coordinate inversion retains compensating bootstrap branches despite a close modal fit. The fitted coordinates do not establish separate physical stiffness and support diagnoses.
- LOSO is **conditional**: trajectory amplitudes and additional predictive discrepancy are refitted within each fold, while modal selection, trajectory exponents, and base discrepancy retain values developed from the full AVT campaign.
- FVT uses the AVT-developed trajectory without amplitude refitting, together with regime-specific observations, a healthy FVT reference, and its specified inversion procedure. Preserved ordering accompanies a failed modal-reconstruction criterion.
- Evidence concerns one bridge and a controlled settlement sequence. The progression coordinate is not a measurement of residual capacity, failure probability, or calendar-time remaining useful life.

The archive preserves intermediate and unsuccessful stages as part of the execution record. Its diagnostic labels and stored working title predate the final manuscript wording.

## Repository contents

| File or directory | Purpose |
| --- | --- |
| [Source notebook](GPT_PINN_Z24_Physics_Digital_Twin_V0_6_FINAL_R3.ipynb) | Complete V0.6_FINAL_R3 workflow |
| [Executed notebook](GPT_PINN_Z24_Physics_Digital_Twin_V0_6_FINAL_R3_EXECUTED_508150.ipynb) | Saved outputs from MARWAN job 508150 |
| [Archived run directory](V0_6_FINAL_R3_FULL_508150_20260906T011342Z/) | CSV tables, figures, configuration, diagnostics, and execution records |
| [Run archive](GPT_PINN_Z24_R3_FULL_508150_FROZEN.zip) | ZIP copy of the archived computational outputs |
| [Slurm script](run_r3_full_fixed.sbatch) | Original full-run submission script |
| [Standard output](r3-full-508150.out) and [error log](r3-full-508150.err) | Original job logs |
| [SHA-256 manifest](WINDOWS_SHA256_MANIFEST_RUN_508150.csv) | File sizes and hashes for archived run outputs |

**Raw Z24 measurements and trained checkpoint weight files are not included.** Checkpoint audit tables document the original run, but a fresh checkout must retrain the networks for a new full execution.

## Inspect the archived results

Raw measurements are not required to read the executed notebook, view exported figures, or inspect the numerical tables.

Download the repository through GitHub, or clone the computational release:

```bash
git clone --branch v1.0-ieee-access-submission --depth 1 https://github.com/AbdellahRiyahi/GPT_PINN_Z24.git
cd GPT_PINN_Z24
```

For example, display the archived timing summary with Python's standard library:

```bash
python -m json.tool V0_6_FINAL_R3_FULL_508150_20260906T011342Z/V0_6_FINAL_TIMING_SUMMARY.json
```

Useful starting points within the run directory are:

- [Reduced-model verification](V0_6_FINAL_R3_FULL_508150_20260906T011342Z/tables/gate_f_gpt_independent_validation_full.csv)
- [Conditional LOSO results](V0_6_FINAL_R3_FULL_508150_20260906T011342Z/tables/gate_g1_loso_full.csv)
- [FVT inverse-update results](V0_6_FINAL_R3_FULL_508150_20260906T011342Z/tables/gate_i_fvt_locked_inverse_results.csv)
- [Basis-size and ordering ablation](V0_6_FINAL_R3_FULL_508150_20260906T011342Z/tables/V0_6_FINAL_basis_ablation.csv)
- [Execution summary](V0_6_FINAL_R3_FULL_508150_20260906T011342Z/V0_6_FINAL_EVIDENCE_SUMMARY.json)

## Data access

The original Z24 measurements are provided by the **KU Leuven Structural Mechanics Section** through the [Z24 benchmark portal](https://bwk.kuleuven.be/bwm/z24), subject to the provider's access and use conditions. Obtain the measurements directly from the provider before rerunning the experimental processing.

The local archive used by this study contained 306 MATLAB files: 17 scenarios, two excitation regimes, and nine acquisition setups per scenario. The primary analysis uses scenarios 01, 03, 04, 05, and 06, corresponding to imposed settlements of 0, 20, 40, 80, and 95 mm.

The complete notebook first checks the full 306-file benchmark layout, so a rerun requires more than the five primary scenarios. Preserve the provider's directory structure, including paths such as `DATASET_ROOT/01/avt/01setup01.mat` and `DATASET_ROOT/17/fvt/17setup09.mat`. Use lower-case `avt` and `fvt` directories. The archived files contain a time-by-channel matrix named `data` and channel labels named `labelshulp`.

## Re-execute the workflow

### Recorded environment

The original full run used Linux, Python 3.11.7, CPU execution, and the following package versions, as recorded in [environment_audit.json](V0_6_FINAL_R3_FULL_508150_20260906T011342Z/environment_audit.json):

| Package | Recorded version |
| --- | --- |
| NumPy | 1.23.5 |
| SciPy | 1.11.4 |
| pandas | 2.1.4 |
| Matplotlib | 3.8.0 |
| PyTorch | 2.7.1+cu118; CUDA was unavailable during execution |
| scikit-learn | 1.2.2 |
| nbformat | 5.9.2 |
| nbclient | 0.8.0 |

Execution also requires `psutil`, IPython/Jupyter, `ipykernel`, and `nbconvert`. Use the archived environment information when preparing a compatible environment.

When local EMPA documentation (`.doc` files) is present in the scenario directories, the notebook uses the system command `strings` to inspect it. Install GNU binutils, or provide an equivalent `strings` executable, before running that audit.

### Configure local paths

In the initialization cell of the source notebook, set `PROJECT_ROOT` to your checkout directory and `DATASET_ROOT` to the directory containing the original Z24 MATLAB files. These are assignments inside the notebook, not environment-variable overrides. `NOTEBOOK_PATH` is derived from `PROJECT_ROOT`.

Keep the original source and executed notebook unchanged when inspecting the archived release. Use a separate working checkout for path adaptations, retaining the notebook filename expected by `NOTEBOOK_PATH` and the Slurm script.

### Select an execution profile

The notebook reads `GPT_PINN_RUN_PROFILE` before execution:

| Value | Behavior |
| --- | --- |
| `smoke` | Lightweight workflow checks; reduced budgets and possible FE proxy stages. Results do not reproduce the full-run evidence. |
| `full` | Full computational profile, including network training and statistical assessments. |
| `auto` | Selects `full` inside a Slurm allocation on a non-login host; otherwise selects `smoke`. |

The source notebook can be run interactively with a configured Jupyter kernel. Set the profile in the environment **before starting the kernel**, and execute the cells in order.

For an HPC full run, adapt a local copy of `run_r3_full_fixed.sbatch` to your cluster. Update the project directory, Python executable, Slurm partition and resources, log paths, and temporary-directory paths. The original script requests eight CPUs, 32 GB of memory, and a three-day time limit; these are its submitted resource requests, not portable minimum requirements.

After adapting the script and notebook, create the configured log directory and submit the job:

```bash
mkdir -p logs/slurm
sbatch run_r3_full_fixed.sbatch
```

The script selects the full profile, configures a job-specific Jupyter kernel, and executes the notebook through `nbconvert`. The default strict compute guard prevents heavy full-profile stages on a host recognized as a login node. Follow your cluster's compute-node policy.

New runs write outputs under `PROJECT_ROOT/outputs/v0_6_final/runs/<RUN_ID>/`. Training and statistical results may vary with initialization, numerical libraries, and hardware. The archived job outputs remain the reference for the reported manuscript values.

## Integrity and provenance

The computational release records MARWAN job **508150**, run **V0_6_FINAL_R3_FULL_508150_20260906T011342Z**. Configuration and execution details accompany the tables and figures.

The repository includes CSV SHA-256 manifests and an original text checksum record. Some recorded paths refer to the original MARWAN filesystem; the Windows CSV uses backslash-separated relative paths. Resolve these against the archived run directory when checking hashes on another platform.

## Citation

For the software and archived outputs, use the citation metadata provided by the [Zenodo record](https://doi.org/10.5281/zenodo.23712373).

The associated manuscript can be cited as a work under review:

```bibtex
@unpublished{riyahi2026gptpinnz24,
  author = {Riyahi, Abdellah and Mestari, Mohammed and Bouihi, Bouchra},
  title = {A Greedy {GPT-PINN} Reduced-Order Digital Twin for Identifiability-Aware Modal Updating of the {Z24} Bridge},
  year = {2026},
  note = {Under review at IEEE Access, manuscript Access-2026-55644}
}
```

## Acknowledgments and reuse

The authors acknowledge MARWAN for computational resources and the KU Leuven Structural Mechanics Section for the Z24 experimental data.

No license file is included in this computational release. Contact the corresponding author regarding reuse permissions. Access to and reuse of the raw measurements remain governed by the data provider's conditions.

For questions about the implementation or archived results, open a [GitHub issue](https://github.com/AbdellahRiyahi/GPT_PINN_Z24/issues) or contact [a.riyahi@enset-media.ac.ma](mailto:a.riyahi@enset-media.ac.ma).
