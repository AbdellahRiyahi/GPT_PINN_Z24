#!/bin/bash

#SBATCH --job-name=gptpinn_r3_full
#SBATCH --partition=mediumq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=3-00:00:00
#SBATCH --output=/home/a.riyahi/GPT_PINN/logs/slurm/r3-full-%j.out
#SBATCH --error=/home/a.riyahi/GPT_PINN/logs/slurm/r3-full-%j.err

set -Eeuo pipefail

PROJECT_ROOT="/home/a.riyahi/GPT_PINN"
PYTHON="/cm/shared/apps/eb/software/Anaconda3/2024.02-1/bin/python"

NOTEBOOK_NAME="GPT_PINN_Z24_Physics_Digital_Twin_V0_6_FINAL_R3.ipynb"
NOTEBOOK_PATH="${PROJECT_ROOT}/${NOTEBOOK_NAME}"

EXECUTED_NOTEBOOK_NAME="GPT_PINN_Z24_Physics_Digital_Twin_V0_6_FINAL_R3_EXECUTED_${SLURM_JOB_ID}.ipynb"
EXECUTED_NOTEBOOK_PATH="${PROJECT_ROOT}/${EXECUTED_NOTEBOOK_NAME}"

error_report() {
    local rc=$?
    echo
    echo "============================================================" >&2
    echo "JOB FAILED" >&2
    echo "Exit code : ${rc}" >&2
    echo "Line      : ${BASH_LINENO[0]:-unknown}" >&2
    echo "Command   : ${BASH_COMMAND:-unknown}" >&2
    echo "Date UTC  : $(date -u --iso-8601=seconds)" >&2
    echo "============================================================" >&2
    exit "${rc}"
}

trap error_report ERR

cd "${PROJECT_ROOT}"

# ---------------------------------------------------------------------
# Publication/full execution profile
# ---------------------------------------------------------------------

export GPT_PINN_RUN_PROFILE="full"
export GPT_PINN_COMPUTE_GUARD="strict"
export GPT_PINN_ALLOW_LOGIN_HEAVY="0"
export GPT_PINN_ALLOW_NETWORK_CLONE="0"

# Reuse only checkpoints that pass the notebook compatibility checks.
export GPT_PINN_GATE_B_RESUME="1"
export GPT_PINN_GATE_C_RESUME="1"
export GPT_PINN_GATE_D_RESUME="1"
export GPT_PINN_GATE_F_RESUME="1"
export GPT_PINN_IMPORT_LEGACY_CHECKPOINTS="1"

export GPT_PINN_RUN_ID="V0_6_FINAL_R3_FULL_${SLURM_JOB_ID}_$(date -u +%Y%m%dT%H%M%SZ)"

printf '%s\n' "${SLURM_JOB_ID}" \
  > "${PROJECT_ROOT}/logs/slurm/LAST_R3_FULL_JOBID"

printf '%s\n' "${GPT_PINN_RUN_ID}" \
  > "${PROJECT_ROOT}/logs/slurm/LAST_R3_FULL_RUN_ID"

# ---------------------------------------------------------------------
# CPU resources allocated by Slurm
# ---------------------------------------------------------------------

THREADS="${SLURM_CPUS_PER_TASK:-8}"

export OMP_NUM_THREADS="${THREADS}"
export MKL_NUM_THREADS="${THREADS}"
export OPENBLAS_NUM_THREADS="${THREADS}"
export NUMEXPR_NUM_THREADS="${THREADS}"

export OMP_DYNAMIC="FALSE"
export MKL_DYNAMIC="FALSE"
export PYTHONUNBUFFERED="1"
export PYTHONHASHSEED="20260828"
export MPLBACKEND="Agg"
export MALLOC_ARENA_MAX="4"

# ---------------------------------------------------------------------
# Temporary directories
# ---------------------------------------------------------------------

export TMPDIR="/home/a.riyahi/.tmp/gptpinn_r3_${SLURM_JOB_ID}"
export JUPYTER_RUNTIME_DIR="${TMPDIR}/jupyter-runtime"
export MPLCONFIGDIR="${TMPDIR}/matplotlib"
export XDG_CACHE_HOME="${TMPDIR}/cache"

KERNEL_PREFIX="${TMPDIR}/kernel-prefix"
KERNEL_NAME="gptpinn_r3_${SLURM_JOB_ID}"

mkdir -p \
  "${TMPDIR}" \
  "${JUPYTER_RUNTIME_DIR}" \
  "${MPLCONFIGDIR}" \
  "${XDG_CACHE_HOME}" \
  "${KERNEL_PREFIX}"

chmod 700 "${JUPYTER_RUNTIME_DIR}"

# ---------------------------------------------------------------------
# Pre-execution validation
# ---------------------------------------------------------------------

echo "============================================================"
echo "GPT-PINN Z24 R3 — FULL SLURM RUN"
echo "Date UTC          : $(date -u --iso-8601=seconds)"
echo "Job ID            : ${SLURM_JOB_ID}"
echo "Node              : $(hostname)"
echo "Partition         : ${SLURM_JOB_PARTITION:-unknown}"
echo "Allocated CPUs    : ${SLURM_CPUS_PER_TASK:-unknown}"
echo "Allocated memory  : ${SLURM_MEM_PER_NODE:-unknown} MB"
echo "Python            : ${PYTHON}"
echo "Run profile       : ${GPT_PINN_RUN_PROFILE}"
echo "Run ID            : ${GPT_PINN_RUN_ID}"
echo "Notebook          : ${NOTEBOOK_PATH}"
echo "Executed notebook : ${EXECUTED_NOTEBOOK_PATH}"
echo "============================================================"

if [[ "$(hostname)" == login* ]]; then
    echo "ERROR: the full run was allocated on a login node." >&2
    exit 10
fi

if [[ -z "${SLURM_JOB_ID:-}" ]]; then
    echo "ERROR: SLURM_JOB_ID is absent." >&2
    exit 11
fi

if [[ ! -x "${PYTHON}" ]]; then
    echo "ERROR: Python executable is absent: ${PYTHON}" >&2
    exit 12
fi

if [[ ! -s "${NOTEBOOK_PATH}" ]]; then
    echo "ERROR: notebook is absent or empty: ${NOTEBOOK_PATH}" >&2
    exit 13
fi

"${PYTHON}" --version

"${PYTHON}" - <<'PY'
import os
import socket
import sys

import ipykernel
import jupyter_client
import nbconvert
import nbformat
import numpy
import pandas
import scipy
import torch

print("Hostname          :", socket.gethostname())
print("SLURM_JOB_ID      :", os.environ.get("SLURM_JOB_ID"))
print("Python executable :", sys.executable)
print("Python version    :", sys.version)
print("nbconvert         :", nbconvert.__version__)
print("nbformat          :", nbformat.__version__)
print("jupyter_client    :", jupyter_client.__version__)
print("ipykernel         :", ipykernel.__version__)
print("NumPy             :", numpy.__version__)
print("SciPy             :", scipy.__version__)
print("Pandas            :", pandas.__version__)
print("PyTorch           :", torch.__version__)
print("CUDA available    :", torch.cuda.is_available())
print("RUN_PROFILE       :", os.environ.get("GPT_PINN_RUN_PROFILE"))

if socket.gethostname().lower().startswith("login"):
    raise RuntimeError("Execution incorrectly started on a login node.")

if not os.environ.get("SLURM_JOB_ID"):
    raise RuntimeError("SLURM_JOB_ID is absent.")

if os.environ.get("GPT_PINN_RUN_PROFILE") != "full":
    raise RuntimeError("GPT_PINN_RUN_PROFILE is not full.")

print("FULL_ENVIRONMENT_CHECK: PASS")
PY

# ---------------------------------------------------------------------
# Job-specific kernel using the same validated Python executable
# ---------------------------------------------------------------------

"${PYTHON}" -m ipykernel install \
  --prefix "${KERNEL_PREFIX}" \
  --name "${KERNEL_NAME}" \
  --display-name "${KERNEL_NAME}"

export JUPYTER_PATH="${KERNEL_PREFIX}/share/jupyter${JUPYTER_PATH:+:${JUPYTER_PATH}}"

"${PYTHON}" - <<PY
from jupyter_client.kernelspec import KernelSpecManager

name = "${KERNEL_NAME}"
specification = KernelSpecManager().get_kernel_spec(name)

print("Kernel name :", name)
print("Kernel argv :", specification.argv)
print("KERNEL_CHECK: PASS")
PY

# ---------------------------------------------------------------------
# Heartbeat: shows that the job is still running while nbconvert is quiet
# ---------------------------------------------------------------------

heartbeat() {
    while true
    do
        echo
        echo "[HEARTBEAT] $(date -u --iso-8601=seconds)"
        echo "[HEARTBEAT] job=${SLURM_JOB_ID} node=$(hostname)"

        checkpoint_count="$(
          find "${PROJECT_ROOT}/outputs/v0_6_final/checkpoints" \
            -type f -name "*.pt" 2>/dev/null \
            | wc -l
        )"

        echo "[HEARTBEAT] checkpoint_count=${checkpoint_count}"

        find "${PROJECT_ROOT}/outputs/v0_6_final/checkpoints" \
          -type f -name "*.pt" \
          -printf "%TY-%Tm-%Td %TH:%TM:%TS  %10s  %p\n" \
          2>/dev/null \
          | sort \
          | tail -n 5 \
          || true

        sleep 300
    done
}

heartbeat &
HEARTBEAT_PID=$!

cleanup() {
    kill "${HEARTBEAT_PID}" 2>/dev/null || true
}

trap cleanup EXIT

# ---------------------------------------------------------------------
# Complete notebook execution
# ---------------------------------------------------------------------

echo
echo "============================================================"
echo "START NBCONVERT: $(date -u --iso-8601=seconds)"
echo "============================================================"

"${PYTHON}" -m nbconvert \
  --to notebook \
  --execute "${NOTEBOOK_PATH}" \
  --output "${EXECUTED_NOTEBOOK_NAME}" \
  --output-dir "${PROJECT_ROOT}" \
  --ExecutePreprocessor.timeout=-1 \
  --ExecutePreprocessor.startup_timeout=300 \
  --ExecutePreprocessor.kernel_name="${KERNEL_NAME}" \
  --log-level=INFO

echo
echo "============================================================"
echo "END NBCONVERT: $(date -u --iso-8601=seconds)"
echo "============================================================"

if [[ ! -s "${EXECUTED_NOTEBOOK_PATH}" ]]; then
    echo "ERROR: the executed notebook was not generated." >&2
    exit 20
fi

RUN_DIR="${PROJECT_ROOT}/outputs/v0_6_final/runs/${GPT_PINN_RUN_ID}"

echo
echo "Executed notebook:"
ls -lh "${EXECUTED_NOTEBOOK_PATH}"

echo
echo "Executed notebook SHA-256:"
sha256sum "${EXECUTED_NOTEBOOK_PATH}"

echo
echo "Run directory:"
echo "${RUN_DIR}"

echo
echo "Generated artifacts:"
find "${RUN_DIR}" \
  -maxdepth 2 \
  -type f \
  -printf "%TY-%Tm-%Td %TH:%TM  %10s  %p\n" \
  2>/dev/null \
  | sort

EVIDENCE="${RUN_DIR}/V0_6_FINAL_EVIDENCE_SUMMARY.json"
CERTIFICATE="${RUN_DIR}/V0_6_FINAL_EXECUTION_CERTIFICATE.json"

if [[ ! -s "${EVIDENCE}" ]]; then
    echo "ERROR: final evidence summary was not generated." >&2
    exit 21
fi

if [[ ! -s "${CERTIFICATE}" ]]; then
    echo "ERROR: execution certificate was not generated." >&2
    exit 22
fi

export RUN_DIR

"${PYTHON}" - <<'PY'
import json
import os
from pathlib import Path

run_directory = Path(os.environ["RUN_DIR"])

evidence = json.loads(
    (run_directory / "V0_6_FINAL_EVIDENCE_SUMMARY.json").read_text(
        encoding="utf-8"
    )
)

certificate = json.loads(
    (run_directory / "V0_6_FINAL_EXECUTION_CERTIFICATE.json").read_text(
        encoding="utf-8"
    )
)

print("=" * 76)
print("EXECUTION CERTIFICATE")
print("=" * 76)

for key in (
    "run_profile",
    "hostname",
    "is_login_node",
    "slurm_job_id",
    "all_gate_objects_executed",
    "raw_z24_metadata_unchanged",
    "full_numerical_run_on_marwan_demonstrated",
    "full_run_on_marwan_compute_node_demonstrated",
    "publication_timing_compute_certified",
    "gate_f_smoke_fe_proxy_used",
    "gate_f_state_source_classes",
    "checkpoint_io_failure_count",
):
    print(f"{key:52s}: {certificate.get(key)}")

print()
print("=" * 76)
print("SCIENTIFIC DECISION")
print("=" * 76)

for key in (
    "article_evidence_status",
    "scientific_manuscript_ready",
    "publication_compute_certified",
    "code_freeze_authorized",
    "current_run_evidence_class",
    "locked_fvt_audit_decision",
    "gate_h_supplementary_status",
    "autonomous_prognosis_supported",
    "gate_f_smoke_fe_proxy_used",
):
    print(f"{key:52s}: {evidence.get(key)}")

print()
print("GATE DECISIONS")
for gate, decision in evidence.get("gate_decisions", {}).items():
    print(f"  {gate:44s}: {decision}")

print()
print("FAILED CORE REQUIREMENTS")
requirements = evidence.get("core_scientific_requirements", {})
failed = [name for name, passed in requirements.items() if not passed]

if failed:
    for name in failed:
        print("  -", name)
else:
    print("  None")
PY

cp "${PROJECT_ROOT}/run_r3_full_fixed.sbatch" \
  "${RUN_DIR}/run_r3_full_fixed.sbatch"

sha256sum \
  "${NOTEBOOK_PATH}" \
  "${EXECUTED_NOTEBOOK_PATH}" \
  "${EVIDENCE}" \
  "${CERTIFICATE}" \
  > "${RUN_DIR}/R3_FULL_SHA256SUMS.txt"

echo
echo "============================================================"
echo "FULL JOB COMPLETED SUCCESSFULLY"
echo "Date UTC : $(date -u --iso-8601=seconds)"
echo "Job ID   : ${SLURM_JOB_ID}"
echo "Run ID   : ${GPT_PINN_RUN_ID}"
echo "Run dir  : ${RUN_DIR}"
echo "============================================================"
