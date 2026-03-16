path="http://localhost:8082/api/v1/login"
jwt="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjcsInVzZXJfdHlwZSI6InN0dWRlbnQiLCJ1c2VybmFtZSI6Im5nb2NfaGlldSIsImlzX2FkbWluIjpmYWxzZSwiZW1haWwiOiJuZ29jaGlldUB0ZXN0LmNvbSIsImZ1bGxfbmFtZSI6Ik5ndXlcdTFlYzVuIE5nXHUxZWNkYyBIaVx1MWViZnUiLCJkZXBhcnRtZW50X2lkIjpudWxsLCJjbGFzc19pZCI6MSwiaWF0IjoxNzczMzI1MTY2LCJleHAiOjE3NzMzMjg3NjZ9.f6scyWegl6TPp8tPl0cITEYaB9RdIkdnzX8rZD3FKF8"


curl -X POST "$path" \
-H "Content-Type: application/json" \
-d '{
    "username": "ngoc_hieu",
    "password": "123456",
    "user_type": "student"
}' | jq

