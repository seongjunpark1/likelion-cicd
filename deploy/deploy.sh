#!/bin/bash
set -e
cd "$(dirname "$0")"

export IMAGE="$1"
if [ -z "$IMAGE" ]; then
  echo "사용법: bash deploy.sh <도커이미지:태그>"
  exit 1
fi

# CD 단계에서 띄웠던 단일 컨테이너(app) 정리
docker rm -f app 2>/dev/null || true

# 지금 서비스 중인 색 확인 (처음 배포면 blue부터 띄움)
CURRENT=$(cat current_color 2>/dev/null || echo green)
if [ "$CURRENT" = "blue" ]; then NEXT=green; else NEXT=blue; fi
echo "현재 서비스 중: $CURRENT → 새 버전을 $NEXT 에 띄웁니다"

docker pull "$IMAGE"
docker compose up -d "$NEXT"

# 헬스체크: 새 컨테이너가 정상(UP)인지 최대 60초 확인
OK=false
for i in $(seq 1 30); do
  if docker run --rm --network bluegreen_default busybox:1.36 \
       wget -qO- "http://$NEXT:8080/actuator/health" 2>/dev/null | grep -q '"UP"'; then
    OK=true
    break
  fi
  sleep 2
done

if [ "$OK" != "true" ]; then
  echo "헬스체크 실패 → 전환하지 않습니다. ($CURRENT 가 계속 서비스 중)"
  docker compose stop "$NEXT"
  exit 1
fi

# nginx가 새 컨테이너를 보도록 바꾸고 reload (끊김 없음)
printf 'upstream app {\n    server %s:8080;\n}\n' "$NEXT" > nginx/upstream.conf
docker compose up -d nginx
docker compose exec -T nginx nginx -s reload

echo "$NEXT" > current_color
docker compose stop "$CURRENT" 2>/dev/null || true
echo "$NEXT 로 전환 완료!"