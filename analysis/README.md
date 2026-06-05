# 로컬 분석 작업 흐름

이 디렉터리는 VM/Hive 파이프라인에서 `results_csv/`를 생성한 뒤, Mac 로컬에서 CSV를 분석하고 시각화하는 코드를 두는 공간이다.

## 디렉터리 역할

```text
results_csv/        VM에서 내려받은 최종 CSV. git 제외.
analysis/           로컬 분석/시각화 스크립트. git 포함.
figures/            보고서용 그래프 이미지 산출물. git 제외.
summary_csv/        보고서용 요약 CSV 산출물. git 제외.
```

`src/`와 `sql/`은 Spark/Hive 전처리 및 분석 파이프라인 코드용으로 유지한다. pandas/matplotlib 기반의 보고서 분석과 시각화 코드는 `analysis/`에 둬서 VM 파이프라인과 로컬 작업을 분리한다.

## 권장 로컬 작업 순서

1. VM에서 파이프라인을 실행하고 `results_csv/`를 export한다.
2. `results_csv/` 디렉터리 전체를 Mac 로컬 프로젝트 루트로 복사한다.
3. 프로젝트 루트 또는 `analysis/`에서 로컬 분석 스크립트를 실행한다.
4. 생성한 그래프는 `figures/`에, 보고서용 요약 CSV는 `summary_csv/`에 저장한다.

7개 분석 질문의 기본 해석 파일은 다음이다.

```text
results_csv/question_answer_evidence.csv
```

이 파일은 질문별 순위 결과에 상권 유형, 주요 업종, 우세 시간대 근거를 함께 붙인 파일이므로 보고서 작성 시 가장 먼저 확인한다.

## 분석/시각화 실행

프로젝트 루트에서 다음 명령을 실행한다.

```bash
python3 analysis/analyze_results.py
```

실행 결과:

```text
summary_csv/question_top_answers.csv
summary_csv/time_slot_winners.csv
summary_csv/market_type_counts.csv
summary_csv/q1_top10.csv ... summary_csv/q5_top10.csv

figures/q1_top10.png ... figures/q5_top10.png
figures/time_slot_winners.png
figures/market_type_counts.png
```

콘솔에는 질문별 1위, 시간대별 1위, 상권 유형 분포가 함께 출력된다.
