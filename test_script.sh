path="http://localhost:8888/dispatches/10/assign"
jwt="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjMsInVzZXJfdHlwZSI6ImxlY3R1cmVyIiwidXNlcm5hbWUiOiJ0aGF5X2h1bmciLCJpc19hZG1pbiI6ZmFsc2UsImVtYWlsIjoidGhheWh1bmdAc3lzdGVtLmNvbSIsImZ1bGxfbmFtZSI6IkhvXHUwMGUwbmcgTmdcdTFlY2RjIEhcdTAxYjBuZyIsImRlcGFydG1lbnRfaWQiOjEsImNsYXNzX2lkIjpudWxsLCJpYXQiOjE3NzM3NTE5ODYsImV4cCI6MTc3Mzc1NTU4Nn0.rJKBq-WapucTU9n1ZsIvWOV_uYBw5eqCBc64-9CRkqE"


curl -X POST "$path" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $jwt" \
-d '{
	"assignee_usernames": [
		"thay_tuan_anh"
	],
	"action_required": "Nothing"
}' | jq

