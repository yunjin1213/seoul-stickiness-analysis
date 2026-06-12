# 유입된 사람들은 어디에서 오래 머무르고 소비까지 이어지는가?

> 생활인구·지하철·상권 데이터를 활용한 서울 행정동 단위 유입·체류·소비 분석

## 프로젝트 개요

서울에는 홍대, 강남, 이태원, 건대입구, 신촌 등 다양한 상권이 존재한다. "핫플레이스"는 여러곳이 존재하지만, 사람이 많이 들어오는 곳과 오래 머무르는 곳, 그리고 실제 소비가 강하게 발생하는 곳은 서로 다를 수 있다.

본 프로젝트는 서울 생활인구 데이터, 지하철 승하차 데이터, 서울시 상권분석서비스 데이터를 결합하여 서울의 유입·체류·소비 구조를 분석한다. 최종 분석 단위는 **행정동(`dong_code`)** 이며, 상권 매출 데이터는 서울시 상권분석서비스의 상권-행정동 연결 정보를 이용해 행정동 기준으로 집계한다.

즉, 본 프로젝트의 핵심은 특정 상권을 임의로 추천하는 것이 아니라 다음 질문에 답하는 것이다.

> 지하철로 많이 유입되는 지역, 생활인구가 오래 유지되는 지역, 소비가 강한 지역은 실제로 같은 곳인가?

## 문제 정의

많은 사람이 방문하는 지역이 반드시 경쟁력 있는 지역일까?

상권의 경쟁력은 단순 유입 규모뿐 아니라, 유입된 사람들이 해당 지역에 얼마나 머무르고 실제 소비까지 이어지는지와 관련될 수 있다. 그러나 유동인구, 지하철 하차량, 매출 데이터는 보통 개별적으로 분석되는 경우가 많다.

본 프로젝트는 세 데이터를 하나의 분석 흐름으로 연결한다.

```text
지하철 하차량 = 유입
생활인구 = 체류
상권 매출 = 소비
```

이를 통해 서울 행정동별로 유입형, 체류형, 소비전환형, 종합형, 야간형 패턴을 비교한다.

## 핵심 가설

> 유입이 많은 지역과 체류·소비가 강한 지역은 항상 일치하지 않을 것이다. 사람을 오래 붙잡고 소비까지 이어지는 지역은 시간대별 생활인구 유지와 업종별 매출 구조에서 차이를 보일 것이다.

## 핵심 분석 질문

1. 서울에서 지하철 하차 유입이 가장 많은 행정동은 어디인가?
2. 서울에서 생활인구가 가장 많은 행정동은 어디인가?
3. 지하철 유입 대비 생활인구 규모가 큰 행정동은 어디인가?
4. 생활인구 대비 소비전환이 높은 행정동은 어디인가?
5. 유입, 체류, 소비를 종합했을 때 상권 경쟁력이 높은 행정동은 어디인가?
6. 시간대별로 강한 상권 패턴은 어떻게 달라지는가?
7. 행정동별 상권은 유입형, 체류형, 소비전환형, 종합형, 야간형 중 어디에 가까운가?

## 분석 단위

최종 분석 단위는 **행정동** 이다.

생활인구 데이터가 행정동 단위로 제공되기 때문에, 생활인구를 상권 면적 기준으로 임의 배분하지 않는다. 대신 상권 매출 데이터는 상권-행정동 연결 데이터를 이용해 행정동 기준으로 집계한다.

```text
생활인구 데이터       행정동 기준
지하철 승하차 데이터   역 기준 -> 역 좌표 -> 행정동 매핑
상권 매출 데이터      상권 기준 -> 상권-행정동 매핑 -> 행정동 집계
```

이 구조를 통해 모든 지표를 `dong_code` 기준으로 비교한다.

## 데이터 수집 방법

| 데이터 | 출처 | 수집 방식 | 활용 목적 |
| --- | --- | --- | --- |
| 서울 생활인구 데이터 | 서울 열린데이터광장 | CSV 다운로드 | 행정동별 체류 인구 분석 |
| 서울 지하철 승하차 데이터 | 공공데이터포털 | CSV 다운로드 | 역별 시간대 하차 유입 분석 |
| 서울 지하철 역 마스터 | 서울 열린데이터광장 | CSV 다운로드 | 역 좌표 기반 행정동 매핑 |
| 서울시 상권분석서비스 추정매출 데이터 | 서울 열린데이터광장 | CSV 다운로드 | 행정동별 소비 규모 분석 |
| 서울시 상권분석서비스 영역-상권 데이터 | 서울 열린데이터광장 | CSV 다운로드 | 상권코드와 행정동코드 연결 |
| Kakao Local API | Kakao Developers | REST API 호출 | 지하철역 좌표를 행정동으로 변환 |

데이터 수집은 Bash/Python 스크립트로 자동화하여 재실행 가능하도록 구성한다. 수집한 원천 데이터는 HDFS에 적재하고, Spark와 Hive를 활용해 전처리 및 분석을 수행한다.

## 시스템 아키텍처

```text
공개 데이터 다운로드 / Kakao API 호출
        ↓
Raw CSV 저장
        ↓
HDFS 적재
        ↓
Spark DataFrame 전처리
        ↓
Processed Parquet 저장
        ↓
Hive External Table 등록
        ↓
HiveQL 분석 쿼리 실행
        ↓
분석 결과 CSV 생성
        ↓
로컬 요약 CSV 및 시각화 생성
```

## 데이터 처리 방법

### 생활인구 데이터

- 날짜 및 시간대 컬럼 정리
- 행정동 코드 정리
- 생활인구 컬럼 타입 변환
- 행정동·시간대별 생활인구 집계

활용 목적:

- 행정동별 체류 인구 분석
- 시간대별 생활인구 패턴 분석

### 지하철 데이터

- 역명, 호선, 승하차 구분 정리
- 하차 인원만 유입 지표로 사용
- Kakao Local API로 생성한 역-행정동 매핑과 조인
- 행정동·시간대별 지하철 하차량 집계

활용 목적:

- 행정동별 지하철 유입 분석
- 유입량 대비 체류량 비교

### 상권 매출 데이터

- 상권 코드, 상권명, 업종, 시간대별 매출 정리
- 상권-행정동 매핑과 조인
- 행정동·시간대·업종별 매출 집계

활용 목적:

- 행정동별 소비 규모 분석
- 생활인구 대비 매출 규모 분석
- 업종별 매출 구조를 통한 해석 보강

## 주요 테이블

| 단계 | 테이블/경로 | 설명 |
| --- | --- | --- |
| Raw | `raw_people` | 원천 생활인구 CSV |
| Raw | `raw_subway` | 원천 지하철 승하차 CSV |
| Raw | `raw_station_master` | 원천 역 마스터 CSV |
| Raw | `raw_market_sales` | 원천 상권 추정매출 CSV |
| Raw | `raw_market_area` | 원천 상권-행정동 연결 CSV |
| Clean | `clean_people` | 영어 컬럼명과 타입으로 정리한 생활인구 |
| Clean | `clean_subway` | 영어 컬럼명과 타입으로 정리한 지하철 데이터 |
| Clean | `clean_market_sales` | 영어 컬럼명과 타입으로 정리한 매출 데이터 |
| Bridge | `station_dong_bridge` | Kakao API 기반 역-행정동 매핑 |
| Bridge | `market_dong_bridge` | 상권코드-행정동코드 매핑 |
| Mart | `analysis_mart_quarter` | 분기·행정동·시간대 단위 최종 분석 mart |

## 분석 지표

### Subway Inflow

```text
Subway Inflow = 시간대별 평균 지하철 하차량
```

행정동으로 유입되는 지하철 하차 인원의 규모를 나타낸다.

### Living Population

```text
Living Population = 시간대별 평균 생활인구
```

해당 행정동에 머무르는 인구 규모를 나타낸다.

### Stay Index

```text
Stay Index = Living Population / Subway Inflow
```

지하철 유입 대비 생활인구 규모를 나타낸다.

이 값은 개인별 실제 체류시간이 아니라, 행정동 단위의 상대적 체류 특성을 보기 위한 대리 지표이다. 버스, 도보, 택시, 자가용 유입은 직접 반영하지 않는다.

### Consumption Index

```text
Consumption Index = Sales Amount / Living Population
```

생활인구 대비 매출 규모를 나타낸다.

이 값은 개인별 구매 전환율이 아니라, 행정동 단위에서 생활인구 규모에 비해 매출이 얼마나 크게 나타나는지 비교하기 위한 지표이다.

### Conversion Score

```text
Conversion Score = z(Subway Inflow) + z(Living Population) + z(Sales Amount)
```

유입, 체류, 소비 규모를 표준화해 합산한 종합 점수이다. 분기·시간대 내에서 상대적으로 강한 행정동을 찾기 위해 사용한다.

## 분석 결과 파일

Hive 분석 결과는 HDFS의 `${HDFS_BASE_DIR}/results` 아래에 저장되고, `scripts/export_results.sh` 실행 후 `results_csv/*.csv`로 병합된다.

| 결과 파일 | 의미 |
| --- | --- |
| `top_subway_inflow.csv` | 지하철 하차 유입이 많은 행정동 순위 |
| `top_living_population.csv` | 생활인구가 많은 행정동 순위 |
| `top_stay_index.csv` | 지하철 유입 대비 생활인구 규모가 큰 행정동 순위 |
| `top_consumption_index.csv` | 생활인구 대비 매출 규모가 큰 행정동 순위 |
| `top_conversion_score.csv` | 유입·체류·소비 종합 점수가 높은 행정동 순위 |
| `time_slot_pattern.csv` | 시간대별 종합 점수가 높은 행정동 순위 |
| `dong_market_type.csv` | 행정동별 대표 상권 유형 분류 |
| `dong_service_sales_mix.csv` | 행정동별 업종 매출 구성과 비중 |
| `top_dong_service_top5.csv` | 주요 행정동별 매출 상위 업종 TOP 5 |
| `night_sales_pattern.csv` | 21~24시 매출 비중이 높은 행정동 |
| `result_interpretation_support.csv` | 핵심 TOP 행정동의 상권명, 업종 TOP 5, 우세 시간대 요약 |
| `question_answer_evidence.csv` | 7개 분석 질문별 답변과 해석 보조 근거 |

## 분석 결과 요약

분석 결과, 지하철 유입이 많은 지역과 생활인구가 오래 유지되는 지역, 생활인구 대비 매출이 강한 지역은 항상 일치하지 않았다.

- 역삼1동은 지하철 유입, 생활인구, 매출 규모가 함께 높게 나타난 종합형 상권으로 확인되었다.
- 서교동은 야간 시간대 종합 경쟁력이 높게 나타나 외식, 주점, 쇼핑, 카페 업종이 함께 작동하는 야간형 상권 특성을 보였다.
- 제기동은 생활인구 대비 매출 규모가 높게 나타났으며, 이는 청과상 등 식료품 전문 업종의 매출 집중과 관련되어 해석할 수 있다.
- 방배2동, 가락본동, 불광1동은 지하철 유입 대비 생활인구가 크게 유지되는 체류형 지역으로 나타났다.

따라서 상권 경쟁력은 단순 유입량만으로 설명하기 어렵고, 체류 규모, 소비 구조, 시간대별 특성을 함께 고려해야 한다.

## 실행 방법

HDP Sandbox 또는 Hadoop/Spark/Hive가 설치된 VM에서 실행한다.

### 1. 데이터 다운로드

```bash
bash scripts/download_data.sh
```

### 2. Kakao API 키 설정

Kakao REST API 키는 코드나 README에 직접 쓰지 않는다. 프로젝트 루트의 `.env`에 저장하거나 현재 쉘 환경변수로 제공한다.

```bash
cp .env.example .env
vi .env
```

`.env` 형식:

```bash
KAKAO_REST_API_KEY=...
```

### 3. 역-행정동 매핑 생성

```bash
bash scripts/create_station_dong_mapping.sh
```

생성 파일:

```text
${DATASET_DIR}/StationDongMapping/station_dong_mapping.csv
```

이 파일은 Kakao Local API의 좌표 -> 행정동 변환 결과를 사용한다. Kakao 행정동 코드 10자리 중 앞 8자리를 생활인구 데이터의 행정동 코드와 맞춰 사용한다.

### 4. HDFS 업로드

```bash
bash scripts/upload_hdfs.sh
```

### 5. Spark 전처리

```bash
bash scripts/run_preprocess.sh
```

전처리 결과는 HDFS의 `${HDFS_BASE_DIR}/processed` 아래에 Parquet으로 저장된다.

Hive external table은 HiveServer2의 HDFS 사용자 권한으로 등록된다. 개인 사용자 HDFS 경로에 데이터를 올린 경우를 고려해 스크립트는 Hive 사용자에게 필요한 ACL을 자동으로 부여한다. HiveServer2 HDFS 사용자가 다른 환경이면 다음처럼 지정한다.

```bash
HIVE_HDFS_USER=hive bash scripts/run_preprocess.sh
```

### 6. Hive 분석

```bash
bash scripts/run_analysis.sh
```

분석 결과는 HDFS의 `${HDFS_BASE_DIR}/results` 아래에 저장된다.

### 7. 결과 CSV 병합

```bash
bash scripts/export_results.sh
```

HDFS 결과를 로컬 `results_csv/*.csv`로 병합한다.

### 전체 파이프라인 실행

데이터 다운로드부터 결과 CSV 병합까지 한 번에 실행하려면 다음 명령을 사용한다.

```bash
bash scripts/run_pipeline.sh
```

이미 데이터 수집과 HDFS 업로드가 끝난 상태에서 전처리와 분석만 다시 실행하려면 다음처럼 단계별 플래그를 끈다.

```bash
RUN_DOWNLOAD=0 RUN_MAPPING=0 RUN_UPLOAD=0 bash scripts/run_pipeline.sh
```

분석 쿼리와 결과 CSV 병합만 다시 실행하려면 다음처럼 실행한다.

```bash
RUN_DOWNLOAD=0 RUN_MAPPING=0 RUN_UPLOAD=0 RUN_PREPROCESS=0 bash scripts/run_pipeline.sh
```

## 로컬 결과 확인

VM에서 생성한 `results_csv`를 Mac 로컬로 가져올 때는 두 단계로 복사한다.

먼저 바깥 Ubuntu 계정에서 내부 컨테이너의 결과를 가져온다.

```bash
scp -P 2222 -r maria_dev@localhost:/home/maria_dev/seoul-stickiness-analysis/results_csv /home/ubuntu/
```

그 다음 Mac 터미널에서 Ubuntu 계정의 결과를 현재 디렉터리로 가져온다.

```bash
scp -P 30430 -r ubuntu@access2.bluerack.org:/home/ubuntu/results_csv .
```

로컬 분석과 시각화는 VM 파이프라인 코드와 분리해서 관리한다.

```text
results_csv/        VM에서 내려받은 최종 CSV. git 제외.
analysis/           로컬 분석/시각화 스크립트. git 포함.
figures/            로컬에서 생성한 그래프 이미지. git 제외.
summary_csv/        로컬에서 만든 보고서용 요약 CSV. git 제외.
```

## 상권 유형 분류

행정동별 상권 유형은 여러 특성을 동시에 가질 수 있지만, 본 분석에서는 해석을 단순화하기 위해 우선순위 기준으로 대표 유형 하나를 부여한다.

| market_type | 한글 유형명 | 의미 |
| --- | --- | --- |
| `night_type` | 야간형 | 21~24시 종합 점수가 상대적으로 높은 지역 |
| `overall_type` | 종합형 | 유입·체류·소비 종합 점수가 높은 지역 |
| `consumption_type` | 소비전환형 | 생활인구 대비 매출 규모가 높은 지역 |
| `inflow_type` | 유입형 | 지하철 하차 유입이 높고 체류 지표는 상대적으로 낮은 지역 |
| `stay_type` | 체류형 | 지하철 유입 대비 생활인구 규모가 높은 지역 |
| `general_type` | 일반형 | 위 유형에 뚜렷하게 포함되지 않는 지역 |

Hive CLI에서 한글명이 깨져 보일 수 있으므로 결과 해석과 조인은 `dong_code`를 기준 키로 사용한다.

## 확장 가능성

- 평일/주말 비교
- 20대 생활인구 분석
- 날씨 영향 분석
- 관광지 데이터 결합
- 서울 생활이동 데이터 검증
- Streamlit 기반 대시보드 구축

## 한계

- 생활인구는 추정 기반 데이터이다.
- 체류시간을 개인 단위로 직접 측정할 수 없다.
- 지하철 데이터는 도보, 버스, 택시, 자가용 이동을 반영하지 않는다.
- 소비전환 지표는 개인별 구매 전환이 아니라 행정동 단위의 상대 지표이다.
- 상권 매출 데이터는 상권-행정동 연결 방식에 따라 행정동별 집계 결과가 달라질 수 있다.
- 상관관계 분석만 가능하며 인과관계를 직접 증명할 수는 없다.

## 최종 한 줄 요약

서울 생활인구, 지하철 승하차, 상권 매출 데이터를 행정동 기준으로 결합하여 유입·체류·소비 구조를 분석하고, 사람이 많이 들어오는 지역과 오래 머무르는 지역, 소비가 강한 지역이 어떻게 다른지 규명하는 Spark/Hive 기반 빅데이터 분석 프로젝트.
