# Local analysis workflow

This directory is for local CSV analysis and visualization after the VM/Hive
pipeline has produced `results_csv/`.

## Directory roles

```text
results_csv/        Downloaded CSV outputs from the VM. Ignored by git.
analysis/           Local analysis and visualization scripts. Tracked by git.
figures/            Generated charts/images for reports. Ignored by git.
summary_csv/        Optional local summary tables. Ignored by git.
```

Keep Spark/Hive preprocessing code in `src/` and `sql/`. Put report-oriented
pandas/matplotlib work in `analysis/` so the local workflow stays separate from
the VM pipeline.

## Expected local flow

1. Run the VM pipeline and export `results_csv/` on the VM.
2. Copy the whole `results_csv/` directory into the project root on the Mac.
3. Run local analysis scripts from this directory or from the project root.
4. Save generated plots to `figures/` and derived report tables to `summary_csv/`.

The main interpretation file is:

```text
results_csv/question_answer_evidence.csv
```

Use it as the first source for the seven report questions because it already
joins rank results with market type, top service categories, and dominant time
slot evidence.
