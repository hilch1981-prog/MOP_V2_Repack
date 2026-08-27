# Pandaria 5.4.8 개인 리팩 개발 저장소

이 저장소는 [alexkulya/pandaria_5.4.8](https://github.com/alexkulya/pandaria_5.4.8)을 기반으로 한 개인 리팩의 소스 코드와 DB 사용자 패치를 관리합니다.

## 기준 및 라이선스

- Upstream: `https://github.com/alexkulya/pandaria_5.4.8.git`
- 기준 커밋: `2c2de8c`
- 개발 브랜치: `repack-main`
- 원본의 GPL-2.0 라이선스와 저작권 고지를 유지합니다.

## 저장소에 포함되는 항목

- 수정한 서버 소스 코드
- `repack/database/local-patches`: 리팩 전용 DB 패치
- `repack/database/korean`: 한글 통합 SQL 패치(Git LFS)

## 저장소에 포함되지 않는 항목

- 게임 클라이언트와 Data 파일
- 컴파일 결과물과 실행 파일
- MySQL 실행 환경 및 실제 `data` 디렉터리
- DB 백업, 로그, 인증서, 개인키와 로컬 비밀번호 설정

## Data 파일

Data 파일은 용량 때문에 Git 저장소에 포함하지 않습니다.

- 다운로드: https://naver.me/GntbHFpb

링크의 접근 권한과 보존 기간은 별도로 관리해야 합니다.

## Upstream 소스 갱신

```powershell
git fetch upstream
git switch repack-main
git merge upstream/master
```

병합 충돌이 발생하면 리팩 수정 내용을 확인한 뒤 해결합니다.

## DB 갱신 원칙

Upstream의 `sql/updates`는 리팩 실행 폴더의 `Database/Update-Database.ps1`을 통해 갱신합니다. 이 저장소에는 upstream SQL 전체를 중복 보관하지 않고 리팩 전용 패치만 보관합니다.
