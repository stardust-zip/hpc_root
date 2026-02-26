printf "Welcome to TEST SCRIPT with cURL\n"

while true; do
	read -p "Enter HTTP Method (GET/POST/PUT/DELETE/PATCH) [Default=GET]: " METHOD
	METHOD=${METHOD:-GET}

	# Uppercase
	METHOD=${METHOD^^}
	
	case "$METHOD" in
		GET|POST|PUT|DELETE|PATCH) break ;;
		*) printf "Invalid method. Please try again.\n" ;;
	esac 
done

